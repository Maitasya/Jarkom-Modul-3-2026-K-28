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
## Konfigurasi Interface, Gateway, IPv4 Forwarding, dan Source NAT pada Jichi

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

**SS 1-01 — IP Interface Jichi**

> **[TEMPAT SCREENSHOT 1-01]**: output `ip -br a` di Jichi.

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

**SS 1-02 — Forwarding dan NAT**

> **[TEMPAT SCREENSHOT 1-02]**: output kedua perintah verifikasi.

#### Langkah 4 — Menguji Akses Eksternal dari Jichi

**Console perangkat: Jichi**

```bash
ping -c 3 8.8.8.8
```

**Hasil yang diharapkan:** `0% packet loss`.

**SS 1-03 — Ping Internet dari Jichi**

> **[TEMPAT SCREENSHOT 1-03]**: hasil ping `8.8.8.8` dari Jichi.

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

**SS 1-04 — IP Statis Host**

> **[TEMPAT SCREENSHOT 1-04]**: `ip -br a` dan `ip route` di Tengen, Utahime, Shoko, dan Gojo (satu SS per node).

#### Langkah 6 — Menguji Konektivitas Host ke Gateway dan Internet

**Console perangkat: Tengen, Utahime, Shoko, Gojo**

```bash
ping -c 3 <gateway-network-host>
ping -c 3 8.8.8.8
```

**Hasil yang diharapkan:** ping gateway dan `8.8.8.8` berhasil.

**SS 1-05 — Konektivitas Host**

> **[TEMPAT SCREENSHOT 1-05]**: hasil ping gateway dan `8.8.8.8` dari tiap host.

### Catatan Pengujian Ulang

Seluruh perintah verifikasi dapat dijalankan berulang. IP yang diatur dengan `ip addr add` hilang saat node di-stop, jadi jalankan ulang script jika node baru dinyalakan.

### Kesimpulan

Jichi berhasil dikonfigurasi sebagai router dengan gateway Network 1–4, IPv4 forwarding aktif, dan source NAT `MASQUERADE` pada `eth0`. Host infrastruktur memperoleh IP statis dan dapat menjangkau gateway serta internet melalui Jichi.

### Otomatisasi Menggunakan Script

#### Script Jichi

**Cara membuat script**

Pada console Jichi, buat file `/root/soal1_jichi.sh`:

```bash
# TEMPEL ISI: cat /root/soal1_jichi.sh
```

Berikan izin eksekusi:

```bash
chmod +x /root/soal1_jichi.sh
```

**Cara menjalankan script**

```bash
bash /root/soal1_jichi.sh
```

**Output yang diharapkan:** `<isi sesuai output aslimu>`

**SS 1-06 — Output Script Soal 1**

> **[TEMPAT SCREENSHOT 1-06]**: hasil `bash /root/soal1_jichi.sh`.

#### Script IP Statis Host

| Node | File | Perintah |
|---|---|---|
| Tengen | `/root/init.sh` | `bash /root/init.sh` |
| Utahime | `/root/init.sh` | `bash /root/init.sh` |
| Shoko | `/root/init.sh` | `bash /root/init.sh` |
| Gojo | `/root/konfig_gojo.sh` | `bash /root/konfig_gojo.sh` |

```bash
# TEMPEL ISI: cat /root/init.sh  (Tengen)
```

```bash
# TEMPEL ISI: cat /root/init.sh  (Utahime)
```

```bash
# TEMPEL ISI: cat /root/init.sh  (Shoko)
```

```bash
# TEMPEL ISI: cat /root/konfig_gojo.sh
```

**SS 1-07 — Output Script Host**

> **[TEMPAT SCREENSHOT 1-07]**: hasil script di tiap host.

**Urutan Demo:** (1) Jichi: `bash /root/soal1_jichi.sh`, (2) tiap host: jalankan script IP, (3) tiap host: ping gateway dan `8.8.8.8`.

---

# Soal 2
## Konfigurasi Dasar ISC DHCP Server di Tengen

Konfigurasikan `isc-dhcp-server` pada `192.225.4.10`. Deklarasikan Network 4 sebagai subnet lokal tanpa pool dinamis, siapkan scope DHCP untuk Network 2 dan Network 3, validasi konfigurasi, dan pastikan service aktif tanpa error "No subnet declaration".

### Langkah Pengerjaan

#### Langkah 1 — Memeriksa IP dan Routing Tengen

**Console perangkat: Tengen**

```bash
ip -br a
ip route
```

**Hasil yang diharapkan:** `eth0` berIP `192.225.4.10/24` dan `default via 192.225.4.1`.

**SS 2-01 — IP dan Routing Tengen**

> **[TEMPAT SCREENSHOT 2-01]**: output `ip -br a` dan `ip route`.

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

**SS 2-02 — Interface DHCP Server**

> **[TEMPAT SCREENSHOT 2-02]**: `cat /etc/default/isc-dhcp-server`.

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

**SS 2-03 — Isi dhcpd.conf**

> **[TEMPAT SCREENSHOT 2-03]**: `cat /etc/dhcp/dhcpd.conf` yang memperlihatkan blok `subnet 192.225.4.0 ... { }`, Network 2, dan Network 3.

#### Langkah 4 — Validasi dan Menjalankan Service

**Console perangkat: Tengen**

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
```

**Hasil yang diharapkan:** `dhcpd -t` tanpa error dan status `dhcpd is running`.

**SS 2-04 — Validasi dan Status Service**

> **[TEMPAT SCREENSHOT 2-04]**: output `dhcpd -t` dan `service isc-dhcp-server status`.

### Catatan Pengujian Ulang

`dhcpd -t`, `service ... status`, dan `ps aux | grep '[d]hcpd'` dapat dijalankan berulang. Jika `dhcpd -t` error, perbaiki sintaks dulu sebelum restart service.

### Kesimpulan

DHCP Server pada Tengen berhasil dikonfigurasi dengan subnet lokal Network 4 tanpa pool serta scope Network 2 dan Network 3. Konfigurasi valid dan service berjalan tanpa error "No subnet declaration".

### Otomatisasi Menggunakan Script

#### Script DHCP Server pada Tengen

**Cara membuat script**

Pada console Tengen, buat file `/root/soal2_tengen.sh`:

```bash
# TEMPEL ISI: cat /root/soal2_tengen.sh
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

**SS 2-05 — Output Script Soal 2**

> **[TEMPAT SCREENSHOT 2-05]**: hasil `bash /root/soal2_tengen.sh`.

**Urutan Demo:** (1) Tengen: `bash /root/soal2_tengen.sh`, (2) cek `ps aux | grep '[d]hcpd'`.

---

# Soal 3
## Konfigurasi DHCP Relay pada Jichi

Konfigurasikan Jichi sebagai DHCP Relay menuju Tengen (`192.225.4.10`), menggunakan `eth2` untuk Network 2 dan `eth3` untuk Network 3. Buktikan client dari kedua subnet memperoleh lease melalui relay.

> Catatan: `eth4` ikut dimasukkan karena balasan dari Tengen masuk melalui `eth4`.

### Langkah Pengerjaan

#### Langkah 1 — Memastikan DHCP Server Aktif

**Console perangkat: Tengen**

```bash
service isc-dhcp-server status
```

**Hasil yang diharapkan:** `dhcpd is running`.

**SS 3-01 — Status DHCP Server**

> **[TEMPAT SCREENSHOT 3-01]**: output status service.

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

**SS 3-02 — Konfigurasi Relay**

> **[TEMPAT SCREENSHOT 3-02]**: `cat /etc/default/isc-dhcp-relay`.

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

**SS 3-03 — Proses Relay Aktif**

> **[TEMPAT SCREENSHOT 3-03]**: output `ps aux | grep '[d]hcrelay'`.

#### Langkah 4 — Menguji Lease Client Network 2

**Console perangkat: Itadori**

```bash
udhcpc -i eth0 -n -q
ip -br a show eth0
ip route
```

**Hasil yang diharapkan:** IP `192.225.2.x/24` dan `default via 192.225.2.1`.

**SS 3-04 — Lease Client Network 2**

> **[TEMPAT SCREENSHOT 3-04]**: output di Itadori.

#### Langkah 5 — Menguji Lease Client Network 3

**Console perangkat: Ino**

```bash
udhcpc -i eth0 -n -q
ip -br a show eth0
ip route
```

**Hasil yang diharapkan:** IP `192.225.3.x/24` dan `default via 192.225.3.1`.

**SS 3-05 — Lease Client Network 3**

> **[TEMPAT SCREENSHOT 3-05]**: output di Ino.

### Catatan Pengujian Ulang

Sebelum menjalankan `dhcrelay`, selalu cek `pgrep -a dhcrelay` agar tidak ada proses ganda. Jika client `no lease`, periksa relay di Jichi, service di Tengen, dan default route Tengen.

### Kesimpulan

Jichi berhasil berfungsi sebagai DHCP Relay menuju Tengen. Client Network 2 dan Network 3 memperoleh lease dan gateway sesuai subnet masing-masing melalui relay.

### Otomatisasi Menggunakan Script

#### Script DHCP Relay pada Jichi

**Cara membuat script**

Pada console Jichi, buat file `/root/soal3_jichi.sh`:

```bash
# TEMPEL ISI: cat /root/soal3_jichi.sh
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

**SS 3-06 — Output Script Soal 3**

> **[TEMPAT SCREENSHOT 3-06]**: hasil `bash /root/soal3_jichi.sh`.

#### Script Client (Itadori)

**Cara membuat script**

Pada console Itadori, buat file `/root/get_ip.sh`:

```bash
# TEMPEL ISI: cat /root/get_ip.sh
```

**Cara menjalankan script**

```bash
sh /root/get_ip.sh
```

**SS 3-07 — Output Script Client**

> **[TEMPAT SCREENSHOT 3-07]**: hasil `sh /root/get_ip.sh` di Itadori.

**Urutan Demo:** (1) Tengen: server aktif, (2) Jichi: `bash /root/soal3_jichi.sh`, (3) Itadori dan Ino: minta lease, (4) cek IP dan route.

---

# Soal 4
## DHCP Class dan Dua Pool pada Network 2

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

**SS 4-01 — MAC Address Client**

> **[TEMPAT SCREENSHOT 4-01]**: output `ip -br link show eth0` di keempat client.

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

**SS 4-02 — Class dan Pool di dhcpd.conf**

> **[TEMPAT SCREENSHOT 4-02]**: bagian `class "pool1-clients"`, `class "pool2-clients"`, dan dua blok `pool` pada subnet Network 2.

#### Langkah 3 — Validasi dan Restart Service

**Console perangkat: Tengen**

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
```

**Hasil yang diharapkan:** tanpa error dan `dhcpd is running`.

**SS 4-03 — Validasi dan Status**

> **[TEMPAT SCREENSHOT 4-03]**: output ketiga perintah.

#### Langkah 4 — Menguji Client Pool 1

**Console perangkat: Itadori dan Fushiguro**

```bash
ip addr flush dev eth0
udhcpc -i eth0 -n -q
ip -br a show eth0
```

**Hasil yang diharapkan:** IP berada di `192.225.2.10`–`192.225.2.35`.

**SS 4-04 — Client Pool 1**

> **[TEMPAT SCREENSHOT 4-04]**: output di Itadori dan Fushiguro.

#### Langkah 5 — Menguji Client Pool 2

**Console perangkat: Zenin dan Okkotsu**

```bash
ip addr flush dev eth0
udhcpc -i eth0 -n -q
ip -br a show eth0
```

**Hasil yang diharapkan:** IP berada di `192.225.2.70`–`192.225.2.95`.

**SS 4-05 — Client Pool 2**

> **[TEMPAT SCREENSHOT 4-05]**: output di Zenin dan Okkotsu.

#### Langkah 6 — Membuktikan Rentang `.2.36`–`.2.69` Tidak Terpakai

**Console perangkat: Tengen**

```bash
grep "^lease" /var/lib/dhcp/dhcpd.leases | awk '{print $2}' | awk -F. '$3==2 && $4>=36 && $4<=69'
```

**Hasil yang diharapkan:** output kosong.

**SS 4-06 — Rentang Terlarang Kosong**

> **[TEMPAT SCREENSHOT 4-06]**: output perintah di atas (kosong) beserta `grep "^lease" /var/lib/dhcp/dhcpd.leases` sebagai pembanding.

### Catatan Pengujian Ulang

Jika client masih memegang IP lama, jalankan `ip addr flush dev eth0` sebelum `udhcpc`. IP yang diperoleh tiap client bisa berbeda antar pengujian selama masih dalam rentang pool-nya.

### Kesimpulan

DHCP class berbasis MAC address berhasil memisahkan Network 2 menjadi Pool 1 dan Pool 2. Itadori dan Fushiguro memperoleh IP `.2.10`–`.2.35`, Zenin dan Okkotsu memperoleh IP `.2.70`–`.2.95`, dan rentang `.2.36`–`.2.69` tidak pernah dialokasikan.

### Otomatisasi Menggunakan Script

#### Script DHCP Class dan Pool pada Tengen

**Cara membuat script**

Pada console Tengen, buat file `/root/soal4_tengen.sh`:

```bash
# TEMPEL ISI: cat /root/soal4_tengen.sh
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

**SS 4-07 — Output Script Soal 4**

> **[TEMPAT SCREENSHOT 4-07]**: hasil `bash /root/soal4_tengen.sh`.

#### Script Client

Jalankan pada Itadori, Fushiguro, Zenin, dan Okkotsu:

```bash
sh /root/get_ip.sh
```

> Ganti dengan nama script client yang kamu pakai jika berbeda (mis. `soal7_klien.sh`).

**Urutan Demo:** (1) Tengen: `bash /root/soal4_tengen.sh`, (2) Jichi: pastikan relay aktif, (3) keempat client: minta lease, (4) Tengen: cek rentang terlarang.

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

**SS 5-01 — MAC Address Client Network 3**

> **[TEMPAT SCREENSHOT 5-01]**: output `ip -br link show eth0` di ketiga client.

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

**SS 5-02 — Class dan Pool Network 3**

> **[TEMPAT SCREENSHOT 5-02]**: bagian `class "short-lease-clients"`, `class "long-lease-clients"`, dan dua blok `pool` Network 3.

#### Langkah 4 — Validasi dan Restart Service

**Console perangkat: Tengen**

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
```

**SS 5-03 — Validasi dan Status**

> **[TEMPAT SCREENSHOT 5-03]**: output ketiga perintah.

#### Langkah 5 — Menguji Client Short Lease

**Console perangkat: Ino dan Kusakabe**

```bash
ip addr flush dev eth0
udhcpc -i eth0 -n -q
ip -br a show eth0
cat /etc/resolv.conf
```

**Hasil yang diharapkan:** IP di `192.225.3.10`–`192.225.3.89`, lease time sekitar `1800`, serta `search K28.com`, `nameserver 192.225.1.2`, `nameserver 192.225.1.3`.

**SS 5-04 — Client Short Lease**

> **[TEMPAT SCREENSHOT 5-04]**: output di Ino dan Kusakabe.

#### Langkah 6 — Menguji Client Long Lease

**Console perangkat: Miwa**

```bash
ip addr flush dev eth0
udhcpc -i eth0 -n -q
ip -br a show eth0
cat /etc/resolv.conf
```

**Hasil yang diharapkan:** IP di `192.225.3.100`–`192.225.3.199` dan lease time sekitar `43200`.

**SS 5-05 — Client Long Lease**

> **[TEMPAT SCREENSHOT 5-05]**: output di Miwa.

#### Langkah 7 — Membuktikan Durasi Lease di Server

**Console perangkat: Tengen**

```bash
grep -E "^lease|starts|ends|hardware ethernet" /var/lib/dhcp/dhcpd.leases | tail -n 30
```

**Hasil yang diharapkan:** selisih `starts` dan `ends` untuk Ino/Kusakabe tepat 30 menit, dan untuk Miwa tepat 12 jam.

> Lease time yang tampil di `udhcpc` adalah sisa waktu, bukan nilai penuh (mis. `1714` berarti lease 1800 yang sudah berjalan sekitar 86 detik).

**SS 5-06 — Bukti Durasi Lease**

> **[TEMPAT SCREENSHOT 5-06]**: isi `dhcpd.leases` yang memperlihatkan selisih `starts`–`ends` Short Lease (30 menit) dan Long Lease (12 jam).

### Catatan Pengujian Ulang

`dhcpd.leases` adalah jurnal, jadi IP yang sama dapat muncul berulang setelah renew. Baca entri paling bawah untuk status terbaru. Jika client belum memakai konfigurasi baru, jalankan `ip addr flush dev eth0` lalu `udhcpc` lagi.

### Kesimpulan

Class berbasis MAC address berhasil membedakan lease time Network 3. Ino dan Kusakabe memperoleh short lease 1800 detik pada pool `.3.10`–`.3.89`, sedangkan Miwa memperoleh long lease 43200 detik pada pool `.3.100`–`.3.199`, dengan DNS dan domain-search `K28.com` sesuai ketentuan.

### Otomatisasi Menggunakan Script

#### Script Short/Long Lease pada Tengen

**Cara membuat script**

Pada console Tengen, buat file `/root/soal5_tengen.sh`:

```bash
# TEMPEL ISI: cat /root/soal5_tengen.sh
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

**SS 5-07 — Output Script Soal 5**

> **[TEMPAT SCREENSHOT 5-07]**: hasil `bash /root/soal5_tengen.sh`.

#### Script Client

Jalankan pada Ino, Kusakabe, dan Miwa:

```bash
ip addr flush dev eth0; udhcpc -i eth0 -n -q; ip -br a show eth0; cat /etc/resolv.conf
```

**Urutan Demo:** (1) Tengen: `bash /root/soal5_tengen.sh`, (2) Jichi: pastikan relay aktif, (3) Ino, Kusakabe, Miwa: minta lease, (4) Tengen: cek `dhcpd.leases`.

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
# Soal 10: Pemulihan dan Autostart Layanan DHCP Setelah Restart

## Deskripsi Tugas

Pengujian memastikan DHCP Server pada Tengen dan DHCP Relay pada Jichi tetap berjalan setelah restart. Pemeriksaan mencakup status layanan, IP, gateway, lease, DNS, dan konektivitas client Network 2 dan 3. Kebijakan Pool 1, Pool 2, short lease, long lease, dan fixed address juga diverifikasi.

| Client | IP yang harus didapat | Lease |
|---|---|---|
| itadori, fushiguro | `192.225.2.10` sampai `192.225.2.35` | 600 (default) |
| zenin, okkotsu | `192.225.2.70` sampai `192.225.2.95` | 600 (default) |
| ino, kusakabe | `192.225.3.10` sampai `192.225.3.89` | 1800 |
| miwa | `192.225.3.100` sampai `192.225.3.199` | 43200 |
| kugisaki | tepat `192.225.3.99` | 600 (default) |

Tidak boleh ada IP di rentang `192.225.2.36` sampai `192.225.2.69`.

---

## Langkah Pengerjaan

### Langkah 1: Memeriksa Init System pada Tengen

**Console perangkat:** Tengen

```bash
ps -p 1 -o comm=
```

**Hasil yang diharapkan:** `dumb-init`, artinya node **bukan systemd**. `systemctl enable` tidak berlaku, sehingga autostart dibuat lewat `/root/autostart.sh` yang dipanggil dari `/root/.bashrc` (berjalan saat console node dibuka).
<img width="308" height="98" alt="image" src="https://github.com/user-attachments/assets/bfb837b5-ec57-4dfe-9ca1-f605e7180be2" />


### Langkah 2: Memeriksa Konfigurasi DHCP Server

**Console perangkat:** Tengen

```bash
cat /etc/default/isc-dhcp-server
dhcpd -t -cf /etc/dhcp/dhcpd.conf
grep -c "pool1-clients\|short-lease\|long-lease\|host kugisaki" /root/dhcpd.conf
```

**Hasil yang diharapkan:** `INTERFACESv4="eth0"`, `dhcpd -t` tanpa error, dan hitungan `grep` bernilai 6 atau lebih (config lengkap).

<img width="727" height="303" alt="image" src="https://github.com/user-attachments/assets/7ef0b1da-7abf-48de-8164-2e635546817d" />


### Langkah 3: Memeriksa Konfigurasi DHCP Relay

**Console perangkat:** Jichi

```bash
cat /etc/default/isc-dhcp-relay
```

**Hasil yang diharapkan:**

```
SERVERS="192.225.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
```

`eth4` disertakan karena balasan dari tengen masuk lewat eth4.

<img width="414" height="99" alt="image" src="https://github.com/user-attachments/assets/7bc9fe30-e4b6-4735-9d77-db4ee2094951" />

### Langkah 4: Mengaktifkan Autostart Layanan

#### 4.1 Tengen

**Console perangkat:** Tengen

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
: > /var/lib/dhcp/dhcpd.leases
sed -i 's/^INTERFACESv4=.*/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server
pgrep -x dhcpd >/dev/null || service isc-dhcp-server start
EOF
cp /root/soal10-tengen.sh /root/autostart.sh
chmod +x /root/soal10-tengen.sh /root/autostart.sh
grep -q autostart.sh /root/.bashrc || echo "bash /root/autostart.sh" >> /root/.bashrc
```

Cara menjalankan manual (jika perlu): `bash /root/autostart.sh`

| Baris | Fungsi |
|---|---|
| `ip addr flush dev eth0` | Menghapus IP nyasar sebelum memasang `192.225.4.10` |
| `ip route replace default via 192.225.4.1` | Balasan DHCP ke relay butuh default route yang benar |
| `cp /root/dhcpd.conf /etc/dhcp/dhcpd.conf` | Memulihkan config lengkap dari salinan di `/root` |
| `: > /var/lib/dhcp/dhcpd.leases` | Mengosongkan lease lama |
| `pgrep -x dhcpd \|\| service ... start` | Menjalankan dhcpd hanya jika belum berjalan |

#### 4.2 Jichi

**Console perangkat:** Jichi

```bash
cat > /root/soal10-jichi.sh <<'EOF'
#!/bin/bash
for i in 0 1 2 3 4; do ip link set eth$i up; done
ip addr add 192.225.1.1/24 dev eth1 2>/dev/null
ip addr add 192.225.2.1/24 dev eth2 2>/dev/null
ip addr add 192.225.3.1/24 dev eth3 2>/dev/null
ip addr add 192.225.4.1/24 dev eth4 2>/dev/null
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo "nameserver 192.168.122.1" > /etc/resolv.conf
pgrep -x dhcrelay >/dev/null || dhcrelay -i eth2 -i eth3 -i eth4 192.225.4.10
EOF
cp /root/soal10-jichi.sh /root/autostart.sh
chmod +x /root/soal10-jichi.sh /root/autostart.sh
grep -q autostart.sh /root/.bashrc || echo "bash /root/autostart.sh" >> /root/.bashrc

cat > /etc/default/isc-dhcp-relay <<'EOF'
SERVERS="192.225.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
EOF
```

Cara menjalankan manual (jika perlu): `bash /root/autostart.sh`

| Baris | Fungsi |
|---|---|
| `ip addr add ... eth1` sampai `eth4` | Mengembalikan IP gateway tiap network (IP hilang saat node di-stop) |
| `ip_forward = 1` | Mengaktifkan routing antar network |
| `iptables ... MASQUERADE` | NAT keluar lewat eth0 |
| `dhcrelay -i eth2 -i eth3 -i eth4 192.225.4.10` | Meneruskan DHCP dari Network 2 dan 3 ke tengen |

#### 4.3 (Opsional) Start command GNS3

Klik kanan node, **Configure**, **Advanced**, isi **Start command** dengan `bash /root/autostart.sh` (tengen dan jichi, jika opsinya tersedia).

### Langkah 5: Melakukan Restart Kedua Node

**Console perangkat:** GNS3

1. **Stop semua node** (tengen, jichi, dan client).
2. **Start** tengen, jichi, lalu semua client.
3. Buka console **tengen**, lalu **jichi**, dan tunggu sekitar 10 detik. Jangan menjalankan script apa pun secara manual.

**Hasil yang diharapkan:** layanan DHCP berjalan tanpa dinyalakan manual.

> Autostart lewat `.bashrc` berjalan saat console dibuka. Jika console belum dibuka, layanan belum aktif dan client akan gagal mendapat lease. Itu bukan kesalahan konfigurasi.



### Langkah 6: Memeriksa Status Layanan Setelah Restart

**Console perangkat:** Tengen

```bash
service isc-dhcp-server status
ps aux | grep [d]hcpd
ip -br a
ip route
```

**Console perangkat:** Jichi

```bash
ps aux | grep [d]hcrelay
ip -br a
cat /proc/sys/net/ipv4/ip_forward
iptables -t nat -S | grep MASQ
```

**Hasil yang diharapkan:**

- Tengen: layanan aktif, proses `dhcpd` ada, eth0 hanya `192.225.4.10/24`, `default via 192.225.4.1`.
- Jichi: proses `dhcrelay -i eth2 -i eth3 -i eth4 192.225.4.10`, eth1 sampai eth4 punya IP `.1`, ip_forward bernilai 1, ada `MASQUERADE`.

<img width="714" height="306" alt="image" src="https://github.com/user-attachments/assets/8e9882db-ade1-4773-afd0-ba6f7b40497f" />
<img width="718" height="307" alt="image" src="https://github.com/user-attachments/assets/c59a3ecf-5b2d-4847-89c7-0db1a06019f9" />


### Langkah 7: Memeriksa Lease dan Kebijakan Pool

**Console perangkat:** Tengen (jalankan setelah Langkah 8 agar semua client tercatat)

```bash
grep -E "^lease|starts|ends|hardware ethernet" /var/lib/dhcp/dhcpd.leases
grep -n "kugisaki" -A 8 /etc/dhcp/dhcpd.conf
grep "^lease" /var/lib/dhcp/dhcpd.leases | awk '{print $2}' | awk -F. '$3==2 && $4>=36 && $4<=69'
```

**Hasil yang diharapkan:**

- Short lease (ino, kusakabe): selisih `starts` dan `ends` tepat 30 menit.
- Long lease (miwa): selisih tepat 12 jam.
- Perintah ketiga kosong (tidak ada lease di `.2.36` sampai `.2.69`).
- Kugisaki memakai `fixed-address 192.225.3.99`. Host reservasi tidak selalu tercatat di `dhcpd.leases`, sehingga buktinya adalah blok `host kugisaki` dan output `udhcpc` di client.
- Entri IP yang sama muncul berulang karena `dhcpd.leases` adalah jurnal (renew menambah entri dengan MAC yang sama).

### Langkah 8: Memeriksa IP, Gateway, dan DNS Client

**Console perangkat:** Itadori, Fushiguro, Zenin, Okkotsu, Ino, Kusakabe, Miwa, Kugisaki

Jalankan satu perintah ini di **setiap client**:

```sh
udhcpc -i eth0 -n -q 2>&1 | grep "lease of"; ip -4 -br addr show eth0; ip route; cat /etc/resolv.conf
```

**Hasil yang diharapkan:**

| Client | Hasil |
|---|---|
| itadori, fushiguro | `.2.10` sampai `.2.35` |
| zenin, okkotsu | `.2.70` sampai `.2.95` |
| ino, kusakabe | `.3.10` sampai `.3.89`, lease sekitar 1800 |
| miwa | `.3.100` sampai `.3.199`, lease sekitar 43200 |
| kugisaki | tepat `.3.99` |

Di setiap client juga harus ada: netmask `/24`, `default via` gateway wilayahnya (`192.225.2.1` untuk Network 2, `192.225.3.1` untuk Network 3), `search K28.com`, `nameserver 192.225.1.2`, dan `nameserver 192.225.1.3`.

> Lease time yang tampil di `udhcpc` adalah sisa waktu, bukan nilai penuh. Contoh: 1714 berarti lease 1800 yang sudah berjalan sekitar 86 detik.

### Langkah 9: Menguji Konektivitas Client

**Console perangkat:** Client Network 2 dan Network 3

```sh
ping -c 2 -W 2 $(ip route | awk '/default/ {print $3; exit}')
ping -c 2 -W 2 8.8.8.8
```

Perintah pertama otomatis memakai gateway wilayah client (`192.225.2.1` atau `192.225.3.1`).

**Hasil yang diharapkan:** ping gateway berhasil (membuktikan relay dan routing jichi), ping `8.8.8.8` berhasil (membuktikan NAT jichi).


---

## Catatan Pengujian Ulang

Perintah pada Langkah 6, 7, 8, dan 9 dapat dijalankan kembali kapan saja setelah restart. Kesimpulan hanya diambil dari output aktual yang diperoleh saat pengujian.

## Hasil Pengujian

Hasil setelah restart total (ganti dengan hasil tes sendiri jika diulang):

| Client | IP | Lease (sisa) | Status |
|---|---|---|---|
| itadori | `192.225.2.11` | 558 | Pool 1 |
| fushiguro | `192.225.2.10` | 538 | Pool 1 |
| zenin | `192.225.2.71` | 529 | Pool 2 |
| okkotsu | `192.225.2.70` | 520 | Pool 2 |
| ino | `192.225.3.11` | 1714 | Short lease |
| kusakabe | `192.225.3.12` | 1712 | Short lease |
| miwa | `192.225.3.100` | 43102 | Long lease |
| kugisaki | `192.225.3.99` | 600 | Fixed address |

## Urutan Demo

1. **GNS3:** Stop semua node, lalu Start tengen, jichi, dan client.
2. **Tengen, lalu Jichi:** buka console, tunggu 10 detik.
3. **Tengen dan Jichi:** jalankan perintah Langkah 6.
4. **Setiap client:** jalankan perintah Langkah 8 dan 9.
5. **Tengen:** jalankan perintah Langkah 7.

## Troubleshooting

| Gejala | Penyebab umum | Solusi |
|---|---|---|
| Client `no lease, failing` | Console tengen atau jichi belum dibuka | Buka console tengen lalu jichi, tunggu 10 detik, ulangi |
| Masih `no lease` padahal proses hidup | Kabel salah port atau Packet filter aktif di link GNS3 | Client Network 2 ke jichi eth2, Network 3 ke eth3, tengen eth0 ke jichi eth4. Hapus Packet filters di link |
| Masih gagal | Kondisi node atau link nyangkut | Stop semua node, lalu Start tengen, jichi, dan client |
| Tengen punya IP nyasar | Template network configuration lama | `ip addr flush dev eth0` di autostart sudah menangani ini |
| `dhcpd -t` error | Config rusak atau tertimpa | `cp /root/dhcpd.conf /etc/dhcp/dhcpd.conf`, lalu `dhcpd -t -cf /etc/dhcp/dhcpd.conf` |
| `systemctl` gagal | Node memakai `dumb-init` | Pakai `service ... start` dan autostart lewat `.bashrc` |

## Daftar File

| Node | File | Cara menjalankan |
|---|---|---|
| tengen | `/root/dhcpd.conf` | `cp /root/dhcpd.conf /etc/dhcp/dhcpd.conf` |
| tengen | `/root/soal10-tengen.sh`, `/root/autostart.sh` | `bash /root/autostart.sh` |
| jichi | `/root/soal10-jichi.sh`, `/root/autostart.sh` | `bash /root/autostart.sh` |
| jichi | `/etc/default/isc-dhcp-relay` | Dibaca layanan relay |

# Soal 11 — Konfigurasi DNS Master dan Slave menggunakan BIND9

## 1. Tujuan

Praktikum ini bertujuan untuk mengonfigurasi layanan DNS menggunakan BIND9 dengan menerapkan arsitektur Master–Slave. Utahime berfungsi sebagai DNS Master yang menyimpan zona DNS utama, sedangkan Shoko berfungsi sebagai DNS Slave yang memperoleh salinan zona dari Master melalui mekanisme zone transfer.

Pengujian dilakukan untuk memastikan kedua server dapat memberikan jawaban DNS yang benar, proses transfer zona berjalan dengan baik, dan perubahan serial zona pada Master tersinkronisasi ke Slave.

## 2. Topologi dan Konfigurasi

| Komponen | Peran | Alamat IP |
|---|---|---|
| Utahime | DNS Master | `192.225.1.2/24` |
| Shoko | DNS Slave | `192.225.1.3/24` |
| Itadori | Client pengujian | Network 2 |
| Domain | Zona DNS | `jujutsu.k28.com` |

Nama nameserver yang digunakan:

- `ns1.jujutsu.k28.com` mengarah ke `192.225.1.2`.
- `ns2.jujutsu.k28.com` mengarah ke `192.225.1.3`.

## 3. Langkah Kerja Manual

### 3.1. Instalasi BIND9 pada Utahime

Pada terminal Utahime, jalankan:

```bash
apt-get update
apt-get install -y bind9 bind9-utils dnsutils
```

Paket `bind9` digunakan untuk menjalankan layanan DNS, `bind9-utils` menyediakan utilitas pemeriksaan konfigurasi, sedangkan `dnsutils` menyediakan perintah pengujian DNS seperti `dig`.

### 3.2. Membuat direktori zona DNS pada Utahime

Jalankan perintah berikut:

```bash
mkdir -p /etc/bind/zones
```

Direktori `/etc/bind/zones` digunakan untuk menyimpan file zona DNS Master.

### 3.3. Mengonfigurasi DNS Master

Buka konfigurasi zona lokal:

```bash
nano /etc/bind/named.conf.local
```

Tambahkan konfigurasi berikut:

```conf
zone "jujutsu.k28.com" {
    type master;
    file "/etc/bind/zones/db.jujutsu.k28.com";
    allow-transfer { 192.225.1.3; };
    also-notify { 192.225.1.3; };
    notify yes;
};
```

Keterangan:

- `type master` menetapkan Utahime sebagai DNS Master.
- `file` menentukan lokasi file zona DNS.
- `allow-transfer` mengizinkan Shoko mengambil salinan zona dari Master.
- `also-notify` memberi tahu Shoko ketika zona diperbarui.
- `notify yes` mengaktifkan pemberitahuan perubahan zona kepada nameserver terkait.

Simpan file dengan `Ctrl + O`, tekan `Enter`, kemudian keluar menggunakan `Ctrl + X`.


### 3.4. Membuat file zona DNS Master

Buat dan buka file zona:

```bash
nano /etc/bind/zones/db.jujutsu.k28.com
```

Isi file dengan konfigurasi berikut:

```dns
$TTL 604800
@   IN  SOA ns1.jujutsu.k28.com. admin.jujutsu.k28.com. (
        2026101502 ; serial
        604800     ; refresh
        86400      ; retry
        2419200    ; expire
        604800     ; negative cache TTL
)
@    IN NS ns1.jujutsu.k28.com.
@    IN NS ns2.jujutsu.k28.com.

ns1  IN A 192.225.1.2
ns2  IN A 192.225.1.3
```

Penjelasan:

- `SOA` menyimpan informasi utama mengenai zona DNS.
- `serial` merupakan nomor versi zona yang dinaikkan setiap kali isi zona diubah.
- `NS` menentukan nameserver yang bertanggung jawab terhadap zona.
- `A` memetakan nama host nameserver ke alamat IPv4.

Simpan file setelah selesai.



### 3.5. Memvalidasi konfigurasi Master

Jalankan pada Utahime:

```bash
named-checkconf
```

Kemudian periksa file zona:

```bash
named-checkzone jujutsu.k28.com /etc/bind/zones/db.jujutsu.k28.com
```

Hasil yang diharapkan adalah pesan yang menunjukkan zona berhasil dimuat dan berakhir dengan `OK`.

Pemeriksaan ini memastikan konfigurasi dan sintaks file zona dapat diterima oleh BIND9.

<img width="712" height="122" alt="image" src="https://github.com/user-attachments/assets/8d7a80c7-868f-42fd-a38c-db04cc943904" />


### 3.6. Menginstal dan mengonfigurasi DNS Slave pada Shoko

Pada terminal Shoko, jalankan:

```bash
apt-get update
apt-get install -y bind9 bind9-utils dnsutils
```

Pastikan direktori penyimpanan zona Slave tersedia:

```bash
mkdir -p /var/cache/bind
chown bind:bind /var/cache/bind
chmod 775 /var/cache/bind
```

Buka konfigurasi zona lokal:

```bash
nano /etc/bind/named.conf.local
```

Tambahkan konfigurasi:

```conf
zone "jujutsu.k28.com" {
    type slave;
    masters { 192.225.1.2; };
    file "/var/cache/bind/db.jujutsu.k28.com";
};
```

Keterangan:

- `type slave` menetapkan Shoko sebagai DNS Slave.
- `masters` menentukan alamat DNS Master yang menjadi sumber zona.
- `file` menentukan lokasi penyimpanan salinan zona yang diperoleh dari Master.

Simpan konfigurasi, kemudian validasi:

```bash
named-checkconf
````.

### 3.7. Menjalankan DNS Slave dan memeriksa zone transfer

Pada Shoko, periksa apakah proses `named` sudah berjalan:

```bash
ps aux | grep '[n]amed'
```

Jika proses belum berjalan, jalankan:

```bash
named -u bind
```

Jika proses sudah berjalan, jangan menjalankan proses kedua. Periksa log BIND9 untuk memastikan transfer zona selesai.

Pada konfigurasi yang diuji, log menunjukkan bahwa transfer zona `jujutsu.k28.com` berhasil, dengan serial `2026101502`.

Periksa file hasil transfer:

```bash
ls -l /var/cache/bind/db.jujutsu.k28.com
```

File tersebut seharusnya tersedia setelah transfer berhasil.

<img width="751" height="77" alt="image" src="https://github.com/user-attachments/assets/f8af01e0-b3b8-4446-aab3-d45c10965ca2" />


### 3.8. Menguji DNS Master dan Slave

Pada Itadori, jalankan query SOA ke DNS Master:

```bash
dig @192.225.1.2 jujutsu.k28.com SOA
```

Kemudian query ke DNS Slave:

```bash
dig @192.225.1.3 jujutsu.k28.com SOA
```

Hasil pengujian menunjukkan kedua server memberikan `status: NOERROR` dan flag `aa`. Flag `aa` menunjukkan bahwa jawaban yang diberikan bersifat otoritatif untuk zona yang diuji.

Pada tahap ini, serial awal yang digunakan adalah `2026101502`.

**Bukti screenshot 7:** Tampilkan hasil query SOA ke Master dan Slave.

### 3.9. Menguji A record nameserver melalui Slave

Pada Itadori, jalankan:

```bash
dig @192.225.1.3 ns1.jujutsu.k28.com A
dig @192.225.1.3 ns2.jujutsu.k28.com A
```

Hasil yang diharapkan:

- `ns1.jujutsu.k28.com` mengarah ke `192.225.1.2`.
- `ns2.jujutsu.k28.com` mengarah ke `192.225.1.3`.

Pengujian ini membuktikan bahwa Slave dapat memberikan jawaban untuk record yang terdapat di zona hasil transfer.

**Bukti screenshot 8:** Tampilkan kedua hasil query A record dari Itadori.

### 3.10. Menguji sinkronisasi perubahan serial

Untuk menguji pembaruan zona, pada Utahime buka kembali file zona:

```bash
nano /etc/bind/zones/db.jujutsu.k28.com
```

Naikkan serial dari:

```dns
2026101502 ; serial
```

menjadi:

```dns
2026101503 ; serial
```

Simpan perubahan, kemudian validasi zona:

```bash
named-checkzone jujutsu.k28.com /etc/bind/zones/db.jujutsu.k28.com
```

Jika validasi berhasil, muat ulang zona:

```bash
rndc reload jujutsu.k28.com
```

Apabila `rndc` gagal karena belum dikonfigurasi, jangan langsung menghentikan proses BIND9. Periksa pesan kesalahannya terlebih dahulu. Pada lingkungan yang menjalankan `named` langsung, sinyal reload dapat digunakan setelah memastikan proses yang benar:

```bash
kill -HUP "$(pgrep -xo named)"
```

Selanjutnya, pada Itadori periksa serial Master:

```bash
dig @192.225.1.2 jujutsu.k28.com SOA
```

Kemudian periksa serial Slave:

```bash
dig @192.225.1.3 jujutsu.k28.com SOA
```

Hasil pengujian menunjukkan serial pada kedua server menjadi `2026101503`. Dengan demikian, pembaruan zona berhasil tersinkronisasi dari Master ke Slave.

**Bukti screenshot 9:** Tampilkan hasil query SOA yang menunjukkan serial `2026101503` pada Master dan Slave.

### 3.11. Memeriksa konfigurasi DNS pada client

Pada Itadori, jalankan:

```bash
cat /etc/resolv.conf
```

Konfigurasi yang diperoleh:

```conf
search K28.com
nameserver 192.225.1.2
nameserver 192.225.1.3
```

Konfigurasi tersebut menunjukkan bahwa client mencantumkan Utahime sebagai nameserver pertama dan Shoko sebagai nameserver kedua.

Kemudian lakukan pengujian akhir:

```bash
dig @192.225.1.2 jujutsu.k28.com SOA
dig @192.225.1.3 jujutsu.k28.com SOA

dig @192.225.1.3 ns1.jujutsu.k28.com A
dig @192.225.1.3 ns2.jujutsu.k28.com A
```

Semua query yang diuji menghasilkan `status: NOERROR`. Serial pada kedua server adalah `2026101503`, sedangkan record A nameserver mengarah ke alamat IP yang sesuai.

**Bukti screenshot 10:** Tampilkan konfigurasi `resolv.conf` dan hasil query akhir dari Itadori.

## 4. Script Otomatisasi Konfigurasi

Selain konfigurasi manual, konfigurasi DNS dapat disiapkan menggunakan script Bash. Script berikut merupakan alternatif untuk menyiapkan konfigurasi; script tidak wajib dijalankan ulang apabila konfigurasi yang sudah ada telah berhasil.

**Catatan:** Simpan backup konfigurasi sebelum menjalankan script. Jalankan script Master hanya di Utahime dan script Slave hanya di Shoko. Script ini menulis ulang file zona Master dan menambahkan konfigurasi zona hanya jika belum ada.

### 4.1. Script DNS Master

Buat file:

```bash
nano /root/soal11_master.sh
```

Isi file:

```bash
#!/bin/bash
set -e

DOMAIN="jujutsu.k28.com"
SLAVE_IP="192.225.1.3"
ZONE_DIR="/etc/bind/zones"
ZONE_FILE="$ZONE_DIR/db.$DOMAIN"
LOCAL_CONF="/etc/bind/named.conf.local"

apt-get update
apt-get install -y bind9 bind9-utils dnsutils

mkdir -p "$ZONE_DIR"

# Backup konfigurasi yang sudah ada
cp -a "$LOCAL_CONF" "$LOCAL_CONF.bak.$(date +%Y%m%d%H%M%S)"

if [ -f "$ZONE_FILE" ]; then
    cp -a "$ZONE_FILE" "$ZONE_FILE.bak.$(date +%Y%m%d%H%M%S)"
fi

# Tambahkan zona jika belum terdaftar
if ! grep -q "zone \"$DOMAIN\"" "$LOCAL_CONF"; then
    cat >> "$LOCAL_CONF" <<EOF

zone "$DOMAIN" {
    type master;
    file "$ZONE_FILE";
    allow-transfer { $SLAVE_IP; };
    also-notify { $SLAVE_IP; };
    notify yes;
};
EOF
fi

# Buat file zona
cat > "$ZONE_FILE" <<EOF
\$TTL 604800
@ IN SOA ns1.$DOMAIN. admin.$DOMAIN. (
    2026101503
    604800
    86400
    2419200
    604800
)
@   IN NS ns1.$DOMAIN.
@   IN NS ns2.$DOMAIN.
ns1 IN A 192.225.1.2
ns2 IN A 192.225.1.3
EOF

chown bind:bind "$ZONE_FILE"
chmod 644 "$ZONE_FILE"

named-checkconf
named-checkzone "$DOMAIN" "$ZONE_FILE"

if rndc reload "$DOMAIN"; then
    echo "Zona berhasil di-reload menggunakan rndc."
elif pgrep -x named >/dev/null; then
    kill -HUP "$(pgrep -xo named)"
    echo "Sinyal reload dikirim ke named."
else
    named -u bind
fi

echo "Konfigurasi DNS Master selesai."
```

Jalankan pada Utahime:

```bash
chmod +x /root/soal11_master.sh
bash /root/soal11_master.sh
```

### 4.2. Script DNS Slave

Buat file pada Shoko:

```bash
nano /root/soal11_slave.sh
```

Isi file:

```bash
#!/bin/bash
set -e

DOMAIN="jujutsu.k28.com"
MASTER_IP="192.225.1.2"
LOCAL_CONF="/etc/bind/named.conf.local"
ZONE_FILE="/var/cache/bind/db.$DOMAIN"

apt-get update
apt-get install -y bind9 bind9-utils dnsutils

cp -a "$LOCAL_CONF" "$LOCAL_CONF.bak.$(date +%Y%m%d%H%M%S)"

if ! grep -q "zone \"$DOMAIN\"" "$LOCAL_CONF"; then
    cat >> "$LOCAL_CONF" <<EOF

zone "$DOMAIN" {
    type slave;
    masters { $MASTER_IP; };
    file "$ZONE_FILE";
};
EOF
fi

mkdir -p /var/cache/bind
chown bind:bind /var/cache/bind
chmod 775 /var/cache/bind

named-checkconf

if pgrep -x named >/dev/null; then
    if ! rndc reload "$DOMAIN"; then
        kill -HUP "$(pgrep -xo named)"
    fi
else
    named -u bind
fi

echo "Konfigurasi DNS Slave selesai."
echo "Periksa hasil transfer dengan:"
echo "dig @192.225.1.3 $DOMAIN SOA"
```

Jalankan pada Shoko:

```bash
chmod +x /root/soal11_slave.sh
bash /root/soal11_slave.sh
```

Script Slave mengambil salinan zona dari Master melalui mekanisme zone transfer. Jika proses BIND9 sudah berjalan, script mencoba melakukan reload dan tidak sengaja menjalankan proses kedua.

## 5. Hasil Pengujian

Berdasarkan pengujian yang dilakukan, diperoleh hasil sebagai berikut:

| Pengujian | Hasil |
|---|---|
| Validasi konfigurasi Master | Berhasil |
| Validasi zona Master | Berhasil |
| Zone transfer ke Shoko | Berhasil |
| Query SOA ke Master | `NOERROR` |
| Query SOA ke Slave | `NOERROR` |
| A record `ns1` melalui Slave | `192.225.1.2` |
| A record `ns2` melalui Slave | `192.225.1.3` |
| Sinkronisasi serial | `2026101502` menjadi `2026101503` |
| Query dari Itadori ke kedua DNS | Berhasil |

## 6. Kesimpulan

Pada praktikum ini, layanan DNS Master–Slave menggunakan BIND9 berhasil dikonfigurasi. Utahime berfungsi sebagai DNS Master dengan zona `jujutsu.k28.com`, sedangkan Shoko berfungsi sebagai DNS Slave yang memperoleh salinan zona melalui zone transfer.

Keberhasilan konfigurasi dibuktikan melalui validasi zona, query SOA dan A record, serta pengujian perubahan serial dari `2026101502` menjadi `2026101503`. Kedua DNS memberikan jawaban `NOERROR` saat diuji dari client Itadori. Hasil ini menunjukkan bahwa layanan DNS Master–Slave dan sinkronisasi zona telah berfungsi sesuai pengujian yang dilakukan.

---
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

**SS 11-01 — Konfigurasi Zona Master**

> **[TEMPAT SCREENSHOT 11-01]**: `cat /etc/bind/named.conf.local` di Utahime.

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

**SS 11-02 — Validasi Zona**

> **[TEMPAT SCREENSHOT 11-02]**: output `named-checkconf` dan `named-checkzone`.

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

**SS 11-03 — Konfigurasi Zona Slave**

> **[TEMPAT SCREENSHOT 11-03]**: `cat /etc/bind/named.conf.local` di Shoko.

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

**SS 11-04 — Zone Transfer Berhasil**

> **[TEMPAT SCREENSHOT 11-04]**: `pgrep -a named` di kedua node dan `ls -l` file zona di Shoko.

#### Langkah 6 — Query `dig` ke Master dan Slave dari Client

**Console perangkat: Itadori**

```bash
dig @192.225.1.2 jujutsu.k28.com SOA
dig @192.225.1.3 jujutsu.k28.com SOA
```

**Hasil yang diharapkan:** keduanya `status: NOERROR` dengan flag `aa` dan serial `2026101502`.

**SS 11-05 — Query SOA Master dan Slave**

> **[TEMPAT SCREENSHOT 11-05]**: output kedua `dig`.

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

**SS 11-06 — Serial Tersinkronisasi**

> **[TEMPAT SCREENSHOT 11-06]**: output `dig +short` kedua server dengan serial baru.

### Catatan Pengujian Ulang

Setiap perubahan zona harus disertai kenaikan serial, kalau tidak Slave tidak menyalin ulang. Jangan menjalankan `named -u bind` jika proses sudah ada; cukup reload.

### Kesimpulan

DNS Master (Utahime) dan Slave (Shoko) berhasil dikonfigurasi untuk `jujutsu.k28.com`. Zone transfer berjalan dan kenaikan serial pada Master otomatis tersalin ke Slave, terbukti dari query `dig` ke kedua server.

### Otomatisasi Pengujian Menggunakan Script

#### Script DNS Master pada Utahime

**Cara membuat script**

Pada console Utahime, buat file `/root/soal11_master.sh`:

```bash
# TEMPEL ISI: cat /root/soal11_master.sh
```

```bash
chmod +x /root/soal11_master.sh
```

**Cara menjalankan script**

```bash
bash /root/soal11_master.sh
```

**Fungsi:** memasang BIND9, membuat zona Master beserta file zona, memvalidasi, lalu me-reload `named`.

#### Script DNS Slave pada Shoko

**Cara membuat script**

Pada console Shoko, buat file `/root/soal11_slave.sh`:

```bash
# TEMPEL ISI: cat /root/soal11_slave.sh
```

```bash
chmod +x /root/soal11_slave.sh
```

**Cara menjalankan script**

```bash
bash /root/soal11_slave.sh
```

**Fungsi:** memasang BIND9 dan mendaftarkan zona Slave yang mengambil data dari Utahime.

#### Script Pengujian pada Itadori

**Cara membuat script**

Pada console Itadori, buat file `/root/soal11-test.sh`:

```bash
# TEMPEL ISI: cat /root/soal11-test.sh
```

**Cara menjalankan script**

```bash
sh /root/soal11-test.sh
```

**Fungsi:** menjalankan `dig` SOA dan A record ke Master dan Slave.

**SS 11-07 — Output Script Soal 11**

> **[TEMPAT SCREENSHOT 11-07]**: hasil script Master, Slave, dan pengujian client.

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

**SS 12-01 — Isi File Zona**

> **[TEMPAT SCREENSHOT 12-01]**: `cat /etc/bind/zones/db.jujutsu.k28.com`.

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

**SS 12-02 — Zona Reverse**

> **[TEMPAT SCREENSHOT 12-02]**: `cat /etc/bind/zones/db.192.225.1` dan blok zona reverse di `named.conf.local`.

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

**SS 12-03 — Validasi dan Reload**

> **[TEMPAT SCREENSHOT 12-03]**: output ketiga validasi.

#### Langkah 5 — Menguji A, CNAME, dan PTR dari Client

**Console perangkat: Itadori**

```bash
dig @192.225.1.2 jujutsu.k28.com A +short
dig @192.225.1.2 www.jujutsu.k28.com CNAME +short
dig @192.225.1.2 -x <IP-Gojo> +short
```

**Hasil yang diharapkan:** A mengarah ke Gojo, CNAME ke `jujutsu.k28.com.`, dan PTR kembali ke `jujutsu.k28.com.`.

**SS 12-04 — Hasil dig A, CNAME, PTR**

> **[TEMPAT SCREENSHOT 12-04]**: output ketiga `dig`.

#### Langkah 6 — Menguji Forwarder ke Internet

**Console perangkat: Itadori**

```bash
dig @192.225.1.2 google.com +short
ping -c 3 google.com
```

**Hasil yang diharapkan:** `google.com` ter-resolve dan ping berhasil.

**SS 12-05 — Ping google.com**

> **[TEMPAT SCREENSHOT 12-05]**: output `dig` dan `ping google.com`.

### Catatan Pengujian Ulang

Naikkan serial setiap mengubah zona agar Shoko ikut tersinkron. Ping domain internet hanya berhasil jika NAT Jichi aktif dan client memakai Utahime/Shoko sebagai DNS.

### Kesimpulan

Utahime berhasil memetakan `jujutsu.k28.com` dan `www` ke Gojo, menyediakan PTR untuk IP Gojo, serta meneruskan query eksternal ke `192.168.122.1`. Client dapat meresolusi CNAME, PTR, dan tetap menjangkau `google.com`.

### Otomatisasi Pengujian Menggunakan Script

#### Script DNS pada Utahime

**Cara membuat script**

Pada console Utahime, buat file `/root/soal12_dns.sh`:

```bash
# TEMPEL ISI: cat /root/soal12_dns.sh
```

```bash
chmod +x /root/soal12_dns.sh
```

**Cara menjalankan script**

```bash
bash /root/soal12_dns.sh
```

**Fungsi:** menambah A, CNAME, zona PTR, dan forwarder, lalu memvalidasi dan me-reload BIND9.

**SS 12-06 — Output Script Soal 12**

> **[TEMPAT SCREENSHOT 12-06]**: hasil `bash /root/soal12_dns.sh`.

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

**SS 13-01 — Konfigurasi Master**

> **[TEMPAT SCREENSHOT 13-01]**: baris `bind-address`, `server-id`, `log-bin` di Yaga.

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

**SS 13-02 — Status Master**

> **[TEMPAT SCREENSHOT 13-02]**: output `SHOW MASTER STATUS` dan `SHOW TABLES`.

#### Langkah 4 — Mengonfigurasi Slave

**Console perangkat: Inumaki**

```bash
nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

Isi pada `[mysqld]`: `server-id = 2` dan `bind-address = 0.0.0.0`, lalu `service mariadb restart`.

**SS 13-03 — Konfigurasi Slave**

> **[TEMPAT SCREENSHOT 13-03]**: baris `server-id` di Inumaki.

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

**SS 13-04 — Status Slave**

> **[TEMPAT SCREENSHOT 13-04]**: output `SHOW SLAVE STATUS\G`.

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

**SS 13-05 — Data Tereplikasi**

> **[TEMPAT SCREENSHOT 13-05]**: INSERT di Yaga dan SELECT di Inumaki.

### Catatan Pengujian Ulang

Jika Slave `No`, baca `Last_IO_Error` pada `SHOW SLAVE STATUS\G` dan cek file/posisi log Master. Setelah node di-restart, pastikan service MariaDB dijalankan kembali (`service mariadb start`).

### Kesimpulan

MariaDB Master (Yaga) dan Slave (Inumaki) berhasil dikonfigurasi dengan database `db_shibuya_K28` dan tabel `request_logs`. Data yang dimasukkan di Master langsung muncul di Slave, sehingga replikasi berjalan.

### Otomatisasi Pengujian Menggunakan Script

#### Script Master pada Yaga

**Cara membuat script**

Pada console Yaga, buat file `/root/soal13_master.sh`:

```bash
# TEMPEL ISI: cat /root/soal13_master.sh
```

```bash
chmod +x /root/soal13_master.sh
```

**Cara menjalankan script**

```bash
bash /root/soal13_master.sh
```

**Fungsi:** mengonfigurasi binary log, membuat database, tabel, serta user replikasi dan remote.

#### Script Slave pada Inumaki

**Cara membuat script**

Pada console Inumaki, buat file `/root/soal13_slave.sh`:

```bash
# TEMPEL ISI: cat /root/soal13_slave.sh
```

```bash
chmod +x /root/soal13_slave.sh
```

**Cara menjalankan script**

```bash
bash /root/soal13_slave.sh
```

**Fungsi:** mengatur `server-id` Slave, menjalankan `CHANGE MASTER TO`, dan memulai replikasi.

**SS 13-06 — Output Script Soal 13**

> **[TEMPAT SCREENSHOT 13-06]**: hasil kedua script.

#### Urutan Menjalankan Script untuk Demonstrasi

1. **Yaga:** `bash /root/soal13_master.sh`
2. **Inumaki:** `bash /root/soal13_slave.sh`
3. **Yaga lalu Inumaki:** INSERT di Master, SELECT di Slave.

---
# Soal 14
## Worker Frontend dan API dengan Nginx + PHP-FPM

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

**SS 14-01 — Virtual Host Worker**

> **[TEMPAT SCREENSHOT 14-01]**: `cat` vhost di salah satu web worker dan salah satu API worker, plus `nginx -t`.

#### Langkah 5 — Menguji Akses Langsung Ditolak

**Console perangkat: Itadori**

```bash
curl -I http://<IP-Maki>/
curl -I http://<IP-Nanami>/
```

**Hasil yang diharapkan:** `403 Forbidden` (akses langsung dari client ditolak).

**SS 14-02 — Akses Langsung Ditolak**

> **[TEMPAT SCREENSHOT 14-02]**: output kedua `curl` di Itadori.

#### Langkah 6 — Menguji Akses Melalui Proxy

**Console perangkat: Gojo (web) dan Geto (API)**

```bash
curl -s -H "Host: jujutsu.k28.com" http://<IP-Maki>/
curl -s -H "Host: jujutsu.k28.com" http://<IP-Nanami>/
```

**Hasil yang diharapkan:** web membalas hostname Maki/Panda dan API membalas JSON dengan `status: ok`. Pastikan baris baru muncul di `request_logs` Yaga.

**SS 14-03 — Akses Melalui Proxy Berhasil**

> **[TEMPAT SCREENSHOT 14-03]**: output `curl` dari Gojo dan Geto, serta `SELECT` di Yaga.

### Catatan Pengujian Ulang

Jika muncul `502`, periksa PHP-FPM dan path socket (`ls /run/php/`). Jika API gagal menyimpan log, cek koneksi dan user `app` ke Yaga.

### Kesimpulan

Maki dan Panda berhasil menyajikan frontend, sedangkan Nanami, Todo, dan Kirara mencatat request ke database Yaga. Akses langsung client ditolak dan hanya jalur proxy yang diizinkan.

### Otomatisasi Pengujian Menggunakan Script

#### Script Worker

**Cara membuat script**

Pada console Maki, Panda, Nanami, Todo, dan Kirara, buat file `/root/soal14_worker.sh`:

```bash
# TEMPEL ISI: cat /root/soal14_worker.sh  (satu per node; isinya bisa berbeda untuk frontend dan API)
```

```bash
chmod +x /root/soal14_worker.sh
```

**Cara menjalankan script**

```bash
bash /root/soal14_worker.sh
```

**Fungsi:** memasang Nginx dan PHP-FPM, membuat halaman/API, serta virtual host dengan pembatasan akses.

**SS 14-04 — Output Script Soal 14**

> **[TEMPAT SCREENSHOT 14-04]**: hasil script di salah satu web worker dan salah satu API worker.

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

**SS 15-01 — Konfigurasi Load Balancer**

> **[TEMPAT SCREENSHOT 15-01]**: `cat /etc/nginx/conf.d/api_cluster.conf`.

#### Langkah 3 — Validasi dan Menjalankan Nginx

**Console perangkat: Geto**

```bash
rm -f /etc/nginx/sites-enabled/default
nginx -t
pgrep -x nginx >/dev/null && nginx -s reload || service nginx start
```

**Hasil yang diharapkan:** `nginx -t` berstatus `successful`.

**SS 15-02 — Validasi Nginx**

> **[TEMPAT SCREENSHOT 15-02]**: output `nginx -t` dan `pgrep -a nginx`.

#### Langkah 4 — Menguji Rasio Distribusi Beban

**Console perangkat: Tengen** (satu jaringan Data Center dengan Geto)

```bash
for i in $(seq 1 40); do curl -s http://<IP-Geto>/ ; echo; done | sort | uniq -c
```

**Hasil yang diharapkan:** Nanami menerima sekitar 30 respons dan Todo sekitar 10 (rasio 3:1).

**SS 15-03 — Rasio Respons 3:1**

> **[TEMPAT SCREENSHOT 15-03]**: output `sort | uniq -c`.

### Catatan Pengujian Ulang

Jika semua respons dari satu worker, periksa apakah worker lain bisa dijangkau dari Geto dan apakah vhost mengizinkan IP Geto. Gunakan jumlah request kelipatan 4 agar rasio mudah dibaca.

### Kesimpulan

Geto berhasil menjadi load balancer internal dengan upstream `api_cluster` dan Weighted Round Robin 3:1. Loop request menunjukkan Nanami menerima beban sekitar tiga kali lipat Todo.

### Otomatisasi Pengujian Menggunakan Script

#### Script Load Balancer pada Geto

**Cara membuat script**

Pada console Geto, buat file `/root/soal15_geto.sh`:

```bash
# TEMPEL ISI: cat /root/soal15_geto.sh
```

```bash
chmod +x /root/soal15_geto.sh
```

**Cara menjalankan script**

```bash
bash /root/soal15_geto.sh
```

**Fungsi:** menulis konfigurasi upstream `api_cluster`, memvalidasi, dan me-reload Nginx.

**SS 15-04 — Output Script Soal 15**

> **[TEMPAT SCREENSHOT 15-04]**: hasil `bash /root/soal15_geto.sh`.

#### Urutan Menjalankan Script untuk Demonstrasi

1. **Geto:** `bash /root/soal15_geto.sh`
2. **Tengen:** jalankan loop `curl` ke Geto lalu hitung rasio.
