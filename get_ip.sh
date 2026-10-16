#!/bin/sh
# ==========================================
# Script Refresh DHCP pada Client Alpine
# Simpan di /root/get_ip.sh
# ==========================================

echo "=== Meminta IP Lease Baru via DHCP ==="
killall udhcpc 2>/dev/null || true
ip addr flush dev eth0
udhcpc -i eth0 -n -q

echo "=== IP Address eth0 ==="
ip addr show eth0

echo "=== Routing Table ==="
ip route

echo "=== Resolv.conf ==="
cat /etc/resolv.conf