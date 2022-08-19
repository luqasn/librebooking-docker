FROM php:7.4-apache

ARG VERSION=2.8.5.5

# set up apache and php
RUN sed -i "s#DocumentRoot /var/www/html#DocumentRoot /var/www/librebooking/Web#" /etc/apache2/sites-enabled/000-default.conf
RUN a2enmod rewrite
RUN a2enmod headers

RUN apt update && \
  apt install -y \
  zlib1g-dev \
  libpng-dev \
  libfreetype6-dev
RUN docker-php-ext-install mysqli
RUN docker-php-ext-configure gd --with-freetype && docker-php-ext-install gd

COPY entrypoint.sh /

# set up application
RUN apt install -y unzip

RUN mkdir /var/www/librebooking && chown www-data:www-data /var/www/librebooking
USER www-data

RUN curl -sSfLo /tmp/booked.zip \
  https://github.com/effgarces/BookedScheduler/releases/download/${VERSION}/booked-${VERSION}.zip && \
  unzip /tmp/booked.zip -d /var/www/librebooking && \
  rm /tmp/booked.zip

WORKDIR /var/www/librebooking

COPY log4php.config.xml /

VOLUME ["/var/www/librebooking/uploads", "/var/www/librebooking/config"]

ENTRYPOINT ["/entrypoint.sh"]
