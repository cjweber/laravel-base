#DEV DOCKERFILE

FROM php:7.3-fpm
# Uncomment below if your package list is corrupted
#RUN rm -rf /var/lib/apt/lists/* && apt update
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-mysql-client libmagickwand-dev cron nano procps libzip-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd
RUN apt-get install -y wget git-core

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Supervisor if you need to test
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD php-ini-dev.conf /usr/local/etc/php/php.ini
ADD supervisor-default.conf /etc/supervisor/conf.d/default.conf

# Install Xdebug
RUN curl -fsSL 'https://xdebug.org/files/xdebug-2.7.2.tgz' -o xdebug.tar.gz \
    && mkdir -p xdebug \
    && tar -xf xdebug.tar.gz -C xdebug --strip-components=1 \
    && rm xdebug.tar.gz \
    && ( \
    cd xdebug \
    && phpize \
    && ./configure --enable-xdebug \
    && make -j$(nproc) \
    && make install \
    ) \
    && rm -r xdebug \
    && docker-php-ext-enable xdebug

# Add crontab file in the cron directory for scheduler
ADD scheduler-crontab /etc/cron.d/scheduler-cron
# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/scheduler-cron
# Apply cron job
RUN crontab /etc/cron.d/scheduler-cron

CMD ["/bin/bash","-c","chmod +x /var/www/scripts/dev-entrypoint.sh && /var/www/scripts/dev-entrypoint.sh"]