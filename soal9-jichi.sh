#!/bin/bash
SERVER="192.225.4.10"
echo "=================================="
echo " DEMO SOAL 9 - DHCP RELAY JICHI"
echo "=================================="
case "$1" in
  stop)
    echo "[1] Menghentikan DHCP relay:"
    pkill dhcrelay 2>/dev/null
    sleep 1
    if pgrep -x dhcrelay >/dev/null; then
        echo "ERROR: relay masih berjalan."; exit 1
    fi
    echo "OK: relay dihentikan."
    echo "[2] Status relay:"
    ps aux | grep '[d]hcrelay' || echo "(tidak ada proses dhcrelay)"
    ;;
  start)
    echo "[1] Memeriksa paket dhcrelay:"
    if ! command -v dhcrelay >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update && apt-get install -y isc-dhcp-relay || { echo "ERROR: gagal memasang relay"; exit 1; }
    fi
    echo "OK"
    echo "[2] Memulihkan DHCP relay:"
    pkill dhcrelay 2>/dev/null
    sleep 1
    dhcrelay -i eth2 -i eth3 -i eth4 "$SERVER" >/dev/null 2>&1
    sleep 2
    if pgrep -x dhcrelay >/dev/null; then
        ps aux | grep '[d]hcrelay'
        echo "OK: relay pulih dan berjalan."
    else
        echo "ERROR: relay gagal berjalan."; exit 1
    fi
    ;;
  *)
    echo "Pemakaian: bash /root/soal9-jichi.sh stop|start"; exit 1
    ;;
esac
