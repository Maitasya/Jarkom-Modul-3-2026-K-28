#!/bin/bash
set -e

DOMAIN="jujutsu.k28.com"
PREFIX="192.225"
GOJO_IP="192.225.1.4"
ZONE_DIR="/etc/bind/zones"
ZONE_FILE="$ZONE_DIR/db.$DOMAIN"
REV_ZONE="1.225.192.in-addr.arpa"
REV_FILE="$ZONE_DIR/db.192.225.1"

# Pastikan script dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
    echo "Jalankan script sebagai root."
    exit 1
fi

# Pastikan IP Gojo sesuai sebelum melanjutkan
echo "Domain : $DOMAIN"
echo "IP Gojo: $GOJO_IP"
read -r -p "Apakah IP Gojo sudah benar? (y/n): " confirm
[ "$confirm" = "y" ] || {
    echo "Batalkan. Edit GOJO_IP di /root/soal12_dns.sh."
    exit 1
}

# Backup konfigurasi yang akan diubah
BACKUP="/root/backup_soal12_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP"
cp -a /etc/bind/named.conf.local "$BACKUP/"
cp -a /etc/bind/named.conf.options "$BACKUP/"
[ ! -f "$ZONE_FILE" ] || cp -a "$ZONE_FILE" "$BACKUP/"
[ ! -f "$REV_FILE" ] || cp -a "$REV_FILE" "$BACKUP/"
echo "Backup: $BACKUP"

mkdir -p "$ZONE_DIR"

# Naikkan serial dari zona lama jika tersedia
SERIAL="2026101501"
if [ -f "$ZONE_FILE" ]; then
    OLD_SERIAL=$(sed -n '/SOA/,/)/s/^[[:space:]]*\([0-9]\{10\}\).*/\1/p' "$ZONE_FILE" | head -n1)
    if [[ "$OLD_SERIAL" =~ ^[0-9]{10}$ ]]; then
        SERIAL=$((OLD_SERIAL + 1))
    fi
fi

# Tulis zona forward
cat > "$ZONE_FILE" <<ZONE
\$TTL 604800
@ IN SOA ns1.$DOMAIN. admin.$DOMAIN. (
    $SERIAL
    604800
    86400
    2419200
    604800
)
@    IN NS ns1.$DOMAIN.
@    IN NS ns2.$DOMAIN.
ns1  IN A  192.225.1.2
ns2  IN A  192.225.1.3
@    IN A  $GOJO_IP
www  IN CNAME $DOMAIN.
ZONE

# Tulis zona reverse untuk Network 1
cat > "$REV_FILE" <<ZONE
\$TTL 604800
@ IN SOA ns1.$DOMAIN. admin.$DOMAIN. (
    $SERIAL
    604800
    86400
    2419200
    604800
)
@ IN NS ns1.$DOMAIN.
@ IN NS ns2.$DOMAIN.
$(echo "$GOJO_IP" | awk -F. '{print $4}') IN PTR $DOMAIN.
ZONE

# Daftarkan zona reverse jika belum ada
if ! grep -q "zone \"$REV_ZONE\"" /etc/bind/named.conf.local; then
cat >> /etc/bind/named.conf.local <<ZONE

zone "$REV_ZONE" {
    type master;
    file "$REV_FILE";
};
ZONE
fi

# Tambahkan DNS forwarder tanpa mengganti seluruh options
if ! grep -q '192\.168\.122\.1' /etc/bind/named.conf.options; then
    sed -i '/options[[:space:]]*{/a\        forwarders { 192.168.122.1; };' \
        /etc/bind/named.conf.options
fi

# Validasi konfigurasi dan zona
named-checkconf
named-checkzone "$DOMAIN" "$ZONE_FILE"
named-checkzone "$REV_ZONE" "$REV_FILE"

# Reload jika memungkinkan, selain itu jalankan named
if command -v rndc >/dev/null 2>&1 && rndc reload; then
    :
else
    echo "rndc reload gagal/tidak tersedia. Periksa cara named dijalankan sebelum restart."
fi

echo
echo "Selesai. Serial zona: $SERIAL"
echo "Forward zone: $ZONE_FILE"
echo "Reverse zone: $REV_FILE"
echo "Backup konfigurasi: $BACKUP"