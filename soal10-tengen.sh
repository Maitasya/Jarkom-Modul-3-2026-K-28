#!/bin/bash

ip link set eth0 up
ip addr flush dev eth0
ip addr add 192.225.4.10/24 dev eth0
ip route replace default via 192.225.4.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf

cp /root/dhcpd.conf /etc/dhcp/dhcpd.conf
mkdir -p /var/lib/dhcp
touch /var/lib/dhcp/dhcpd.leases

sed -i 's/^INTERFACESv4=.*/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server

pgrep -x dhcpd >/dev/null || service isc-dhcp-server start

echo "=== STATUS DHCP SERVER ==="
service isc-dhcp-server status
ps aux | grep '[d]hcpd'
echo "=== SOAL 10 TENGEN SELESAI ==="
