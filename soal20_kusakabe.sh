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
