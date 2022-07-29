FROM ubuntu:20.04

# Install apache, PHP, MariaDb, LibreOffice
RUN apt-get update && apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install libapache2-mod-php7.4
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-mysql
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-pdo-mysql
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-gd
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-json
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-curl
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-xml
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-mbstring
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-soap
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-bcmath
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mariadb-server
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mariadb-client
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php-pear
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php-gmp
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php7.4-odbc
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php-tidy
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php-xmlrpc
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php-zip
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install libmcrypt-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install imagemagick
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install ghostscript
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install libreoffice-writer-nogui
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install ttf-mscorefonts-installer
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install tesseract-ocr
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install tesseract-ocr-pol
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install msttcorefonts
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install libreoffice-java-common
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install default-jre
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install zip
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install zlibc
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install libzip-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install p7zip-full

# Install PDF converter
RUN apt-get install -y wget
RUN wget --no-check-certificate https://dl.xpdfreader.com/xpdf-tools-linux-4.04.tar.gz && \
    tar -xvf xpdf-tools-linux-4.04.tar.gz && cp xpdf-tools-linux-4.04/bin64/pdftotext /usr/local/bin && cp xpdf-tools-linux-4.04/bin64/pdftohtml /usr/bin
COPY installDir/pdftohtml2 /usr/bin/pdftohtml2

#Install xdebug
RUN pecl install xdebug

# Enable apache mods
RUN a2enmod php7.4
RUN a2enmod rewrite

# Install Nano
RUN apt-get install -y mc nano

# Update the PHP.ini file
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/g" /etc/php/7.4/apache2/php.ini
RUN sed -i "s/zlib.output_compression = Off/zlib.output_compression = on/g" /etc/php/7.4/apache2/php.ini
RUN sed -i -r "s/^error_reporting = .*/error_reporting = E_ALL \& ~E_NOTICE \& ~E_WARNING/m" /etc/php/7.4/apache2/php.ini

RUN echo "zend_extension='/usr/lib/php/20190902/xdebug.so'" >> /etc/php/7.4/apache2/php.ini
RUN echo "xdebug.mode=debug,develop" >> /etc/php/7.4/apache2/php.ini
RUN echo "xdebug.client_host=host.docker.internal" >> /etc/php/7.4/apache2/php.ini
RUN echo "xdebug.client_port=9003" >> /etc/php/7.4/apache2/php.ini
RUN echo "xdebug.start_with_request=yes" >> /etc/php/7.4/apache2/php.ini

RUN sed -i "s/short_open_tag = Off/short_open_tag = On/g" /etc/php/7.4/cli/php.ini
RUN sed -i "s/zlib.output_compression = Off/zlib.output_compression = on/g" /etc/php/7.4/cli/php.ini
RUN sed -i -r "s/^error_reporting = .*/error_reporting = E_ALL \& ~E_NOTICE \& ~E_WARNING \& ~E_DEPRECATED/m" /etc/php/7.4/cli/php.ini

RUN echo "zend_extension='/usr/lib/php/20190902/xdebug.so'" >> /etc/php/7.4/cli/php.ini
RUN echo "xdebug.mode=debug,develop" >> /etc/php/7.4/cli/php.ini
RUN echo "xdebug.client_host=host.docker.internal" >> /etc/php/7.4/cli/php.ini
RUN echo "xdebug.client_port=9003" >> /etc/php/7.4/cli/php.ini
RUN echo "xdebug.start_with_request=yes" >> /etc/php/7.4/cli/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Copy and create repo into place
RUN mkdir -p /var/www/code

# Composer install
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# Set access
RUN chmod -R 777 /var/www/code

# Update the default apache site with the config
COPY installDir/apache-config-local.conf /etc/apache2/sites-available/000-default.conf

# Set timezone
RUN echo "Europe/Warsaw" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

#RUN a2dissite 000-default.conf
#RUN a2ensite localhost.local.conf

# Expose apache
EXPOSE 9003
EXPOSE 80

# Enable xdebug
ENV PHP_XDEBUG_ENABLED: 1

# Setup ImageMagick
RUN sed -i -r "s/<policy domain=\"coder\" rights=\"none\" pattern=\"PDF\" \/>/<\!-- <policy domain=\"coder\" rights=\"none\" pattern=\"PDF\" \/> -->/gm" /etc/ImageMagick-6/policy.xml

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND && bash -c "composer install --working-dir=/var/www/code"