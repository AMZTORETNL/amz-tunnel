#!/bin/bash
# ======== IP VERIFIKASI ========
# Fungsi untuk memverifikasi IP VPS
verif_ip() {
    # URL file daftar IP yang tersimpan di GitHub
    url="https://raw.githubusercontent.com/AMZTORETNL/amz-tunnel/main/permission?$(date +%s)"
    
    # Ambil seluruh baris dari file daftar IP dan simpan ke dalam array
    readarray -t daftar_ip < <(curl -s "$url")
    
    # Ambil IP VPS saat ini dan tanggal hari ini
    current_ip=$(curl -s https://ipinfo.io/ip)
    current_date=$(date +%Y-%m-%d)
    # Konversi tanggal saat ini ke detik agar perbandingan tanggal lebih mudah
    current_date_sec=$(date -d "$current_date" +%s)
    
    # Inisialisasi status verifikasi
    verified=false
    
    # Iterasi setiap baris di file daftar IP
    for entry in "${daftar_ip[@]}"; do
        # Abaikan baris kosong atau baris yang diawali dengan tanda pagar (komentar)
        [[ -z "$entry" || "$entry" =~ ^# ]] && continue

        # Pisahkan IP dan tanggal kedaluwarsa berdasarkan spasi
        IFS=' ' read -r ip expiry_date <<< "$entry"
        
        # Pastikan format tanggal valid dan konversikan ke detik
        expiry_date_sec=$(date -d "$expiry_date" +%s 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo "Format tanggal tidak valid untuk IP $ip: $expiry_date"
            continue
        fi
        
        # Jika IP cocok dan tanggal saat ini kurang dari atau sama dengan tanggal kedaluwarsa,
        # artinya IP tersebut masih dalam masa aktif
        if [[ "$current_ip" == "$ip" && "$current_date_sec" -le "$expiry_date_sec" ]]; then
            verified=true
            break
        fi
    done

    # Tampilkan pesan sesuai hasil verifikasi
    if $verified; then
        echo "————————————————————————————————————"
        echo "           Success Message !!"
        echo "————————————————————————————————————"
        echo "       IP ANDA TERVERIFIKASI ✓"
        echo "————————————————————————————————————"
    else
        echo "————————————————————————————————————"
        echo "           Error Message !!"
        echo "————————————————————————————————————"
        echo "     Anda Belum Terdaftar Untuk"
        echo "   Menggunakan Script ini. Silahkan"
        echo "            Registrasi ke"
        echo "  Tele : Sanmaxx | Wa : 085155208019"
        echo "————————————————————————————————————"
        exit 1
    fi
}


# Script untuk Verifikasi Pengguna
while true; do
    echo " .:: Pilih tipe pengguna ::."
    echo "1. Owner Script"
    echo "2. Pengguna Script"
    read -p "Masukkan pilihan Anda (1/2): " pilihan

    if [ "$pilihan" == "1" ]; then
        read -sp "Masukkan Password Owner: " password
        echo
        if [ "$password" == "@adminamz" ]; then
            echo -e "${GB}Selamat Datang Tuan${NC}"
            mkdir -p /etc/xray/
            touch /etc/xray/admin
            sleep 2
            break
        else
            echo -e "Password Salah, Jika Kamu Pengguna Silahkan Memilih Opsi No.2"
        fi
    elif [ "$pilihan" == "2" ]; then
        verif_ip
        break
    else
        echo -e "Pilihan tidak valid. Silakan coba lagi."
    fi
done
clear
# ======== END IP VERIFIKASI ========

clear
# ==== Export Warna
green='\e[0;32m'
NC='\e[0m'

# ==== Export CREDITS
CREDITS="${green} ـــــــــــــــﮩ٨ـ QuickTunnel ${NC}" 

# ==== Export Link Github 
GITHUB="https://raw.githubusercontent.com/AMZTORETNL/amz-tunnel/main/"

# Running Banner
TEXT="QuickTunnel ـــــــــــــــﮩ٨ـ | Preparing . . . "
for (( i=0; i<${#TEXT}; i++ ))
do
    echo -n -e "${green}${TEXT:$i:1}${NC}"
    sleep 0.1 #Delay Antar Huruf
done
clear


# ==== Setup Input Domain
echo -e "┌───────────────────────────────────────────────────┐"
echo -e "│  Setup Your Domain For This Script | ${green}QuickTunnel${NC}  │"
echo -e "└───────────────────────────────────────────────────┘"
echo ""
read -p "Type Your Domain : " domain

mkdir -p /etc/xray/limitip/
mkdir -p /opt/history/
echo $domain >> /root/domain
echo $domain >> /etc/xray/domain

${CREDITS}
# ==== Perbaharui System
apt update -y
apt upgrade -y

${CREDITS}
# ==== Install SSH & Xray
wget -q ${GITHUB}install/install-ssh.sh && bash install-ssh.sh
wget -q ${GITHUB}install/install-xray.sh && bash install-xray.sh
${CREDITS}
# ==== Install Menu
wget -q ${GITHUB}install/install-menu.sh && bash install-menu.sh
${CREDITS}
# ==== Install Vnstat
wget -q ${GITHUB}install/install-vnstat.sh && bash install-vnstat.sh
# ==== Install Limit IP Xray
cd /etc/xray/limitip
wget -q ${GITHUB}tools/check-ip-limit.sh
wget -q ${GITHUB}tools/clients_limit.conf
cd
${CREDITS}
# ==== Install Auto Backup
wget -q ${GITHUB}tools/auto_backup.sh && bash auto_backup.sh

# ==== Memasang Default Menu saat Boot
cat> /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
menu
END
chmod 644 /root/.profile

# ===== Pasang Cronjob limitIP
CRON_JOB="*/5 * * * * /bin/bash /etc/xray/check-ip-limit.sh"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

# ==== Pasang auto Reboot
(crontab -l 2>/dev/null; echo "0 23 * * * reboot # auto_reboot") | crontab -
    


echo ""
echo -e "┌─────────────────────────────────────┐"
echo -e "│ .::  DETAIL SCRIPT QUICKTUNNEL ::.  │"
echo -e "└─────────────────────────────────────┘"
echo -e "√ SERVICE :"
echo -e "   SSH WEBSOCKET "
echo -e "   XRAY VMESS WS & GRPC"
echo -e "   XRAY VLESS WS & GRPC"
echo -e "   XRAY TROJAN WS & GRPC"
echo -e "√ PORT : "
echo -e "   DROPBEAR      : 22, 109, 5000"
echo -e "   WEBSOCKET     : 80"
echo -e "   EBSOCKET TLS  : 443"
echo -e "   GRPC          : 443"
echo -e "└─────────────────────────────────────┘"

rm -rf /root/*

echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
