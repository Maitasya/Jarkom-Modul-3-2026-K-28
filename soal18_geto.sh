#!/bin/bash
set -e

echo "=== Setup Soal 18: API Failover ==="

# Simpan konfigurasi sebelumnya
if [ -f /etc/nginx/sites-available/default ]; then
    cp /etc/nginx/sites-available/default \
       /root/soal18_geto_before.conf
fi

cat > /etc/nginx/sites-available/default <<'NGINX'
upstream api_cluster {
    server 192.225.4.5:80 weight=3 max_fails=2 fail_timeout=5s;
    server 192.225.4.6:80 weight=1 max_fails=2 fail_timeout=5s;
    server 192.225.4.7:80 backup;
}

server {
    listen 80;
