#!/bin/bash

OS=$(/bin/bash /vagrant/shell/os-detect.sh ID)
CODENAME=$(/bin/bash /vagrant/shell/os-detect.sh CODENAME)

# Get su permission
sudo su

cd /tmp
echo "Downloading the SDK, x64"

## STABLE VERSION. COMMENT FOR DEV VERSION.
wget http://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip

## UNCOMMENT FOR DEV VERSION
# wget http://storage.googleapis.com/dart-archive/channels/dev/release/latest/sdk/dartsdk-linux-x64-release.zip

echo "Downloading done."

echo "Unzipping to /usr/local/bin"
unzip dartsdk-linux-x64-release.zip -d /usr/local/bin

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

echo "DARK_SDK env var set as ${DARK_SDK}"
echo "SDK's bin subfolder added to PATH. PATH is now: ${PATH}"

cd /vagrant
mkdir sample_apps
cd sample_apps
git clone https://github.com/Swader/dart_sample_01 sample_01
git clone https://github.com/Swader/dart_sample_02 sample_02
git clone https://github.com/Swader/dart_sample_03 sample_03

cmd="/vagrant/shell/dartsync.sh"
job="*/1 * * * * $cmd"
echo "$job" > tempcron
crontab tempcron
rm tempcron
#cat <(fgrep -i -v "$cmd" <(crontab -l)) <(echo "$job") | crontab -
