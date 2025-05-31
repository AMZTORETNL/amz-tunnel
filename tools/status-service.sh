#!/bin/bash

# Warna ANSI
GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
BLUE='\e[34m'
NC='\e[0m'

# Fungsi untuk cek status service
check_service() {
    local service_name="$1"
    if systemctl is-active --quiet "$service_name"; then
        echo -e "🟢  ${service_name} : ${GREEN}Aktif${NC}"
    else
        echo -e "🔴  ${service_name} : ${RED}Tidak Aktif${NC}"
    fi
}

# Header
echo "┌──────────────────────────────┐"
echo "│     🔍 STATUS LAYANAN VPS    │"
echo "└──────────────────────────────┘"

# Cek status layanan
check_service "ws-service.service"
check_service "auto.service"
check_service "xray.service"
check_service "dropbear"
check_service "nginx"

# Footer
echo ""
echo "📌 Uptime Sistem: $(uptime -p | sed 's/up //')"
echo "📅 Waktu Sekarang: $(date +"%Y-%m-%d %H:%M")"
echo "-------------------------------"
echo "✔️ Selesai memeriksa layanan."
echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
