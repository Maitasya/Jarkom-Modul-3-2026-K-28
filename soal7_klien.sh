#!/bin/sh
set -eu

echo "===== SOAL 7: PENGUJIAN DHCP KLIEN ====="

if ! command -v udhcpc >/dev/null 2>&1; then
    echo "[GAGAL] Perintah udhcpc tidak tersedia."
    exit 1
fi

echo "[1/3] Meminta alamat IP dari DHCP Server..."
udhcpc -i eth0 -n -q

echo
echo "[2/3] Alamat IP klien:"
ip -br addr show eth0

echo
echo "[3/3] Informasi gateway dan DNS:"
ip route
cat /etc/resolv.conf

IP=$(ip -4 -o addr show dev eth0 | awk '{print $4}' | cut -d/ -f1)

case "$IP" in
    192.225.2.*)
        GATEWAY="192.225.2.1"
        ;;
    192.225.3.*)
        GATEWAY="192.225.3.1"
        ;;
    *)
        echo
        echo "[PERINGATAN] IP tidak berada pada subnet Divisi A/B yang diharapkan: $IP"
        exit 1
        ;;
esac

echo
echo "===== PENGUJIAN GATEWAY $GATEWAY ====="
ping -c 4 "$GATEWAY"

echo
echo "===== PENGUJIAN KLIEN SELESAI ====="
