#!/bin/bash
php artisan migrate --force
php artisan passport:keys -q
cron
php-fpm
