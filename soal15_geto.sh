#!/bin/bash
set -e

NANAMI_IP="192.225.4.5"
TODO_IP="192.225.4.6"

apt-get install -y nginx curl

cat > /etc/nginx/sites-available/default <<NGINX
upstream api_cluster {
    server ${NANAMI_IP}:80 weight=3;
    server ${TODO_IP}:80 weight=1;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://api_cluster;
