#!/bin/bash
set -e

CONF="/etc/nginx/sites-available/default"

echo "=== Setup Soal 17: Forward Client IP ==="

cp "$CONF" /root/soal17_gojo_before.conf

# Ganti X-Forwarded-For agar Gojo mengirim IP klien yang dilihatnya
sed -i \
  's/proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;/proxy_set_he>
  "$CONF"

# Pastikan X-Real-IP tersedia
if ! grep -q 'proxy_set_header X-Real-IP \$remote_addr;' "$CONF"; then
    echo "ERROR: Header X-Real-IP tidak ditemukan."
    cp /root/soal17_gojo_before.conf "$CONF"
    exit 1
fi
