FROM ubuntu:20.04

# Install apache, PHP, and supplimentary programs. openssh-server, curl, and lynx-cur are for debugging the container.
RUN apt-get update && apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install libapache2-mod-php7.4
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-mysql
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-gd
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-json
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-curl
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-xml
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-mbstring
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-soap
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-bcmath
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-client
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php-pear
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php-dev

RUN pecl install xdebug-3.1.5

# Enable apache mods.
RUN a2enmod php7.4
RUN a2enmod rewrite

RUN apt-get install -y mc nano

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.4/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.4/apache2/php.ini

RUN echo "zend_extension='/usr/lib/php/20190902/xdebug.so'" >> /etc/php/7.4/apache2/php.ini
RUN echo "xdebug.mode=debug,develop" >> /etc/php/7.4/apache2/php.ini
RUN echo "xdebug.client_host=host.docker.internal" >> /etc/php/7.4/apache2/php.ini
RUN echo "xdebug.client_port=9003" >> /etc/php/7.4/apache2/php.ini
RUN echo "xdebug.start_with_request=yes" >> /etc/php/7.4/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Composer install
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# Expose apache.
EXPOSE 9003
EXPOSE 80

ENV PHP_XDEBUG_ENABLED: 1

# Copy this repo into place.
ADD www /var/www/site

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND