#!/bin/bash
MODE="$1"
IFACE="eth0"
echo "=================================="
echo " DEMO SOAL 9 - CLIENT ($MODE)"
echo "=================================="

echo
echo "[1] Menghapus IP lama:"
ip addr flush dev "$IFACE"
ip -4 -br addr show "$IFACE"

echo
echo "[2] Meminta lease baru:"
udhcpc -i "$IFACE" -n -q -t 3 -T 2
RC=$?

echo
echo "[3] IP dan routing sesudah permintaan:"
ip -4 -br addr show "$IFACE"
ip route

CURRENT_IP=$(ip -4 -o addr show "$IFACE" | awk '{print $4}' | cut -d/ -f1)

if [ "$MODE" = "gangguan" ]; then
    echo
    if [ "$RC" -ne 0 ] || [ -z "$CURRENT_IP" ]; then
        echo "GEJALA TERCATAT:"
        echo "- udhcpc mengirim DISCOVER berulang tanpa OFFER"
        echo "- udhcpc gagal: no lease"
        echo "- eth0 tidak memiliki alamat IP"
        echo "- tidak ada default gateway"
    else
        echo "PERINGATAN: client masih memperoleh lease ($CURRENT_IP)."
        echo "Pastikan relay Jichi sudah dihentikan."
    fi
    exit 0
fi

if [ "$RC" -ne 0 ] || [ -z "$CURRENT_IP" ]; then
    echo
    echo "ERROR: client belum memperoleh lease. Pastikan relay Jichi sudah dipulihkan."
    exit 1
fi

LAST=${CURRENT_IP##*.}
GW=""; POOL="tidak"
case "$CURRENT_IP" in
    192.225.2.*)
        GW="192.225.2.1"
        if { [ "$LAST" -ge 10 ] && [ "$LAST" -le 35 ]; } || { [ "$LAST" -ge 70 ] && [ "$LAST" -le 95 ]; }; then POOL="ya"; fi
        ;;
    192.225.3.*)
        GW="192.225.3.1"
        if { [ "$LAST" -ge 10 ] && [ "$LAST" -le 89 ]; } || { [ "$LAST" -ge 100 ] && [ "$LAST" -le 199 ]; } || [ "$LAST" -eq 99 ]; then POOL="ya"; fi
        ;;
    *)
        echo "ERROR: IP di luar Network 2 dan 3: $CURRENT_IP"; exit 1
        ;;
esac

CURRENT_GW=$(ip route | awk '$1 == "default" {print $3; exit}')

echo
echo "IP diperoleh : $CURRENT_IP (pool benar: $POOL)"
echo "Gateway      : ${CURRENT_GW:-tidak ada} (diharapkan $GW)"
if [ "$POOL" = "ya" ] && [ "$CURRENT_GW" = "$GW" ]; then
    echo "BERHASIL: client kembali memperoleh alamat dari pool yang benar dengan gateway semula."
else
    echo "ERROR: pool atau gateway tidak sesuai."
    exit 1
fi
