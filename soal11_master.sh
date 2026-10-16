
#!/bin/bash
set -e

DOMAIN="jujutsu.k28.com"
SLAVE_IP="192.225.1.3"
ZONE_DIR="/etc/bind/zones"
ZONE_FILE="$ZONE_DIR/db.$DOMAIN"

# Install BIND9 jika belum tersedia
apt-get update
apt-get install -y bind9 bind9-utils dnsutils

# Buat direktori zona
mkdir -p "$ZONE_DIR"

# Konfigurasi zona Master
cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
    type master;
    file "$ZONE_FILE";
    allow-transfer { $SLAVE_IP; };
    also-notify { $SLAVE_IP; };
    notify yes;
};
EOF

# Buat file zona
cat > "$ZONE_FILE" <<EOF
\$TTL 604800
@   IN SOA ns1.$DOMAIN. admin.$DOMAIN. (
        2026101503
        604800
        86400
        2419200
        604800
)
@    IN NS ns1.$DOMAIN.
@    IN NS ns2.$DOMAIN.
ns1  IN A 192.225.1.2
ns2  IN A 192.225.1.3
EOF

# Atur kepemilikan dan permission
chown -R bind:bind "$ZONE_DIR"
chmod 755 "$ZONE_DIR"
chmod 644 "$ZONE_FILE"

# Validasi konfigurasi
named-checkconf
named-checkzone "$DOMAIN" "$ZONE_FILE"

# Reload jika rndc tersedia dan aktif; jika tidak, gunakan sinyal reload
if rndc reload "$DOMAIN"; then
    echo "Zona berhasil di-reload menggunakan rndc."
elif pgrep -x named >/dev/null; then
    kill -HUP "$(pgrep -xo named)"
    echo "Mengirim sinyal reload ke proses named."
else
    named -u bind
    echo "Proses named dijalankan."
fi

echo "Konfigurasi DNS Master selesai."