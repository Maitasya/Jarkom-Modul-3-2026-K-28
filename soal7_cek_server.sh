#!/bin/bash
set -u

echo "===== SOAL 7: VERIFIKASI DHCP SERVER ====="

echo
echo "[1] Alamat IP Tengen:"
ip -br addr

echo
echo "[2] Routing Tengen:"
ip route

echo
echo "[3] Validasi konfigurasi DHCP:"
dhcpd -t -cf /etc/dhcp/dhcpd.conf

echo
echo "[4] Status DHCP Server:"
service isc-dhcp-server status || true

echo
echo "[5] Daftar lease DHCP:"
if [ -f /var/lib/dhcp/dhcpd.leases ]; then
    cat /var/lib/dhcp/dhcpd.leases
else
    echo "File lease belum tersedia."
fi

echo
echo "===== VERIFIKASI SELESAI ====="
