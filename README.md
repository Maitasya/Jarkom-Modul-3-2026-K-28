## Kelompok K-28

| Nama | NRP |
| :---: | :---: |
| Maitasya Rohmatul Ula | 5027251026 |
| A. Algifari Rantiga Isdar | 5027251084 |

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
