FROM php:5.6-apache

RUN requirements="" \
    && apt-get update && apt-get install -y $requirements && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && requirementsToRemove="" \
    && apt-get purge --auto-remove -y $requirementsToRemove \
    && echo "always_populate_raw_post_data=-1" > /usr/local/etc/php/php.ini


RUN apt-get update && apt-get install libssl-dev pkg-config

#install mongo driver php extention
RUN pecl install mongo && docker-php-ext-enable mongo

RUN usermod -u 1000 www-data
RUN chown -R www-data:www-data /var/www

COPY www/html /var/www/html

#enable mode
RUN a2enmod rewrite
RUN a2enmod cgi
RUN a2enmod headers

#open short tag
#RUN sed -i "s/short_open_tag = .*/short_open_tag = On/" /etc/php/5.6/apache2/php.ini

#reinitialize the host directory
ADD config/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN service apache2 restart

#cross browser compatibility
RUN apt-get update \
    && apt-get install -y libxslt-dev \
&& docker-php-ext-install xsl

RUN pecl install redis && docker-php-ext-enable redis

#Install SSH
RUN apt-get install openssh-server -y
RUN update-rc.d ssh defaults
RUN sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config
RUN echo "root:ChaneMeNow" | chpasswd

#Install Cron
RUN apt install cron -y
RUN update-rc.d cron defaults
COPY config/crontab/ /var/spool/cron/crontabs/
