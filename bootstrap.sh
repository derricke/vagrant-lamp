#!/usr/bin/env bash
MYSQL_PASSWORD='VG1234!@#$'

### !!!!!!!!!! DO NOT UNCOMMENT THESE LINES THEY INSTALL WRONG PASSENGER VERSION !!!!!!!!!!!!! ###
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
#apt-get install apt-transport-https ca-certificates
##### !!!! Only add ONE of these lines, not all of them !!!! #####
# Ubuntu 14.04
#echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' > /etc/apt/sources.list.d/passenger.list
# Ubuntu 12.04
#echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger precise main' > /etc/apt/sources.list.d/passenger.list
#chown root: /etc/apt/sources.list.d/passenger.list
#chmod 600 /etc/apt/sources.list.d/passenger.list

apt-get update

debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"


apt-get install -y mysql-client mysql-server libmysqlclient-dev \
        apache2 apache2-dev curl libcurl4-gnutls-dev libapache2-svn openssl \
        php5 php5-curl php-pear php5-cli php5-gd php5-common php5-dev php5-ldap php5-sybase php5-mysql \
        libapache-dbi-perl libapache2-mod-perl2 libdbd-mysql-perl libauthen-simple-ldap-perl \
        zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev python-software-properties \
        libreadline6-dev zlib1g-dev autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev \
        ruby-rmagick ruby-mysql imagemagick libmagickwand-dev \
        git git-core subversion \
        imagemagick libmagickwand-dev 
        #libapache2-mod-passenger ruby-dev \ #installs wrong version of ruby and passenger
        #ruby-railties # we install rails via gem


# Setup database
if [ ! -f /var/log/databasesetup ];
then
    echo "DROP DATABASE IF EXISTS redmine" | mysql -u root -p"$MYSQL_PASSWORD"
    echo "CREATE DATABASE IF NOT EXISTS redmine;" | mysql -u root -p"$MYSQL_PASSWORD"
    echo "CREATE USER 'redmine'@'localhost' IDENTIFIED BY 'redmine\!\@\#\$';" | mysql -u root -p"$MYSQL_PASSWORD"
    echo "GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'localhost';" | mysql -u root -p"$MYSQL_PASSWORD"
    echo "FLUSH PRIVILEGES;" | mysql -u root -p"$MYSQL_PASSWORD"

    touch /var/log/databasesetup

    if [ -f /var/sqldump/database.sql ];
    then
        mysql -u root -p"$MYSQL_PASSWORD" redmine < /var/sqldump/database.sql
    fi
fi

#Setup Apache
if [ ! -f /var/log/webserversetup ];
then
    echo "ServerName localhost" | tee /etc/apache2/httpd.conf > /dev/null
    a2enmod rewrite cgi headers proxy proxy_http reqtimeout ssl perl dav dav_svn dav_fs rewrite #passenger installed elsewhere
    service apache2 restart
    # sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default

    #sed -i 's/;include_path = \".:\/usr\/share\/php\"/include_path = \".:\/usr\/share\/php:\/var\/www\/lib\/trunk\"/' /etc/php5/apache2/php.ini

    touch /var/log/webserversetup
fi

# Install Composer
if [ ! -f /var/log/composersetup ];
then
    curl -s https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer # Make Composer available globally

    touch /var/log/composersetup
fi


# Setup Ruby
if [ ! -f /var/log/rubysetup ];
then

    curl -sSL https://get.rvm.io | bash -s stable --ruby=2.1.2 #install with 1 line so no need to run source & install
    source /usr/local/rvm/scripts/rvm
    echo "source /usr/local/rvm/scripts/rvm" >> ~/.bashrc
    #source /home/$USER/.rvm/scripts/rvm # this should be put in /usr/local and not the current user. Might be better used for CentOS
    #rvm install 2.1.2 #already installed above
    rvm use 2.1.2 --default
    echo "gem: --no-ri --no-rdoc" > ~/.gemrc
    

    gem install rails
    gem install passenger
    passenger-install-apache2-module --auto
    gem install bundler

    touch /var/log/rubysetup
fi


# Setup Redmine
if [ ! -f /var/log/redminesetup ];
then
    cd /var/www
    if [ ! -d /var/www/redmine ];
    then
        mkdir redmine
    fi
    
    cd redmine/
    svn co http://svn.redmine.org/redmine/branches/2.5-stable current
    cd current/

    if [ ! -d /var/www/redmine/current/public/plugin_assets ];
    then
        mkdir -p tmp tmp/pdf public/plugin_assets
        #chown -R www-data:www-data files log tmp public/plugin_assets
        chmod -R 755 files log tmp public/plugin_assets

        mkdir -p /var/www/redmine/repos/svn /var/www/redmine/repos/git
        #chown -R www-data:www-data /opt/redmine/repos
    fi



    cp config/configuration.yml.example config/configuration.yml
    cp config/database.yml.example config/database.yml
    sed -i '0,/username/s/username: root/username: redmine/' config/database.yml
    sed -i '0,/password/s/password: ""/password: "redmine!@#$"/' config/database.yml
    if [ ! -L /var/www/redmine/current/extra/svn/Redmine.pm ];
    then
        ln -s /var/www/redmine/current/extra/svn/Redmine.pm /usr/lib/perl5/Apache/
    fi

    bundle install --without development
    bundle exec rake generate_secret_token
    RAILS_ENV=production bundle exec rake db:migrate
    echo 'en' | RAILS_ENV=production bundle exec rake redmine:load_default_data

    touch /var/log/redmine

fi

#copy Vhosts
cp /vagrant/sites-conf/*.conf /etc/apache2/sites-enabled/

PVER=$(gem list | awk '/passenger/ { print $2 }' | tr -d '()')
sed -i "s/\$PVER/$PVER/" /etc/apache2/sites-enabled/redmine.conf

service apache2 restart

