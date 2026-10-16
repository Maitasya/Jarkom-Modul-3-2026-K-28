#!/bin/bash
set -e

echo "=== Setup Soal 17: Trusted Proxy Geto ==="

mkdir -p /etc/nginx/conf.d

if [ -f /etc/nginx/conf.d/trusted_proxy.conf ]; then
    cp /etc/nginx/conf.d/trusted_proxy.conf \
       /root/soal17_geto_before.conf
fi

cat > /etc/nginx/conf.d/trusted_proxy.conf <<'CONF'
# Only trust the reverse proxy Gojo
set_real_ip_from 192.225.1.4;
real_ip_header X-Real-IP;
real_ip_recursive off;
CONF

nginx -t
