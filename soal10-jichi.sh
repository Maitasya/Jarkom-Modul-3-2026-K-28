#!/bin/bash

for i in 0 1 2 3 4; do
    ip link set eth$i up
done

ip addr add 192.225.1.1/24 dev eth1 2>/dev/null
ip addr add 192.225.2.1/24 dev eth2 2>/dev/null
ip addr add 192.225.3.1/24 dev eth3 2>/dev/null
ip addr add 192.225.4.1/24 dev eth4 2>/dev/null

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo "nameserver 192.168.122.1" > /etc/resolv.conf

cat > /etc/default/isc-dhcp-relay <<'CONFIG'
SERVERS="192.225.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
CONFIG

if ! pgrep -x dhcrelay >/dev/null; then
    service isc-dhcp-relay start
fi

echo "=== STATUS DHCP RELAY ==="
ps aux | grep '[d]hcrelay'
echo "=== SOAL 10 JICHI SELESAI ==="
