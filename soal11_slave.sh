#!/bin/bash
set -e

DOMAIN="jujutsu.k28.com"
MASTER_IP="192.225.1.2"
ZONE_FILE="/var/cache/bind/db.$DOMAIN"

# Install BIND9 jika belum tersedia
apt-get update
apt-get install -y bind9 bind9-utils dnsutils

# Konfigurasi zona Slave
cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
    type slave;
    masters { $MASTER_IP; };
    file "$ZONE_FILE";
};
EOF

# Pastikan direktori cache tersedia
mkdir -p /var/cache/bind
chown bind:bind /var/cache/bind
chmod 775 /var/cache/bind

# Validasi konfigurasi
named-checkconf

# Jalankan named jika belum aktif
if pgrep -x named >/dev/null; then
    rndc reload "$DOMAIN" || kill -HUP "$(pgrep -xo named)"
else
    named -u bind
fi

echo "Konfigurasi DNS Slave selesai."
echo "Periksa hasil transfer dengan:"
echo "dig @192.225.1.3 $DOMAIN SOA"
