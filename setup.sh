#!/bin/bash

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

loading() {
    local message=$1
    echo -ne "${CYAN}$message${NC}"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.5
    done
    echo ""
}

print_line() {
    echo -e "${BLUE}────────────────────────────────────────${NC}"
}

clear
echo -e "${CYAN}"
print_line
echo -e "      ${WHITE}API Service Setup Script${CYAN} "
print_line
echo -e "${NC}"

echo -e "${YELLOW}Step 1: Masukkan IP yang diizinkan${NC}"
echo -e "${WHITE}Pisahkan dengan koma jika lebih dari satu (contoh: 192.168.1.1,192.168.1.2)${NC}"
read -p "> " ALLOWED_IPS

echo -e "\n${YELLOW}Step 2: Masukkan port yang akan digunakan${NC}"
read -p "> " PORT

if [[ -z "$PORT" ]]; then
    echo -e "\n${RED}❌ Port tidak boleh kosong! Jalankan ulang script dan masukkan port yang valid.${NC}"
    exit 1
fi

echo -e "\n${CYAN}🔍 Konfigurasi Anda:${NC}"
print_line
echo -e "${WHITE}ALLOWED_IPS: ${GREEN}$ALLOWED_IPS${NC}"
echo -e "${WHITE}PORT       : ${GREEN}$PORT${NC}"
print_line

read -p "Apakah konfigurasi sudah benar? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    echo -e "${RED}❌ Konfigurasi dibatalkan. Tidak ada perubahan yang dibuat.${NC}"
    exit 1
fi

loading "📂 Membuat file konfigurasi .env"
cat >/root/Api/.env << EOF
ALLOWED_IPS=$ALLOWED_IPS
PORT=$PORT
EOF
echo -e "${GREEN}✅ File .env berhasil dibuat.${NC}"

loading "📂 Membuat file service systemd"
cat >/etc/systemd/system/sapi.service << EOF
[Unit]
Description=API Service
After=network.target

[Service]
WorkingDirectory=/root/Apibt
ExecStart=/usr/bin/env node /root/Apibt/apiV2.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF
echo -e "${GREEN}✅ File service systemd berhasil dibuat.${NC}"

loading "🔄 Reload systemd dan memulai service"
systemctl daemon-reload
systemctl restart api
systemctl enable api
echo -e "${GREEN}✅ Service API berhasil dimulai.${NC}"

echo -e "\n${CYAN}ℹ️  Status Service:${NC}"
print_line
systemctl status api --no-pager
print_line

# Pesan akhir
echo -e "${CYAN}✨ Setup selesai! Anda dapat mulai menggunakan API di port ${WHITE}$PORT${CYAN}.${NC}"
echo -e "${CYAN}Terima kasih telah menggunakan script ini! 🚀${NC}"
