#!/bin/bash

echo "================================"
echo " DEMO SOAL 6 - DHCP RELAY JICHI"
echo "================================"

SERVER="192.225.4.10"

# 1. Periksa proses DHCP relay
echo
echo "[1] Memeriksa DHCP relay:"
if pgrep -f '^dhcrelay .*192\.225\.4\.10' >/dev/null; then
    echo "DHCP relay sudah berjalan. Tidak menjalankan proses baru."
else
    # 2. Jalankan relay jika belum aktif
    echo
    echo "[2] Menjalankan DHCP relay:"
    dhcrelay -i eth3 -i eth4 "$SERVER"
fi

# 3. Tampilkan proses relay
echo
echo "[3] Proses DHCP relay:"
ps aux | grep '[d]hcrelay'

echo
echo "Pemeriksaan Jichi selesai."