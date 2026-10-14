#!/bin/bash
echo "=================================="
echo " DEMO SOAL 9 - PULIHKAN DHCP SERVER"
echo "=================================="
echo "nameserver 192.168.122.1" > /etc/resolv.conf
if ! command -v dhcpd >/dev/null 2>&1; then
    apt-get update && apt-get install -y isc-dhcp-server || { echo "ERROR: gagal memasang isc-dhcp-server"; exit 1; }
fi
cp /root/dhcpd.conf /etc/dhcp/dhcpd.conf
printf 'INTERFACESv4="eth0"\nINTERFACESv6=""\n' > /etc/default/isc-dhcp-server
ip -4 addr show eth0 | grep -q "192.225.4.10/24" || ip addr add 192.225.4.10/24 dev eth0
ip route | grep -q "^default" || ip route add default via 192.225.4.1
dhcpd -t -cf /etc/dhcp/dhcpd.conf || { echo "ERROR: dhcpd.conf tidak valid"; exit 1; }
service isc-dhcp-server restart
service isc-dhcp-server status
grep -n "range" /etc/dhcp/dhcpd.conf
