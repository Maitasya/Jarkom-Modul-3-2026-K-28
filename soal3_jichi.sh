#!/bin/bash
set -e

CONF="/etc/default/isc-dhcp-relay"

echo "=== SOAL 3: KONFIGURASI DHCP RELAY JICHI ==="

# Simpan konfigurasi sebelumnya jika backup belum tersedia
cp -n "$CONF" "${CONF}.backup-soal3-final"

# Konfigurasi server DHCP dan arah relay
cat > "$CONF" <<'CONFIG'
SERVERS="192.225.4.10"
INTERFACES=""
OPTIONS="-iu eth4 -id eth2 -id eth3"
CONFIG

# Pastikan konfigurasi relay sesuai
cat "$CONF"

# Terapkan konfigurasi
service isc-dhcp-relay restart

echo "=== STATUS DHCP RELAY ==="
service isc-dhcp-relay status

echo "=== PROSES DHCP RELAY ==="
ps | grep '[d]hcrelay' || true

echo "=== SOAL 3 SELESAI ==="
