#!/bin/bash
set -e

CONF="/etc/dhcp/dhcpd.conf"

echo "=== SOAL 4: DHCP CLASS DAN POOL ==="

# Pastikan class dan rentang DHCP tersedia
grep -q 'class "pool1-clients"' "$CONF"
grep -q 'class "pool2-clients"' "$CONF"
grep -q 'range 192.225.2.10 192.225.2.35' "$CONF"
grep -q 'range 192.225.2.70 192.225.2.95' "$CONF"

# Validasi konfigurasi sebelum restart
dhcpd -t -cf "$CONF"

service isc-dhcp-server restart

echo "=== CLASS POOL 1 ==="
grep -n -A 4 'class "pool1-clients"' "$CONF"

echo "=== CLASS POOL 2 ==="
grep -n -A 4 'class "pool2-clients"' "$CONF"

echo "=== RENTANG DHCP NETWORK 2 ==="
grep -n -A 16 'subnet 192.225.2.0' "$CONF"

echo "=== STATUS DHCP ==="
service isc-dhcp-server status

echo "=== SOAL 4 SELESAI ==="