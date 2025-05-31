#!/bin/bash

# Export File tujuan
FILE="/etc/xray/config.json"

# === Vmess Expired
grep -n '##' "$FILE" | while IFS=: read -r line_num comment; do
    # Ambil kata ke-3 sebagai tanggal
    expiry_date=$(echo "$comment" | awk '{print $3}')
    
    # Validasi apakah tanggal sesuai format YYYY-MM-DD
    if [[ "$expiry_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        # Bandingkan tanggal dengan hari ini
        today=$(date +%F)
        if [[ "$expiry_date" < "$today" ]]; then
            echo "Tanggal expired ditemukan di baris $line_num: $comment"
            echo "Menghapus baris $line_num dan $((line_num + 1))..."

            # Hapus baris tersebut dan baris berikutnya secara aman
            sed -i "${line_num}d" "$FILE"
            sed -i "${line_num}d" "$FILE"
        fi
    else
        echo "Format tanggal tidak valid pada baris $line_num: $comment"
    fi
done

# === Vless Expired
grep -n '#?' "$FILE" | while IFS=: read -r line_num comment; do
    # Ambil kata ke-3 sebagai tanggal
    expiry_date=$(echo "$comment" | awk '{print $3}')
    
    # Validasi apakah tanggal sesuai format YYYY-MM-DD
    if [[ "$expiry_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        # Bandingkan tanggal dengan hari ini
        today=$(date +%F)
        if [[ "$expiry_date" < "$today" ]]; then
            echo "Tanggal expired ditemukan di baris $line_num: $comment"
            echo "Menghapus baris $line_num dan $((line_num + 1))..."

            # Hapus baris tersebut dan baris berikutnya secara aman
            sed -i "${line_num}d" "$FILE"
            sed -i "${line_num}d" "$FILE"
        fi
    else
        echo "Format tanggal tidak valid pada baris $line_num: $comment"
    fi
done

# === Trojan Expired
grep -n '#!' "$FILE" | while IFS=: read -r line_num comment; do
    # Ambil kata ke-3 sebagai tanggal
    expiry_date=$(echo "$comment" | awk '{print $3}')
    
    # Validasi apakah tanggal sesuai format YYYY-MM-DD
    if [[ "$expiry_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        # Bandingkan tanggal dengan hari ini
        today=$(date +%F)
        if [[ "$expiry_date" < "$today" ]]; then
            echo "Tanggal expired ditemukan di baris $line_num: $comment"
            echo "Menghapus baris $line_num dan $((line_num + 1))..."

            # Hapus baris tersebut dan baris berikutnya secara aman
            sed -i "${line_num}d" "$FILE"
            sed -i "${line_num}d" "$FILE"
        fi
    else
        echo "Format tanggal tidak valid pada baris $line_num: $comment"
    fi
done

systemctl restart xray

# ==== Expired SSH
hapus_user_kadaluarsa() {
    echo "Memeriksa dan menghapus akun yang sudah kadaluarsa..."
    for user in $(cut -f1 -d: /etc/passwd); do
        expire_date=$(chage -l "$user" 2>/dev/null | grep "Account expires" | awk -F": " '{print $2}')
        if [[ "$expire_date" != "never" && "$expire_date" != "" ]]; then
            # Konversi tanggal expired dan tanggal hari ini ke format detik sejak epoch
            expire_seconds=$(date -d "$expire_date" +%s 2>/dev/null)
            today_seconds=$(date +%s)

            if [[ "$expire_seconds" -lt "$today_seconds" ]]; then
                echo "Akun $user telah kadaluarsa. Menghapus..."
                userdel -r "$user" &>/dev/null
            fi
        fi
    done
}
hapus_user_kadaluarsa
