#!/bin/bash

echo "=================================="
echo " DEMO SOAL 6 - DHCP SERVER TENGEN"
echo "=================================="

CONFIG="/etc/dhcp/dhcpd.conf"

# 1. Periksa file konfigurasi
if [ ! -f "$CONFIG" ]; then
    echo "ERROR: File konfigurasi DHCP tidak ditemukan."
    exit 1
fi

# 2. Tampilkan konfigurasi static lease Kugisaki
echo
echo "[1] Konfigurasi static lease Kugisaki:"
grep -A 8 'host kugisaki' "$CONFIG"

if [ $? -ne 0 ]; then
    echo "ERROR: Konfigurasi host Kugisaki tidak ditemukan."
    exit 1
fi

# 3. Validasi konfigurasi DHCP
echo
echo "[2] Validasi konfigurasi DHCP:"
if ! dhcpd -t -cf "$CONFIG"; then
    echo "ERROR: Konfigurasi DHCP tidak valid."
    exit 1
fi

# 4. Jalankan DHCP server jika belum aktif
echo
echo "[3] Memastikan DHCP server berjalan:"
service isc-dhcp-server start

# 5. Tampilkan status layanan
echo
echo "[4] Status DHCP server:"
service isc-dhcp-server status

echo
echo "Pemeriksaan Tengen selesai."
