#!/bin/bash
PCAP=/root/soal8.pcap; TXT=/root/soal8.txt
rm -f $PCAP $TXT
timeout 90 tcpdump -i eth0 -n -U -w $PCAP 'udp and (port 67 or port 68)' >/dev/null 2>&1 &
sleep 2
echo ">>> SEKARANG jalankan udhcpc di client (maks 90 detik) <<<"
for i in $(seq 1 45); do
  tcpdump -r $PCAP -n -vvv 2>/dev/null | grep -q "DHCP-Message.*ACK" && break
  sleep 2
done
sleep 1
pkill -INT tcpdump
sleep 1
tcpdump -r $PCAP -n -vvv > $TXT 2>/dev/null
if [ ! -s $TXT ]; then echo "GAGAL: 0 paket. Cek relay Jichi."; exit 1; fi
echo; echo "=== URUTAN DHCP ==="
grep -E "BOOTP/DHCP|DHCP-Message" $TXT | sed 's/^[[:space:]]*//'
echo; echo "=== FIELD PENTING ==="
grep -E "Gateway-IP|Your-IP|Server-ID|Lease-Time" $TXT | sed 's/^[[:space:]]*//'
IP=$(grep -m1 "Your-IP" $TXT | grep -oE '[0-9]+(\.[0-9]+){3}' | head -1)
GI=$(grep -m1 "Gateway-IP" $TXT | grep -oE '[0-9]+(\.[0-9]+){3}' | head -1)
SV=$(grep -m1 "Server-ID" $TXT | grep -oE '[0-9]+(\.[0-9]+){3}' | head -1)
LT=$(grep -m1 "Lease-Time" $TXT | grep -oE '[0-9]+' | tail -1)
echo; echo "=== RINGKASAN ==="
echo "Server-ID : $SV"; echo "Your-IP   : $IP"; echo "Lease     : $LT detik"; echo "giaddr    : $GI"
case "$IP" in 192.225.2.*) EX=192.225.2.1;; 192.225.3.*) EX=192.225.3.1;; esac
[ "$GI" = "$EX" ] && echo "BERHASIL: giaddr $GI sesuai interface Jichi" || echo "CEK: giaddr $GI, harusnya $EX"
