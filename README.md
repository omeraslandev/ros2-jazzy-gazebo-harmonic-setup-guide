# ROS2 Jazzy ve Gazebo Harmonic Kurulum ve Yapılandırma Kılavuzu

Bu doküman; Ubuntu LTS üzerinde Zsh kabuğu (shell) kullanılarak **ROS2 Jazzy Jalisco** ve **Gazebo Harmonic** simülasyon ortamının sıfırdan kurulması, karşılaşılan kritik terminal hatalarının çözümü ve örnek bir Python paketinin derlenmesi süreçlerini içerir.


## 🚀 Hızlı Otomatik Kurulum

Tüm bağımlılıkları, GPG anahtarlarını, ROS2 Jazzy ve Gazebo Harmonic entegrasyonunu tek komutla kurmak için betiği çalıştırabilirsiniz:

```bash
chmod +x setup.sh && ./setup.sh
```
- *(Adım adım manuel kurulum yapmak istiyorsanız aşağıdaki rehberi takip edebilirsiniz.)*

---

## 1. Sistem Hazırlığı ve Yerel Ayarlar (Locale)

ROS2 kurulumunun sorunsuz ilerlemesi için sistem dil ve UTF-8 ayarlarının doğru yapılandırılması gerekir.

```bash
# Sistem paket listesini güncelle ve locale araçlarını kur
sudo apt update && sudo apt install locales -y

# UTF-8 yerel ayarlarını oluştur ve sistem geneline uygula
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

```

---

## 2. ROS2 Jazzy Depolarının (Repository) Sisteme Eklenmesi

Ubuntu paket yöneticisine ROS2 resmi depoları ve anahtarları (GPG keys) tanıtılır.

```bash
# Gerekli bağımlılıkları ve Ubuntu Universe deposunu aktif et
sudo apt install software-properties-common curl gnupg2 lsb-release -y
sudo add-apt-repository universe -y

# ROS2 GPG anahtarını indir ve sisteme kaydet
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

# Kaynak listesine ROS2 Jazzy deposunu ekle
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

```

---

## 3. ROS2 Jazzy Masaüstü Sürümü Kurulumu

Depolar güncellendikten sonra temel ROS2 ve görsel araçları içeren masaüstü paketi yüklenir.

```bash
sudo apt update
sudo apt install ros-jazzy-desktop -y

```

### ⚠️ Kritik Zsh Yapılandırması (Environment Setup)

Varsayılan `setup.bash` betiği Zsh altında çalıştırıldığında dizin yollarında sapmalara neden olur. Bu yüzden `.zshrc` dosyasına doğrudan Zsh için derlenmiş betik eklenmelidir:

```bash
# Çevre değişkenini Zsh profilinin sonuna ekle
echo "source /opt/ros/jazzy/setup.zsh" >> ~/.zshrc
source ~/.zshrc

# Kurulumu doğrula (Çıktıda ROS2 yolları görünmelidir)
printenv | grep ROS

```

---

## 4. Çalışma Alanı (Workspace) ve Paket Oluşturma

ROS2 projelerini geliştirmek için standart katmanlı bir çalışma alanı oluşturulur ve Python tabanlı test paketi enjekte edilir.

```bash
# Workspace dizin mimarisini oluştur
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws/src

# 'swarm_simulation' adında Python tabanlı paket üret
ros2 pkg create --build-type ament_python swarm_simulation --dependencies rclpy

```

> **Not:** Paket oluşturulduktan sonra `swarm_simulation/swarm_simulation/simple_node.py` dosyası oluşturulup kaynak kodlar yazılmış ve `setup.py` içerisindeki `entry_points` alanına bu düğüm (node) kaydedilmiştir.

---

## 5. Derleme Araçları ve Zsh Önbellek Çözümü (`colcon`)

Paketleri derlemek için kullanılan `colcon` aracı sisteme kurulurken Zsh kabuğunun komut tablosu yenilenmelidir.

```bash
# Colcon derleme araçlarını sisteme yükle
sudo apt update && sudo apt install python3-colcon-common-extensions -y

# CRITICAL: Zsh komut önbelleğini (cache) temizle ve colcon'u kabuğa tanıt
rehash

# Çalışma alanının kök dizinine dön ve paketi derle
cd ~/ros2_ws
colcon build --packages-select swarm_simulation

# Yeni derlenen paketi geçerli terminal oturumuna kaynak et
source install/setup.zsh

# Test düğümünü koştur
ros2 run swarm_simulation simple_node

```

---

## 6. Gazebo Harmonic Entegrasyonu ve Sürüm Mutabakatı

ROS2 Jazzy ile Gazebo simülasyon dünyasını bağlamak için `ros_gz` köprüsü kurulur.

```bash
# ROS2 - Gazebo köprü paketlerini kur
sudo apt install ros-jazzy-ros-gz -y

```

### ⚠️ Kritik `GZ_VERSION` Hatası ve Çözümü

`ros_gz_sim` launch dosyaları tetiklendiğinde, Python altyapısı varsayılan simülatör sürümünü algılayamazsa `NoneType` hatası fırlatır. Çözüm için Gazebo sürümü kabuğa kalıcı olarak deklare edilmelidir:

```bash
# Çevre değişkenini sisteme göm ve profili yenile
echo "export GZ_VERSION=harmonic" >> ~/.zshrc
source ~/.zshrc

# Alternatif: Standart SDF dünyasını doğrudan Gazebo ile açmak için:
gz sim shapes.sdf

# ROS2 Launch sistemi üzerinden entegrasyonu başlatmak için:
ros2 launch ros_gz_sim gz_sim.launch.py gz_args:="shapes.sdf"

```

---

**Sonuç:** Bu adımların ardından simülasyon evreni grafik motoru hatası olmaksızın ayağa kalkacak, yazılan custom Python düğümleri ile Gazebo dünyası arasında veri iletişimi başarıyla sağlanacaktır.
