#!/usr/bin/env bash
# ==============================================================================
# File        : setup.sh
# Description : Automated Installer for ROS2 Jazzy Jalisco & Gazebo Harmonic on Zsh
# Usage       : chmod +x setup.sh && ./setup.sh
# ==============================================================================

set -e  # Herhangi bir komut hata verirse betiği durdur

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}==> [1/5] Sistem Güncellemesi ve Yerel Ayarlar (Locale) Yapılandırılıyor...${NC}"
sudo apt update && sudo apt install -y locales software-properties-common curl gnupg2 lsb-release
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

echo -e "${BLUE}==> [2/5] ROS2 GPG Anahtarları ve Depoları Ekleniyor...${NC}"
sudo add-apt-repository universe -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

echo -e "${BLUE}==> [3/5] ROS2 Jazzy Masaüstü Paketi Yükleniyor (Bu işlem biraz sürebilir)...${NC}"
sudo apt update
sudo apt install -y ros-jazzy-desktop

echo -e "${BLUE}==> [4/5] Colcon Derleme Araçları ve Gazebo Entegrasyonu Yükleniyor...${NC}"
sudo apt install -y python3-colcon-common-extensions ros-jazzy-ros-gz

echo -e "${BLUE}==> [5/5] Zsh Kabuk Yapılandırması ve Çevre Değişkenleri İşleniyor...${NC}"
ZSH_RC="$HOME/.zshrc"

# Duplicate kayıt oluşmasını önleyerek .zshrc dosyasına ekleme yap
if [ -f "$ZSH_RC" ]; then
    grep -qF 'source /opt/ros/jazzy/setup.zsh' "$ZSH_RC" || echo 'source /opt/ros/jazzy/setup.zsh' >> "$ZSH_RC"
    grep -qF 'export GZ_VERSION=harmonic' "$ZSH_RC" || echo 'export GZ_VERSION=harmonic' >> "$ZSH_RC"
    echo -e "${GREEN}✓ ~/.zshrc dosyasına ROS2 ve GZ_VERSION ayarları eklendi.${NC}"
else
    echo -e "${YELLOW}! ~/.zshrc bulunamadı, varsayılan bash ortamı kontrol ediliyor...${NC}"
    grep -qF 'source /opt/ros/jazzy/setup.bash' "$HOME/.bashrc" || echo 'source /opt/ros/jazzy/setup.bash' >> "$HOME/.bashrc"
    grep -qF 'export GZ_VERSION=harmonic' "$HOME/.bashrc" || echo 'export GZ_VERSION=harmonic' >> "$HOME/.bashrc"
fi

echo -e "${GREEN}========================================================================${NC}"
echo -e "${GREEN}   ROS2 Jazzy & Gazebo Harmonic Kurulumu Başarıyla Tamamlandı! 🎉       ${NC}"
echo -e "${GREEN}========================================================================${NC}"
echo -e "${YELLOW}Lütfen değişikliklerin geçerli olması için terminalinizi kapatıp açın${NC}"
echo -e "${YELLOW}veya şu komutu çalıştırın: source ~/.zshrc${NC}"