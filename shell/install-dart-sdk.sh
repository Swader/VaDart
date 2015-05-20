#!/bin/bash

OS=$(/bin/bash /vagrant/shell/os-detect.sh ID)
CODENAME=$(/bin/bash /vagrant/shell/os-detect.sh CODENAME)

cd /tmp
echo "Downloading the SDK, x64"

## STABLE VERSION. COMMENT FOR DEV VERSION.
wget http://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip

# UNCOMMENT FOR DEV VERSION
# wget http://storage.googleapis.com/dart-archive/channels/dev/release/latest/sdk/dartsdk-linux-x64-release.zip

echo "Downloading done."

# remove the currently install version of the dart sdk
rm -r /usr/local/bin/dart-sdk

echo "Unzipping to /usr/local/bin"
unzip dartsdk-linux-x64-release.zip -d /usr/local/bin

# for some reason permissions default to 700
chmod -R 755 /usr/local/bin/dart-sdk/

echo "Cleaning up"
rm dartsdk-linux-x64-release.zip

echo "Setting up environment variables"

if [ "$OS" == 'debian' ] || [ "$OS" == 'ubuntu' ]; then

    grep -q 'export DART_SDK=/usr/local/bin/dart-sdk' /etc/profile || echo 'export DART_SDK=/usr/local/bin/dart-sdk' >> /etc/profile
    grep -q 'export PATH=$PATH:$DART_SDK/bin' /etc/profile || echo 'export PATH=$PATH:$DART_SDK/bin' >> /etc/profile
    grep -q "alias dartsync='/vagrant/shell/dartsync.sh'" /etc/profile || echo "alias dartsync='/vagrant/shell/dartsync.sh'" >> /etc/profile

elif [[ "$OS" == 'centos' ]]; then

    if [[ ! -d /etc/profile.d ]]; then
        mkdir /etc/profile.d
    fi

    if [[ ! -f /etc/profile.d/dartvars.sh ]]; then
        touch /etc/profile.d/dartvars.sh
    fi

    if [[ ! -f /etc/profile.d/dartsync_alias.sh ]]; then
        touch /etc/profile.d/dartsync_alias.sh
    fi

    grep -q 'export DART_SDK=/usr/local/bin/dart-sdk' /etc/profile.d/dartvars.sh || echo 'export DART_SDK=/usr/local/bin/dart-sdk' >> /etc/profile.d/dartvars.sh
    grep -q 'export PATH=$PATH:$DART_SDK/bin' /etc/profile.d/dartvars.sh || echo 'export PATH=$PATH:$DART_SDK/bin' >> /etc/profile.d/dartvars.sh
    grep -q "alias dartsync='/vagrant/shell/dartsync.sh'" /etc/profile.d/dartsync_alias.sh || echo "alias dartsync='/vagrant/shell/dartsync.sh'" >> /etc/profile.d/dartsync_alias.sh

fi

echo "DART_SDK env var set as ${DART_SDK}"
echo "SDK's bin subfolder added to PATH. PATH is now: ${PATH}"

cd /vagrant
if [[ ! -d /vagrant/sample_apps ]]; then
    mkdir /vagrant/sample_apps
fi

cd /vagrant/sample_apps
if [[ ! -d /vagrant/sample_apps/sample_01 ]]; then
    git clone https://github.com/Swader/dart_sample_01 sample_01
else
    cd /vagrant/sample_apps/sample_01
    git pull
fi

cd /vagrant/sample_apps
if [[ ! -d /vagrant/sample_apps/sample_02 ]]; then
    git clone https://github.com/Swader/dart_sample_02 sample_02
else
    cd /vagrant/sample_apps/sample_02
    git pull
fi

cd /vagrant/sample_apps
if [[ ! -d /vagrant/sample_apps/sample_03 ]]; then
    git clone https://github.com/Swader/dart_sample_02 sample_03
else
    cd /vagrant/sample_apps/sample_03
    git pull
fi

cmd="/vagrant/shell/dartsync.sh"
job="*/1 * * * * $cmd"
echo "$job" > tempcron
crontab tempcron
rm tempcron
#cat <(fgrep -i -v "$cmd" <(crontab -l)) <(echo "$job") | crontab -

# verify dart is working correctly
/usr/local/bin/dart-sdk/bin/dart --version
