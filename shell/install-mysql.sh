#!/bin/bash

OS=$(/bin/bash /vagrant/shell/os-detect.sh ID)
CODENAME=$(/bin/bash /vagrant/shell/os-detect.sh CODENAME)

# Get su permission
sudo su

if [ "$OS" == 'debian' ] || [ "$OS" == 'ubuntu' ]; then
    echo "Ubuntu/Debian mode detected. Installing MySQL 5.6"
    add-apt-repository -y ppa:ondrej/mysql-5.6
    apt-get update
    debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
    apt-get install -y mysql-server-5.6

    # https://github.com/fideloper/Vaprobash/blob/master/scripts/mysql.sh
    echo "Commenting out bind-address to make MySQL accept remote connections."
    sed -i 's/bind-address/#bind-address/g' /etc/mysql/my.cnf

    echo "Adding a root user for remote connections"
    cat /vagrant/shell/install-mysql.sql | mysql -u root -proot
    service mysql restart

elif [[ "$OS" == 'centos' ]]; then
    yum -y install mysql-server mysql
    chkconfig --levels 235 mysqld on
    service mysqld start
fi
