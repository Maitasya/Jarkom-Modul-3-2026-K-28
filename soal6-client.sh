#!/bin/bash

echo "=================================="
echo " DEMO SOAL 6 - CLIENT KUGISAKI"
echo "=================================="

INTERFACE="eth0"
EXPECTED_IP="192.225.3.99"
EXPECTED_GATEWAY="192.225.3.1"

# 1. Periksa MAC address
echo
echo "[1] MAC address Kugisaki:"
ip link show "$INTERFACE"

# 2. Minta IP reservasi dari DHCP
echo
echo "[2] Meminta IP reservasi dari DHCP:"
udhcpc -i "$INTERFACE" -n -q

if [ $? -ne 0 ]; then
    echo "ERROR: Gagal memperoleh lease DHCP."
    echo "Periksa DHCP server Tengen dan relay Jichi."
    exit 1
fi

# 3. Periksa IP yang diperoleh
echo
echo "[3] Alamat IP client:"
ip -4 -br addr show "$INTERFACE"

CURRENT_IP=$(ip -4 -o addr show "$INTERFACE" | awk '{print $4}' | cut -d/ -f1)

if [ "$CURRENT_IP" != "$EXPECTED_IP" ]; then
    echo "ERROR: IP tidak sesuai dengan reservasi."
    echo "IP yang diharapkan: $EXPECTED_IP"
    echo "IP yang diperoleh: $CURRENT_IP"
    exit 1
fi

# 4. Periksa gateway
echo
echo "[4] Routing client:"
ip route

CURRENT_GATEWAY=$(ip route | awk '$1 == "default" {print $3; exit}')

if [ "$CURRENT_GATEWAY" != "$EXPECTED_GATEWAY" ]; then
    echo "PERINGATAN: Gateway tidak sesuai."
    echo "Gateway yang diharapkan: $EXPECTED_GATEWAY"
    echo "Gateway yang ditemukan: $CURRENT_GATEWAY"
    exit 1
fi

echo
echo "BERHASIL: IP reservasi dan gateway sesuai."
