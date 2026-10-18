## Kelompok K-28

| Nama | NRP |
| :---: | :---: |
| Maitasya Rohmatul Ula | 5027251026 |
| A. Algifari Rantiga Isdar | 5027251084 |

---
# LAPORAN RESMI PRAKTIKUM KOMUNIKASI DATA & JARINGAN KOMPUTER
## MODUL 3: CURTAIN PROTOCOL - SHIBUYA INCIDENT

### Informasi Dasar Pengalamatan (Prefix 192.225)

| Network | Subnet | Gateway (Jichi) | Isi |
|---|---|---|---|
| Network 1 (DMZ) | `192.225.1.0/24` | `192.225.1.1` (`eth1`) | Utahime, Shoko, Gojo |
| Network 2 (Divisi A) | `192.225.2.0/24` | `192.225.2.1` (`eth2`) | Itadori, Fushiguro, Zenin, Okkotsu |
| Network 3 (Divisi B) | `192.225.3.0/24` | `192.225.3.1` (`eth3`) | Ino, Kusakabe, Miwa, Kugisaki |
| Network 4 (Data Center) | `192.225.4.0/24` | `192.225.4.1` (`eth4`) | Tengen, Geto, worker, database |
| WAN | NAT GNS3 | - | `eth0` Jichi |

---

# Soal 1
Konfigurasi Interface, Gateway, IPv4 Forwarding, dan Source NAT pada Jichi

Konfigurasikan Jichi agar `eth0` memperoleh WAN dari NAT dan `eth1`–`eth4` menjadi gateway Network 1–4. Aktifkan IPv4 forwarding dan source NAT, tetapkan IP statis host infrastruktur, lalu buktikan konektivitas setiap host ke gateway dan akses eksternal dari host yang relevan.

### Langkah Pengerjaan

#### Langkah 1 — Mengaktifkan Interface Jichi

**Console perangkat: Jichi**

```bash
for i in 0 1 2 3 4; do ip link set eth$i up; done
```

**Hasil yang diharapkan:** tidak ada pesan error.

#### Langkah 2 — Menetapkan IP Gateway Network 1–4

**Console perangkat: Jichi**

```bash
ip addr flush dev eth1; ip addr add 192.225.1.1/24 dev eth1
ip addr flush dev eth2; ip addr add 192.225.2.1/24 dev eth2
ip addr flush dev eth3; ip addr add 192.225.3.1/24 dev eth3
ip addr flush dev eth4; ip addr add 192.225.4.1/24 dev eth4
ip -br a
```

**Hasil yang diharapkan:** `eth0` memperoleh IP dari NAT, `eth1`–`eth4` berturut-turut `192.225.1.1/24` sampai `192.225.4.1/24`.

<img width="936" height="107" alt="image" src="https://github.com/user-attachments/assets/137ce4ac-6e05-4610-bb55-77266702d5d6" />

output `ip -br a` di Jichi.

#### Langkah 3 — Mengaktifkan IPv4 Forwarding dan Source NAT

**Console perangkat: Jichi**

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

Verifikasi:

```bash
cat /proc/sys/net/ipv4/ip_forward
iptables -t nat -L POSTROUTING -v -n
```

**Hasil yang diharapkan:** nilai forwarding `1` dan ada rule `MASQUERADE` pada `eth0`.

**Forwarding dan NAT**

<img width="937" height="120" alt="image" src="https://github.com/user-attachments/assets/fe060002-6f4f-413f-b24d-6fcafe51a5a3" />
output kedua perintah verifikasi.

#### Langkah 4 — Menguji Akses Eksternal dari Jichi

**Console perangkat: Jichi**

```bash
ping -c 3 8.8.8.8
```

**Hasil yang diharapkan:** `0% packet loss`.

<img width="935" height="134" alt="image" src="https://github.com/user-attachments/assets/47341f11-72ec-4a77-b898-85183e178eaf" />

hasil ping `8.8.8.8` dari Jichi.

#### Langkah 5 — Menetapkan IP Statis Host Infrastruktur

**Console perangkat: Tengen, Utahime, Shoko, Gojo**

Contoh Tengen (host lain dengan pola sama, sesuaikan IP dan gateway):

```bash
ip addr flush dev eth0
ip addr add 192.225.4.10/24 dev eth0
ip link set eth0 up
ip route replace default via 192.225.4.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

| Host | IP | Gateway |
|---|---|---|
| Utahime | `192.225.1.2/24` | `192.225.1.1` |
| Shoko | `192.225.1.3/24` | `192.225.1.1` |
| Gojo | `<isi>/24` | `192.225.1.1` |
| Tengen | `192.225.4.10/24` | `192.225.4.1` |


#### Langkah 6 — Menguji Konektivitas Host ke Gateway dan Internet

**Console perangkat: Tengen, Utahime, Shoko, Gojo**

```bash
ping -c 3 <gateway-network-host>
ping -c 3 8.8.8.8
```

**Hasil yang diharapkan:** ping gateway dan `8.8.8.8` berhasil.

### Catatan Pengujian Ulang

Seluruh perintah verifikasi dapat dijalankan berulang. IP yang diatur dengan `ip addr add` hilang saat node di-stop, jadi jalankan ulang script jika node baru dinyalakan.

### Kesimpulan

Jichi berhasil dikonfigurasi sebagai router dengan gateway Network 1–4, IPv4 forwarding aktif, dan source NAT `MASQUERADE` pada `eth0`. Host infrastruktur memperoleh IP statis dan dapat menjangkau gateway serta internet melalui Jichi.

### Otomatisasi Menggunakan Script

#### Script Jichi

**Cara membuat script**

Pada console Jichi, buat file `/root/soal1_jichi.sh`:

```bash
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
```

Berikan izin eksekusi:

```bash
chmod +x /root/soal1_jichi.sh
```

**Cara menjalankan script**

```bash
bash /root/soal1_jichi.sh
```

**Output yang diharapkan:** `

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/a18f0080-5d8c-4dc5-9e55-6aa5fc0b0934" />

hasil `bash /root/soal1_jichi.sh`.

#### Script IP Statis Host

| Node | File | Perintah |
|---|---|---|
| Tengen | `/root/init.sh` | `bash /root/init.sh` |
| Utahime | `/root/init.sh` | `bash /root/init.sh` |
| Shoko | `/root/init.sh` | `bash /root/init.sh` |
| Gojo | `/root/konfig_gojo.sh` | `bash /root/konfig_gojo.sh` |

**Output Script Host**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/3aeac602-e096-4cfa-96b3-ce40a8b42806" />

hasil script di tiap host.

hasil ping 8.8.8.8

<img width="936" height="131" alt="image" src="https://github.com/user-attachments/assets/d98f553f-29f7-4ffe-874d-7132995d00ef" />

**Urutan Demo:** 
(1) Jichi: `bash /root/soal1_jichi.sh`, 

(2) tiap host: jalankan script IP, 

(3) tiap host: ping gateway dan `8.8.8.8`.

---

# Soal 2
Konfigurasi Dasar ISC DHCP Server di Tengen

Konfigurasikan `isc-dhcp-server` pada `192.225.4.10`. Deklarasikan Network 4 sebagai subnet lokal tanpa pool dinamis, siapkan scope DHCP untuk Network 2 dan Network 3, validasi konfigurasi, dan pastikan service aktif tanpa error "No subnet declaration".

### Langkah Pengerjaan

#### Langkah 1 — Memeriksa IP dan Routing Tengen

**Console perangkat: Tengen**

```bash
ip -br a
ip route
```

**Hasil yang diharapkan:** `eth0` berIP `192.225.4.10/24` dan `default via 192.225.4.1`.

**IP dan Routing Tengen**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/3657dc3a-16ce-41bd-ad60-910ab314785e" />

output `ip -br a` dan `ip route`.

#### Langkah 2 — Menentukan Interface DHCP Server

**Console perangkat: Tengen**

```bash
nano /etc/default/isc-dhcp-server
```

Isi:

```text
INTERFACESv4="eth0"
INTERFACESv6=""
```

#### Langkah 3 — Menulis Konfigurasi DHCP

**Console perangkat: Tengen**

```bash
nano /etc/dhcp/dhcpd.conf
```

Isi:

```text
ddns-update-style none;
authoritative;

option domain-name "K28.com";
option domain-name-servers 192.225.1.2, 192.225.1.3;

# Network 4: subnet lokal tanpa pool (mencegah 'No subnet declaration')
subnet 192.225.4.0 netmask 255.255.255.0 {
}

# Network 2 (Divisi A)
subnet 192.225.2.0 netmask 255.255.255.0 {
    option routers 192.225.2.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.225.2.255;
    option domain-name-servers 192.225.1.2, 192.225.1.3;
    option domain-search "K28.com";
}

# Network 3 (Divisi B)
subnet 192.225.3.0 netmask 255.255.255.0 {
    option routers 192.225.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.225.3.255;
    option domain-name-servers 192.225.1.2, 192.225.1.3;
    option domain-search "K28.com";
}
```

**Isi dhcpd.conf**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/23f239c2-1eee-4f61-96e5-379350f5fa93" />

 `cat /etc/dhcp/dhcpd.conf` yang memperlihatkan blok `subnet 192.225.4.0 ... { }`, Network 2, dan Network 3.

#### Langkah 4 — Validasi dan Menjalankan Service

**Console perangkat: Tengen**

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
```

**Hasil yang diharapkan:** `dhcpd -t` tanpa error dan status `dhcpd is running`.

**Validasi dan Status Service**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/7ad472f8-17ce-4e28-96b9-5af4a82e9c99" />

output `dhcpd -t` dan `service isc-dhcp-server status`.

### Catatan Pengujian Ulang

`dhcpd -t`, `service ... status`, dan `ps aux | grep '[d]hcpd'` dapat dijalankan berulang. Jika `dhcpd -t` error, perbaiki sintaks dulu sebelum restart service.

### Kesimpulan

DHCP Server pada Tengen berhasil dikonfigurasi dengan subnet lokal Network 4 tanpa pool serta scope Network 2 dan Network 3. Konfigurasi valid dan service berjalan tanpa error "No subnet declaration".

### Otomatisasi Menggunakan Script

#### Script DHCP Server pada Tengen

**Cara membuat script**

Pada console Tengen, buat file `cat /root/soal2_tengen.sh`:

```bash

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
```

Berikan izin eksekusi:

```bash
chmod +x /root/soal2_tengen.sh
```

**Cara menjalankan script**

```bash
bash /root/soal2_tengen.sh
```

**Output yang diharapkan:** `dhcpd -t` tanpa error dan `dhcpd is running`.

**Output Script Soal 2**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/5011bd3e-be00-4b14-8af0-73de78be9534" />

hasil `bash /root/soal2_tengen.sh`.

**Urutan Demo:** 

(1) Tengen: `bash /root/soal2_tengen.sh`, 

(2) cek `ps aux | grep '[d]hcpd'`.

---
# Soal 3
Konfigurasi DHCP Relay pada Jichi

Konfigurasikan Jichi sebagai DHCP Relay menuju Tengen (`192.225.4.10`), menggunakan `eth2` untuk Network 2 dan `eth3` untuk Network 3. Buktikan client dari kedua subnet memperoleh lease melalui relay.

> Catatan: `eth4` ikut dimasukkan karena balasan dari Tengen masuk melalui `eth4`.

### Langkah Pengerjaan

#### Langkah 1 — Memastikan DHCP Server Aktif

**Console perangkat: Tengen**

```bash
service isc-dhcp-server status
```

**Hasil yang diharapkan:** `dhcpd is running`.

#### Langkah 2 — Mengonfigurasi DHCP Relay

**Console perangkat: Jichi**

```bash
nano /etc/default/isc-dhcp-relay
```

Isi:

```text
SERVERS="192.225.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
```

#### Langkah 3 — Menjalankan Relay

**Console perangkat: Jichi**

Periksa dulu apakah relay sudah aktif:

```bash
pgrep -a dhcrelay
```

Jika belum ada proses:

```bash
dhcrelay -i eth2 -i eth3 -i eth4 192.225.4.10
```

Verifikasi:

```bash
ps aux | grep '[d]hcrelay'
```

**Hasil yang diharapkan:** ada proses `dhcrelay` dengan server `192.225.4.10`. Jangan menjalankan relay kedua.

**Proses Relay Aktif**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/e5205b6b-0e6f-498a-8c8d-d447018fed8a" />

output `ps aux | grep '[d]hcrelay'`.

#### Langkah 4 — Menguji Lease Client Network 2

**Console perangkat: Itadori**

```bash
udhcpc -i eth0 -n -q
ip -br a show eth0
ip route
```

**Hasil yang diharapkan:** IP `192.225.2.x/24` dan `default via 192.225.2.1`.

**Lease Client Network 2**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/8578f1cf-e297-41f7-ac00-397d16d219fb" />

output di Itadori.

#### Langkah 5 — Menguji Lease Client Network 3

**Console perangkat: Ino**

```bash
udhcpc -i eth0 -n -q
ip -br a show eth0
ip route
```

**Hasil yang diharapkan:** IP `192.225.3.x/24` dan `default via 192.225.3.1`.

**Lease Client Network 3**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/1321c5c3-6401-4b8c-8266-3dbc20325849" />

 output di Ino.

### Catatan Pengujian Ulang

Sebelum menjalankan `dhcrelay`, selalu cek `pgrep -a dhcrelay` agar tidak ada proses ganda. Jika client `no lease`, periksa relay di Jichi, service di Tengen, dan default route Tengen.

### Kesimpulan

Jichi berhasil berfungsi sebagai DHCP Relay menuju Tengen. Client Network 2 dan Network 3 memperoleh lease dan gateway sesuai subnet masing-masing melalui relay.

### Otomatisasi Menggunakan Script

#### Script DHCP Relay pada Jichi

**Cara membuat script**

Pada console Jichi, buat file `cat /root/soal3_jichi.sh`:

```bash
#!/bin/bash
set -e

CONF="/etc/default/isc-dhcp-relay"

echo "=== SOAL 3: KONFIGURASI DHCP RELAY JICHI ==="

# Simpan konfigurasi sebelumnya jika backup belum tersedia
cp -n "$CONF" "${CONF}.backup-soal3-final"

# Konfigurasi server DHCP dan arah relay
cat > "$CONF" <<'CONFIG'
SERVERS="192.225.4.10"
INTERFACES=""
OPTIONS="-iu eth4 -id eth2 -id eth3"
CONFIG

# Pastikan konfigurasi relay sesuai
cat "$CONF"

# Terapkan konfigurasi
service isc-dhcp-relay restart

echo "=== STATUS DHCP RELAY ==="
service isc-dhcp-relay status

echo "=== PROSES DHCP RELAY ==="
ps | grep '[d]hcrelay' || true

echo "=== SOAL 3 SELESAI ==="
```

Berikan izin eksekusi:

```bash
chmod +x /root/soal3_jichi.sh
```

**Cara menjalankan script**

```bash
bash /root/soal3_jichi.sh
```

**Output yang diharapkan:** proses `dhcrelay -i eth2 -i eth3 -i eth4 192.225.4.10` tampil.

**Output Script Soal 3**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/45275b02-03aa-4a8a-803f-a572e7938e65" />

 hasil `bash /root/soal3_jichi.sh`.

#### Script Client (Itadori)

**Cara membuat script**

Pada console Itadori, buat file `cat /root/get_ip.sh`:

```bash
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
```

**Cara menjalankan script**

```bash
sh /root/get_ip.sh
```

**Output Script Client**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/ed6187ea-a2e0-4446-9525-d40920c37854" />

hasil `sh /root/get_ip.sh` di Itadori.

**Urutan Demo:** 

(1) Tengen: server aktif, 

(2) Jichi: `bash /root/soal3_jichi.sh`, 

(3) Itadori dan Ino: minta lease, 

(4) cek IP dan route.

---
# Soal 4
DHCP Class dan Dua Pool pada Network 2

Atur dua pool pada Network 2: Pool 1 (`192.225.2.10–192.225.2.35`) untuk Itadori dan Fushiguro, Pool 2 (`192.225.2.70–192.225.2.95`) untuk Zenin dan Okkotsu. Rentang `192.225.2.36–192.225.2.69` tidak boleh dialokasikan. Pisahkan kedua kelompok dengan DHCP class berdasarkan MAC address.

### Langkah Pengerjaan

#### Langkah 1 — Mencatat MAC Address Client Network 2

**Console perangkat: Itadori, Fushiguro, Zenin, Okkotsu**

```bash
ip -br link show eth0
```

**Hasil yang diharapkan:**

| Client | MAC eth0 | Kelompok |
|---|---|---|
| Itadori | `02:42:33:e9:7e:00` | Pool 1 |
| Fushiguro | `02:42:7b:f1:68:00` | Pool 1 |
| Zenin | `02:42:6b:7c:b7:00` | Pool 2 |
| Okkotsu | `02:42:9f:c2:73:00` | Pool 2 |

**MAC Address Client**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/8636345d-ec5b-466f-84ae-844132047e08" />

 output `ip -br link show eth0` di Itadori.

#### Langkah 2 — Menambahkan Class dan Pool

**Console perangkat: Tengen**

```bash
nano /etc/dhcp/dhcpd.conf
```

Tambahkan class sebelum blok subnet:

```text
class "pool1-clients" {
    match if substring(hardware, 1, 6) = 02:42:33:e9:7e:00 or
             substring(hardware, 1, 6) = 02:42:7b:f1:68:00;
}

class "pool2-clients" {
    match if substring(hardware, 1, 6) = 02:42:6b:7c:b7:00 or
             substring(hardware, 1, 6) = 02:42:9f:c2:73:00;
}
```

Ubah blok `subnet 192.225.2.0` menjadi:

```text
subnet 192.225.2.0 netmask 255.255.255.0 {
    option routers 192.225.2.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.225.2.255;
    option domain-name-servers 192.225.1.2, 192.225.1.3;
    option domain-search "K28.com";

    pool {
        allow members of "pool1-clients";
        range 192.225.2.10 192.225.2.35;
    }

    pool {
        allow members of "pool2-clients";
        range 192.225.2.70 192.225.2.95;
    }
}
```

#### Langkah 3 — Validasi dan Restart Service

**Console perangkat: Tengen**

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
```

**Hasil yang diharapkan:** tanpa error dan `dhcpd is running`.

**Validasi dan Status**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/02928b1b-9134-40b4-9170-276bd71e8bd6" />

output ketiga perintah.

#### Langkah 4 — Menguji Client Pool 1

**Console perangkat: Itadori dan Fushiguro**

```bash
ip addr flush dev eth0
udhcpc -i eth0 -n -q
ip -br a show eth0
```

**Hasil yang diharapkan:** IP berada di `192.225.2.10`–`192.225.2.35`.

**Client Pool 1**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/de0d88b1-2807-41a5-b296-1e90f5ec5890" />

output di Itadori.

#### Langkah 5 — Menguji Client Pool 2

**Console perangkat: Zenin dan Okkotsu**

```bash
ip addr flush dev eth0
udhcpc -i eth0 -n -q
ip -br a show eth0
```

**Hasil yang diharapkan:** IP berada di `192.225.2.70`–`192.225.2.95`.

**Client Pool 2**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/b64edab0-5d39-4d21-bd78-9edd24a056a2" />

 output di Okkotsu.

#### Langkah 6 — Membuktikan Rentang `.2.36`–`.2.69` Tidak Terpakai

**Console perangkat: Tengen**

```bash
grep "^lease" /var/lib/dhcp/dhcpd.leases | awk '{print $2}' | awk -F. '$3==2 && $4>=36 && $4<=69'
```

### Catatan Pengujian Ulang

Jika client masih memegang IP lama, jalankan `ip addr flush dev eth0` sebelum `udhcpc`. IP yang diperoleh tiap client bisa berbeda antar pengujian selama masih dalam rentang pool-nya.

### Kesimpulan

DHCP class berbasis MAC address berhasil memisahkan Network 2 menjadi Pool 1 dan Pool 2. Itadori dan Fushiguro memperoleh IP `.2.10`–`.2.35`, Zenin dan Okkotsu memperoleh IP `.2.70`–`.2.95`, dan rentang `.2.36`–`.2.69` tidak pernah dialokasikan.

### Otomatisasi Menggunakan Script

#### Script DHCP Class dan Pool pada Tengen

**Cara membuat script**

Pada console Tengen, buat file `cat /root/soal4_tengen.sh`:

```bash
#!/bin/bash
set -e

CONF="/etc/dhcp/dhcpd.conf"

echo "=== SOAL 4: DHCP CLASS DAN POOL ==="

# Pastikan class dan rentang DHCP tersedia
grep -q 'class "pool1-clients"' "$CONF"
grep -q 'class "pool2-clients"' "$CONF"
grep -q 'range 192.225.2.10 192.225.2.35' "$CONF"
grep -q 'range 192.225.2.70 192.225.2.95' "$CONF"

# Validasi konfigurasi sebelum restart
dhcpd -t -cf "$CONF"

service isc-dhcp-server restart

echo "=== CLASS POOL 1 ==="
grep -n -A 4 'class "pool1-clients"' "$CONF"

echo "=== CLASS POOL 2 ==="
grep -n -A 4 'class "pool2-clients"' "$CONF"

echo "=== RENTANG DHCP NETWORK 2 ==="
grep -n -A 16 'subnet 192.225.2.0' "$CONF"

echo "=== STATUS DHCP ==="
service isc-dhcp-server status

echo "=== SOAL 4 SELESAI ==="
```

Berikan izin eksekusi:

```bash
chmod +x /root/soal4_tengen.sh
```

**Cara menjalankan script**

```bash
bash /root/soal4_tengen.sh
```

**Output yang diharapkan:** `dhcpd -t` tanpa error dan `dhcpd is running`.

**Output Script Soal 4**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/5050335c-0241-4e89-a26b-16925a5cfbdf" />

hasil `bash /root/soal4_tengen.sh`.

#### Script Client

Jalankan pada Itadori, Fushiguro, Zenin, dan Okkotsu:

```bash
sh /root/get_ip.sh
```

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/f3219045-da8b-4bdc-8426-bae088828098" />

**Urutan Demo:** 

(1) Tengen: `bash /root/soal4_tengen.sh`, 

(2) Jichi: pastikan relay aktif, 

(3) keempat client: minta lease, 

(4) Tengen: cek rentang terlarang.

---

# Soal 5
## Short Lease dan Long Lease pada Network 3

Pada Network 3, berikan short lease 30 menit (1800 detik) kepada Ino dan Kusakabe, serta long lease 12 jam (43200 detik) kepada Miwa. Gunakan pool short `192.225.3.10–192.225.3.89` dan pool long `192.225.3.100–192.225.3.199`. Sesuaikan `default-lease-time` dan `max-lease-time` tiap class, serta berikan DNS `192.225.1.2`, `192.225.1.3`, dan domain-search `K28.com`.

### Langkah Pengerjaan

#### Langkah 1 — Mencatat MAC Address Client Network 3

**Console perangkat: Ino, Kusakabe, Miwa**

```bash
ip -br link show eth0
```

**Hasil yang diharapkan:**

| Client | MAC eth0 | Kelompok |
|---|---|---|
| Ino | `02:42:2c:11:46:00` | Short lease |
| Kusakabe | `02:42:94:28:a5:00` | Short lease |
| Miwa | `02:42:84:4d:0b:00` | Long lease |

#### Langkah 2 — Menambahkan Class Lease Time

**Console perangkat: Tengen**

```bash
nano /etc/dhcp/dhcpd.conf
```

Tambahkan sebelum blok subnet:

```text
class "short-lease-clients" {
    match if substring(hardware, 1, 6) = 02:42:2c:11:46:00 or
             substring(hardware, 1, 6) = 02:42:94:28:a5:00;
    default-lease-time 1800;
    max-lease-time 1800;
}

class "long-lease-clients" {
    match if substring(hardware, 1, 6) = 02:42:84:4d:0b:00;
    default-lease-time 43200;
    max-lease-time 43200;
}
```

#### Langkah 3 — Menambahkan Dua Pool pada Network 3

**Console perangkat: Tengen**

Ubah blok `subnet 192.225.3.0` menjadi:

```text
subnet 192.225.3.0 netmask 255.255.255.0 {
    option routers 192.225.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.225.3.255;
    option domain-name-servers 192.225.1.2, 192.225.1.3;
    option domain-search "K28.com";

    pool {
        allow members of "short-lease-clients";
        range 192.225.3.10 192.225.3.89;
    }

    pool {
        allow members of "long-lease-clients";
        range 192.225.3.100 192.225.3.199;
    }
}
```

#### Langkah 4 — Validasi dan Restart Service

**Console perangkat: Tengen**

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
```

**Validasi dan Status**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/02928b1b-9134-40b4-9170-276bd71e8bd6" />

 output ketiga perintah.

#### Langkah 5 — Menguji Client Short Lease

**Console perangkat: Ino dan Kusakabe**

```bash
ip addr flush dev eth0
udhcpc -i eth0 -n -q
ip -br a show eth0
cat /etc/resolv.conf
```

**Hasil yang diharapkan:** IP di `192.225.3.10`–`192.225.3.89`, lease time sekitar `1800`, serta `search K28.com`, `nameserver 192.225.1.2`, `nameserver 192.225.1.3`.

**Client Short Lease**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/0cea46c7-3f5f-4045-a089-8fcdb223dc0f" />

output di Kusakabe.

#### Langkah 6 — Menguji Client Long Lease

**Console perangkat: Miwa**

```bash
ip addr flush dev eth0
udhcpc -i eth0 -n -q
ip -br a show eth0
cat /etc/resolv.conf
```

**Hasil yang diharapkan:** IP di `192.225.3.100`–`192.225.3.199` dan lease time sekitar `43200`.

**Client Long Lease**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/0fdc382e-890a-4d44-9c76-3009298d28fd" />

output di Miwa.

#### Langkah 7 — Membuktikan Durasi Lease di Server

**Console perangkat: Tengen**

```bash
grep -E "^lease|starts|ends|hardware ethernet" /var/lib/dhcp/dhcpd.leases | tail -n 30
```

**Hasil yang diharapkan:** selisih `starts` dan `ends` untuk Ino/Kusakabe tepat 30 menit, dan untuk Miwa tepat 12 jam.

> Lease time yang tampil di `udhcpc` adalah sisa waktu, bukan nilai penuh (mis. `1714` berarti lease 1800 yang sudah berjalan sekitar 86 detik).

**Bukti Durasi Lease**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/988bced1-0feb-4d2e-8870-c272ad759703" />

isi `dhcpd.leases` yang memperlihatkan selisih `starts`–`ends` Short Lease (30 menit) dan Long Lease (12 jam).

### Catatan Pengujian Ulang

`dhcpd.leases` adalah jurnal, jadi IP yang sama dapat muncul berulang setelah renew. Baca entri paling bawah untuk status terbaru. Jika client belum memakai konfigurasi baru, jalankan `ip addr flush dev eth0` lalu `udhcpc` lagi.

### Kesimpulan

Class berbasis MAC address berhasil membedakan lease time Network 3. Ino dan Kusakabe memperoleh short lease 1800 detik pada pool `.3.10`–`.3.89`, sedangkan Miwa memperoleh long lease 43200 detik pada pool `.3.100`–`.3.199`, dengan DNS dan domain-search `K28.com` sesuai ketentuan.

### Otomatisasi Menggunakan Script

#### Script Short/Long Lease pada Tengen

**Cara membuat script**

Pada console Tengen, buat file `cat /root/soal5_tengen.sh`:

```bash
#!/bin/bash
set -e

CONF="/etc/dhcp/dhcpd.conf"

echo "=== SOAL 5: LEASE DAN RESERVASI DHCP ==="

# Pastikan class lease tersedia
grep -q 'class "short-lease-clients"' "$CONF"
grep -q 'class "long-lease-clients"' "$CONF"

# Pastikan durasi lease sesuai ketentuan
grep -q 'default-lease-time 1800;' "$CONF"
grep -q 'max-lease-time 1800;' "$CONF"
grep -q 'default-lease-time 43200;' "$CONF"
grep -q 'max-lease-time 43200;' "$CONF"

# Pastikan reservasi Kugisaki sesuai
grep -q 'host kugisaki' "$CONF"
grep -q 'hardware ethernet 02:42:51:c8:03:00;' "$CONF"
grep -q 'fixed-address 192.225.3.99;' "$CONF"

# Validasi tanpa mengubah konfigurasi
dhcpd -t -cf "$CONF"

echo "=== KONFIGURASI LEASE PENDEK ==="
grep -n -A 5 'class "short-lease-clients"' "$CONF"

echo "=== KONFIGURASI LEASE PANJANG ==="
grep -n -A 4 'class "long-lease-clients"' "$CONF"

echo "=== RESERVASI KUGISAKI ==="
grep -n -A 9 'host kugisaki' "$CONF"

echo "=== LEASE AKTIF TERSIMPAN ==="
grep -n -E -B 5 -A 5 \
    'hardware ethernet 02:42:(2c:11:46:00|94:28:a5:00|84:4d:0b:00|51:c8:03:00)' \
    /var/lib/dhcp/dhcpd.leases || true

echo "=== STATUS DHCP ==="
service isc-dhcp-server status

echo "=== SOAL 5 SELESAI ==="
```

Berikan izin eksekusi:

```bash
chmod +x /root/soal5_tengen.sh
```

**Cara menjalankan script**

```bash
bash /root/soal5_tengen.sh
```

**Output yang diharapkan:** `dhcpd -t` tanpa error dan `dhcpd is running`.

**Output Script Soal 5**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/e326fee0-dadc-4559-8090-1005dfb18c52" />

hasil `bash /root/soal5_tengen.sh`.

#### Script Client

Jalankan pada Ino, Kusakabe, dan Miwa:

```bash
ip addr flush dev eth0; udhcpc -i eth0 -n -q; ip -br a show eth0; cat /etc/resolv.conf
```

hasil:

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/c5274ad5-b238-43c2-af92-a38849859053" />

**Urutan Demo:** 

(1) Tengen: `bash /root/soal5_tengen.sh`, 

(2) Jichi: pastikan relay aktif, 

(3) Ino, Kusakabe, Miwa: minta lease, 

(4) Tengen: cek `dhcpd.leases`.

---
### Soal 6
DHCP Static Lease untuk Kugisaki

Konfigurasikan DHCP Static Lease untuk client Kugisaki berdasarkan MAC address agar selalu memperoleh IP `192.225.3.99`. Pastikan alamat tersebut berada di luar rentang IP dinamis dan konfigurasi DHCP server valid. Lakukan pengujian untuk membuktikan bahwa Kugisaki memperoleh IP reservasi melalui DHCP server Tengen dengan bantuan DHCP relay pada Jichi.

### Langkah Pengerjaan

#### Langkah 1 — Memeriksa MAC Address Kugisaki

**Console perangkat: Kugisaki**

Jalankan perintah berikut:

```bash
ip -br link
```

**Hasil yang diharapkan:** MAC address interface `eth0` adalah `02:42:51:c8:03:00`.

#### Langkah 2 — Memeriksa Konfigurasi Static Lease

**Console perangkat: Tengen**

Konfigurasi host Kugisaki disimpan pada `/etc/dhcp/dhcpd.conf`. Untuk memeriksa konfigurasi, jalankan:

```bash
grep -A 8 'host kugisaki' /etc/dhcp/dhcpd.conf
```

**Hasil yang diharapkan:**

```text
host kugisaki {
    hardware ethernet 02:42:51:c8:03:00;
    fixed-address 192.225.3.99;
    option routers 192.225.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.225.3.255;
    option domain-name-servers 192.225.1.2, 192.225.1.3;
    option domain-search "K28.com";
}
```

Alamat `192.225.3.99` berada di luar pool dinamis `192.225.3.10–192.225.3.89` dan `192.225.3.100–192.225.3.199`.

**Konfigurasi Static Lease**
<img width="960" height="504" alt="SS 1 — Konfigurasi Static Lease" src="https://github.com/user-attachments/assets/db9f10b3-7d64-46e6-9401-428e0e60c660" />

#### Langkah 3 — Memvalidasi Konfigurasi DHCP

**Console perangkat: Tengen**

Validasi konfigurasi DHCP menggunakan perintah:

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

**Hasil yang diharapkan:** konfigurasi berhasil diperiksa tanpa pesan kesalahan sintaks.

**Validasi DHCP**

<img width="959" height="200" alt="SS 2 — Validasi Konfigurasi DHCP" src="https://github.com/user-attachments/assets/5496074c-d12e-487c-a344-5687962e9f09" />

#### Langkah 4 — Memeriksa Status DHCP Server

**Console perangkat: Tengen**

Periksa status layanan DHCP server menggunakan perintah:

```bash
service isc-dhcp-server status
```

**Hasil yang diharapkan:**

```text
Status of ISC DHCPv4 server: dhcpd is running.
```

Hasil tersebut menunjukkan bahwa layanan DHCP server sedang berjalan.

**Status Server**

<img width="959" height="74" alt="SS 3 — DHCP Server Aktif" src="https://github.com/user-attachments/assets/28127987-a512-4176-a80b-2c724f86b1eb" />

#### Langkah 5 — Memeriksa DHCP Relay

**Console perangkat: Jichi**

Periksa apakah proses DHCP relay sudah berjalan menggunakan perintah:

```bash
ps aux | grep '[d]hcrelay'
```

**Hasil yang diharapkan:** terdapat proses `dhcrelay` yang meneruskan permintaan DHCP menuju server `192.225.4.10`.

Jika proses relay belum berjalan, jalankan perintah berikut:

```bash
dhcrelay -i eth3 -i eth4 192.225.4.10
```

Biarkan console tetap terbuka jika relay berjalan di foreground. **Jangan menjalankan perintah tersebut kembali jika relay sudah aktif**, untuk menghindari proses relay ganda.

**DHCP Relay**

<img width="960" height="504" alt="SS 4 — DHCP Relay di Jichi" src="https://github.com/user-attachments/assets/058674a3-eb2d-47b8-9b78-dcf48a8208d4" />

#### Langkah 6 — Menguji Pemberian IP Reservasi

**Console perangkat: Kugisaki**

Minta lease DHCP melalui interface `eth0` menggunakan perintah:

```bash
udhcpc -i eth0 -n -q
```

**Hasil aktual yang berhasil diperoleh:**

```text
udhcpc: broadcasting select for 192.225.3.99, server 192.225.4.10
udhcpc: lease of 192.225.3.99 obtained from 192.225.4.10, lease time 43200
```

Hasil tersebut menunjukkan bahwa Kugisaki berhasil mendapatkan IP reservasi dari DHCP server Tengen.

**Client Mendapatkan IP**

<img width="960" height="504" alt="SS 5 — Kugisaki Berhasil Mendapatkan IP" src="https://github.com/user-attachments/assets/e4f3fb55-4404-484e-b7c1-6434b83468a4" />

#### Langkah 7 — Memverifikasi IP dan Gateway

**Console perangkat: Kugisaki**

Periksa alamat IP pada interface menggunakan perintah:

```bash
ip -4 -br addr
```

Kemudian periksa rute jaringan menggunakan perintah:

```bash
ip route
```

**Hasil aktual yang diperoleh:**

```text
eth0  UNKNOWN  192.225.3.99/24
default via 192.225.3.1 dev eth0 metric 70858
```

Hasil tersebut membuktikan bahwa IP reservasi terpasang pada interface `eth0` dan gateway mengarah ke `192.225.3.1`.

**Verifikasi IP dan Route**

<img width="960" height="504" alt="SS 6 — Verifikasi IP dan Gateway" src="https://github.com/user-attachments/assets/7c7a3ded-1918-46d0-917b-d6f628ea54e8" />

### Catatan Pengujian Ulang

Perintah pemeriksaan seperti `ip -br link`, `grep`, `dhcpd -t`, `service isc-dhcp-server status`, `ip -4 -br addr`, dan `ip route` dapat dijalankan berulang kali.

Namun, sebelum menjalankan DHCP relay, periksa terlebih dahulu apakah prosesnya sudah aktif menggunakan:

```bash
ps aux | grep '[d]hcrelay'
```

Jika relay sudah aktif, tidak perlu menjalankan perintah `dhcrelay` kembali. Pengujian `udhcpc` dilakukan ketika diperlukan untuk memperoleh atau memperbarui lease DHCP.

### Kesimpulan

Konfigurasi DHCP Static Lease untuk Kugisaki berhasil dilakukan berdasarkan MAC address `02:42:51:c8:03:00` dengan IP tetap `192.225.3.99`. DHCP server Tengen berhasil memberikan lease melalui DHCP relay pada Jichi. Keberhasilan dibuktikan melalui output `udhcpc`, alamat IP pada interface `eth0`, serta gateway `192.225.3.1`.

### Otomatisasi Pengujian DHCP Static Lease Menggunakan Script

#### Script DHCP Relay pada Jichi

**Cara membuat script**

Pada console Jichi, buat file `/root/soal6-relay.sh` menggunakan perintah:

```bash
#!/bin/bash

echo "================================"
echo " DEMO SOAL 6 - DHCP RELAY JICHI"
echo "================================"

SERVER="192.225.4.10"

echo
echo "[1] Memeriksa DHCP relay:"
if pgrep -f '^dhcrelay .*192\.225\.4\.10' >/dev/null; then
    echo "DHCP relay sudah berjalan. Tidak menjalankan proses baru."
else
    echo
    echo "[2] Menjalankan DHCP relay:"
    dhcrelay -i eth3 -i eth4 "$SERVER"
fi

echo
echo "[3] Proses DHCP relay:"
ps aux | grep '[d]hcrelay'

echo
echo "Pemeriksaan Jichi selesai."
```

Berikan izin eksekusi:

```bash
chmod +x /root/soal6-relay.sh
```

**Cara menjalankan script**

```bash
/root/soal6-relay.sh
```

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/ed4ad1de-4f56-4024-af19-4da9b3e14eb0" />

**Fungsi:** memeriksa proses DHCP relay pada Jichi dan menjalankannya jika belum terdeteksi aktif. Pemeriksaan ini membantu menghindari pembuatan proses relay baru ketika proses sebelumnya masih berjalan.

#### Script DHCP Client pada Kugisaki

**Cara membuat script**

Pada console Kugisaki, buat file `/root/soal6-client.sh` menggunakan perintah:

```bash
#!/bin/bash

echo "=================================="
echo " DEMO SOAL 6 - CLIENT KUGISAKI"
echo "=================================="

INTERFACE="eth0"
EXPECTED_IP="192.225.3.99"
EXPECTED_GATEWAY="192.225.3.1"

echo
echo "[1] MAC address Kugisaki:"
ip link show "$INTERFACE"

echo
echo "[2] Meminta IP reservasi dari DHCP:"
udhcpc -i "$INTERFACE" -n -q

if [ $? -ne 0 ]; then
    echo "ERROR: Gagal memperoleh lease DHCP."
    echo "Periksa DHCP server Tengen dan relay Jichi."
    exit 1
fi

echo
echo "[3] Alamat IP client:"
ip -4 -br addr show "$INTERFACE"

CURRENT_IP=$(ip -4 -o addr show "$INTERFACE" | awk '{print $4}' | cut -d/ -f1)

if [ "$CURRENT_IP" != "$EXPECTED_IP" ]; then
    echo "ERROR: IP tidak sesuai dengan reservasi."
    echo "IP yang diharapkan: $EXPECTED_IP"
    echo "IP yang diperoleh: $CURRENT_IP"
    exit 1
fi

echo
echo "[4] Routing client:"
ip route

CURRENT_GATEWAY=$(ip route | awk '$1 == "default" {print $3; exit}')

if [ "$CURRENT_GATEWAY" != "$EXPECTED_GATEWAY" ]; then
    echo "PERINGATAN: Gateway tidak sesuai."
    echo "Gateway yang diharapkan: $EXPECTED_GATEWAY"
    echo "Gateway yang ditemukan: $CURRENT_GATEWAY"
    exit 1
fi

echo
echo "BERHASIL: IP reservasi dan gateway sesuai."
```

Berikan izin eksekusi:

```bash
chmod +x /root/soal6-client.sh
```

**Cara menjalankan script**

```bash
/root/soal6-client.sh
```

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/8ff1d3f8-f4d9-4ad2-89fc-fc3d2cd0b3d9" />

**Fungsi:** meminta lease DHCP melalui interface `eth0`, memeriksa IP yang diperoleh, dan memverifikasi gateway. Pengujian dinyatakan berhasil jika Kugisaki memperoleh IP `192.225.3.99` dan gateway `192.225.3.1`.

####  Urutan Menjalankan Script untuk Demonstrasi

Script dijalankan melalui console masing-masing perangkat dengan urutan berikut:

1. **Jichi:** jalankan `/root/soal6-relay.sh` untuk memeriksa serta memastikan DHCP relay aktif.
2. **Kugisaki:** jalankan `/root/soal6-client.sh` untuk meminta IP reservasi dan memverifikasi alamat IP serta gateway.

---
### Soal 7
Konfigurasi DHCP Server dan DHCP Relay

Konfigurasikan DHCP server pada Tengen untuk membagikan alamat IP kepada client Divisi A dan Divisi B melalui DHCP relay pada Jichi. Atur rentang IP, gateway, DNS, domain pencarian, serta static lease untuk Kugisaki dengan IP `192.225.3.99`. Lakukan pengujian untuk memastikan delapan client memperoleh IP sesuai subnet dan konfigurasi jaringan yang ditentukan.

### Langkah Pengerjaan

#### Langkah 1 — Memeriksa IP dan Routing Tengen

**Console perangkat: Tengen**

Jalankan perintah berikut:

```bash
ip -br addr
ip route
```

**Hasil yang diharapkan:** interface `eth0` memiliki IP `192.225.4.10/24` dan default gateway `192.225.4.1`.

**IP dan Routing Tengen**

<img width="959" height="108" alt="IP Tengen dan routing soal7" src="https://github.com/user-attachments/assets/a6cdd139-7688-47d3-86e4-513987ecaa42" />

#### Langkah 2 — Memeriksa Konfigurasi DHCP Server

**Console perangkat: Tengen**

Periksa konfigurasi DHCP menggunakan perintah:

```bash
cat /etc/dhcp/dhcpd.conf
```

**Hasil yang diharapkan:** konfigurasi mencakup subnet Divisi A dan B, rentang IP dinamis, gateway, DNS `192.225.1.2` dan `192.225.1.3`, serta static lease Kugisaki dengan IP `192.225.3.99`.

**Konfigurasi DHCP Server**

<img width="960" height="516" alt="image" src="https://github.com/user-attachments/assets/345b6909-c084-4e61-ad88-f5f46f2b6b3e" />

#### Langkah 3 — Memvalidasi dan Memeriksa Status DHCP Server

**Console perangkat: Tengen**

Validasi konfigurasi:

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

Periksa status layanan:

```bash
service isc-dhcp-server status
```

**Hasil yang diharapkan:** konfigurasi valid dan layanan DHCP server berstatus berjalan.

**Validasi dan Status DHCP Server**

<img width="960" height="516" alt="Konfigurasi DHCP server soal7" src="https://github.com/user-attachments/assets/bdc0908b-0080-4e42-9769-eb1d2398b1aa" />


#### Langkah 4 — Memeriksa DHCP Relay

**Console perangkat: Jichi**

Periksa proses DHCP relay:

```bash
ps aux | grep '[d]hcrelay'
```

Jika belum ada proses relay, jalankan:

```bash
dhcrelay -d -i eth2 -i eth3 -i eth4 192.225.4.10
```

Biarkan terminal tetap terbuka selama pengujian client.

**Hasil yang diharapkan:** DHCP relay berjalan dan meneruskan permintaan client menuju server Tengen `192.225.4.10`.

**DHCP Relay pada Jichi**

<img width="960" height="516" alt="DHCP relay di Jichi soal 7" src="https://github.com/user-attachments/assets/79912c3c-3505-4062-91af-6c9dd475e121" />

#### Langkah 5 — Menguji Pemberian IP pada Client

**Console perangkat:** Itadori, Fushiguro, Zenin, Okkotsu, Ino, Kusakabe, Miwa, dan Kugisaki.

Jalankan perintah berikut pada setiap client:

```bash
udhcpc -i eth0 -n -q
```

**Hasil aktual yang diperoleh:**

| Client | IP yang diperoleh |
|---|---|
| Itadori | `192.225.2.12` |
| Fushiguro | `192.225.2.11` |
| Zenin | `192.225.2.13` |
| Okkotsu | `192.225.2.10` |
| Ino | `192.225.3.13` |
| Kusakabe | `192.225.3.12` |
| Miwa | `192.225.3.11` |
| Kugisaki | `192.225.3.99` |

**Hasil yang diharapkan:** seluruh client memperoleh IP sesuai subnetnya dari DHCP server Tengen. Kugisaki memperoleh IP reservasi `192.225.3.99`.

**Screenshot dan keterangannya:**

- **DHCP Client Divisi A.** Tampilkan hasil pemberian IP Itadori, Fushiguro, Zenin, dan Okkotsu.
  
  1. Itadori
     
<img width="960" height="516" alt="Itadori soal 7" src="https://github.com/user-attachments/assets/57b91fcd-c48b-4a32-b2c3-9a3d6f3311c0" />

  2. Fushiguro
     
<img width="960" height="516" alt="Fushiguro soal7" src="https://github.com/user-attachments/assets/3c40b0f1-e03e-441c-b329-7ba859af2814" />

  3. Zenin
     
<img width="960" height="516" alt="Zenin soal7" src="https://github.com/user-attachments/assets/245203ea-083e-4015-9e65-da187ffd07e7" />

  4. Okkotsu
     
<img width="960" height="516" alt="okkotsu soal 7" src="https://github.com/user-attachments/assets/feda94a6-2112-4bd2-a616-8b38bba82ace" />

- **SS 7-06 — DHCP Client Divisi B.** Tampilkan hasil pemberian IP Ino, Kusakabe, Miwa, dan Kugisaki.
  
  1. Ino
     
<img width="960" height="516" alt="Ino  soal7" src="https://github.com/user-attachments/assets/ac41a2fb-90c3-49e4-bc14-8eb77b1821b4" />

  2. Kusakabe
     
<img width="960" height="516" alt="Kusakabe soal7" src="https://github.com/user-attachments/assets/7c380883-f202-47c5-8567-f613e7faf33b" />

  3. Miwa
     
<img width="960" height="516" alt="Miwa soal 7" src="https://github.com/user-attachments/assets/38e811f5-e4f5-446d-a311-0db1da4ce746" />

  4. Kugisaki
     
<img width="960" height="516" alt="Kugisaki soal7" src="https://github.com/user-attachments/assets/fc71a7a1-b43c-4693-bf1c-fcfc55c17240" />


#### Langkah 6 — Memverifikasi Gateway, DNS, dan Domain Pencarian

**Console perangkat: Okkotsu**

Periksa routing dan alamat IP:

```bash
ip route
ip -br addr
```

Periksa DNS dan domain pencarian:

```bash
cat /etc/resolv.conf
```

**Hasil aktual yang diperoleh:** Okkotsu menggunakan IP `192.225.2.10/24`, gateway `192.225.2.1`, domain pencarian `K28.com`, serta DNS `192.225.1.2` dan `192.225.1.3`.

**Verifikasi Gateway, DNS, dan Domain Pencarian**

<img width="960" height="516" alt="image" src="https://github.com/user-attachments/assets/42d1b8cd-0d36-4c14-831d-0dc9f72a942d" />

#### Langkah 7 — Menguji Konektivitas Gateway

**Console perangkat: Kugisaki**

Jalankan perintah berikut:

```bash
ping -c 4 192.225.3.1
```

**Hasil aktual yang diperoleh:**

```text
4 packets transmitted, 4 received, 0% packet loss
```

**Hasil yang diharapkan:** seluruh paket berhasil diterima dari gateway Jichi `192.225.3.1`.

**Pengujian Konektivitas Gateway**

<img width="960" height="516" alt="Ping gateway berhasil soal 7" src="https://github.com/user-attachments/assets/5d5e0831-df6e-4d39-83b3-6f7a053fde92" />

### Catatan Pengujian Ulang

Perintah pemeriksaan konfigurasi, status layanan, alamat IP, routing, dan DNS dapat dijalankan berulang kali. Sebelum menjalankan DHCP relay, periksa prosesnya menggunakan `ps aux | grep '[d]hcrelay'` dan jangan menjalankan relay baru jika proses sebelumnya masih aktif. Jika DHCP server belum berjalan, periksa validitas konfigurasi terlebih dahulu sebelum menjalankan `service isc-dhcp-server start`, lalu ulangi pengujian client setelah relay aktif.

### Kesimpulan

Konfigurasi DHCP server pada Tengen dan DHCP relay pada Jichi berhasil diterapkan sehingga delapan client memperoleh alamat IP sesuai subnet masing-masing. Static lease Kugisaki berhasil memberikan IP `192.225.3.99`, sedangkan pemeriksaan Okkotsu menunjukkan konfigurasi gateway, subnet mask, DNS, dan domain pencarian sesuai hasil yang diharapkan. Pengujian konektivitas Kugisaki ke gateway berhasil dengan `0% packet loss`.

### Otomatisasi Pengujian DHCP Server dan DHCP Relay Menggunakan Script

#### Script DHCP Server pada Tengen

**Cara membuat script**

Pada console Tengen, buat file `/root/soal7_server.sh` menggunakan perintah:

```bash
#!/bin/bash
set -eu

echo "===== SOAL 7: DHCP SERVER TENGEN ====="

if [ ! -f /etc/dhcp/dhcpd.conf ]; then
    echo "[GAGAL] File konfigurasi DHCP tidak ditemukan."
    exit 1
fi

echo "[1/3] Memeriksa konfigurasi DHCP..."
dhcpd -t -cf /etc/dhcp/dhcpd.conf

echo "[2/3] Memastikan layanan DHCP aktif..."
service isc-dhcp-server start

echo "[3/3] Status layanan DHCP:"
service isc-dhcp-server status || true

echo
echo "===== KONFIGURASI DHCP SELESAI DIPERIKSA ====="
```

Berikan izin eksekusi:

```bash
chmod +x /root/soal7_server.sh
```

**Cara menjalankan script**

```bash
/root/soal7_server.sh
```

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/571624a7-5023-4dbc-822b-72c8c8e73a3f" />

**Fungsi:** memeriksa keberadaan file konfigurasi DHCP, memvalidasi konfigurasi menggunakan `dhcpd -t`, memastikan layanan DHCP server berjalan, dan menampilkan status layanan.

#### Script DHCP Relay pada Jichi

**Cara membuat script**

Pada console Jichi, buat file `/root/soal7-relay.sh` menggunakan perintah:

```bash
#!/bin/bash
#!/bin/bash
set -eu

echo "===== SOAL 7: DHCP RELAY JICHI ====="

if ! command -v dhcrelay >/dev/null 2>&1; then
    echo "[GAGAL] dhcrelay belum terpasang."
    echo "Pasang isc-dhcp-relay terlebih dahulu."
    exit 1
fi

if pgrep -x dhcrelay >/dev/null 2>&1; then
    echo "[INFO] DHCP Relay sudah berjalan."
    echo "Tidak menjalankan relay kedua."
    pgrep -af dhcrelay || true
    exit 0
fi

echo "[INFO] Menjalankan DHCP Relay menuju 192.225.4.10..."
echo "[INFO] Interface: eth2, eth3, eth4"
echo "[INFO] Tekan Ctrl+C untuk menghentikan relay."

exec dhcrelay -d -i eth2 -i eth3 -i eth4 192.225.4.10
```

Berikan izin eksekusi:

```bash
chmod +x /root/soal7-relay.sh
```

**Cara menjalankan script**

```bash
/root/soal7-relay.sh
```

**Fungsi:** memeriksa proses DHCP relay pada Jichi dan menjalankannya jika belum aktif. Relay menggunakan interface `eth2`, `eth3`, dan `eth4` agar permintaan DHCP dari Divisi A dan Divisi B dapat diteruskan ke server Tengen melalui `192.225.4.10`. Relay berjalan di foreground sehingga pesan proses dapat diamati selama pengujian.

#### Script Pengujian DHCP Client pada Divisi A dan Divisi B

**Cara membuat script**

Pada console masing-masing klien, buat file `/root/soal7_klien.sh` menggunakan perintah:

```bash
#!/bin/sh
set -eu

echo "===== SOAL 7: PENGUJIAN DHCP KLIEN ====="

if ! command -v udhcpc >/dev/null 2>&1; then
    echo "[GAGAL] Perintah udhcpc tidak tersedia."
    exit 1
fi

echo "[1/3] Meminta alamat IP dari DHCP Server..."
udhcpc -i eth0 -n -q

echo
echo "[2/3] Alamat IP klien:"
ip -br addr show eth0

echo
echo "[3/3] Informasi gateway dan DNS:"
ip route
cat /etc/resolv.conf

IP=$(ip -4 -o addr show dev eth0 | awk '{print $4}' | cut -d/ -f1)

case "$IP" in
    192.225.2.*)
        GATEWAY="192.225.2.1"
        ;;
    192.225.3.*)
        GATEWAY="192.225.3.1"
        ;;
    *)
        echo
        echo "[PERINGATAN] IP tidak berada pada subnet Divisi A/B yang diharapkan: $IP"
        exit 1
        ;;
esac

echo
echo "===== PENGUJIAN GATEWAY $GATEWAY ====="
ping -c 4 "$GATEWAY"

echo
echo "===== PENGUJIAN KLIEN SELESAI ====="
```

Berikan izin eksekusi:

```bash
chmod +x /root/soal7_klien.sh
```

**Cara menjalankan script**

```bash
/root/soal7_klien.sh
```
<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/b63439af-5a80-472f-bcab-7a8bc7334707" />

Jalankan script pada setiap klien: Itadori, Fushiguro, Zenin, Okkotsu, Ino, Kusakabe, Miwa, dan Kugisaki.

**Fungsi:** meminta alamat IP melalui DHCP, menampilkan alamat IP dan routing, memeriksa kesesuaian gateway berdasarkan subnet klien, menampilkan konfigurasi DNS, serta menguji koneksi ke gateway menggunakan `ping`.

#### Script Verifikasi DHCP Server pada Tengen

**Cara membuat script**

Pada console Tengen, buat file `/root/soal7_cek_server.sh` menggunakan perintah:

```bash
#!/bin/bash
set -u

echo "===== SOAL 7: VERIFIKASI DHCP SERVER ====="

echo
echo "[1] Alamat IP Tengen:"
ip -br addr

echo
echo "[2] Routing Tengen:"
ip route

echo
echo "[3] Validasi konfigurasi DHCP:"
dhcpd -t -cf /etc/dhcp/dhcpd.conf

echo
echo "[4] Status DHCP Server:"
service isc-dhcp-server status || true

echo
echo "[5] Daftar lease DHCP:"
if [ -f /var/lib/dhcp/dhcpd.leases ]; then
    cat /var/lib/dhcp/dhcpd.leases
else
    echo "File lease belum tersedia."
fi

echo
echo "===== VERIFIKASI SELESAI ====="
```

Berikan izin eksekusi:

```bash
chmod +x /root/soal7_cek_server.sh
```

**Cara menjalankan script**

```bash
/root/soal7_cek_server.sh
```

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/fde89e87-89fd-4665-aa32-5a47328b82fe" />

**Fungsi:** menampilkan alamat IP server, routing, daftar lease yang tercatat, dan status layanan DHCP server untuk membantu verifikasi hasil pengujian.

#### Urutan Menjalankan Script untuk 

Script dijalankan melalui console masing-masing perangkat dengan urutan berikut:

1. **Tengen:** jalankan `/root/soal7_server.sh` untuk memvalidasi konfigurasi dan memastikan DHCP server aktif.
2. **Jichi:** jalankan `/root/soal7_relay.sh` untuk memastikan DHCP relay berjalan. Biarkan terminal tetap terbuka selama pengujian.
3. **Klien Divisi A dan Divisi B:** jalankan `/root/soal7_klien.sh` pada setiap klien untuk meminta alamat IP, memeriksa gateway, dan menguji koneksi.
4. **Tengen:** jalankan `/root/soal7_cek_server.sh` untuk memeriksa lease yang tercatat pada DHCP server.

Script ini dijalankan pada perangkat masing-masing, bukan seluruhnya dari satu console. Jika DHCP relay sudah berjalan, script tidak membuat proses relay baru. Untuk menghindari gangguan, jangan menghentikan relay selama pengujian klien berlangsung.

---

# Soal 8
Packet Capture Proses DHCP Menggunakan tcpdump

Lakukan packet capture saat client Network 2 atau Network 3 meminta lease baru. Gunakan `tcpdump` pada Tengen untuk membuktikan urutan DHCPDISCOVER → DHCPOFFER → DHCPREQUEST → DHCPACK, serta mengidentifikasi alamat server, alamat IP client, lease time, dan `giaddr` yang sesuai dengan interface Jichi.

## Langkah Pengerjaan

### Langkah 1 — Memastikan DHCP Relay Aktif

**Konsol perangkat: Jichi**

Periksa proses DHCP Relay dan alamat interface menggunakan perintah:

```bash
pgrep -a dhcrelay; ip -br addr | grep -E "eth[2-4]"
```

Jika relay belum berjalan, jalankan:

```bash
dhcrelay -d -i eth2 -i eth3 -i eth4 192.225.4.10
```

Pastikan `eth2` terhubung ke Network 2, `eth3` ke Network 3, dan `eth4` ke Data Center. Biarkan relay aktif selama pengujian dan jangan menjalankan proses relay ganda.

**DHCP Relay Aktif di Jichi**

<img width="960" height="516" alt="Soal8 Relay aktif di Jichi" src="https://github.com/user-attachments/assets/8b0e66c6-4962-4bdc-93f8-9cd76bbfd322" />

### Langkah 2 — Memeriksa DHCP Server

**Konsol perangkat: Tengen**

Periksa status DHCP Server:

```bash
service isc-dhcp-server status
```

Periksa IP server dan rentang alamat yang tersedia:

```bash
ip -br addr show eth0
grep -n "range" /etc/dhcp/dhcpd.conf
```

Hasil yang diharapkan: DHCP Server aktif dan interface `eth0` memiliki alamat `192.225.4.10/24`.

**DHCP Server Aktif di Tengen**

<img width="960" height="516" alt="Soal8 DHCP server aktif di Tengen  " src="https://github.com/user-attachments/assets/eabb4325-ee9a-4c80-b03d-5d8e069015e3" />

### Langkah 3 — Menjalankan Packet Capture

**Konsol perangkat: Tengen**

Jalankan script yang sudah dibuat:

```bash
bash /root/soal8.sh
```

Tunggu hingga muncul instruksi:

```text
>>> SEKARANG jalankan udhcpc di client (maks 90 detik) <<<
```

Instruksi tersebut menandakan bahwa client harus segera meminta lease baru agar paket DHCP tertangkap.

### Langkah 4 — Meminta Lease Baru dari Itadori

**Konsol perangkat: Itadori**

Setelah instruksi muncul pada Tengen, jalankan:

```bash
ip addr flush dev eth0; udhcpc -i eth0 -n -q; ip -4 -br addr show eth0; ip route
```

Perintah ini menghapus IP IPv4 sebelumnya, meminta lease DHCP baru, lalu menampilkan alamat IP dan routing client.

Hasil aktual:

```text
lease of 192.225.2.10 obtained from 192.225.4.10
```

Itadori berhasil memperoleh IP `192.225.2.10` dari DHCP Server `192.225.4.10`. Alamat tersebut termasuk Pool 1 Network 2, yaitu `192.225.2.10–192.225.2.35`.

**Itadori Berhasil Mendapatkan Lease DHCP**

<img width="960" height="516" alt="Soal8 SS 8-03 (Itadori)" src="https://github.com/user-attachments/assets/551519be-b031-47e7-ac39-0e26ee76fca3" />

### Langkah 5 — Memeriksa Urutan Paket DHCP

**Konsol perangkat: Tengen**

Hasil packet capture yang diperoleh:

```text
=== URUTAN DHCP ===
192.225.4.1.67 > 192.225.4.10.67: [udp sum ok] BOOTP/DHCP, Request from 02:42:33:e9:7e:00, length 300, hops 1, xid 0x27a4ce0e, Flags [none] (0x0000)
DHCP-Message (53), length 1: Discover
192.225.4.10.67 > 192.225.2.1.67: [udp sum ok] BOOTP/DHCP, Reply, length 300, hops 1, xid 0x27a4ce0e, Flags [none] (0x0000)
DHCP-Message (53), length 1: Offer
192.225.4.1.67 > 192.225.4.10.67: [udp sum ok] BOOTP/DHCP, Request from 02:42:33:e9:7e:00, length 300, hops 1, xid 0x27a4ce0e, secs 1, Flags [none] (0x0000)
DHCP-Message (53), length 1: Request
192.225.4.10.67 > 192.225.2.1.67: [udp sum ok] BOOTP/DHCP, Reply, length 300, hops 1, xid 0x27a4ce0e, secs 1, Flags [none] (0x0000)
DHCP-Message (53), length 1: ACK
```

Capture menunjukkan urutan DHCPDISCOVER, DHCPOFFER, DHCPREQUEST, dan DHCPACK. Keempat pesan memiliki transaction ID (`xid`) yang sama, yaitu `0x27a4ce0e`.

**Urutan Paket DHCP**

<img width="960" height="516" alt="soal8 Bukti mentah dari file capture" src="https://github.com/user-attachments/assets/820d6434-6770-4aea-9ffa-0380a278297b" />

### Langkah 6 — Mengidentifikasi Field Penting

**Konsol perangkat: Tengen**

Ringkasan hasil capture:

```text
=== RINGKASAN ===
Server-ID : 192.225.4.10
Your-IP   : 192.225.2.10
Lease     : 600 detik
giaddr    : 192.225.2.1
BERHASIL: giaddr 192.225.2.1 sesuai interface Jichi
```

| Parameter | Hasil |
|---|---|
| DHCP Server | `192.225.4.10` |
| IP client | `192.225.2.10` |
| Lease time | 600 detik |
| `giaddr` | `192.225.2.1` |
| Interface Jichi | `eth2` |

Nilai `giaddr` `192.225.2.1` sesuai dengan interface `eth2` pada Jichi yang terhubung ke Network 2.

**Ringkasan Field DHCP dan Verifikasi giaddr**

<img width="960" height="516" alt="Soal8 SS 8-04 (Tengen)" src="https://github.com/user-attachments/assets/af40e61c-c324-453d-984f-5a260eabeae4" />

### Langkah 7 — Memeriksa File Packet Capture

**Konsol perangkat: Tengen**

Untuk membaca kembali paket yang tersimpan, jalankan:

```bash
tcpdump -r /root/soal8.pcap -n -vvv 2>/dev/null | grep -E "BOOTP/DHCP|DHCP-Message|Gateway-IP|Your-IP|Server-ID|Lease-Time"
```

Perintah ini membaca file `/root/soal8.pcap` dan menampilkan pesan DHCP beserta field penting yang tersedia dalam hasil capture.

**Verifikasi File Packet Capture**

## Otomatisasi Pengujian Packet Capture DHCP Menggunakan Script

isi script soal8.sh

```
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
```

### Script Packet Capture pada Tengen

**Cara menjalankan script**

Pada konsol Tengen, jalankan:

```bash
bash /root/soal8.sh
```

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/d96d8d81-bf39-4f68-9853-c16226c33f40" />

Script digunakan untuk menangkap paket DHCP, menampilkan urutan pesan, serta merangkum alamat server, IP client, lease time, dan `giaddr`.

**Cara menjalankan pengujian client**

Saat Tengen menampilkan instruksi untuk meminta lease, jalankan pada konsol Itadori:

```bash
ip addr flush dev eth0; udhcpc -i eth0 -n -q; ip -4 -br addr show eth0; ip route
```

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/92938972-2aaf-4306-8637-7fb09c57c1f1" />

Setelah pengujian selesai, periksa hasil capture pada Tengen.

**Catatan:** Script menggunakan batas waktu maksimal 90 detik sesuai instruksi terminal. Client harus meminta lease ketika proses capture masih aktif.

### Urutan Script untuk 

1. **Jichi:** periksa DHCP Relay menggunakan `pgrep -a dhcrelay; ip -br addr | grep -E "eth[2-4]"`.
2. **Tengen:** periksa DHCP Server menggunakan `service isc-dhcp-server status`.
3. **Tengen:** jalankan `bash /root/soal8.sh` dan tunggu instruksi.

## Kesimpulan

Packet capture pada Tengen berhasil menunjukkan urutan DHCPDISCOVER → DHCPOFFER → DHCPREQUEST → DHCPACK dengan transaction ID `0x27a4ce0e`. Itadori memperoleh IP `192.225.2.10` dari server `192.225.4.10` dengan lease time 600 detik. Nilai `giaddr` sebesar `192.225.2.1` sesuai dengan interface `eth2` pada Jichi. Hasil ini

---
# SOAL 9 
Pemulihan DHCP Relay pada Gangguan Jaringan

## Deskripsi Tugas

Sebuah gangguan memutus jalur relay sehingga permintaan DHCP dari client tidak sampai ke Data Center. Pengujian dilakukan dengan menghentikan DHCP Relay pada Jichi, memaksa client meminta lease baru, mencatat gejala kegagalan, kemudian memulihkan relay dan mengulangi permintaan DHCP. Keberhasilan dibuktikan dengan client memperoleh alamat IP dari pool jaringan yang benar serta gateway yang sama seperti sebelumnya.

## Langkah Pengerjaan

### 1. Memastikan DHCP Server pada Tengen Berjalan

**Perangkat: Tengen (DHCP Server/Data Center)**

Sebelum membuat simulasi gangguan, pastikan DHCP Server masih berjalan. Hal ini dilakukan agar kegagalan yang terjadi benar-benar berasal dari jalur relay, bukan karena DHCP Server berhenti.

Jalankan perintah berikut pada terminal Tengen:

```bash
systemctl status isc-dhcp-server --no-pager
```

**Hasil yang diharapkan:**

Status service menunjukkan `active (running)`, yang berarti DHCP Server sedang berjalan.

Jika service sudah berjalan, lanjutkan ke tahap berikutnya.
   
### 2. Menghentikan DHCP Relay pada Jichi

**Perangkat: Jichi (Router/Relay)**

DHCP Relay bertugas meneruskan permintaan DHCP dari client di Network 2 dan Network 3 menuju DHCP Server pada Tengen. Untuk membuat simulasi gangguan, proses relay dihentikan sementara.

Periksa proses relay yang sedang berjalan:

```bash
pgrep -a dhcrelay
```

Jika proses ditemukan, hentikan DHCP Relay menggunakan:

```bash
pkill dhcrelay
```

Kemudian periksa kembali prosesnya:

```bash
pgrep -a dhcrelay
```

**Hasil yang diharapkan:**

Tidak ada proses `dhcrelay` yang ditampilkan setelah proses dihentikan. Dengan demikian, permintaan DHCP dari client tidak dapat diteruskan melalui relay menuju server.


### 3. Menguji Client Saat DHCP Relay Mengalami Gangguan

**Perangkat: Itadori (Client Network 2)**

Setelah DHCP Relay dihentikan, client dipaksa menghapus konfigurasi IP pada interface `eth0` dan meminta lease baru. Langkah ini dilakukan untuk menguji apakah client masih dapat memperoleh alamat IP ketika jalur relay terputus.

Jalankan perintah berikut pada terminal Itadori:

```bash
ip addr flush dev eth0
udhcpc -i eth0 -n -q
```

Perintah pertama menghapus alamat IP pada interface `eth0`, sedangkan perintah kedua meminta alamat IP baru melalui DHCP.

**Hasil pengujian:**

Karena DHCP Relay sedang berhenti, permintaan DHCP dari Itadori seharusnya tidak sampai ke Tengen. Client dapat menampilkan pesan `broadcasting discover` tanpa memperoleh lease, kemudian proses permintaan berakhir tanpa alamat IP baru.

Gejala tersebut menunjukkan bahwa client tidak memperoleh lease selama jalur relay terputus. Catat hasil terminal yang benar-benar muncul saat pengujian.


### 4. Memulihkan DHCP Relay pada Jichi

**Perangkat: Jichi (Router/Relay)**

Setelah gejala gangguan dicatat, DHCP Relay dijalankan kembali agar permintaan DHCP client dapat diteruskan ke server.

Jalankan perintah berikut pada terminal Jichi:

```bash
dhcrelay -i eth2 -i eth3 -i eth4 192.225.4.10
```

Keterangan:
- `eth2` terhubung ke Network 2.
- `eth3` terhubung ke Network 3.
- `eth4` terhubung ke jaringan Data Center.
- `192.225.4.10` merupakan alamat DHCP Server pada Tengen.

Perintah ini dapat berjalan di foreground dan mempertahankan terminal tetap aktif. **Jangan tutup terminal tersebut selama pengujian.** Jika perintah sudah berjalan, gunakan terminal Jichi lain untuk melakukan pemeriksaan.

Periksa proses relay dari terminal Jichi lain:

```bash
pgrep -a dhcrelay
```

**Hasil yang diharapkan:**

Proses `dhcrelay` kembali ditemukan dan meneruskan permintaan DHCP dari Network 2 maupun Network 3 menuju DHCP Server Tengen.

### 5. Meminta Lease Baru Setelah Relay Pulih

**Perangkat: Itadori (Client Network 2)**

Setelah DHCP Relay aktif kembali, ulangi permintaan DHCP pada Itadori. Langkah ini digunakan untuk membuktikan bahwa client dapat memperoleh alamat IP setelah jalur komunikasi dipulihkan.

Jalankan:

```bash
ip addr flush dev eth0
udhcpc -i eth0 -n -q
```

**Hasil pengujian aktual:**

```text
udhcpc: started, v1.37.0
udhcpc: broadcasting discover
udhcpc: broadcasting select for 192.225.2.13, server 192.225.4.10
udhcpc: lease of 192.225.2.13 obtained from 192.225.4.10, lease time 595
```
<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/0916a1a8-8153-462c-b303-01648e827168" />

Output menunjukkan bahwa Itadori berhasil memperoleh lease baru `192.225.2.13` dari DHCP Server `192.225.4.10` dengan lease time 595 detik.

### 6. Memeriksa Alamat IP dan Gateway Client

**Perangkat: Itadori (Client Network 2)**

Setelah lease berhasil diperoleh, periksa alamat IP dan routing untuk memastikan client berada pada jaringan yang benar dan menggunakan gateway semula.

Jalankan:

```bash
ip -4 -br addr show eth0
ip route
```

**Hasil pengujian aktual:**

```text
eth0             UNKNOWN        192.225.2.13/24
default via 192.225.2.1 dev eth0 metric 85793
192.225.2.0/24 dev eth0 proto kernel scope link src 192.225.2.13
```

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/0dd7670d-4409-4c1c-aecf-74dcccf9d3a5" />

Berdasarkan hasil tersebut:
- **Alamat IP client:** `192.225.2.13/24`.
- **Jaringan client:** `192.225.2.0/24` atau Network 2.
- **Gateway:** `192.225.2.1`.
- **DHCP Server:** `192.225.4.10`.
- **Status:** Berhasil memperoleh lease baru setelah relay dipulihkan.

Alamat `192.225.2.13` berada dalam pool Network 2, yaitu `192.225.2.10–192.225.2.35`. Gateway `192.225.2.1` juga sesuai dengan konfigurasi jaringan Itadori.


### 7. Memastikan DHCP Server Tetap Berjalan

**Perangkat: Tengen (DHCP Server/Data Center)**

Sebagai pemeriksaan akhir, pastikan DHCP Server tetap berjalan setelah pengujian gangguan dan pemulihan relay.

Jalankan:

```bash
systemctl status isc-dhcp-server --no-pager
```

Pastikan status service menunjukkan `active (running)`. Pool Network 2 yang digunakan dalam pengujian mencakup alamat `192.225.2.10–192.225.2.35`, sehingga alamat `192.225.2.13` yang diperoleh Itadori termasuk dalam rentang yang benar.


## Kesimpulan

Pengujian Soal 9 dilakukan dengan menghentikan DHCP Relay pada Jichi, menguji permintaan lease baru dari client Itadori, kemudian mengaktifkan kembali relay dan mengulangi permintaan DHCP. Saat relay berhenti, permintaan DHCP seharusnya gagal memperoleh lease karena jalur menuju Data Center terputus. Setelah relay dipulihkan, Itadori berhasil memperoleh alamat IP `192.225.2.13/24` dari DHCP Server `192.225.4.10`, dengan gateway `192.225.2.1`. Alamat IP tersebut berada dalam pool Network 2 yang sesuai, sehingga pemulihan jalur relay berhasil dibuktikan.


## Otomatisasi Pengujian Menggunakan Script

Setelah pengujian manual dilakukan, proses gangguan dan pemulihan dapat dijalankan menggunakan script yang telah disiapkan. Bagian ini menggunakan script yang sama, tanpa mengubah isi script.

### 1. Memulihkan DHCP Server pada Tengen

**Perangkat: Tengen**

isi script:

```
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
```

Jalankan:

```bash
bash /root/soal9-pulihkan-dhcp.sh
```

Script digunakan untuk memulihkan dan memeriksa service ISC DHCP Server serta menampilkan rentang pool yang dikonfigurasi.

**Hasil aktual:** Status DHCP Server menunjukkan `dhcpd is running`, dan rentang pool Network 2 serta Network 3 ditampilkan.

**SS  Otomatisasi Pemulihan DHCP Server**

<img width="960" height="516" alt="image" src="https://github.com/user-attachments/assets/7ed26197-5132-4ced-8e58-5dbbb1c8c6d8" />

### 2. Menjalankan Simulasi Gangguan pada Jichi

**Perangkat: Jichi**

isi script:

```
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
```
Jalankan:

```bash
bash /root/soal9-jichi.sh stop
```

Script menghentikan DHCP Relay untuk mensimulasikan gangguan. Output yang diharapkan adalah:

```text
OK: relay dihentikan.
```

**SS Script Penghentian DHCP Relay**

<img width="960" height="516" alt="image" src="https://github.com/user-attachments/assets/9307b20d-5366-4a60-a4b7-46b18cb81178" />

### 3. Menguji Client dalam Kondisi Gangguan

isi script:

```
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
```
**Perangkat: Itadori**

Jalankan:

```bash
bash /root/soal9-client.sh gangguan
```

Script menjalankan pengujian DHCP saat relay berhenti dan mencatat gejala kegagalan yang ditemukan.

**SS  Script Pengujian Client Saat Gangguan**

<img width="960" height="516" alt="image" src="https://github.com/user-attachments/assets/2408514e-33dd-4a0f-89e0-802631db72a5" />

### 4. Memulihkan DHCP Relay pada Jichi

**Perangkat: Jichi**

Jalankan:

```bash
bash /root/soal9-jichi.sh start
bash /root/soal9-nat-jichi.sh
```

Script mengaktifkan kembali DHCP Relay. Output yang diharapkan adalah:

```text
OK: relay pulih dan berjalan.
```

**SS  Script Pemulihan DHCP Relay**

<img width="960" height="516" alt="image" src="https://github.com/user-attachments/assets/ca0e280b-8ef3-47b9-a540-e7283638cbc0" />

### 5. Menguji Client Setelah Pemulihan

**Perangkat: Itadori**

Jalankan:

```bash
bash /root/soal9-client.sh pulih
```

**Hasil aktual:**

```text
IP diperoleh : 192.225.2.13 (pool benar: ya)
Gateway      : 192.225.2.1 (diharapkan 192.225.2.1)
BERHASIL: client kembali memperoleh alamat dari pool yang benar dengan gateway semula.
```

Hasil tersebut membuktikan bahwa client kembali mendapatkan alamat dari pool yang benar dan menggunakan gateway semula setelah DHCP Relay dipulihkan.

**SS  Hasil Otomatisasi Pemulihan Client**

<img width="960" height="516" alt="image" src="https://github.com/user-attachments/assets/01b4b7b7-702b-40a3-91ed-6208844a5058" />

---

# SOAL 10 
Pemulihan dan Autostart Layanan DHCP Setelah Restart

### Deskripsi Tugas

Melakukan konfigurasi dan pengujian DHCP Server pada Tengen serta DHCP Relay pada Jichi secara manual. Pengujian meliputi IP, routing, status layanan, distribusi lease, gateway, DNS, dan konektivitas klien setelah restart.

### Langkah Pengerjaan

#### Langkah 1 — Memeriksa Init System Tengen

**Console perangkat: Tengen**

```bash
ps -p 1 -o comm=
```

**Hasil yang diharapkan:** output `dumb-init`, sehingga pengelolaan layanan dan autostart tidak mengandalkan `systemctl enable`.

#### Langkah 2 — Mengatur IP dan DHCP Server Tengen

**Console perangkat: Tengen**

```bash
ip link set eth0 up
ip addr flush dev eth0
ip addr add 192.225.4.10/24 dev eth0
ip route replace default via 192.225.4.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

Pastikan konfigurasi DHCP Server tersedia:

```bash
cp /root/dhcpd.conf /etc/dhcp/dhcpd.conf
sed -i 's/^INTERFACESv4=.*/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server
dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

Jalankan layanan:

```bash
service isc-dhcp-server restart
```

**Hasil yang diharapkan:** Tengen memiliki IP `192.225.4.10/24`, gateway `192.225.4.1`, dan konfigurasi DHCP lolos pemeriksaan tanpa error.

**Konfigurasi DHCP Server Tengen**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/f1b2ef7b-b46e-445e-bbd0-9647f8ca034b" />

 output `ip -br a`, `ip route`, dan pemeriksaan konfigurasi DHCP Server.

#### Langkah 3 — Mengatur Gateway dan DHCP Relay Jichi

**Console perangkat: Jichi**

```bash
for i in 0 1 2 3 4; do ip link set eth$i up; done

ip addr add 192.225.1.1/24 dev eth1
ip addr add 192.225.2.1/24 dev eth2
ip addr add 192.225.3.1/24 dev eth3
ip addr add 192.225.4.1/24 dev eth4

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

Konfigurasikan DHCP Relay:

```bash
cat > /etc/default/isc-dhcp-relay <<'EOF'
SERVERS="192.225.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
EOF
```

Terapkan konfigurasi:

```bash
service isc-dhcp-relay restart
```

**Hasil yang diharapkan:** Jichi memiliki gateway untuk Network 1–4, IPv4 forwarding aktif, dan DHCP Relay dikonfigurasi untuk interface `eth2`, `eth3`, serta `eth4`.

**Konfigurasi DHCP Relay Jichi**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/7fa36da9-8d6e-4793-9536-f8098435c890" />

 output `cat /etc/default/isc-dhcp-relay` dan `ip -br a`.

#### Langkah 4 — Memeriksa Status DHCP Server dan Relay

**Console perangkat: Tengen**

```bash
service isc-dhcp-server status
ps aux | grep '[d]hcpd'
```
<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/13243773-6346-4b6d-b963-6b79f45c8522" />

**Console perangkat: Jichi**

```bash
ps aux | grep '[d]hcrelay'
cat /proc/sys/net/ipv4/ip_forward
iptables -t nat -S | grep MASQ
```

**Hasil yang diharapkan:** proses `dhcpd` dan `dhcrelay` terdeteksi, forwarding bernilai `1`, dan rule `MASQUERADE` tersedia.

**Status Layanan DHCP**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/1884116f-2101-431e-8fb2-72825a91f0a4" />

hasil pemeriksaan proses dan layanan pada Tengen dan Jichi.

#### Langkah 5 — Menguji DHCP Client

**Console perangkat:** seluruh klien Network 2 dan Network 3.

Jalankan pada setiap klien:

```bash
udhcpc -i eth0 -n -q
ip -4 -br addr show eth0
ip route
cat /etc/resolv.conf
```

**Hasil yang diharapkan:** klien mendapatkan IP sesuai pool, default gateway sesuai jaringan, dan DNS sesuai konfigurasi DHCP.

| Klien | Rentang IP yang diharapkan | Lease |
|---|---|---:|
| Itadori, Fushiguro | `192.225.2.10–192.225.2.35` | 600 detik |
| Zenin, Okkotsu | `192.225.2.70–192.225.2.95` | 600 detik |
| Ino, Kusakabe | `192.225.3.10–192.225.3.89` | 1800 detik |
| Miwa | `192.225.3.100–192.225.3.199` | 43200 detik |
| Kugisaki | `192.225.3.99` | 600 detik |

**Hasil DHCP Client**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/40ed0f58-7555-45d7-b23b-ba371a86ad2f" />

 hasil IP, gateway, DNS, dan lease dari setiap klien.

#### Langkah 6 — Menguji Konektivitas

**Console perangkat:** klien Network 2 dan Network 3.

```bash
ping -c 2 -W 2 $(ip route | awk '/default/ {print $3; exit}')
ping -c 2 -W 2 8.8.8.8
```

**Hasil yang diharapkan:** ping gateway berhasil dan ping `8.8.8.8` berhasil jika akses eksternal tersedia.

**Pengujian Konektivitas**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/244e67af-6465-4742-a78d-4e1d7069bc5d" />

 hasil ping gateway dan alamat eksternal dari klien.

### Kesimpulan Konfigurasi Manual

Konfigurasi manual dilakukan untuk memastikan DHCP Server, DHCP Relay, routing, dan NAT berjalan sebelum pengujian autostart. Keberhasilan harus dibuktikan melalui status proses, IP yang diperoleh klien, dan hasil pengujian konektivitas.

## Konfigurasi Otomatis Menggunakan Script

####  Membuat Script Autostart Tengen

**Console perangkat: Tengen**

Buat file `/root/soal10-tengen.sh`:

```bash
cat > /root/soal10-tengen.sh <<'EOF'
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
EOF
```

Daftarkan script sebagai autostart:

```bash
cp /root/soal10-tengen.sh /root/autostart.sh
chmod +x /root/soal10-tengen.sh /root/autostart.sh
grep -q autostart.sh /root/.bashrc || echo "bash /root/autostart.sh" >> /root/.bashrc
```

Cara menjalankan manual:

```bash
bash /root/autostart.sh
```

**Hasil yang diharapkan:** script mengatur IP Tengen, memulihkan konfigurasi DHCP Server, lalu memeriksa proses layanan.

**Output Script Tengen**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/cf9d4d71-9a58-4358-918d-4fad383c978c" />

output menjalankan `bash /root/autostart.sh` pada Tengen.

#### Membuat Script Autostart Jichi

**Console perangkat: Jichi**

Buat file `/root/soal10-jichi.sh`:

```bash
cat > /root/soal10-jichi.sh <<'EOF'
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
EOF
```

Daftarkan script sebagai autostart:

```bash
cp /root/soal10-jichi.sh /root/autostart.sh
chmod +x /root/soal10-jichi.sh /root/autostart.sh
grep -q autostart.sh /root/.bashrc || echo "bash /root/autostart.sh" >> /root/.bashrc
```

Cara menjalankan manual:

```bash
bash /root/autostart.sh
```

**Hasil yang diharapkan:** script memulihkan IP gateway Jichi, mengaktifkan forwarding dan NAT, mengatur DHCP Relay, lalu memeriksa proses relay.

**Output Script Jichi**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/69b6006e-62c4-434e-bbe9-754790830e3e" />

 output menjalankan `bash /root/autostart.sh` pada Jichi.

#### Melakukan Restart Node

**Console perangkat: GNS3**

1. Stop Tengen, Jichi, dan seluruh klien.
2. Start Tengen, kemudian Jichi dan seluruh klien.
3. Buka Console Tengen dan Jichi.
4. Tunggu sekitar 10 detik agar mekanisme autostart pada `.bashrc` berjalan.

**Hasil yang diharapkan:** layanan DHCP kembali berjalan tanpa perlu menjalankan script konfigurasi secara manual setelah console dibuka.

####  Memverifikasi Layanan Setelah Restart

**Console perangkat: Tengen**

```bash
service isc-dhcp-server status
ps aux | grep '[d]hcpd'
ip -br a
ip route
```

**Console perangkat: Jichi**

```bash
ps aux | grep '[d]hcrelay'
ip -br a
cat /proc/sys/net/ipv4/ip_forward
iptables -t nat -S | grep MASQ
```

**Hasil yang diharapkan:** proses DHCP Server dan Relay berjalan, IP serta gateway benar, forwarding bernilai `1`, dan rule NAT tersedia.

** Verifikasi Setelah Restart**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/4005718f-1989-4df0-8257-59bb7a0cf40c" />

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/66fa0d34-5424-4787-9388-b2c744622998" />

output verifikasi Tengen dan Jichi setelah restart.

#### Memeriksa Lease dan Kebijakan Pool

**Console perangkat: Tengen**

```bash
grep -E "^lease|starts|ends|hardware ethernet" /var/lib/dhcp/dhcpd.leases
grep -n "kugisaki" -A 8 /etc/dhcp/dhcpd.conf
grep "^lease" /var/lib/dhcp/dhcpd.leases | awk '{print $2}' | awk -F. '$3==2 && $4>=36 && $4<=69'
```

**Hasil yang diharapkan:** lease sesuai kebijakan pool, Kugisaki memiliki fixed address `192.225.3.99`, dan tidak ada lease di rentang `192.225.2.36–192.225.2.69`.

**Verifikasi Lease**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/fd5bcc1a-b134-425e-b60d-258730768b5c" />

output lease, konfigurasi fixed address, dan pemeriksaan rentang IP terlarang.

#### Memeriksa IP, Gateway, dan DNS Klien

**Console perangkat:** seluruh klien Network 2 dan Network 3.

```bash
udhcpc -i eth0 -n -q 2>&1 | grep "lease of"
ip -4 -br addr show eth0
ip route
cat /etc/resolv.conf
```

**Hasil yang diharapkan:** seluruh klien memperoleh IP sesuai pool, gateway sesuai jaringan, dan DNS sesuai konfigurasi DHCP.

**Verifikasi DHCP Client**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/f9fd034c-193a-4a5f-8ab3-33be9516fa65" />

output pemeriksaan IP, gateway, DNS, dan lease setiap klien.

#### Menguji Konektivitas Klien

**Console perangkat:** klien Network 2 dan Network 3.

```bash
ping -c 2 -W 2 $(ip route | awk '/default/ {print $3; exit}')
ping -c 2 -W 2 8.8.8.8
```

**Hasil yang diharapkan:** klien dapat menjangkau gateway dan alamat eksternal jika konektivitas WAN tersedia.

**Pengujian Konektivitas Setelah Restart**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/4467dea6-15a3-4260-8756-53441da795ca" />

 output ping gateway dan `8.8.8.8` dari klien.

### Catatan Pengujian Ulang

Script dapat dijalankan kembali untuk memulihkan konfigurasi. Namun, jangan mengosongkan file lease setiap kali script dijalankan karena dapat menghilangkan catatan lease sebelumnya. Autostart melalui `.bashrc` berjalan saat console dibuka, bukan otomatis pada saat node mulai berjalan tanpa console.

### Kesimpulan Konfigurasi Otomatis

Script autostart digunakan untuk memulihkan konfigurasi DHCP Server dan DHCP Relay setelah restart node. Keberhasilan ditentukan dari proses layanan yang aktif, IP klien yang sesuai, kebijakan lease yang benar, serta hasil pengujian gateway dan konektivitas eksternal.

### Urutan Demo Otomatis

1. Tengen: `bash /root/autostart.sh`.
2. Jichi: `bash /root/autostart.sh`.
3. Stop seluruh node, lalu start kembali Tengen, Jichi, dan klien.
4. Buka console Tengen dan Jichi, lalu tunggu mekanisme autostart berjalan.
5. Periksa status DHCP Server dan proses DHCP Relay.
6. Periksa lease, IP, gateway, dan DNS setiap klien.
7. Uji ping gateway dan `8.8.8.8`.

---
# Soal 11
## Konfigurasi DNS Master dan Slave menggunakan BIND9

Utahime dan Shoko membangun sistem penamaan domain agar pos tidak perlu menghafal IP mentah. BIND9 dikonfigurasi pada Utahime sebagai DNS Master dan Shoko sebagai DNS Slave untuk domain `jujutsu.k28.com`. Zona harus tersinkronisasi otomatis ke Shoko saat serial dinaikkan, dibuktikan dengan `dig` ke kedua server dari client.

### Langkah Pengerjaan

#### Langkah 1 — Memasang BIND9 di Utahime dan Shoko

**Console perangkat: Utahime dan Shoko**

```bash
apt-get update
apt-get install -y bind9 bind9-utils dnsutils
```

**Hasil yang diharapkan:** paket terpasang tanpa error. Pastikan `nameserver 192.168.122.1` terpasang di `/etc/resolv.conf` agar unduhan berhasil.

#### Langkah 2 — Mengonfigurasi Zona Master

**Console perangkat: Utahime**

```bash
mkdir -p /etc/bind/zones
nano /etc/bind/named.conf.local
```

Isi:

```conf
zone "jujutsu.k28.com" {
    type master;
    file "/etc/bind/zones/db.jujutsu.k28.com";
    allow-transfer { 192.225.1.3; };
    also-notify { 192.225.1.3; };
    notify yes;
};
```

`allow-transfer` mengizinkan Shoko mengambil zona, sedangkan `also-notify` memberi tahu Shoko saat zona berubah.

#### Langkah 3 — Membuat File Zona

**Console perangkat: Utahime**

```bash
nano /etc/bind/zones/db.jujutsu.k28.com
```

Isi:

```dns
$TTL 604800
@   IN  SOA ns1.jujutsu.k28.com. admin.jujutsu.k28.com. (
        2026101502 ; serial
        604800     ; refresh
        86400      ; retry
        2419200    ; expire
        604800 )   ; negative cache TTL
@    IN NS ns1.jujutsu.k28.com.
@    IN NS ns2.jujutsu.k28.com.
ns1  IN A 192.225.1.2
ns2  IN A 192.225.1.3
```

Validasi:

```bash
named-checkconf
named-checkzone jujutsu.k28.com /etc/bind/zones/db.jujutsu.k28.com
```

**Hasil yang diharapkan:** `named-checkzone` berakhir dengan `OK`.

** Validasi Zona**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/38ebf072-c8e8-4b4a-86c9-b64ea134cec0" />

output `named-checkconf` dan `named-checkzone`.

#### Langkah 4 — Mengonfigurasi Zona Slave

**Console perangkat: Shoko**

```bash
mkdir -p /var/cache/bind
chown bind:bind /var/cache/bind
nano /etc/bind/named.conf.local
```

Isi:

```conf
zone "jujutsu.k28.com" {
    type slave;
    masters { 192.225.1.2; };
    file "/var/cache/bind/db.jujutsu.k28.com";
};
```

Validasi dengan `named-checkconf`.

#### Langkah 5 — Menjalankan BIND9 dan Memeriksa Zone Transfer

**Console perangkat: Utahime lalu Shoko**

```bash
pgrep -a named || named -u bind
```

Di Shoko, periksa file hasil transfer:

```bash
ls -l /var/cache/bind/db.jujutsu.k28.com
```

**Hasil yang diharapkan:** file zona muncul di Shoko. Jika `named` sudah berjalan, jangan menjalankan proses kedua.

#### Langkah 6 — Query `dig` ke Master dan Slave dari Client

**Console perangkat: Itadori**

```bash
dig @192.225.1.2 jujutsu.k28.com SOA
dig @192.225.1.3 jujutsu.k28.com SOA
```

**Hasil yang diharapkan:** keduanya `status: NOERROR` dengan flag `aa` dan serial `2026101502`.

#### Langkah 7 — Menguji Sinkronisasi Serial

**Console perangkat: Utahime**

Naikkan serial menjadi `2026101503` lalu reload:

```bash
nano /etc/bind/zones/db.jujutsu.k28.com
named-checkzone jujutsu.k28.com /etc/bind/zones/db.jujutsu.k28.com
rndc reload jujutsu.k28.com || kill -HUP "$(pgrep -xo named)"
```

**Console perangkat: Itadori**

```bash
dig @192.225.1.2 jujutsu.k28.com SOA +short
dig @192.225.1.3 jujutsu.k28.com SOA +short
```

**Hasil yang diharapkan:** serial pada Master dan Slave sama-sama `2026101503`.

### Catatan Pengujian Ulang

Setiap perubahan zona harus disertai kenaikan serial, kalau tidak Slave tidak menyalin ulang. Jangan menjalankan `named -u bind` jika proses sudah ada; cukup reload.

### Kesimpulan

DNS Master (Utahime) dan Slave (Shoko) berhasil dikonfigurasi untuk `jujutsu.k28.com`. Zone transfer berjalan dan kenaikan serial pada Master otomatis tersalin ke Slave, terbukti dari query `dig` ke kedua server.

### Otomatisasi Pengujian Menggunakan Script

#### Script DNS Master pada Utahime

**Cara membuat script**

Pada console Utahime, buat file `/root/soal11_master.sh`:

```bash

#!/bin/bash
set -e

DOMAIN="jujutsu.k28.com"
SLAVE_IP="192.225.1.3"
ZONE_DIR="/etc/bind/zones"
ZONE_FILE="$ZONE_DIR/db.$DOMAIN"

# Install BIND9 jika belum tersedia
apt-get update
apt-get install -y bind9 bind9-utils dnsutils

# Buat direktori zona
mkdir -p "$ZONE_DIR"

# Konfigurasi zona Master
cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
    type master;
    file "$ZONE_FILE";
    allow-transfer { $SLAVE_IP; };
    also-notify { $SLAVE_IP; };
    notify yes;
};
EOF

# Buat file zona
cat > "$ZONE_FILE" <<EOF
\$TTL 604800
@   IN SOA ns1.$DOMAIN. admin.$DOMAIN. (
        2026101503
        604800
        86400
        2419200
        604800
)
@    IN NS ns1.$DOMAIN.
@    IN NS ns2.$DOMAIN.
ns1  IN A 192.225.1.2
ns2  IN A 192.225.1.3
EOF

# Atur kepemilikan dan permission
chown -R bind:bind "$ZONE_DIR"
chmod 755 "$ZONE_DIR"
chmod 644 "$ZONE_FILE"

# Validasi konfigurasi
named-checkconf
named-checkzone "$DOMAIN" "$ZONE_FILE"

# Reload jika rndc tersedia dan aktif; jika tidak, gunakan sinyal reload
if rndc reload "$DOMAIN"; then
    echo "Zona berhasil di-reload menggunakan rndc."
elif pgrep -x named >/dev/null; then
    kill -HUP "$(pgrep -xo named)"
    echo "Mengirim sinyal reload ke proses named."
else
    named -u bind
    echo "Proses named dijalankan."
fi

echo "Konfigurasi DNS Master selesai."
```

```bash
chmod +x /root/soal11_master.sh
```

**Cara menjalankan script**

```bash
bash /root/soal11_master.sh
```
<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/087003ff-b485-4dba-8e04-c246102dc9d9" />

**Fungsi:** memasang BIND9, membuat zona Master beserta file zona, memvalidasi, lalu me-reload `named`.

#### Script DNS Slave pada Shoko

**Cara membuat script**

Pada console Shoko, buat file `/root/soal11_slave.sh`:

```bash
#!/bin/bash
set -e

DOMAIN="jujutsu.k28.com"
MASTER_IP="192.225.1.2"
ZONE_FILE="/var/cache/bind/db.$DOMAIN"

# Install BIND9 jika belum tersedia
apt-get update
apt-get install -y bind9 bind9-utils dnsutils

# Konfigurasi zona Slave
cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
    type slave;
    masters { $MASTER_IP; };
    file "$ZONE_FILE";
};
EOF

# Pastikan direktori cache tersedia
mkdir -p /var/cache/bind
chown bind:bind /var/cache/bind
chmod 775 /var/cache/bind

# Validasi konfigurasi
named-checkconf

# Jalankan named jika belum aktif
if pgrep -x named >/dev/null; then
    rndc reload "$DOMAIN" || kill -HUP "$(pgrep -xo named)"
else
    named -u bind
fi

echo "Konfigurasi DNS Slave selesai."
echo "Periksa hasil transfer dengan:"
echo "dig @192.225.1.3 $DOMAIN SOA"

```

```bash
chmod +x /root/soal11_slave.sh
```

**Cara menjalankan script**

```bash
bash /root/soal11_slave.sh
```
<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/b6110b56-73ba-4e63-93b9-a38c3f322d4a" />

**Fungsi:** memasang BIND9 dan mendaftarkan zona Slave yang mengambil data dari Utahime.

#### Script Pengujian pada Itadori

**Cara membuat script**

Pada console Itadori, buat file `/root/soal11-test.sh`:

```bash
#!/bin/bash
DOMAIN="jujutsu.k28.com"
IP_UTAHIME="192.225.1.5"  # <-- GANTI IP Utahime asli
IP_SHOKO="192.225.1.6"    # <-- GANTI IP Shoko asli

echo "=== QUERY KE MASTER (UTAHIME) ==="
dig @$IP_UTAHIME $DOMAIN +short

echo "=== QUERY KE SLAVE (SHOKO) ==="
dig @$IP_SHOKO $DOMAIN +short
```

**Cara menjalankan script**

```bash
sh /root/soal11-test.sh
```

**Fungsi:** menjalankan `dig` SOA dan A record ke Master dan Slave.

**Output Script Soal 11**

 hasil script Master, Slave, dan pengujian client.

#### Urutan Menjalankan Script untuk Demonstrasi

1. **Utahime:** `bash /root/soal11_master.sh`
2. **Shoko:** `bash /root/soal11_slave.sh`
3. **Itadori:** `sh /root/soal11-test.sh`

---
# Soal 12
## A Record, CNAME, Reverse DNS, dan DNS Forwarder

Peta domain harus memetakan pintu masuk utama ke Gojo dan tetap bisa mencari alamat di luar Shibuya. Pada Utahime dibuat A record `jujutsu.k28.com` ke Gojo, CNAME `www`, zona PTR untuk IP Gojo, serta forwarder ke `192.168.122.1`. Hasilnya diuji dari client dengan `dig` (CNAME dan PTR) dan `ping google.com`.

### Langkah Pengerjaan

#### Langkah 1 — Menambahkan A Record dan CNAME

**Console perangkat: Utahime**

```bash
nano /etc/bind/zones/db.jujutsu.k28.com
```

Naikkan serial menjadi `2026101504` dan tambahkan:

```dns
@    IN A     <IP-Gojo>
www  IN CNAME jujutsu.k28.com.
```

**Hasil yang diharapkan:** zona valid saat dicek `named-checkzone`.

#### Langkah 2 — Membuat Zona Reverse (PTR)

**Console perangkat: Utahime**

Tambahkan ke `/etc/bind/named.conf.local`:

```conf
zone "1.225.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.225.1";
    allow-transfer { 192.225.1.3; };
    also-notify { 192.225.1.3; };
};
```

Buat `/etc/bind/zones/db.192.225.1`:

```dns
$TTL 604800
@   IN  SOA ns1.jujutsu.k28.com. admin.jujutsu.k28.com. (
        2026101501 604800 86400 2419200 604800 )
@   IN  NS  ns1.jujutsu.k28.com.
@   IN  NS  ns2.jujutsu.k28.com.
<oktet-akhir-Gojo> IN PTR jujutsu.k28.com.
```

#### Langkah 3 — Mengaktifkan DNS Forwarder

**Console perangkat: Utahime**

```bash
nano /etc/bind/named.conf.options
```

Pastikan di dalam blok `options` ada:

```conf
forwarders { 192.168.122.1; };
dnssec-validation no;
allow-recursion { any; };
```

#### Langkah 4 — Validasi dan Reload

**Console perangkat: Utahime**

```bash
named-checkconf
named-checkzone jujutsu.k28.com /etc/bind/zones/db.jujutsu.k28.com
named-checkzone 1.225.192.in-addr.arpa /etc/bind/zones/db.192.225.1
rndc reload || kill -HUP "$(pgrep -xo named)"
```

**Hasil yang diharapkan:** semua pengecekan `OK`.

#### Langkah 5 — Menguji A, CNAME, dan PTR dari Client

**Console perangkat: Itadori**

```bash
dig @192.225.1.2 jujutsu.k28.com A +short
dig @192.225.1.2 www.jujutsu.k28.com CNAME +short
dig @192.225.1.2 -x <IP-Gojo> +short
```

**Hasil yang diharapkan:** A mengarah ke Gojo, CNAME ke `jujutsu.k28.com.`, dan PTR kembali ke `jujutsu.k28.com.`.

#### Langkah 6 — Menguji Forwarder ke Internet

**Console perangkat: Itadori**

```bash
dig @192.225.1.2 google.com +short
ping -c 3 google.com
```

**Hasil yang diharapkan:** `google.com` ter-resolve dan ping berhasil.

### Catatan Pengujian Ulang

Naikkan serial setiap mengubah zona agar Shoko ikut tersinkron. Ping domain internet hanya berhasil jika NAT Jichi aktif dan client memakai Utahime/Shoko sebagai DNS.

### Kesimpulan

Utahime berhasil memetakan `jujutsu.k28.com` dan `www` ke Gojo, menyediakan PTR untuk IP Gojo, serta meneruskan query eksternal ke `192.168.122.1`. Client dapat meresolusi CNAME, PTR, dan tetap menjangkau `google.com`.

### Otomatisasi Pengujian Menggunakan Script

#### Script DNS pada Utahime

**Cara membuat script**

Pada console Utahime, buat file `/root/soal12_dns.sh`:

```bash
#!/bin/bash
set -e

DOMAIN="jujutsu.k28.com"
PREFIX="192.225"
GOJO_IP="192.225.1.4"
ZONE_DIR="/etc/bind/zones"
ZONE_FILE="$ZONE_DIR/db.$DOMAIN"
REV_ZONE="1.225.192.in-addr.arpa"
REV_FILE="$ZONE_DIR/db.192.225.1"

# Pastikan script dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
    echo "Jalankan script sebagai root."
    exit 1
fi

# Pastikan IP Gojo sesuai sebelum melanjutkan
echo "Domain : $DOMAIN"
echo "IP Gojo: $GOJO_IP"
read -r -p "Apakah IP Gojo sudah benar? (y/n): " confirm
[ "$confirm" = "y" ] || {
    echo "Batalkan. Edit GOJO_IP di /root/soal12_dns.sh."
    exit 1
}

# Backup konfigurasi yang akan diubah
BACKUP="/root/backup_soal12_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP"
cp -a /etc/bind/named.conf.local "$BACKUP/"
cp -a /etc/bind/named.conf.options "$BACKUP/"
[ ! -f "$ZONE_FILE" ] || cp -a "$ZONE_FILE" "$BACKUP/"
[ ! -f "$REV_FILE" ] || cp -a "$REV_FILE" "$BACKUP/"
echo "Backup: $BACKUP"

mkdir -p "$ZONE_DIR"

# Naikkan serial dari zona lama jika tersedia
SERIAL="2026101501"
if [ -f "$ZONE_FILE" ]; then
    OLD_SERIAL=$(sed -n '/SOA/,/)/s/^[[:space:]]*\([0-9]\{10\}\).*/\1/p' "$ZONE_FILE" | head -n1)
    if [[ "$OLD_SERIAL" =~ ^[0-9]{10}$ ]]; then
        SERIAL=$((OLD_SERIAL + 1))
    fi
fi

# Tulis zona forward
cat > "$ZONE_FILE" <<ZONE
\$TTL 604800
@ IN SOA ns1.$DOMAIN. admin.$DOMAIN. (
    $SERIAL
    604800
    86400
    2419200
    604800
)
@    IN NS ns1.$DOMAIN.
@    IN NS ns2.$DOMAIN.
ns1  IN A  192.225.1.2
ns2  IN A  192.225.1.3
@    IN A  $GOJO_IP
www  IN CNAME $DOMAIN.
ZONE

# Tulis zona reverse untuk Network 1
cat > "$REV_FILE" <<ZONE
\$TTL 604800
@ IN SOA ns1.$DOMAIN. admin.$DOMAIN. (
    $SERIAL
    604800
    86400
    2419200
    604800
)
@ IN NS ns1.$DOMAIN.
@ IN NS ns2.$DOMAIN.
$(echo "$GOJO_IP" | awk -F. '{print $4}') IN PTR $DOMAIN.
ZONE

# Daftarkan zona reverse jika belum ada
if ! grep -q "zone \"$REV_ZONE\"" /etc/bind/named.conf.local; then
cat >> /etc/bind/named.conf.local <<ZONE

zone "$REV_ZONE" {
    type master;
    file "$REV_FILE";
};
ZONE
fi

# Tambahkan DNS forwarder tanpa mengganti seluruh options
if ! grep -q '192\.168\.122\.1' /etc/bind/named.conf.options; then
    sed -i '/options[[:space:]]*{/a\        forwarders { 192.168.122.1; };' \
        /etc/bind/named.conf.options
fi

# Validasi konfigurasi dan zona
named-checkconf
named-checkzone "$DOMAIN" "$ZONE_FILE"
named-checkzone "$REV_ZONE" "$REV_FILE"

# Reload jika memungkinkan, selain itu jalankan named
if command -v rndc >/dev/null 2>&1 && rndc reload; then
    :
else
    echo "rndc reload gagal/tidak tersedia. Periksa cara named dijalankan sebelum restart."
fi

echo
echo "Selesai. Serial zona: $SERIAL"
echo "Forward zone: $ZONE_FILE"
echo "Reverse zone: $REV_FILE"
echo "Backup konfigurasi: $BACKUP"
```

```bash
chmod +x /root/soal12_dns.sh
```

**Cara menjalankan script**

```bash
bash /root/soal12_dns.sh
```

**Fungsi:** menambah A, CNAME, zona PTR, dan forwarder, lalu memvalidasi dan me-reload BIND9.

**Output Script Soal 12**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/8fa58faf-6584-404f-b5f7-4b24f30f40f8" />

 hasil `bash /root/soal12_dns.sh`.

#### Urutan Menjalankan Script untuk Demonstrasi

1. **Utahime:** `bash /root/soal12_dns.sh`
2. **Itadori:** jalankan `dig` A, CNAME, PTR, lalu `ping google.com`.

---
# Soal 13
## Replikasi MariaDB Master-Slave (Yaga dan Inumaki)

Database terpusat yang redundan dibangun agar log aktivitas tetap aman. MariaDB pada Yaga menjadi Master dengan binary logging, sedangkan Inumaki menjadi Slave lewat `CHANGE MASTER TO`. Replikasi dibuktikan dengan memasukkan data di Master dan memeriksanya di Slave.

### Langkah Pengerjaan

#### Langkah 1 — Memasang MariaDB

**Console perangkat: Yaga dan Inumaki**

```bash
apt-get update
apt-get install -y mariadb-server
```

#### Langkah 2 — Mengaktifkan Binary Log di Master

**Console perangkat: Yaga**

```bash
nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

Pada bagian `[mysqld]` isi:

```ini
bind-address = 0.0.0.0
server-id    = 1
log-bin      = /var/log/mysql/mysql-bin.log
```

Jalankan ulang service:

```bash
mkdir -p /var/log/mysql && chown mysql:mysql /var/log/mysql
service mariadb restart
```

#### Langkah 3 — Membuat Database, Tabel, dan User

**Console perangkat: Yaga**

```bash
mariadb
```

```sql
CREATE DATABASE db_shibuya_K28;
USE db_shibuya_K28;
CREATE TABLE request_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  hostname VARCHAR(100),
  client_ip VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE USER 'repl'@'192.225.4.%' IDENTIFIED BY '<password>';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'192.225.4.%';
CREATE USER 'app'@'192.225.4.%' IDENTIFIED BY '<password>';
GRANT ALL ON db_shibuya_K28.* TO 'app'@'192.225.4.%';
FLUSH PRIVILEGES;
SHOW MASTER STATUS;
```

**Hasil yang diharapkan:** `SHOW MASTER STATUS` menampilkan `File` dan `Position`; catat keduanya. User `app` memberi akses remote bagi seluruh node Network 4.

#### Langkah 4 — Mengonfigurasi Slave

**Console perangkat: Inumaki**

```bash
nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

Isi pada `[mysqld]`: `server-id = 2` dan `bind-address = 0.0.0.0`, lalu `service mariadb restart`.

#### Langkah 5 — Menghubungkan Slave ke Master

**Console perangkat: Inumaki**

```bash
mariadb
```

```sql
CHANGE MASTER TO
  MASTER_HOST='<IP-Yaga>',
  MASTER_USER='repl',
  MASTER_PASSWORD='<password>',
  MASTER_LOG_FILE='<File-dari-Master>',
  MASTER_LOG_POS=<Position-dari-Master>;
START SLAVE;
SHOW SLAVE STATUS\G
```

**Hasil yang diharapkan:** `Slave_IO_Running: Yes` dan `Slave_SQL_Running: Yes`.

#### Langkah 6 — Membuktikan Replikasi

**Console perangkat: Yaga**

```sql
INSERT INTO db_shibuya_K28.request_logs (hostname, client_ip) VALUES ('uji-replikasi','192.225.2.10');
```

**Console perangkat: Inumaki**

```sql
SELECT * FROM db_shibuya_K28.request_logs;
```

**Hasil yang diharapkan:** baris `uji-replikasi` muncul di Slave.


### Catatan Pengujian Ulang

Jika Slave `No`, baca `Last_IO_Error` pada `SHOW SLAVE STATUS\G` dan cek file/posisi log Master. Setelah node di-restart, pastikan service MariaDB dijalankan kembali (`service mariadb start`).

### Kesimpulan

MariaDB Master (Yaga) dan Slave (Inumaki) berhasil dikonfigurasi dengan database `db_shibuya_K28` dan tabel `request_logs`. Data yang dimasukkan di Master langsung muncul di Slave, sehingga replikasi berjalan.

### Otomatisasi Pengujian Menggunakan Script

#### Script Master pada Yaga

**Cara membuat script**

Pada console Yaga, buat file `/root/soal13_master.sh`:

```bash
#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

DB_NAME="db_shibuya_k28"
REPL_USER="replica"
REPL_PASS="ReplicaPass123!"

apt-get update
apt-get install -y mariadb-server mariadb-client

cat > /etc/mysql/mariadb.conf.d/60-master.cnf <<'EOC'
[mysqld]
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_format = ROW
bind-address = 0.0.0.0
EOC

service mariadb restart

mariadb <<EOSQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

USE \`${DB_NAME}\`;

CREATE TABLE IF NOT EXISTS request_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_ip VARCHAR(45),
    endpoint VARCHAR(255),
    request_method VARCHAR(10),
    status_code INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE USER IF NOT EXISTS '${REPL_USER}'@'192.225.4.%'
IDENTIFIED BY '${REPL_PASS}';

GRANT REPLICATION SLAVE ON *.* TO '${REPL_USER}'@'192.225.4.%';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${REPL_USER}'@'192.225.4.%';

CREATE USER IF NOT EXISTS 'appuser'@'192.225.4.%'
IDENTIFIED BY 'AppPass123!';

GRANT SELECT, INSERT, UPDATE, DELETE
ON \`${DB_NAME}\`.* TO 'appuser'@'192.225.4.%';

FLUSH PRIVILEGES;
EOSQL

echo "=== STATUS MASTER ==="
mariadb -e "SHOW MASTER STATUS;"
```

```bash
chmod +x /root/soal13_master.sh
```

**Cara menjalankan script**

```bash
bash /root/soal13_master.sh
```
<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/65a16780-8ce4-47a0-b1b3-8155eb2f35c4" />

**Fungsi:** mengonfigurasi binary log, membuat database, tabel, serta user replikasi dan remote.

#### Script Slave pada Inumaki

**Cara membuat script**

Pada console Inumaki, buat file `/root/soal13_slave.sh`:

```bash
#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

MASTER_IP="192.225.4.9"
SLAVE_ID="2"
DB_NAME="db_shibuya_k28"
REPL_USER="replica"
REPL_PASS="ReplicaPass123!"
MASTER_LOG_FILE="mysql-bin.000001"
MASTER_LOG_POS="2005"

apt-get update
apt-get install -y mariadb-server mariadb-client

cat > /etc/mysql/mariadb.conf.d/60-slave.cnf <<'EOC'
[mysqld]
server-id = 2
relay_log = /var/log/mysql/mysql-relay-bin.log
read_only = ON
bind-address = 0.0.0.0
EOC

mkdir -p /var/log/mysql /run/mysqld
chown mysql:mysql /var/log/mysql /run/mysqld

service mariadb restart

# Siapkan skema awal agar tabel sudah tersedia di Slave
mariadb <<EOSQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

USE \`${DB_NAME}\`;

CREATE TABLE IF NOT EXISTS request_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_ip VARCHAR(45),
    endpoint VARCHAR(255),
    request_method VARCHAR(10),
    status_code INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOSQL

mariadb <<EOSQL
STOP SLAVE;
RESET SLAVE ALL;

CHANGE MASTER TO
    MASTER_HOST='${MASTER_IP}',
    MASTER_PORT=3306,
    MASTER_USER='${REPL_USER}',
    MASTER_PASSWORD='${REPL_PASS}',
    MASTER_LOG_FILE='${MASTER_LOG_FILE}',
    MASTER_LOG_POS=${MASTER_LOG_POS};

START SLAVE;
EOSQL

echo "=== STATUS SLAVE ==="
mariadb -e "SHOW SLAVE STATUS\\G"

```

```bash
chmod +x /root/soal13_slave.sh
```

**Cara menjalankan script**

```bash
bash /root/soal13_slave.sh
```

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/78fe74bd-6560-42af-a7f6-b332ccfcc121" />

**Fungsi:** mengatur `server-id` Slave, menjalankan `CHANGE MASTER TO`, dan memulai replikasi.

#### Urutan Menjalankan Script untuk Demonstrasi

1. **Yaga:** `bash /root/soal13_master.sh`
2. **Inumaki:** `bash /root/soal13_slave.sh`
3. **Yaga lalu Inumaki:** INSERT di Master, SELECT di Slave.

---
# Soal 14
Worker Frontend dan API dengan Nginx + PHP-FPM

Para worker di Data Center menjadi backend aplikasi. Maki dan Panda menyajikan web frontend yang menampilkan hostname, sedangkan Nanami, Todo, dan Kirara menyediakan API yang mencatat request ke database Yaga. Akses langsung dari client harus ditolak: web worker hanya menerima trafik dari Gojo dan API worker hanya dari Geto.

### Langkah Pengerjaan

#### Langkah 1 — Memasang Nginx dan PHP-FPM

**Console perangkat: Maki, Panda, Nanami, Todo, Kirara**

```bash
apt-get update
apt-get install -y nginx php-fpm php-mysql
```

#### Langkah 2 — Membuat Halaman Frontend

**Console perangkat: Maki dan Panda**

```bash
cat > /var/www/html/index.php <<'EOF'
<?php echo "Worker Frontend: " . gethostname(); ?>
EOF
```

**Hasil yang diharapkan:** halaman menampilkan hostname masing-masing worker.

#### Langkah 3 — Membuat Endpoint API

**Console perangkat: Nanami, Todo, Kirara**

Buat `/var/www/html/index.php` yang menampilkan hostname dan menyimpan log ke Yaga:

```php
<?php
header('Content-Type: application/json');
$host = gethostname();
$db = new mysqli('<IP-Yaga>', 'app', '<password>', 'db_shibuya_K28');
$ip = $_SERVER['REMOTE_ADDR'];
$stmt = $db->prepare("INSERT INTO request_logs (hostname, client_ip) VALUES (?, ?)");
$stmt->bind_param('ss', $host, $ip);
$stmt->execute();
echo json_encode(['server' => $host, 'status' => 'ok']);
```

#### Langkah 4 — Virtual Host dan Pembatasan Akses

**Console perangkat: Maki dan Panda**

```nginx
server {
    listen 80;
    server_name jujutsu.k28.com www.jujutsu.k28.com;
    root /var/www/html;
    index index.php;
    allow <IP-Gojo>;
    deny all;
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
    }
}
```

**Console perangkat: Nanami, Todo, Kirara**

Konfigurasi sama, tetapi `allow <IP-Geto>;`. Jalankan `nginx -t`, mulai PHP-FPM, lalu `service nginx restart`.

#### Langkah 5 — Menguji Akses Langsung Ditolak

**Console perangkat: Itadori**

```bash
curl -I http://<IP-Maki>/
curl -I http://<IP-Nanami>/
```

**Hasil yang diharapkan:** `403 Forbidden` (akses langsung dari client ditolak).

#### Langkah 6 — Menguji Akses Melalui Proxy

**Console perangkat: Gojo (web) dan Geto (API)**

```bash
curl -s -H "Host: jujutsu.k28.com" http://<IP-Maki>/
curl -s -H "Host: jujutsu.k28.com" http://<IP-Nanami>/
```

**Hasil yang diharapkan:** web membalas hostname Maki/Panda dan API membalas JSON dengan `status: ok`. Pastikan baris baru muncul di `request_logs` Yaga.

### Catatan Pengujian Ulang

Jika muncul `502`, periksa PHP-FPM dan path socket (`ls /run/php/`). Jika API gagal menyimpan log, cek koneksi dan user `app` ke Yaga.

### Kesimpulan

Maki dan Panda berhasil menyajikan frontend, sedangkan Nanami, Todo, dan Kirara mencatat request ke database Yaga. Akses langsung client ditolak dan hanya jalur proxy yang diizinkan.

### Otomatisasi Pengujian Menggunakan Script

#### Script Worker

**Cara membuat script**

Pada console Maki, Panda, Nanami, Todo, dan Kirara, buat file `/root/soal14_worker.sh`:

```bash
#!/bin/bash
set -e

ROLE="${1:?Gunakan frontend atau api}"
NODE="${2:?Masukkan nama worker}"

DB_HOST="192.225.4.9"
DB_NAME="db_shibuya_k28"
DB_USER="appuser"
DB_PASS="AppPass123!"

GOJO_IP="192.225.1.4"
GETO_IP="192.225.4.2"

if [ "$ROLE" != "frontend" ] && [ "$ROLE" != "api" ]; then
    echo "Role harus frontend atau api"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
echo "=== Instalasi worker $NODE ($ROLE) ==="
apt-get update
apt-get install -y nginx php-fpm php-mysql mariadb-client

# Mulai PHP-FPM
for svc in /etc/init.d/php*-fpm; do
    [ -x "$svc" ] && service "$(basename "$svc")" start
done

PHP_SOCK="$(find /run/php -maxdepth 1 -name 'php*-fpm.sock' | head -n 1)"
if [ -z "$PHP_SOCK" ]; then
    echo "ERROR: socket PHP-FPM tidak ditemukan"
    exit 1
fi

mkdir -p /var/www/html

if [ "$ROLE" = "frontend" ]; then
    ALLOW_IP="$GOJO_IP"

    cat > /var/www/html/index.php <<PHP
<?php
header('Content-Type: text/html; charset=utf-8');
echo '<h1>Jujutsu High Frontend</h1>';
echo '<p>Worker: ' . htmlspecialchars('$NODE') . '</p>';
echo '<p>Hostname: ' . htmlspecialchars(gethostname()) . '</p>';
?>
PHP

    SERVER_NAMES="jujutsu.k28.com www.jujutsu.k28.com"
else
    ALLOW_IP="$GETO_IP"

    cat > /var/www/html/index.php <<'PHP'
<?php
header('Content-Type: application/json; charset=utf-8');

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$endpoint = $_SERVER['REQUEST_URI'] ?? '/';
$client_ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
$status_code = 200;

mysqli_report(MYSQLI_REPORT_OFF);
$db = new mysqli(
    '192.225.4.9',
    'appuser',
    'AppPass123!',
    'db_shibuya_k28'
);

if ($db->connect_errno) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Database connection failed',
        'worker' => gethostname()
    ]);
    exit;
}

$stmt = $db->prepare(
    'INSERT INTO request_logs
    (client_ip, endpoint, request_method, status_code)
    VALUES (?, ?, ?, ?)'
);

if ($stmt) {
    $stmt->bind_param('sssi', $client_ip, $endpoint, $method, $status_code);
    $stmt->execute();
    $stmt->close();
}

$db->close();

echo json_encode([
    'service' => 'Jujutsu High API',
    'worker' => gethostname(),
    'endpoint' => $endpoint,
    'method' => $method,
    'logged' => true
], JSON_PRETTY_PRINT);
echo "\n";
?>
PHP

    SERVER_NAMES="api.jujutsu.k28.com"
fi

cat > /etc/nginx/sites-available/default <<NGINX
server {
    listen 80;
    server_name $SERVER_NAMES;

    root /var/www/html;
    index index.php index.html;

    # Hanya proxy yang ditentukan boleh mengakses worker
    allow $ALLOW_IP;
    deny all;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$PHP_SOCK;
    }

    location ~ /\. {
        deny all;
    }
}
NGINX

nginx -t
service nginx restart

echo "=== SELESAI: $NODE ($ROLE) ==="
nginx -t
service nginx status

```

```bash
chmod +x /root/soal14_worker.sh
```

**Cara menjalankan script**

```bash
bash /root/soal14_worker.sh
```

**Fungsi:** memasang Nginx dan PHP-FPM, membuat halaman/API, serta virtual host dengan pembatasan akses.

**Output Script Soal 14**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/dec6ee55-eedb-47b5-8562-3ed815310308" />
 hasil script di salah satu web worker dan salah satu API worker.

#### Urutan Menjalankan Script untuk Demonstrasi

1. **Maki, Panda, Nanami, Todo, Kirara:** `bash /root/soal14_worker.sh`
2. **Itadori:** `curl` langsung ke worker (harus ditolak).
3. **Gojo dan Geto:** `curl` ke worker (harus berhasil).

---
# Soal 15
## Load Balancer Internal pada Geto (Weighted Round Robin 3:1)

Geto mengendalikan pembagian beban request API di Data Center agar server tidak tumbang bersamaan. Nginx pada Geto dikonfigurasi dengan upstream `api_cluster` ke Nanami dan Todo memakai Weighted Round Robin bobot 3:1. Distribusi dibuktikan dengan loop request dari jaringan lokal Data Center dan menghitung rasio responsnya.

### Langkah Pengerjaan

#### Langkah 1 — Memasang Nginx di Geto

**Console perangkat: Geto**

```bash
apt-get update
apt-get install -y nginx
```

#### Langkah 2 — Mengonfigurasi Upstream dan Proxy

**Console perangkat: Geto**

```bash
nano /etc/nginx/conf.d/api_cluster.conf
```

Isi:

```nginx
upstream api_cluster {
    server <IP-Nanami> weight=3;
    server <IP-Todo>   weight=1;
}

server {
    listen 80;
    server_name jujutsu.k28.com;
    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host $host;
    }
}
```
#### Langkah 3 — Validasi dan Menjalankan Nginx

**Console perangkat: Geto**

```bash
rm -f /etc/nginx/sites-enabled/default
nginx -t
pgrep -x nginx >/dev/null && nginx -s reload || service nginx start
```

**Hasil yang diharapkan:** `nginx -t` berstatus `successful`.

#### Langkah 4 — Menguji Rasio Distribusi Beban

**Console perangkat: Tengen** (satu jaringan Data Center dengan Geto)

```bash
for i in $(seq 1 40); do curl -s http://<IP-Geto>/ ; echo; done | sort | uniq -c
```

**Hasil yang diharapkan:** Nanami menerima sekitar 30 respons dan Todo sekitar 10 (rasio 3:1).

### Catatan Pengujian Ulang

Jika semua respons dari satu worker, periksa apakah worker lain bisa dijangkau dari Geto dan apakah vhost mengizinkan IP Geto. Gunakan jumlah request kelipatan 4 agar rasio mudah dibaca.

### Kesimpulan

Geto berhasil menjadi load balancer internal dengan upstream `api_cluster` dan Weighted Round Robin 3:1. Loop request menunjukkan Nanami menerima beban sekitar tiga kali lipat Todo.

### Otomatisasi Pengujian Menggunakan Script

#### Script Load Balancer pada Geto

**Cara membuat script**

Pada console Geto, buat file `/root/soal15_geto.sh`:

```bash
#!/bin/bash
set -e

NANAMI_IP="192.225.4.5"
TODO_IP="192.225.4.6"

apt-get install -y nginx curl

cat > /etc/nginx/sites-available/default <<NGINX
upstream api_cluster {
    server ${NANAMI_IP}:80 weight=3;
    server ${TODO_IP}:80 weight=1;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
NGINX

nginx -t
service nginx restart

echo "=== TEST NANAMI ==="
curl -i --connect-timeout 3 http://${NANAMI_IP}/

echo "=== TEST TODO ==="
curl -i --connect-timeout 3 http://${TODO_IP}/

echo "=== SELESAI ==="

```

```bash
chmod +x /root/soal15_geto.sh
```

**Cara menjalankan script**

```bash
bash /root/soal15_geto.sh
```

**Fungsi:** menulis konfigurasi upstream `api_cluster`, memvalidasi, dan me-reload Nginx.

**Output Script Soal 15**

 hasil `bash /root/soal15_geto.sh`.

#### Urutan Menjalankan Script untuk Demonstrasi

1. **Geto:** `bash /root/soal15_geto.sh`
2. **Tengen:** jalankan loop `curl` ke Geto lalu hitung rasio.

---
# Soal 16
## Gojo sebagai Public Reverse Proxy (Path-Based Routing)

Gojo berdiri di perbatasan DMZ sebagai gerbang publik tunggal bagi client dari dalam maupun luar. Nginx pada Gojo melayani `jujutsu.k28.com` dan `www.jujutsu.k28.com`, dengan `/` diteruskan Round Robin ke Maki dan Panda, sedangkan `/api` diteruskan ke Geto. Hasilnya diuji dari client bahwa web utama dibalas Maki/Panda dan `/api` dijawab Nanami/Todo.

### Langkah Pengerjaan

#### Langkah 1 — Memasang Nginx di Gojo

**Console perangkat: Gojo**

```bash
apt-get update
apt-get install -y nginx
```

#### Langkah 2 — Mengonfigurasi Path-Based Routing

**Console perangkat: Gojo**

```bash
nano /etc/nginx/conf.d/gojo.conf
```

Isi:

```nginx
upstream web_frontend {
    server <IP-Maki>;
    server <IP-Panda>;
}

server {
    listen 80;
    server_name jujutsu.k28.com www.jujutsu.k28.com;

    location / {
        proxy_pass http://web_frontend;
        proxy_set_header Host $host;
    }

    location /api {
        proxy_pass http://<IP-Geto>;
        proxy_set_header Host $host;
    }
}
```

**SS 16-01 — Konfigurasi Gojo**

<img width="561" height="427" alt="image" src="https://github.com/user-attachments/assets/39a3e9a0-8433-4443-8d10-62e84ec124e5" />


#### Langkah 3 — Validasi dan Menjalankan Nginx

**Console perangkat: Gojo**

```bash
rm -f /etc/nginx/sites-enabled/default
nginx -t
pgrep -x nginx >/dev/null && nginx -s reload || service nginx start
```

**Hasil yang diharapkan:** `nginx -t` berstatus `successful`.

**SS 16-02 — Validasi Nginx**
<img width="648" height="206" alt="image" src="https://github.com/user-attachments/assets/b60866af-9b3a-4a1d-97a6-f3c53e435060" />


#### Langkah 4 — Menguji Root (`/`) ke Maki/Panda

**Console perangkat: Itadori (Divisi A) dan Ino (Divisi B)**

```bash
for i in 1 2 3 4; do curl -s http://jujutsu.k28.com/; echo; done
```

**Hasil yang diharapkan:** respons bergantian dari Maki dan Panda.

**SS 16-03 — Root Dibalas Maki/Panda**
<img width="705" height="187" alt="image" src="https://github.com/user-attachments/assets/61eb6fcb-d2d6-4eb3-aad2-4f8320eb74bf" />

<img width="702" height="162" alt="image" src="https://github.com/user-attachments/assets/176cd4c7-7d6b-4054-902f-26ff9ef3eefc" />


#### Langkah 5 — Menguji `/api` ke Nanami/Todo

**Console perangkat: Itadori dan Ino**

```bash
for i in 1 2 3 4; do curl -s http://jujutsu.k28.com/api; echo; done
```

**Hasil yang diharapkan:** respons JSON dari Nanami atau Todo.

**SS 16-04 — `/api` Dibalas Nanami/Todo**

<img width="735" height="247" alt="image" src="https://github.com/user-attachments/assets/8d9afb89-8ad3-4947-ab56-af8b5a4b1cdb" />
<img width="746" height="240" alt="image" src="https://github.com/user-attachments/assets/1f177f1b-1bf5-44fa-9392-50808ab6e06a" />


### Catatan Pengujian Ulang

Jika muncul `502`, cek Geto dan worker (service Nginx dan PHP-FPM) serta pastikan vhost worker mengizinkan IP proxy yang tepat. Jika domain tidak ter-resolve di client, jalankan ulang `udhcpc` agar DNS Utahime/Shoko terpasang.

### Kesimpulan

Gojo berhasil menjadi gerbang publik dengan Path-Based Routing. Request `/` dibalas bergantian oleh Maki dan Panda, sedangkan `/api` diteruskan ke Geto dan dijawab Nanami/Todo.

### Otomatisasi Pengujian Menggunakan Script

#### Script Reverse Proxy pada Gojo

**Cara membuat script**

Pada console Gojo, buat file `/root/soal16_gojo.sh`:

```bash
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

MAKI_IP="192.225.4.3"
PANDA_IP="192.225.4.4"
GETO_IP="192.225.4.2"

apt-get update
apt-get install -y nginx curl

cat > /etc/nginx/sites-available/default <<NGINX
upstream frontend_cluster {
    server ${MAKI_IP}:80;
    server ${PANDA_IP}:80;
}

server {
    listen 80;
    server_name jujutsu.k28.com www.jujutsu.k28.com;

```

```bash
chmod +x /root/soal16_gojo.sh
```

**Cara menjalankan script**

```bash
bash /root/soal16_gojo.sh
```

**Fungsi:** menulis konfigurasi proxy Gojo, memvalidasi, dan me-reload Nginx. Backup konfigurasi tersimpan di `/root/soal16_gojo_backup.conf`.

**SS 16-05 — Output Script Soal 16**

<img width="643" height="363" alt="image" src="https://github.com/user-attachments/assets/298b0734-f0fc-4cac-b4d7-b88b184f1172" />


#### Urutan Menjalankan Script untuk Demonstrasi

1. **Gojo:** `bash /root/soal16_gojo.sh`
2. **Itadori dan Ino:** `curl` ke `/` dan `/api`.

---
# Soal 17
## Meneruskan IP Asli Klien (X-Real-IP dan X-Forwarded-For)

Komando pusat perlu mengetahui IP asli klien tanpa tertukar dengan IP proxy perantara. Gojo dan Geto dikonfigurasi meneruskan `X-Real-IP` dan `X-Forwarded-For`, dengan Geto hanya mempercayai header dari Gojo. Script API menyimpan IP terverifikasi ke kolom `client_ip` di `request_logs` Yaga, lalu dibuktikan dengan request dari Network 2 dan Network 3.

### Langkah Pengerjaan

#### Langkah 1 — Meneruskan Header di Gojo

**Console perangkat: Gojo**

```bash
nano /etc/nginx/conf.d/gojo.conf
```

Tambahkan pada `location /api` (dan `location /`):

```nginx
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

**SS 17-01 — Header di Gojo**

<img width="805" height="563" alt="image" src="https://github.com/user-attachments/assets/598e1ceb-15bb-4bd0-82c9-e688b53705b9" />

#### Langkah 2 — Mempercayai Hanya Proxy Terpercaya di Geto

**Console perangkat: Geto**

```bash
nano /etc/nginx/conf.d/api_cluster.conf
```

Tambahkan pada blok `server`:

```nginx
set_real_ip_from <IP-Gojo>;
real_ip_header   X-Real-IP;
real_ip_recursive off;
```

Dan pada `location /`:

```nginx
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

`set_real_ip_from` membuat Geto hanya mengambil IP klien dari header jika paket datang dari Gojo.

**SS 17-02 — Trust Proxy di Geto**

<img width="655" height="446" alt="image" src="https://github.com/user-attachments/assets/97db43b0-a4fc-4118-bd25-8bfec4445be8" />


#### Langkah 3 — Menyimpan `client_ip` di Script API

**Console perangkat: Nanami, Todo, dan Kirara**

Ubah `/var/www/html/index.php` agar mengambil IP dari header yang dikirim Geto:

```php
<?php
header('Content-Type: application/json');
$host = gethostname();
$ip = $_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR'];
$db = new mysqli('<IP-Yaga>', 'app', '<password>', 'db_shibuya_K28');
$stmt = $db->prepare("INSERT INTO request_logs (hostname, client_ip) VALUES (?, ?)");
$stmt->bind_param('ss', $host, $ip);
$stmt->execute();
echo json_encode(['server' => $host, 'client_ip' => $ip, 'status' => 'ok']);
```

Worker API hanya menerima trafik dari Geto, sehingga header ini dapat dipercaya.

**SS 17-03 — Script API**

> **[TEMPAT SCREENSHOT 17-03]**: `cat /var/www/html/index.php` di salah satu worker API.

#### Langkah 4 — Validasi dan Reload

**Console perangkat: Gojo dan Geto**

```bash
nginx -t && nginx -s reload
```

**SS 17-04 — Validasi Nginx**

<img width="626" height="138" alt="image" src="https://github.com/user-attachments/assets/47f3f844-9364-4575-9ff7-cf7d68cbe154" />


<img width="621" height="128" alt="image" src="https://github.com/user-attachments/assets/ec375bef-5246-4a72-bbd7-62517ede8f12" />


#### Langkah 5 — Mengirim Request dari Network 2 dan Network 3

**Console perangkat: Itadori (Network 2) dan Ino (Network 3)**

```bash
ip -4 -br addr show eth0
curl -s http://jujutsu.k28.com/api
```

**Hasil yang diharapkan:** JSON memuat `client_ip` sama dengan IP client masing-masing.

**SS 17-05 — Request dari Client**

<img width="452" height="260" alt="image" src="https://github.com/user-attachments/assets/efc46f4d-8bfa-4d6a-b9f9-83401598629a" />
<img width="487" height="287" alt="image" src="https://github.com/user-attachments/assets/3352bf99-7335-4e49-bf9f-a025c1067537" />


#### Langkah 6 — Memeriksa Database

**Console perangkat: Yaga**

```bash
mariadb -e "SELECT hostname, client_ip, created_at FROM db_shibuya_K28.request_logs ORDER BY id DESC LIMIT 10;"
```

**Hasil yang diharapkan:** `client_ip` berisi IP Itadori dan Ino, bukan IP Gojo maupun Geto.

**SS 17-06 — `client_ip` di Database**

><img width="892" height="408" alt="image" src="https://github.com/user-attachments/assets/7ea3a9ea-e0c4-4665-acc9-2813b9cc89d0" />


### Catatan Pengujian Ulang

Jika `client_ip` berisi IP Gojo atau Geto, periksa `set_real_ip_from` dan pastikan modul `real_ip` aktif (`nginx -V 2>&1 | grep real_ip`). Pastikan `index.php` di tiap worker API sudah diperbarui.

### Kesimpulan

Gojo dan Geto berhasil meneruskan `X-Real-IP` dan `X-Forwarded-For`, dan Geto hanya mempercayai header dari Gojo. Database Yaga mencatat IP asli client Network 2 dan Network 3.

### Otomatisasi Pengujian Menggunakan Script

#### Script Gojo dan Geto

**Cara membuat script**

Pada console Gojo, buat `/root/soal17_gojo.sh`, dan pada Geto buat `/root/soal17_geto.sh`:

```bash
#!/bin/bash
set -e

CONF="/etc/nginx/sites-available/default"

echo "=== Setup Soal 17: Forward Client IP ==="

cp "$CONF" /root/soal17_gojo_before.conf

# Ganti X-Forwarded-For agar Gojo mengirim IP klien yang dilihatnya
sed -i \
  's/proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;/proxy_set_he>
  "$CONF"

# Pastikan X-Real-IP tersedia
if ! grep -q 'proxy_set_header X-Real-IP \$remote_addr;' "$CONF"; then
    echo "ERROR: Header X-Real-IP tidak ditemukan."
    cp /root/soal17_gojo_before.conf "$CONF"
    exit 1
fi

```

```bash
#!/bin/bash
set -e

echo "=== Setup Soal 17: Trusted Proxy Geto ==="

mkdir -p /etc/nginx/conf.d

if [ -f /etc/nginx/conf.d/trusted_proxy.conf ]; then
    cp /etc/nginx/conf.d/trusted_proxy.conf \
       /root/soal17_geto_before.conf
fi

cat > /etc/nginx/conf.d/trusted_proxy.conf <<'CONF'
# Only trust the reverse proxy Gojo
set_real_ip_from 192.225.1.4;
real_ip_header X-Real-IP;
real_ip_recursive off;
CONF

nginx -t

```

```bash
chmod +x /root/soal17_gojo.sh
chmod +x /root/soal17_geto.sh
```

**Cara menjalankan script**

```bash
bash /root/soal17_gojo.sh      # di Gojo
bash /root/soal17_geto.sh      # di Geto
```

**Fungsi:** menambahkan header IP klien dan trust proxy, lalu memvalidasi dan me-reload Nginx. Backup sebelum perubahan tersimpan di `soal17_gojo_before.conf` dan `soal17_geto_before.conf`.

#### Urutan Menjalankan Script untuk Demonstrasi

1. **Geto:** `bash /root/soal17_geto.sh`
2. **Gojo:** `bash /root/soal17_gojo.sh`
3. **Itadori dan Ino:** `curl http://jujutsu.k28.com/api`
4. **Yaga:** `SELECT` pada `request_logs`.

---
# Soal 18
## Worker Cadangan Kirara dan Passive Health Check

Nanami dan Todo adalah worker API utama, sedangkan Kirara disiapkan sebagai cadangan. Upstream `api_cluster` pada Geto diubah agar Kirara menjadi `backup` dan worker utama memakai `max_fails=2` dan `fail_timeout=5s`. Gangguan disimulasikan dengan menghentikan Nginx di Nanami dan Todo, lalu dibuktikan dari client bahwa `/api` dijawab Kirara tanpa 502.

### Langkah Pengerjaan

#### Langkah 1 — Memastikan Kirara Menjalankan API

**Console perangkat: Kirara**

```bash
service nginx status
curl -s -H "Host: jujutsu.k28.com" http://127.0.0.1/
```

**Hasil yang diharapkan:** Nginx aktif dan Kirara membalas JSON API yang kompatibel dengan worker utama.

**SS 18-01 — API Kirara Aktif**

<img width="331" height="75" alt="image" src="https://github.com/user-attachments/assets/9822253e-320a-4081-b334-bb7fe115bd08" />
<img width="632" height="202" alt="image" src="https://github.com/user-attachments/assets/71a6b061-fcf8-4b4e-9861-b0215e1afb0b" />
Catatan laporan: “Worker API hanya menerima trafik dari Geto (allow 192.225.4.2), sehingga uji API Kirara dilakukan dari Geto, bukan dari localhost.”

#### Langkah 2 — Mengubah Upstream di Geto

**Console perangkat: Geto**

```bash
nano /etc/nginx/conf.d/api_cluster.conf
```

Ubah blok upstream dan tambahkan `proxy_next_upstream`:

```nginx
upstream api_cluster {
    server <IP-Nanami> weight=3 max_fails=2 fail_timeout=5s;
    server <IP-Todo>   weight=1 max_fails=2 fail_timeout=5s;
    server <IP-Kirara> backup;
}
```

```nginx
proxy_next_upstream error timeout http_502 http_503 http_504;
```

**SS 18-02 — Upstream dengan Backup**

<img width="645" height="435" alt="image" src="https://github.com/user-attachments/assets/99fead81-20b0-4cf9-b729-2fa944127d30" />


#### Langkah 3 — Validasi dan Reload

**Console perangkat: Geto**

```bash
nginx -t && nginx -s reload
```

**SS 18-03 — Validasi Nginx**
<img width="645" height="123" alt="image" src="https://github.com/user-attachments/assets/3aba162b-b0ac-465a-a997-336eec213b4e" />


#### Langkah 4 — Mensimulasikan Gangguan

**Console perangkat: Nanami dan Todo**

```bash
service nginx stop
```

**SS 18-04 — Nginx Worker Utama Dihentikan**

<img width="358" height="142" alt="image" src="https://github.com/user-attachments/assets/bdce14ba-f0b7-4e15-a8f7-ac8d8542439d" />


#### Langkah 5 — Membuktikan Failover ke Kirara

**Console perangkat: Itadori**

```bash
for i in 1 2 3 4 5 6; do curl -s -o /dev/null -w "%{http_code}\n" http://jujutsu.k28.com/api; done
curl -s http://jujutsu.k28.com/api
```

**Hasil yang diharapkan:** semua kode `200` (tanpa `502`) dan JSON menampilkan hostname Kirara.

**SS 18-05 — Failover Berhasil**

<img width="741" height="421" alt="image" src="https://github.com/user-attachments/assets/92e6eca7-ad47-4531-bd6d-37c3b46f9216" />


#### Langkah 6 — Memulihkan Worker Utama

**Console perangkat: Nanami dan Todo**

```bash
service nginx start
```

**Hasil yang diharapkan:** setelah `fail_timeout` lewat, `/api` kembali dijawab Nanami/Todo.

**SS 18-06 — Worker Utama Pulih**

<img width="750" height="158" alt="image" src="https://github.com/user-attachments/assets/d8656e2c-018f-4959-b214-a6e5e513d91a" />


### Catatan Pengujian Ulang

Selalu nyalakan kembali Nginx di Nanami dan Todo setelah simulasi. Failover bisa memakan beberapa detik pertama karena Nginx menandai worker gagal setelah 2 percobaan.

### Kesimpulan

Geto berhasil memakai Kirara sebagai server backup dan menerapkan passive health check pada Nanami dan Todo. Saat kedua worker utama dimatikan, request `/api` tetap dijawab Kirara tanpa 502 Bad Gateway.

### Otomatisasi Pengujian Menggunakan Script

#### Script Geto dan Kirara

**Cara membuat script**

Pada console Geto, buat `/root/soal18_geto.sh`, dan pada Kirara buat `/root/soal18_kirara.sh`:

```bash
#!/bin/bash
set -e

echo "=== Setup Soal 18: API Failover ==="

# Simpan konfigurasi sebelumnya
if [ -f /etc/nginx/sites-available/default ]; then
    cp /etc/nginx/sites-available/default \
       /root/soal18_geto_before.conf
fi

cat > /etc/nginx/sites-available/default <<'NGINX'
upstream api_cluster {
    server 192.225.4.5:80 weight=3 max_fails=2 fail_timeout=5s;
    server 192.225.4.6:80 weight=1 max_fails=2 fail_timeout=5s;
    server 192.225.4.7:80 backup;
}

server {
    listen 80;
```

```bash
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y nginx php-fpm php-mysql mariadb-client

for svc in /etc/init.d/php*-fpm; do
    [ -x "$svc" ] && service "$(basename "$svc")" start
done

PHP_SOCK="$(find /run/php -maxdepth 1 -name 'php*-fpm.sock' | head -n 1)"
if [ -z "$PHP_SOCK" ]; then
    echo "ERROR: socket PHP-FPM tidak ditemukan"
    exit 1
fi

mkdir -p /var/www/html

cat > /var/www/html/index.php <<'PHP'

```

```bash
chmod +x /root/soal18_geto.sh
chmod +x /root/soal18_kirara.sh
```

**Cara menjalankan script**

```bash
bash /root/soal18_kirara.sh    # di Kirara
bash /root/soal18_geto.sh      # di Geto
```

**Fungsi:** menyiapkan API Kirara, lalu mengatur upstream backup dan health check di Geto. Backup konfigurasi ada di `soal18_geto_backup.conf` dan `soal18_geto_before.conf`.


#### Urutan Menjalankan Script 

1. **Kirara:** `bash /root/soal18_kirara.sh`
2. **Geto:** `bash /root/soal18_geto.sh`
3. **Nanami dan Todo:** `service nginx stop`
4. **Itadori:** `curl http://jujutsu.k28.com/api` berulang.
5. **Nanami dan Todo:** `service nginx start`

---
# Soal 19
## Proxy Caching dan Rate Limiting pada Gojo

Gojo mengoptimalkan layanan web sekaligus membatasi request berlebihan. Nginx Proxy Caching diaktifkan untuk halaman frontend dengan masa berlaku 10 menit dan header `X-Cache-Status`, serta rate limiting 10 request per detik per IP klien pada `/api`. Cache dibuktikan dengan status MISS lalu HIT, dan rate limiting diuji terpisah dengan request beruntun ke `/api`.

### Langkah Pengerjaan

#### Langkah 1 — Mengonfigurasi Proxy Cache

**Console perangkat: Gojo**

```bash
mkdir -p /var/cache/nginx/web
nano /etc/nginx/conf.d/gojo.conf
```

Tambahkan di luar blok `server`:

```nginx
proxy_cache_path /var/cache/nginx/web levels=1:2 keys_zone=web_cache:10m max_size=100m inactive=10m;
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
```

Pada `location /`:

```nginx
proxy_cache web_cache;
proxy_cache_valid 200 10m;
add_header X-Cache-Status $upstream_cache_status;
```

#### Langkah 2 — Mengonfigurasi Rate Limiting pada `/api`

**Console perangkat: Gojo**

Pada `location /api`:

```nginx
limit_req zone=api_limit;
limit_req_status 429;
```

**SS 19-01 — Konfigurasi Cache dan Rate Limit**

<img width="850" height="711" alt="image" src="https://github.com/user-attachments/assets/262307f9-8dfb-41c8-bf46-f88738cd098d" />


#### Langkah 3 — Validasi dan Reload

**Console perangkat: Gojo**

```bash
nginx -t && nginx -s reload
```

**SS 19-02 — Validasi Nginx**

<img width="692" height="155" alt="image" src="https://github.com/user-attachments/assets/df8b7df6-4a10-48b0-8d83-3e40633d215d" />


#### Langkah 4 — Menguji Cache (MISS lalu HIT)

**Console perangkat: Itadori**

```bash
curl -sI http://jujutsu.k28.com/ | grep -i x-cache-status
curl -sI http://jujutsu.k28.com/ | grep -i x-cache-status
```

**Hasil yang diharapkan:** akses pertama `MISS`, akses berikutnya `HIT`.

**SS 19-03 — Status MISS dan HIT**

<img width="735" height="152" alt="image" src="https://github.com/user-attachments/assets/2c8131ce-3b6d-4c06-a13a-55435ba71d7e" />

#### Langkah 5 — Menguji Rate Limiting

**Console perangkat: Itadori**

```bash
for i in $(seq 1 30); do curl -s -o /dev/null -w "%{http_code}\n" http://jujutsu.k28.com/api; done | sort | uniq -c
```

**Hasil yang diharapkan:** sebagian respons `200` dan sisanya `429` saat batas terlampaui.

**SS 19-04 — Rate Limiting Aktif**

<img width="722" height="148" alt="image" src="https://github.com/user-attachments/assets/b888de79-4a78-49d9-abf1-20d023550260" />


### Catatan Pengujian Ulang

Cache bertahan 10 menit; untuk mengulang MISS, kosongkan cache (`rm -rf /var/cache/nginx/web/*`) lalu reload Nginx. Jumlah `429` bisa bervariasi karena bergantung pada kecepatan loop.

### Kesimpulan

Gojo berhasil menerapkan proxy cache 10 menit dengan `X-Cache-Status` yang menunjukkan MISS lalu HIT. Rate limiting 10 r/s pada `/api` menghasilkan respons `429` ketika batas terlampaui.

### Otomatisasi Pengujian Menggunakan Script

#### Script Cache dan Rate Limit pada Gojo

**Cara membuat script**

Pada console Gojo, buat file `/root/soal19_gojo.sh`:

```bash
#!/bin/bash
set -e

echo "=== Setup Soal 19: Cache dan Rate Limit ==="

# Simpan konfigurasi aktif sebelum diubah
cp /etc/nginx/sites-available/default \
   /root/soal19_gojo_before.conf

mkdir -p /var/cache/nginx/frontend_cache
chown -R www-data:www-data /var/cache/nginx/frontend_cache

# Pengaturan global: cache dan rate limit
cat > /etc/nginx/conf.d/soal19_limits.conf <<'CONF'
proxy_cache_path /var/cache/nginx/frontend_cache
    levels=1:2
    keys_zone=frontend_cache:10m
    max_size=100m
    inactive=30m
    use_temp_path=off;

```

```bash
chmod +x /root/soal19_gojo.sh
```

**Cara menjalankan script**

```bash
bash /root/soal19_gojo.sh
```

**Fungsi:** menambahkan proxy cache dan rate limit, memvalidasi, dan me-reload Nginx. Konfigurasi sebelumnya dicadangkan di `soal16_gojo_backup_before19.conf` dan `soal19_gojo_before.conf`.


#### Urutan Menjalankan Script 

1. **Gojo:** `bash /root/soal19_gojo.sh`
2. **Itadori:** `curl -sI` dua kali ke `/` (MISS lalu HIT).
3. **Itadori:** loop 30 request ke `/api`, hitung kode respons.

---
# Soal 20
## Benchmark dengan Apache Benchmark dan Analisis Access Log

Kusakabe memimpin audit kapasitas layanan sebelum Curtain dibuka. Dari terminal Kusakabe dijalankan `ab -n 600 -c 30` ke `http://jujutsu.k28.com/` dan `/api` untuk mencatat RPS, latensi, dan request gagal. Hasil baseline dibandingkan dengan saat rate limiting aktif, dan access log Gojo dipakai untuk membedakan kegagalan aplikasi, koneksi, dan penolakan rate limit.

### Langkah Pengerjaan

#### Langkah 1 — Memasang Apache Benchmark

**Console perangkat: Kusakabe**

```bash
apk add apache2-utils
ab -V
```

**Hasil yang diharapkan:** versi `ab` tampil.

> Jika paket tidak tersedia, pastikan Kusakabe punya DNS/internet dan repository `apk` aktif.

#### Langkah 2 — Benchmark Baseline (Halaman Web)

**Console perangkat: Kusakabe**

```bash
ab -n 600 -c 30 http://jujutsu.k28.com/
```

**Hasil yang diharapkan:** catat `Requests per second`, `Time per request`, dan `Failed requests`.

**SS 20-01 — Benchmark Halaman Web**

<img width="1113" height="1028" alt="image" src="https://github.com/user-attachments/assets/b0f0ded2-dc74-4866-a742-30934bd418b2" />


#### Langkah 3 — Benchmark Endpoint `/api` (Rate Limit Aktif)

**Console perangkat: Kusakabe**

```bash
ab -n 600 -c 30 http://jujutsu.k28.com/api
```

**Hasil yang diharapkan:** `Non-2xx responses` muncul karena request melebihi 10 r/s ditolak `429`.

**SS 20-02 — Benchmark `/api` dengan Rate Limit**

<img width="841" height="1077" alt="image" src="https://github.com/user-attachments/assets/0078cb3e-910a-43b8-81ba-e2b60e00d36b" />

#### Langkah 4 — Pembanding Tanpa Rate Limit

**Console perangkat: Gojo lalu Kusakabe**

Nonaktifkan sementara `limit_req` pada `location /api` (backup tersedia di `soal20-rate-limit-backup.conf`), lalu `nginx -t && nginx -s reload`. Ulangi:

```bash
ab -n 600 -c 30 http://jujutsu.k28.com/api
```

Aktifkan kembali `limit_req` setelah pengujian.

**Hasil yang diharapkan:** `Non-2xx responses` turun drastis dan RPS berbeda dibanding saat rate limit aktif.

**SS 20-03 — Benchmark `/api` Tanpa Rate Limit**

<img width="1083" height="1062" alt="image" src="https://github.com/user-attachments/assets/3d7a4404-54e2-495f-b6d1-08b6ee64430e" />

#### Langkah 5 — Menganalisis Access Log Gojo

**Console perangkat: Gojo**

```bash
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn
```

**Hasil yang diharapkan:** pembagian kode status sebagai berikut.

| Kode | Arti |
|---|---|
| `200` | Request berhasil |
| `429` | Ditolak kebijakan rate limit |
| `502` / `504` | Kegagalan aplikasi atau upstream |
| Tidak ada baris log, tetapi `ab` melaporkan gagal | Kegagalan koneksi |

**SS 20-04 — Rekap Access Log**

<img width="738" height="196" alt="image" src="https://github.com/user-attachments/assets/ed02cee0-c520-4127-8308-d227f64b5137" />

#### Langkah 6 — Tabel Perbandingan

Isi dengan hasil aktual:

| Pengujian | RPS | Latensi rata-rata (ms) | Failed requests | Non-2xx |
|---|---|---|---|---|
| `/` (baseline) | `<isi>` | `<isi>` | `<isi>` | `<isi>` |
| `/api` (rate limit aktif) | `<isi>` | `<isi>` | `<isi>` | `<isi>` |
| `/api` (tanpa rate limit) | `<isi>` | `<isi>` | `<isi>` | `<isi>` |

### Catatan Pengujian Ulang

Jalankan `ab` dari Kusakabe saja agar IP klien konsisten, dan kosongkan log (`: > /var/log/nginx/access.log`) sebelum tiap pengujian agar rekap tidak bercampur. Pastikan `limit_req` diaktifkan kembali setelah pembanding.

### Kesimpulan

Benchmark `-n 600 -c 30` menunjukkan kapasitas halaman web (dibantu cache) dan efek rate limiting pada `/api`. Access log Gojo membedakan kegagalan aplikasi (`502`/`504`), kegagalan koneksi, dan penolakan kebijakan (`429`).

### Otomatisasi Pengujian Menggunakan Script

#### Script Benchmark pada Kusakabe

**Cara membuat script**

Pada console Kusakabe, buat file `/root/soal20_kusakabe.sh` (dan `/root/soal20-benchmark.sh` jika dipakai terpisah):

```bash
#!/bin/sh
set -u

DOMAIN="jujutsu.k28.com"
GOJO_IP="192.225.1.4"
LOG="/root/soal20_benchmark_$(date +%Y%m%d_%H%M%S).log"

echo "=== Soal 20: Apache Benchmark ==="
echo "Waktu mulai: $(date)"
echo "Log: $LOG"

# Instal Apache Benchmark pada Alpine jika belum tersedia
if ! command -v ab >/dev/null 2>&1; then
    echo "Apache Benchmark belum tersedia. Menggunakan apk..."
    apk add --no-cache apache2-utils || {
        echo "ERROR: Instalasi apache2-utils gagal."
        echo "Periksa koneksi jaringan dan repository Alpine."
        exit 1
    }
fi

```

```bash
#!/bin/bash

DOMAIN="jujutsu.k28.com"
BASE="http://${DOMAIN}"
OUT="/root/soal20-hasil-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$OUT"

# Pastikan Apache Benchmark tersedia
if ! command -v ab >/dev/null 2>&1; then
    echo "Apache Benchmark belum tersedia."
    echo "Jalankan: apt-get update && apt-get install -y apache2-utils"
    exit 1
fi

# Periksa target sebelum benchmark
if ! getent hosts "$DOMAIN"; then
    echo "Domain tidak bisa di-resolve. Benchmark dibatalkan."
    exit 1
fi

```

```bash
chmod +x /root/soal20_kusakabe.sh /root/soal20-benchmark.sh
```

**Cara menjalankan script**

```bash
sh /root/soal20_kusakabe.sh
sh /root/soal20-benchmark.sh
```

**Fungsi:** menjalankan `ab` ke `/` dan `/api`, lalu menyimpan hasil ke direktori `/root/soal20-hasil*` dan log `/root/soal20_benchmark_*.log`.

#### Urutan Menjalankan Script 

1. **Gojo:** pastikan `bash /root/soal19_gojo.sh` sudah aktif, lalu kosongkan access log.
2. **Kusakabe:** `sh /root/soal20_kusakabe.sh`
3. **Gojo:** jalankan rekap access log (Langkah 5).
4. **Kusakabe:** lengkapi tabel perbandingan.
