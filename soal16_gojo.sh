#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

MAKI_IP="192.225.4.3"
PANDA_IP="192.225.4.4"
GETO_IP="192.225.4.2"

apt-get update
apt-get install -y nginx curl

cat > /etc/nginx/sites-available/default <<NGINX
upstream frontend_cluster {
    server ${MAKI_IP}:80;
    server ${PANDA_IP}:80;
}

server {
    listen 80;
    server_name jujutsu.k28.com www.jujutsu.k28.com;
