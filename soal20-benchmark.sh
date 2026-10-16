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
