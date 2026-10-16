#!/bin/bash
set -e

CONF="/etc/dhcp/dhcpd.conf"

echo "=== SOAL 5: LEASE DAN RESERVASI DHCP ==="

# Pastikan class lease tersedia
grep -q 'class "short-lease-clients"' "$CONF"
grep -q 'class "long-lease-clients"' "$CONF"

# Pastikan durasi lease sesuai ketentuan
grep -q 'default-lease-time 1800;' "$CONF"
grep -q 'max-lease-time 1800;' "$CONF"
grep -q 'default-lease-time 43200;' "$CONF"
grep -q 'max-lease-time 43200;' "$CONF"

# Pastikan reservasi Kugisaki sesuai
grep -q 'host kugisaki' "$CONF"
grep -q 'hardware ethernet 02:42:51:c8:03:00;' "$CONF"
grep -q 'fixed-address 192.225.3.99;' "$CONF"

# Validasi tanpa mengubah konfigurasi
dhcpd -t -cf "$CONF"

echo "=== KONFIGURASI LEASE PENDEK ==="
grep -n -A 5 'class "short-lease-clients"' "$CONF"

echo "=== KONFIGURASI LEASE PANJANG ==="
grep -n -A 4 'class "long-lease-clients"' "$CONF"

echo "=== RESERVASI KUGISAKI ==="
grep -n -A 9 'host kugisaki' "$CONF"

echo "=== LEASE AKTIF TERSIMPAN ==="
grep -n -E -B 5 -A 5 \
    'hardware ethernet 02:42:(2c:11:46:00|94:28:a5:00|84:4d:0b:00|51:c8:03:00)' \
    /var/lib/dhcp/dhcpd.leases || true

echo "=== STATUS DHCP ==="
service isc-dhcp-server status

echo "=== SOAL 5 SELESAI ==="