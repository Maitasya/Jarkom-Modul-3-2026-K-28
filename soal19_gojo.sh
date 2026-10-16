#!/bin/bash
set -e

echo "=== Setup Soal 19: Cache dan Rate Limit ==="

# Simpan konfigurasi aktif sebelum diubah
cp /etc/nginx/sites-available/default \
   /root/soal19_gojo_before.conf

mkdir -p /var/cache/nginx/frontend_cache
chown -R www-data:www-data /var/cache/nginx/frontend_cache

# Pengaturan global: cache dan rate limit
cat > /etc/nginx/conf.d/soal19_limits.conf <<'CONF'
proxy_cache_path /var/cache/nginx/frontend_cache
    levels=1:2
    keys_zone=frontend_cache:10m
    max_size=100m
    inactive=30m
    use_temp_path=off;
