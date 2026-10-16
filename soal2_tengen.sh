
#!/bin/bash
set -e

CONF="/etc/dhcp/dhcpd.conf"

echo "=== SOAL 2: KONFIGURASI DHCP SERVER TENGEN ==="

# Pastikan interface server aktif
ip link set eth0 up

# Pastikan alamat server sesuai topologi
ip addr replace 192.225.4.10/24 dev eth0
ip route replace default via 192.225.4.1

# Atur interface layanan DHCP
printf 'INTERFACESv4="eth0"\nINTERFACESv6=""\n'     > /etc/default/isc-dhcp-server

# Pastikan database lease tersedia tanpa menghapus data lama
mkdir -p /var/lib/dhcp
touch /var/lib/dhcp/dhcpd.leases

# Validasi konfigurasi sebelum menjalankan service
dhcpd -t -cf "$CONF"

# Jalankan ulang DHCP Server
service isc-dhcp-server restart

echo "=== ALAMAT SERVER ==="
ip -br addr show eth0

echo "=== INTERFACE DHCP ==="
cat /etc/default/isc-dhcp-server

echo "=== STATUS DHCP SERVER ==="
service isc-dhcp-server status

echo "=== SUBNET YANG DIKONFIGURASI ==="
grep -nE '^subnet |range |fixed-address' "$CONF"

echo "=== SOAL 2 SELESAI ==="