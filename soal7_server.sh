#!/bin/bash
set -eu

echo "===== SOAL 7: DHCP SERVER TENGEN ====="

if [ ! -f /etc/dhcp/dhcpd.conf ]; then
    echo "[GAGAL] File konfigurasi DHCP tidak ditemukan."
    exit 1
fi

echo "[1/3] Memeriksa konfigurasi DHCP..."
dhcpd -t -cf /etc/dhcp/dhcpd.conf

echo "[2/3] Memastikan layanan DHCP aktif..."
service isc-dhcp-server start

echo "[3/3] Status layanan DHCP:"
service isc-dhcp-server status || true

echo
echo "===== KONFIGURASI DHCP SELESAI DIPERIKSA ====="
