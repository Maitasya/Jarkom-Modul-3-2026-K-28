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
