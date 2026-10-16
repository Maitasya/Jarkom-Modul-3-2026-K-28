#!/bin/bash
DOMAIN="jujutsu.k28.com"
IP_UTAHIME="192.225.1.5"  # <-- GANTI IP Utahime asli
IP_SHOKO="192.225.1.6"    # <-- GANTI IP Shoko asli

echo "=== QUERY KE MASTER (UTAHIME) ==="
dig @$IP_UTAHIME $DOMAIN +short

echo "=== QUERY KE SLAVE (SHOKO) ==="
dig @$IP_SHOKO $DOMAIN +short