#!/bin/bash
echo "=================================="
echo " DEMO SOAL 9 - PERBAIKI NAT JICHI"
echo "=================================="
echo 1 > /proc/sys/net/ipv4/ip_forward
ip route | grep -q "^default" || ip route add default via 192.168.122.1
iptables -t nat -C POSTROUTING -s 192.225.0.0/16 -o eth0 -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -s 192.225.0.0/16 -o eth0 -j MASQUERADE
ip route | grep default
iptables -t nat -L POSTROUTING -n
echo "Tes internet dari Jichi:"
ping -c 2 -W 2 8.8.8.8
