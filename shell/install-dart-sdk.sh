#!/bin/bash

OS=$(/bin/bash /vagrant/shell/os-detect.sh ID)
CODENAME=$(/bin/bash /vagrant/shell/os-detect.sh CODENAME)

cd /tmp

if [ "$OS" == 'debian' ] || [ "$OS" == 'ubuntu' ]; then
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

elif [[ "$OS" == 'centos' ]]; then
    # https://github.com/dart-lang/sdk/wiki/Building
    # https://code.google.com/p/dart/wiki/BuildingOnCentOS
    echo "Build SDK, x64"

    # Install Subversion and the required build-tools
    sudo yum -y install git subversion make gcc-c++

    # Get the depot_tools and add them to the path
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

    export PATH=$PATH:`pwd`/depot_tools

    # Get the Dart source and generate makefiles
    gclient config http://dart.googlecode.com/svn/branches/1.1/deps/all.deps
    gclient sync
    gclient runhooks

    cd dart
    # only build the Dart standalone executable
    tools/build.py --mode=release --arch=x64 runtime

    if [ ! -d '/usr/local/bin/dart-sdk/bin' ]; then
      mkdir -p /usr/local/bin/dart-sdk/bin
    fi

    if [ -f '/usr/local/bin/dart-sdk/bin/dart' ]; then
      rm /usr/local/bin/dart-sdk/bin/dart
    fi

    mv --force out/ReleaseX64/dart /usr/local/bin/dart-sdk/bin/dart

    echo "Cleaning up"
    rm -r /tmp/dart
    rm -r /tmp/depot_tools
    rm -r /tmp/all.deps
else
    echo "Untested version: We have not tested this script with your OS."
    exit 1
fi

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
