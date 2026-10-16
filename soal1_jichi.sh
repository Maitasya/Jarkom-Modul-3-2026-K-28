#!/bin/bash
set -e

echo "=== SOAL 1: KONFIGURASI ROUTER JICHI ==="

# Aktifkan seluruh interface
for iface in eth0 eth1 eth2 eth3 eth4; do
    ip link set "$iface" up
done

# Konfigurasi gateway setiap jaringan LAN
ip addr replace 192.225.1.1/24 dev eth1
ip addr replace 192.225.2.1/24 dev eth2
ip addr replace 192.225.3.1/24 dev eth3
ip addr replace 192.225.4.1/24 dev eth4

# Aktifkan IPv4 forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Pertahankan forwarding setelah konfigurasi sistem dimuat ulang
grep -q '^net.ipv4.ip_forward=1' /etc/sysctl.conf ||
    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf

# NAT untuk koneksi LAN menuju WAN
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null ||
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo "=== VERIFIKASI INTERFACE ==="
ip -br addr

echo "=== VERIFIKASI ROUTING ==="
ip route

echo "=== VERIFIKASI IP FORWARDING ==="
cat /proc/sys/net/ipv4/ip_forward

echo "=== VERIFIKASI NAT ==="
iptables -t nat -L POSTROUTING -n -v

echo "=== SOAL 1 SELESAI ==="