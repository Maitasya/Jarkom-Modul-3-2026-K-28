#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y nginx php-fpm php-mysql mariadb-client

for svc in /etc/init.d/php*-fpm; do
    [ -x "$svc" ] && service "$(basename "$svc")" start
done

PHP_SOCK="$(find /run/php -maxdepth 1 -name 'php*-fpm.sock' | head -n 1)"
if [ -z "$PHP_SOCK" ]; then
    echo "ERROR: socket PHP-FPM tidak ditemukan"
    exit 1
fi

mkdir -p /var/www/html

cat > /var/www/html/index.php <<'PHP'
