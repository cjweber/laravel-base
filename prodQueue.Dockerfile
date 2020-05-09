FROM php:7.3-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
    default-mysql-client libmagickwand-dev procps cron nano libzip-dev \
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

# Supervisor
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD php-ini-default.conf /usr/local/etc/php/php.ini
ADD supervisor-default.conf /etc/supervisor/conf.d/default.conf

# Add crontab file in the cron directory for scheduler
ADD scheduler-crontab /etc/cron.d/scheduler-cron
# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/scheduler-cron
# Apply cron job
RUN crontab /etc/cron.d/scheduler-cron

CMD ["/bin/bash","-c","chmod +x /var/www/scripts/queue-entrypoint.sh && /var/www/scripts/queue-entrypoint.sh"]