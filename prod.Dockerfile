FROM php:7.3-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
    default-mysql-client libmagickwand-dev nano procps libzip-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install zip
RUN apt-get install -y wget git-core

WORKDIR /var/www
COPY . /var/www

RUN chmod +x /var/www/scripts/install-composer.sh && /var/www/scripts/install-composer.sh
RUN php composer.phar install --no-dev --no-scripts && rm composer.phar

RUN chown -R www-data:www-data \
        /var/www/storage \
        /var/www/bootstrap/cache

ADD php-ini-default.conf /usr/local/etc/php/php.ini

CMD ["/bin/bash","-c","chmod +x /var/www/scripts/app-entrypoint.sh && /var/www/scripts/app-entrypoint.sh"]