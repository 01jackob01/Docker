FROM ubuntu:20.04

# Install apache, PHP, and supplimentary programs. openssh-server, curl, and lynx-cur are for debugging the container.
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    apache2 software-properties-common php7.4 libapache2-mod-php7.4 php7.4-mysql php7.4-gd php7.4-json php7.4-curl php7.4-xml php7.4-mbstring php-xdebug php7.4-soap php7.4-bcmath mariadb-server mariadb-client

# Enable apache mods.
RUN a2enmod php7.4
RUN a2enmod rewrite

RUN apt-get install -y mc nano

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.4/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.4/apache2/php.ini

RUN echo "zend_extension=/usr/lib/php/20151012/xdebug.so" >> /etc/php/7.0/apache2/php.ini
RUN echo "xdebug.max_nesting_level=250" >> /etc/php/7.0/apache2/php.ini
RUN echo "xdebug.var_display_max_depth=10" >> /etc/php/7.0/apache2/php.ini
RUN echo "xdebug.remote_enable=true" >> /etc/php/7.0/apache2/php.ini
RUN echo "xdebug.remote_handler=dbgp" >> /etc/php/7.0/apache2/php.ini
RUN echo "xdebug.remote_mode=req" >> /etc/php/7.0/apache2/php.ini
RUN echo "xdebug.remote_port=9000" >> /etc/php/7.0/apache2/php.ini
RUN echo "xdebug.remote_host=127.0.0.1" >> /etc/php/7.0/apache2/php.ini
RUN echo "xdebug.idekey=phpstorm-xdebug" >> /etc/php/7.0/apache2/php.ini
RUN echo "xdebug.remote_autostart=1" >> /etc/php/7.0/apache2/php.ini
RUN echo "xdebug.remote_log=/var/log/apache2/xdebug_remote.log" >> /etc/php/7.0/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Expose apache.
EXPOSE 9000
EXPOSE 80

ENV PHP_XDEBUG_ENABLED: 1
ENV XDEBUG_CONFIG: remote_host=127.0.0.1

# Copy this repo into place.
#ADD www /var/www/site
VOLUME ["/www","/var/www/site"]

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND