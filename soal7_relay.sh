#!/bin/bash
set -eu

echo "===== SOAL 7: DHCP RELAY JICHI ====="

if ! command -v dhcrelay >/dev/null 2>&1; then
    echo "[GAGAL] dhcrelay belum terpasang."
    echo "Pasang isc-dhcp-relay terlebih dahulu."
    exit 1
fi

if pgrep -x dhcrelay >/dev/null 2>&1; then
    echo "[INFO] DHCP Relay sudah berjalan."
    echo "Tidak menjalankan relay kedua."
    pgrep -af dhcrelay || true
    exit 0
fi

echo "[INFO] Menjalankan DHCP Relay menuju 192.225.4.10..."
echo "[INFO] Interface: eth2, eth3, eth4"
echo "[INFO] Tekan Ctrl+C untuk menghentikan relay."

exec dhcrelay -d -i eth2 -i eth3 -i eth4 192.225.4.10
