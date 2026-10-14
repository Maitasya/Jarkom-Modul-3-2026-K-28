## Kelompok K-28

| Nama | NRP |
| :---: | :---: |
| Maitasya Rohmatul Ula | 5027251026 |
| A. Algifari Rantiga Isdar | 5027251084 |

# LAPORAN RESMI PRAKTIKUM KOMUNIKASI DATA & JARINGAN KOMPUTER
## MODUL 3: CURTAIN PROTOCOL - SHIBUYA INCIDENT
---

### Informasi Dasar Pengalamatan Subnet (Prefix 192.225 /24)
* **Network 1 (DMZ)**: `192.225.1.0/24` — Gateway: `192.225.1.1` pada antarmuka `eth1` Jichi
* **Network 2 (Divisi A)**: `192.225.2.0/24` — Gateway: `192.225.2.1` pada antarmuka `eth2` Jichi
* **Network 3 (Divisi B)**: `192.225.3.0/24` — Gateway: `192.225.3.1` pada antarmuka `eth3` Jichi
* **Network 4 (Data Center)**: `192.225.4.0/24` — Gateway: `192.225.4.1` pada antarmuka `eth4` Jichi
* **Koneksi Eksternal / WAN**: Interface `eth0` Jichi terhubung ke NAT node GNS3

---

## SOAL 1: Konfigurasi Interface, Routing Gateway, IPv4 Forwarding, dan Source NAT Masquerade pada Jichi

### A. Langkah-Langkah Pengerjaan Manual

1. Buka terminal console node **Jichi** melalui GNS3.
2. Aktifkan seluruh antarmuka jaringan yang terhubung (`eth0` sampai `eth4`):
   ```bash
   ip link set eth0 up
   ip link set eth1 up
   ip link set eth2 up
   ip link set eth3 up
   ip link set eth4 up
   ```

3. Tetapkan alamat IP gateway untuk masing-masing subnet internal pada antarmuka `eth1`–`eth4`:
   ```bash
   ip addr flush dev eth1
   ip addr add 192.225.1.1/24 dev eth1

   ip addr flush dev eth2
   ip addr add 192.225.2.1/24 dev eth2

   ip addr flush dev eth3
   ip addr add 192.225.3.1/24 dev eth3

   ip addr flush dev eth4
   ip addr add 192.225.4.1/24 dev eth4
   ```

4. Periksa apakah seluruh IP gateway telah terpasang dengan benar pada interface masing-masing:
   ```bash
   ip -br a
   ```
   > **[TEMPAT SCREENSHOT 1.1]**: Output perintah `ip -br a` di terminal Jichi yang memperlihatkan `eth0` memperoleh IP WAN/NAT, dan `eth1`–`eth4` memiliki IP `192.225.1.1/24` sampai `192.225.4.1/24`.

5. Aktifkan fitur routing kernel Linux (IPv4 Packet Forwarding):
   ```bash
   echo 1 > /proc/sys/net/ipv4/ip_forward
   ```

6. Tambahkan aturan Source NAT (MASQUERADE) menggunakan iptables pada antarmuka WAN (`eth0`):
   ```bash
   iptables -t nat -F POSTROUTING
   iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
   ```

7. Verifikasi aturan NAT dan status forwarding di Jichi:
   ```bash
   cat /proc/sys/net/ipv4/ip_forward
   iptables -t nat -L POSTROUTING -v -n
   ```
   > **[TEMPAT SCREENSHOT 1.2]**: Output `cat /proc/sys/net/ipv4/ip_forward` bernilai `1` dan output `iptables -t nat -L POSTROUTING -v -n` yang menampilkan chain POSTROUTING dengan target `MASQUERADE` pada interface `eth0`.

8. Tetapkan DNS resolver lokal awal di Jichi:
   ```bash
   echo "nameserver 192.168.122.1" > /etc/resolv.conf
   ```

9. Lakukan uji konektivitas ke internet langsung dari Jichi:
   ```bash
   ping -c 3 8.8.8.8
   ```

10. Masuk ke salah satu node di Network 4, misalnya **Tengen**, tetapkan IP statis dan default gateway untuk membuktikan konektivitas melalui Jichi:
    ```bash
    ip addr add 192.225.4.10/24 dev eth0
    ip route add default via 192.225.4.1
    ping -c 3 192.225.4.1
    ping -c 3 8.8.8.8
    ```
    > **[TEMPAT SCREENSHOT 1.3]**: Hasil ping dari Jichi ke `8.8.8.8` serta hasil ping dari node internal (`Tengen`) menuju gateway `192.225.4.1` dan tembus ke internet `8.8.8.8` (membuktikan NAT Masquerade berhasil).

### B. Isi Skrip Konfigurasi dan Cara Menjalankannya

Sesuai aturan praktikum nomor 5, skrip disimpan di direktori root node **Jichi** pada file `/root/setup_soal1.sh`:

```bash
#!/bin/bash
# ==========================================
# Skrip Soal 1: Konfigurasi Interface, Routing, dan NAT di Jichi
# Simpan di: /root/setup_soal1.sh
# ==========================================

echo "=== [1] Mengaktifkan Interface Jichi ==="
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up
ip link set eth3 up
ip link set eth4 up

echo "=== [2] Mengonfigurasi IP Gateway Subnet ==="
ip addr flush dev eth1
ip addr add 192.225.1.1/24 dev eth1

ip addr flush dev eth2
ip addr add 192.225.2.1/24 dev eth2

ip addr flush dev eth3
ip addr add 192.225.3.1/24 dev eth3

ip addr flush dev eth4
ip addr add 192.225.4.1/24 dev eth4

echo "=== [3] Mengaktifkan IPv4 Packet Forwarding ==="
echo 1 > /proc/sys/net/ipv4/ip_forward

echo "=== [4] Mengatur Source NAT (MASQUERADE) via eth0 ==="
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo "=== [5] Menetapkan DNS Resolver Awal ==="
echo "nameserver 192.168.122.1" > /etc/resolv.conf

echo "=== Selesai Mengonfigurasi Soal 1 ==="
ip -br a
```

**Cara Menjalankan Skrip:**
1. Buka konsol terminal node **Jichi**.
2. Buat dan simpan skrip di `/root/setup_soal1.sh`.
3. Berikan hak akses eksekusi pada skrip:
   ```bash
   chmod +x /root/setup_soal1.sh
   ```
4. Jalankan skrip konfigurasi:
   ```bash
   /root/setup_soal1.sh
   ```
5. Periksa hasil eksekusi dan jalankan uji ping untuk memastikan rute aktif:
   ```bash
   ping -c 3 8.8.8.8
   ```

---

## SOAL 2: Konfigurasi Dasar ISC DHCP Server di Tengen (Deklarasi Subnet Tanpa Error)

### A. Langkah-Langkah Pengerjaan Manual

1. Buka terminal console node **Tengen**.
2. Konfigurasikan IP statis pada antarmuka `eth0` beserta default gateway ke arah router Jichi:
   ```bash
   ip addr flush dev eth0
   ip addr add 192.225.4.10/24 dev eth0
   ip link set eth0 up
   ip route flush default
   ip route add default via 192.225.4.1
   echo "nameserver 192.168.122.1" > /etc/resolv.conf
   ```

3. Edit file pengaturan antarmuka DHCP Server di `/etc/default/isc-dhcp-server`:
   ```bash
   nano /etc/default/isc-dhcp-server
   ```
   Atur antarmuka yang akan mendengarkan request DHCP menjadi `eth0`:
   ```text
   INTERFACESv4="eth0"
   INTERFACESv6=""
   ```
   > **[TEMPAT SCREENSHOT 2.1]**: Tampilkan isi file `/etc/default/isc-dhcp-server` yang menunjukkan `INTERFACESv4="eth0"`.

4. Buka dan edit file konfigurasi utama DHCP `/etc/dhcp/dhcpd.conf`:
   ```bash
   nano /etc/dhcp/dhcpd.conf
   ```

5. Tuliskan opsi global domain dan deklarasikan Network 4 (`192.225.4.0/24`) sebagai subnet lokal kosong tanpa alokasi pool dinamis agar daemon tidak memunculkan error *"No subnet declaration for eth0"*, lalu siapkan blok deklarasi subnet untuk Network 2 (`192.225.2.0/24`) dan Network 3 (`192.225.3.0/24`):
   ```text
   ddns-update-style none;
   authoritative;

   option domain-name "K28.com";
   option domain-name-servers 192.225.1.2, 192.225.1.3;

   # Subnet lokal Data Center tanpa pool dinamis (Mencegah error 'No subnet declaration')
   subnet 192.225.4.0 netmask 255.255.255.0 {
   }

   # Scope Subnet Network 2 (Divisi A)
   subnet 192.225.2.0 netmask 255.255.255.0 {
       option routers 192.225.2.1;
       option subnet-mask 255.255.255.0;
       option broadcast-address 192.225.2.255;
       option domain-name-servers 192.225.1.2, 192.225.1.3;
       option domain-search "K28.com";
   }

   # Scope Subnet Network 3 (Divisi B)
   subnet 192.225.3.0 netmask 255.255.255.0 {
       option routers 192.225.3.1;
       option subnet-mask 255.255.255.0;
       option broadcast-address 192.225.3.255;
       option domain-name-servers 192.225.1.2, 192.225.1.3;
       option domain-search "K28.com";
   }
   ```
   > **[TEMPAT SCREENSHOT 2.2]**: Tampilkan potongan file `/etc/dhcp/dhcpd.conf` yang memperlihatkan blok deklarasi kosong `subnet 192.225.4.0 netmask 255.255.255.0 { }`.

6. Lakukan pengujian validasi sintaks file konfigurasi:
   ```bash
   dhcpd -t -cf /etc/dhcp/dhcpd.conf
   ```

7. Jalankan ulang layanan daemon DHCP Server dan periksa statusnya:
   ```bash
   service isc-dhcp-server restart
   service isc-dhcp-server status
   ```
   > **[TEMPAT SCREENSHOT 2.3]**: Tampilkan output `dhcpd -t -cf /etc/dhcp/dhcpd.conf` yang bebas dari pesan error dan output `service isc-dhcp-server status` dengan status running normal.

### B. Isi Skrip Konfigurasi dan Cara Menjalankannya

Skrip disimpan di direktori root node **Tengen** pada file `/root/setup_soal2.sh`:

```bash
#!/bin/bash
# ==========================================
# Skrip Soal 2: Konfigurasi Dasar DHCP Server di Tengen
# Simpan di: /root/setup_soal2.sh
# ==========================================

echo "=== [1] Mengonfigurasi Interface dan Route Tengen ==="
ip addr flush dev eth0
ip addr add 192.225.4.10/24 dev eth0
ip link set eth0 up
ip route flush default
ip route add default via 192.225.4.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf

echo "=== [2] Mengatur /etc/default/isc-dhcp-server ==="
cat << 'EOF' > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
EOF

echo "=== [3] Mengatur /etc/dhcp/dhcpd.conf ==="
cat << 'EOF' > /etc/dhcp/dhcpd.conf
ddns-update-style none;
authoritative;

option domain-name "K28.com";
option domain-name-servers 192.225.1.2, 192.225.1.3;

# Subnet 4 lokal Data Center tanpa pool dinamis
subnet 192.225.4.0 netmask 255.255.255.0 {
}

# Subnet 2 Divisi A
subnet 192.225.2.0 netmask 255.255.255.0 {
    option routers 192.225.2.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.225.2.255;
    option domain-name-servers 192.225.1.2, 192.225.1.3;
    option domain-search "K28.com";
}

# Subnet 3 Divisi B
subnet 192.225.3.0 netmask 255.255.255.0 {
    option routers 192.225.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.225.3.255;
    option domain-name-servers 192.225.1.2, 192.225.1.3;
    option domain-search "K28.com";
}
EOF

echo "=== [4] Memvalidasi Sintaks DHCP ==="
dhcpd -t -cf /etc/dhcp/dhcpd.conf

echo "=== [5] Menjalankan Ulang Service isc-dhcp-server ==="
service isc-dhcp-server restart
service isc-dhcp-server status
```

**Cara Menjalankan Skrip:**
1. Buka konsol terminal node **Tengen**.
2. Simpan skrip di `/root/setup_soal2.sh`.
3. Berikan izin eksekusi:
   ```bash
   chmod +x /root/setup_soal2.sh
   ```
4. Jalankan skrip:
   ```bash
   /root/setup_soal2.sh
   ```
5. Periksa status layanan untuk memastikan dhcpd berjalan:
   ```bash
   ps aux | grep dhcpd
   ```

---

## SOAL 3: Konfigurasi DHCP Relay pada Jichi

### A. Langkah-Langkah Pengerjaan Manual

1. Buka terminal console node **Jichi**.
2. Buka file konfigurasi DHCP Relay `/etc/default/isc-dhcp-relay`:
   ```bash
   nano /etc/default/isc-dhcp-relay
   ```

3. Arahkan server tujuan relay ke IP Tengen (`192.225.4.10`) dan tentukan interface yang terlibat: `eth2` (klien Network 2), `eth3` (klien Network 3), dan `eth4` (jalur keluar menuju server Tengen):
   ```text
   SERVERS="192.225.4.10"
   INTERFACES="eth2 eth3 eth4"
   OPTIONS=""
   ```
   > **[TEMPAT SCREENSHOT 3.1]**: Tampilkan isi file `/etc/default/isc-dhcp-relay` di terminal Jichi.

4. Simpan konfigurasi lalu mulai ulang layanan daemon relay:
   ```bash
   service isc-dhcp-relay restart
   ```

5. Verifikasi bahwa proses relay berjalan di sistem:
   ```bash
   ps aux | grep dhcrelay
   ```
   > **[TEMPAT SCREENSHOT 3.2]**: Tampilkan output `ps aux | grep dhcrelay` di Jichi yang memperlihatkan daemon aktif mendengarkan di interface yang telah diatur.

6. Buka konsol klien di Network 2 (misalnya `Itadori`) dan Network 3 (misalnya `Ino`) untuk menguji perolehan IP:
   ```bash
   # Di klien Itadori:
   udhcpc -i eth0 -n -q
   ip -br a show eth0
   ip route

   # Di klien Ino:
   udhcpc -i eth0 -n -q
   ip -br a show eth0
   ip route
   ```
   > **[TEMPAT SCREENSHOT 3.3]**: Tampilkan output perintah `udhcpc`, `ip -br a show eth0`, dan `ip route` pada node `Itadori` dan `Ino` yang membuktikan klien dari kedua subnet berbeda berhasil menerima lease IP dan rute gateway melalui relay Jichi.

### B. Isi Skrip Konfigurasi dan Cara Menjalankannya

Skrip disimpan di direktori root node **Jichi** pada file `/root/setup_soal3.sh`:

```bash
#!/bin/bash
# ==========================================
# Skrip Soal 3: Konfigurasi DHCP Relay di Jichi
# Simpan di: /root/setup_soal3.sh
# ==========================================

echo "=== [1] Mengonfigurasi /etc/default/isc-dhcp-relay ==="
cat << 'EOF' > /etc/default/isc-dhcp-relay
SERVERS="192.225.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
EOF

echo "=== [2] Menjalankan Ulang Layanan isc-dhcp-relay ==="
service isc-dhcp-relay restart

echo "=== [3] Verifikasi Status Proses DHCP Relay ==="
ps aux | grep dhcrelay
```

**Cara Menjalankan Skrip:**
1. Buka konsol terminal node **Jichi**.
2. Simpan skrip di `/root/setup_soal3.sh`.
3. Berikan izin eksekusi:
   ```bash
   chmod +x /root/setup_soal3.sh
   ```
4. Jalankan skrip:
   ```bash
   /root/setup_soal3.sh
   ```
5. Pastikan daemon berjalan dengan memeriksa output `ps aux | grep dhcrelay`.

---

## SOAL 4: Pembagian DHCP Class dan Dua Pool Alokasi di Network 2

### A. Langkah-Langkah Pengerjaan Manual

1. Catat MAC address kartu jaringan `eth0` milik seluruh klien di Network 2:
   * `Itadori`: `02:42:33:e9:7e:00`
   * `Fushiguro`: `02:42:7b:f1:68:00`
   * `Zenin`: `02:42:6b:7c:b7:00`
   * `Okkotsu`: `02:42:9f:c2:73:00`

2. Buka terminal console node **Tengen**.
3. Edit file konfigurasi DHCP `/etc/dhcp/dhcpd.conf`:
   ```bash
   nano /etc/dhcp/dhcpd.conf
   ```

4. Tambahkan deklarasi `class` pada bagian atas file konfigurasi (sebelum blok deklarasi subnet):
   ```text
   # Class Pool 1 untuk Itadori dan Fushiguro
   class "pool1-clients" {
       match if substring(hardware, 1, 6) = 02:42:33:e9:7e:00 or
                substring(hardware, 1, 6) = 02:42:7b:f1:68:00;
   }

   # Class Pool 2 untuk Zenin dan Okkotsu
   class "pool2-clients" {
       match if substring(hardware, 1, 6) = 02:42:6b:7c:b7:00 or
                substring(hardware, 1, 6) = 02:42:9f:c2:73:00;
   }
   ```

5. Modifikasi blok `subnet 192.225.2.0 netmask 255.255.255.0` agar memiliki dua pool terpisah yang membatasi alokasi IP berdasarkan keanggotaan kelas, serta mengosongkan rentang `.2.36` sampai `.2.69`:
   ```text
   subnet 192.225.2.0 netmask 255.255.255.0 {
       option routers 192.225.2.1;
       option subnet-mask 255.255.255.0;
       option broadcast-address 192.225.2.255;
       option domain-name-servers 192.225.1.2, 192.225.1.3;
       option domain-search "K28.com";

       # Pool 1 (192.225.2.10 - 192.225.2.35) untuk Itadori & Fushiguro
       pool {
           allow members of "pool1-clients";
           range 192.225.2.10 192.225.2.35;
       }

       # Pool 2 (192.225.2.70 - 192.225.2.95) untuk Zenin & Okkotsu
       pool {
           allow members of "pool2-clients";
           range 192.225.2.70 192.225.2.95;
       }
   }
   ```
   > **[TEMPAT SCREENSHOT 4.1]**: Tampilkan potongan file `/etc/dhcp/dhcpd.conf` pada definisi `class "pool1-clients"`, `class "pool2-clients"`, serta blok Pool 1 dan Pool 2 di subnet Network 2.

6. Validasi sintaks dan restart ISC DHCP Server di node Tengen:
   ```bash
   dhcpd -t -cf /etc/dhcp/dhcpd.conf
   service isc-dhcp-server restart
   ```

7. Uji perolehan IP pada klien Pool 1. Buka konsol node **Itadori** dan **Fushiguro**:
   ```bash
   killall udhcpc 2>/dev/null
   udhcpc -i eth0 -n -q
   ip -br a show eth0
   ```
   > **[TEMPAT SCREENSHOT 4.2]**: Tampilkan output `ip -br a` pada klien `Itadori` (`192.225.2.10`) dan `Fushiguro` (`192.225.2.11`) yang membuktikan keduanya memperoleh IP dalam rentang Pool 1 (`192.225.2.10`–`.2.35`).

8. Uji perolehan IP pada klien Pool 2. Buka konsol node **Zenin** dan **Okkotsu**:
   ```bash
   killall udhcpc 2>/dev/null
   udhcpc -i eth0 -n -q
   ip -br a show eth0
   ```
   > **[TEMPAT SCREENSHOT 4.3]**: Tampilkan output `ip -br a` pada klien `Zenin` (`192.225.2.70`) dan `Okkotsu` (`192.225.2.71`) yang membuktikan keduanya memperoleh IP dalam rentang Pool 2 (`192.225.2.70`–`.2.95`), serta membuktikan rentang tengah `.2.36` s/d `.2.69` terisolasi dan tidak dialokasikan.

### B. Isi Skrip Konfigurasi dan Cara Menjalankannya

Skrip disimpan di direktori root node **Tengen** pada file `/root/setup_soal4.sh`:

```bash
#!/bin/bash
# ==========================================
# Skrip Soal 4: Konfigurasi DHCP Class dan Dua Pool Network 2
# Simpan di: /root/setup_soal4.sh
# ==========================================

cat << 'EOF' > /etc/dhcp/dhcpd.conf
ddns-update-style none;
authoritative;

option domain-name "K28.com";
option domain-name-servers 192.225.1.2, 192.225.1.3;

# Definisi Kelas Klien Network 2 (Soal 4)
class "pool1-clients" {
    match if substring(hardware, 1, 6) = 02:42:33:e9:7e:00 or
             substring(hardware, 1, 6) = 02:42:7b:f1:68:00;
}

class "pool2-clients" {
    match if substring(hardware, 1, 6) = 02:42:6b:7c:b7:00 or
             substring(hardware, 1, 6) = 02:42:9f:c2:73:00;
}

# Subnet 4 lokal Data Center
subnet 192.225.4.0 netmask 255.255.255.0 {
}

# Subnet 2 Divisi A dengan Dua Pool Alokasi
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

# Subnet 3 Divisi B
subnet 192.225.3.0 netmask 255.255.255.0 {
    option routers 192.225.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.225.3.255;
    option domain-name-servers 192.225.1.2, 192.225.1.3;
    option domain-search "K28.com";
}
EOF

dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
```

**Cara Menjalankan Skrip:**
1. Buka konsol terminal node **Tengen**.
2. Simpan skrip di `/root/setup_soal4.sh`.
3. Berikan izin eksekusi dan jalankan:
   ```bash
   chmod +x /root/setup_soal4.sh
   /root/setup_soal4.sh
   ```
4. Buka terminal masing-masing klien di Network 2 (`Itadori`, `Fushiguro`, `Zenin`, `Okkotsu`) dan minta IP baru:
   ```bash
   udhcpc -i eth0 -n -q
   ip -br a show eth0
   ```

---

## SOAL 5: Pengaturan Durasi Lease Time (Short Lease 30 Menit & Long Lease 12 Jam) pada Network 3

### A. Langkah-Langkah Pengerjaan Manual

1. Catat MAC address kartu jaringan `eth0` milik klien di Network 3:
   * `Ino`: `02:42:2c:11:46:00`
   * `Kusakabe`: `02:42:94:28:a5:00`
   * `miwa`: `02:42:84:4d:0b:00`

2. Buka terminal console node **Tengen**.
3. Edit file konfigurasi DHCP `/etc/dhcp/dhcpd.conf`:
   ```bash
   nano /etc/dhcp/dhcpd.conf
   ```

4. Tambahkan pendefinisian class lease time:
   * Class `short-lease-clients` untuk Ino dan Kusakabe dengan waktu sewa 30 menit (`1800 detik`).
   * Class `long-lease-clients` untuk Miwa dengan waktu sewa 12 jam (`43200 detik`).
   ```text
   # Class Short Lease: 30 menit (1800 detik)
   class "short-lease-clients" {
       match if substring(hardware, 1, 6) = 02:42:2c:11:46:00 or
                substring(hardware, 1, 6) = 02:42:94:28:a5:00;
       default-lease-time 1800;
       max-lease-time 1800;
   }

   # Class Long Lease: 12 jam (43200 detik)
   class "long-lease-clients" {
       match if substring(hardware, 1, 6) = 02:42:84:4d:0b:00;
       default-lease-time 43200;
       max-lease-time 43200;
   }
   ```

5. Perbarui blok deklarasi `subnet 192.225.3.0 netmask 255.255.255.0` agar memiliki dua pool terpisah:
   * Pool Short Lease: Rentang `192.225.3.10` – `192.225.3.89` untuk anggota `short-lease-clients`.
   * Pool Long Lease: Rentang `192.225.3.100` – `192.225.3.199` untuk anggota `long-lease-clients`.
   * Options: DNS Server `192.225.1.2`, `192.225.1.3`, dan domain search `K28.com`.
   ```text
   subnet 192.225.3.0 netmask 255.255.255.0 {
       option routers 192.225.3.1;
       option subnet-mask 255.255.255.0;
       option broadcast-address 192.225.3.255;
       option domain-name-servers 192.225.1.2, 192.225.1.3;
       option domain-search "K28.com";

       # Pool Short Lease (Ino & Kusakabe)
       pool {
           allow members of "short-lease-clients";
           range 192.225.3.10 192.225.3.89;
       }

       # Pool Long Lease (Miwa)
       pool {
           allow members of "long-lease-clients";
           range 192.225.3.100 192.225.3.199;
       }
   }
   ```
   > **[TEMPAT SCREENSHOT 5.1]**: Tampilkan potongan file `/etc/dhcp/dhcpd.conf` pada class `short-lease-clients`, `long-lease-clients`, dan kedua blok pool di Network 3.

6. Simpan perubahan file lalu restart layanan DHCP Server di Tengen:
   ```bash
   dhcpd -t -cf /etc/dhcp/dhcpd.conf
   service isc-dhcp-server restart
   ```

7. Uji pada klien short lease. Buka konsol **Ino** dan **Kusakabe**:
   ```bash
   killall udhcpc 2>/dev/null
   udhcpc -i eth0 -n -q
   ip -br a show eth0
   cat /etc/resolv.conf
   ```
   > **[TEMPAT SCREENSHOT 5.2]**: Tampilkan output `ip -br a show eth0` pada klien `Ino` atau `Kusakabe` (menerima IP rentang `.3.10`–`.3.89`) beserta output `cat /etc/resolv.conf` yang menampilkan nameserver `192.225.1.2`, `192.225.1.3` dan search domain `K28.com`.

8. Uji pada klien long lease. Buka konsol **miwa**:
   ```bash
   killall udhcpc 2>/dev/null
   udhcpc -i eth0 -n -q
   ip -br a show eth0
   cat /etc/resolv.conf
   ```
   > **[TEMPAT SCREENSHOT 5.3]**: Tampilkan output `ip -br a show eth0` pada klien `miwa` (menerima IP rentang `.3.100`–`.3.199`).

9. Verifikasi pembuktian durasi sewa (*lease time*) pada database server DHCP di node **Tengen**:
   ```bash
   cat /var/lib/dhcp/dhcpd.leases | grep -E "lease|starts|ends|hardware" | tail -n 25
   ```
   > **[TEMPAT SCREENSHOT 5.4]**: Tampilkan isi `/var/lib/dhcp/dhcpd.leases` di node Tengen yang memperlihatkan selisih waktu `starts` dan `ends`:
   > * Klien Short Lease (`Ino` / `Kusakabe`): selisih waktu sewa tepat **30 menit** (1800 detik).
   > * Klien Long Lease (`Miwa`): selisih waktu sewa tepat **12 jam** (43200 detik).

### B. Isi Skrip Konfigurasi dan Cara Menjalankannya

Skrip disimpan di direktori root node **Tengen** pada file `/root/setup_soal5.sh`:

```bash
#!/bin/bash
# ==========================================
# Skrip Soal 5: Konfigurasi Short Lease & Long Lease Network 3
# Simpan di: /root/setup_soal5.sh
# ==========================================

cat << 'EOF' > /etc/dhcp/dhcpd.conf
ddns-update-style none;
authoritative;

option domain-name "K28.com";
option domain-name-servers 192.225.1.2, 192.225.1.3;

# Definisi Kelas Network 2 (Soal 4)
class "pool1-clients" {
    match if substring(hardware, 1, 6) = 02:42:33:e9:7e:00 or
             substring(hardware, 1, 6) = 02:42:7b:f1:68:00;
}

class "pool2-clients" {
    match if substring(hardware, 1, 6) = 02:42:6b:7c:b7:00 or
             substring(hardware, 1, 6) = 02:42:9f:c2:73:00;
}

# Definisi Kelas Network 3 (Soal 5)
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

# Network 4: Subnet Lokal Data Center tanpa pool dinamis (Soal 2)
subnet 192.225.4.0 netmask 255.255.255.0 {
}

# Network 2: Subnet Divisi A (Soal 4)
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

# Network 3: Subnet Divisi B (Soal 5)
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
EOF

dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
```

**Cara Menjalankan Skrip:**
1. Buka konsol terminal node **Tengen**.
2. Simpan skrip di `/root/setup_soal5.sh`.
3. Berikan izin eksekusi dan jalankan:
   ```bash
   chmod +x /root/setup_soal5.sh
   /root/setup_soal5.sh
   ```
4. Buka terminal klien di Network 3 (`Ino`, `Kusakabe`, `miwa`) dan jalankan skrip permohonan IP `/root/get_ip.sh`:
   ```sh
   sh /root/get_ip.sh
   ```


---
### Soal 6
## DHCP Static Lease untuk Kugisaki

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

**SS 6-01 — Konfigurasi Static Lease**
<img width="960" height="504" alt="SS 1 — Konfigurasi Static Lease" src="https://github.com/user-attachments/assets/db9f10b3-7d64-46e6-9401-428e0e60c660" />

#### Langkah 3 — Memvalidasi Konfigurasi DHCP

**Console perangkat: Tengen**

Validasi konfigurasi DHCP menggunakan perintah:

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

**Hasil yang diharapkan:** konfigurasi berhasil diperiksa tanpa pesan kesalahan sintaks.

**SS 6-02 — Validasi DHCP**

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

**SS 6-03 — Status Server**

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

**SS 6-04 — DHCP Relay**

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

**SS 6-05 — Client Mendapatkan IP**

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

**SS 6-06 — Verifikasi IP dan Route**

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

####  Script DHCP Server pada Tengen

**Cara membuat script**

Pada console Tengen, buat file `/root/soal6-server.sh` menggunakan perintah:

```bash
#!/bin/bash

echo "=================================="
echo " DEMO SOAL 6 - DHCP SERVER TENGEN"
echo "=================================="

CONFIG="/etc/dhcp/dhcpd.conf"

if [ ! -f "$CONFIG" ]; then
    echo "ERROR: File konfigurasi DHCP tidak ditemukan."
    exit 1
fi

echo
echo "[1] Konfigurasi static lease Kugisaki:"
grep -A 8 'host kugisaki' "$CONFIG"

if [ $? -ne 0 ]; then
    echo "ERROR: Konfigurasi host Kugisaki tidak ditemukan."
    exit 1
fi

echo
echo "[2] Validasi konfigurasi DHCP:"
if ! dhcpd -t -cf "$CONFIG"; then
    echo "ERROR: Konfigurasi DHCP tidak valid."
    exit 1
fi

echo
echo "[3] Memastikan DHCP server berjalan:"
service isc-dhcp-server start

echo
echo "[4] Status DHCP server:"
service isc-dhcp-server status

echo
echo "Pemeriksaan Tengen selesai."
```

Berikan izin eksekusi:

```bash
chmod +x /root/soal6-server.sh
```

**Cara menjalankan script**

```bash
/root/soal6-server.sh
```

**Fungsi:** memeriksa konfigurasi static lease Kugisaki, memvalidasi konfigurasi DHCP, memastikan layanan DHCP server berjalan, dan menampilkan status layanan.

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

**Fungsi:** meminta lease DHCP melalui interface `eth0`, memeriksa IP yang diperoleh, dan memverifikasi gateway. Pengujian dinyatakan berhasil jika Kugisaki memperoleh IP `192.225.3.99` dan gateway `192.225.3.1`.

####  Urutan Menjalankan Script untuk Demonstrasi

Script dijalankan melalui console masing-masing perangkat dengan urutan berikut:

1. **Tengen:** jalankan `/root/soal6-server.sh` untuk memvalidasi konfigurasi dan memastikan DHCP server aktif.
2. **Jichi:** jalankan `/root/soal6-relay.sh` untuk memeriksa serta memastikan DHCP relay aktif.
3. **Kugisaki:** jalankan `/root/soal6-client.sh` untuk meminta IP reservasi dan memverifikasi alamat IP serta gateway.

---
### Soal 7
## Konfigurasi DHCP Server dan DHCP Relay

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

**SS 7-01 — IP dan Routing Tengen**

<img width="959" height="108" alt="IP Tengen dan routing soal7" src="https://github.com/user-attachments/assets/a6cdd139-7688-47d3-86e4-513987ecaa42" />

#### Langkah 2 — Memeriksa Konfigurasi DHCP Server

**Console perangkat: Tengen**

Periksa konfigurasi DHCP menggunakan perintah:

```bash
cat /etc/dhcp/dhcpd.conf
```

**Hasil yang diharapkan:** konfigurasi mencakup subnet Divisi A dan B, rentang IP dinamis, gateway, DNS `192.225.1.2` dan `192.225.1.3`, serta static lease Kugisaki dengan IP `192.225.3.99`.

**SS 7-02 — Konfigurasi DHCP Server**

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

**SS 7-03 — Validasi dan Status DHCP Server**

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

**SS 7-04 — DHCP Relay pada Jichi**

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

- **SS 7-05 — DHCP Client Divisi A.** Tampilkan hasil pemberian IP Itadori, Fushiguro, Zenin, dan Okkotsu.
  
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

**SS 7-07 — Verifikasi Gateway, DNS, dan Domain Pencarian**

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

**SS 7-08 — Pengujian Konektivitas Gateway**

<img width="960" height="516" alt="Ping gateway berhasil soal 7" src="https://github.com/user-attachments/assets/5d5e0831-df6e-4d39-83b3-6f7a053fde92" />

### Catatan Pengujian Ulang

Perintah pemeriksaan konfigurasi, status layanan, alamat IP, routing, dan DNS dapat dijalankan berulang kali. Sebelum menjalankan DHCP relay, periksa prosesnya menggunakan `ps aux | grep '[d]hcrelay'` dan jangan menjalankan relay baru jika proses sebelumnya masih aktif. Jika DHCP server belum berjalan, periksa validitas konfigurasi terlebih dahulu sebelum menjalankan `service isc-dhcp-server start`, lalu ulangi pengujian client setelah relay aktif.

### Kesimpulan

Konfigurasi DHCP server pada Tengen dan DHCP relay pada Jichi berhasil diterapkan sehingga delapan client memperoleh alamat IP sesuai subnet masing-masing. Static lease Kugisaki berhasil memberikan IP `192.225.3.99`, sedangkan pemeriksaan Okkotsu menunjukkan konfigurasi gateway, subnet mask, DNS, dan domain pencarian sesuai hasil yang diharapkan. Pengujian konektivitas Kugisaki ke gateway berhasil dengan `0% packet loss`.

### Otomatisasi Pengujian DHCP Server dan DHCP Relay Menggunakan Script

#### Script DHCP Server pada Tengen

**Cara membuat script**

Pada console Tengen, buat file `/root/soal7-server.sh` menggunakan perintah:

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
chmod +x /root/soal7-server.sh
```

**Cara menjalankan script**

```bash
/root/soal7-server.sh
```

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

Pada console masing-masing klien, buat file `/root/soal7-client.sh` menggunakan perintah:

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
chmod +x /root/soal7-client.sh
```

**Cara menjalankan script**

```bash
/root/soal7-client.sh
```

Jalankan script pada setiap klien: Itadori, Fushiguro, Zenin, Okkotsu, Ino, Kusakabe, Miwa, dan Kugisaki.

**Fungsi:** meminta alamat IP melalui DHCP, menampilkan alamat IP dan routing, memeriksa kesesuaian gateway berdasarkan subnet klien, menampilkan konfigurasi DNS, serta menguji koneksi ke gateway menggunakan `ping`.

#### Script Verifikasi DHCP Server pada Tengen

**Cara membuat script**

Pada console Tengen, buat file `/root/soal7-cek-server.sh` menggunakan perintah:

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
chmod +x /root/soal7-cek-server.sh
```

**Cara menjalankan script**

```bash
/root/soal7-cek-server.sh
```

**Fungsi:** menampilkan alamat IP server, routing, daftar lease yang tercatat, dan status layanan DHCP server untuk membantu verifikasi hasil pengujian.

#### Urutan Menjalankan Script untuk Demonstrasi

Script dijalankan melalui console masing-masing perangkat dengan urutan berikut:

1. **Tengen:** jalankan `/root/soal7-server.sh` untuk memvalidasi konfigurasi dan memastikan DHCP server aktif.
2. **Jichi:** jalankan `/root/soal7-relay.sh` untuk memastikan DHCP relay berjalan. Biarkan terminal tetap terbuka selama pengujian.
3. **Klien Divisi A dan Divisi B:** jalankan `/root/soal7-client.sh` pada setiap klien untuk meminta alamat IP, memeriksa gateway, dan menguji koneksi.
4. **Tengen:** jalankan `/root/soal7-cek-server.sh` untuk memeriksa lease yang tercatat pada DHCP server.

Script ini dijalankan pada perangkat masing-masing, bukan seluruhnya dari satu console. Jika DHCP relay sudah berjalan, script tidak membuat proses relay baru. Untuk menghindari gangguan, jangan menghentikan relay selama pengujian klien berlangsung.

---

# Soal 8
## Packet Capture Proses DHCP Menggunakan tcpdump

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

**SS 8-01 — DHCP Relay Aktif di Jichi**

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

**SS 8-02 — DHCP Server Aktif di Tengen**

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

**SS 8-03 — Packet Capture Siap pada Tengen**


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

**SS 8-04 — Itadori Berhasil Mendapatkan Lease DHCP**

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

**SS 8-05 — Urutan Paket DHCP**

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

**SS 8-06 — Ringkasan Field DHCP dan Verifikasi giaddr**

<img width="960" height="516" alt="Soal8 SS 8-04 (Tengen)" src="https://github.com/user-attachments/assets/af40e61c-c324-453d-984f-5a260eabeae4" />

### Langkah 7 — Memeriksa File Packet Capture

**Konsol perangkat: Tengen**

Untuk membaca kembali paket yang tersimpan, jalankan:

```bash
tcpdump -r /root/soal8.pcap -n -vvv 2>/dev/null | grep -E "BOOTP/DHCP|DHCP-Message|Gateway-IP|Your-IP|Server-ID|Lease-Time"
```

Perintah ini membaca file `/root/soal8.pcap` dan menampilkan pesan DHCP beserta field penting yang tersedia dalam hasil capture.

**SS 8-07 — Verifikasi File Packet Capture**


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

Script digunakan untuk menangkap paket DHCP, menampilkan urutan pesan, serta merangkum alamat server, IP client, lease time, dan `giaddr`.

**Cara menjalankan pengujian client**

Saat Tengen menampilkan instruksi untuk meminta lease, jalankan pada konsol Itadori:

```bash
ip addr flush dev eth0; udhcpc -i eth0 -n -q; ip -4 -br addr show eth0; ip route
```

Setelah pengujian selesai, periksa hasil capture pada Tengen.

**Catatan:** Script menggunakan batas waktu maksimal 90 detik sesuai instruksi terminal. Client harus meminta lease ketika proses capture masih aktif.

### Urutan Script untuk Demonstrasi

1. **Jichi:** periksa DHCP Relay menggunakan `pgrep -a dhcrelay; ip -br addr | grep -E "eth[2-4]"`.
2. **Tengen:** periksa DHCP Server menggunakan `service isc-dhcp-server status`.
3. **Tengen:** jalankan `bash /root/soal8.sh` dan tunggu instruksi.
4. **Itadori:** jalankan perintah `udhcpc` beserta pemeriksaan IP dan routing.
5. **Tengen:** periksa urutan DHCP, ringkasan field, dan nilai `giaddr`.
6. **Tengen:** jika diperlukan, baca file `/root/soal8.pcap` menggunakan `tcpdump -r`.

## Kesimpulan

Packet capture pada Tengen berhasil menunjukkan urutan DHCPDISCOVER → DHCPOFFER → DHCPREQUEST → DHCPACK dengan transaction ID `0x27a4ce0e`. Itadori memperoleh IP `192.225.2.10` dari server `192.225.4.10` dengan lease time 600 detik. Nilai `giaddr` sebesar `192.225.2.1` sesuai dengan interface `eth2` pada Jichi. Hasil ini

---
# SOAL 9 — Pemulihan DHCP Relay pada Gangguan Jaringan

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

---

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

## Urutan Demo Otomatis

1. **Tengen:** Jalankan `bash /root/soal9-pulihkan-dhcp.sh`.
2. **Jichi:** Jalankan `bash /root/soal9-jichi.sh stop`.
3. **Itadori:** Jalankan `bash /root/soal9-client.sh gangguan`.
4. **Jichi:** Jalankan `bash /root/soal9-jichi.sh start`.
5. **Itadori:** Jalankan `bash /root/soal9-client.sh pulih`.

Dengan urutan tersebut, demonstrasi menunjukkan kondisi sebelum pemulihan, gejala gangguan, proses pemulihan relay, dan keberhasilan client mendapatkan lease baru.

**Catatan dokumentasi:** Pastikan screenshot mode `gangguan` berisi output yang benar-benar muncul pada terminalmu. Jangan menggunakan hasil yang diharapkan sebagai bukti hasil aktual apabila output tersebut belum diperoleh saat pengujian.
