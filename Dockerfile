FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y
RUN apt-get install -y build-essential \
    nano \
    unzip \
    curl \
    locales \
    php \
    libapache2-mod-php \
    libapache2-mod-auth-openidc \
    php-bcmath \
    php-cli \
    php-curl \
    php-fpm \
    php-gd \
    php-intl \
    php-json \
    php-ldap \
    php-ldap \
    php-mbstring \
    php-mysql \
    php-pgsql \
    php-soap \
    php-tideways \
    php-xdebug \
    php-xml \
    php-xmlrpc \
    php-zip \
    php-bz2 \
    php-dom \
    php-dev \
    php-pear \
    php-bcmath \
    apache2 \ 
    mysql-client \
    libmysqlclient-dev \
    php-mysql \
    libmcrypt-dev \
    # Ensure apache can bind to 80 as non-root
        libcap2-bin && \
    setcap 'cap_net_bind_service=+ep' /usr/sbin/apache2 && \
    dpkg --purge libcap2-bin && \
    apt-get -y autoremove && \
# As apache is never run as root, change dir ownership
    a2disconf other-vhosts-access-log && \
    chown -Rh www-data. /var/run/apache2 && \
# Clean up apt setup files
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
# Setup apache
    a2enmod rewrite headers expires ext_filter

RUN locale-gen pt_BR.UTF-8

RUN apt-get install --reinstall ca-certificates -y

# Enable apache mod_rewrite
RUN a2enmod rewrite
RUN a2enmod actions

# Change AllowOverride from None to All (between line 170 and 174)
RUN sed -i '170,174 s/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
      
ADD src/ /var/www/html/src/
ADD data/ /var/data/

RUN chown $USER:www-data -R /var/data
RUN chmod u=rwX,g=srX,o=rX -R /var/data
RUN find /var/data -type d -exec chmod g=rwxs "{}" \;
RUN find /var/data -type f -exec chmod g=rws "{}" \;

RUN chown $USER:www-data -R /var/www/html
RUN chmod u=rwX,g=srX,o=rX -R /var/www/html
RUN find /var/www/html -type d -exec chmod g=rwxs "{}" \;
RUN find /var/www/html -type f -exec chmod g=rws "{}" \;

# Start the webserver
RUN service apache2 restart

RUN cd /usr/local/lib/ && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

EXPOSE 80

ENTRYPOINT ["apache2ctl", "-D", "FOREGROUND"]
