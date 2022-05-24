FROM ubuntu:20.04

# Install apache, PHP, and supplimentary programs. openssh-server, curl, and lynx-cur are for debugging the container.
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    apache2 software-properties-common php7.4 php-pear php-dev

RUN pecl install xdebug

# Enable apache mods.
RUN a2enmod php7.4
RUN a2enmod rewrite

RUN apt-get install -y mc nano

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

# Expose apache.
EXPOSE 9003
EXPOSE 80

ENV PHP_XDEBUG_ENABLED: 1

# Copy this repo into place.
RUN mkdir /var/www/mario

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND