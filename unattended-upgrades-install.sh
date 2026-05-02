#!/usr/bin/env bash
set -e

echo "== 安装 unattended-upgrades =="
sudo apt update
sudo apt install -y unattended-upgrades

echo "== 写入 /etc/apt/apt.conf.d/20auto-upgrades =="
sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

echo "== 写入 /etc/apt/apt.conf.d/50unattended-upgrades =="
sudo tee /etc/apt/apt.conf.d/50unattended-upgrades > /dev/null <<'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}:${distro_codename}-updates";
};

Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
EOF

echo "== 再次更新软件源 =="
sudo apt update

echo "== 执行 unattended-upgrade（真实执行） =="
sudo unattended-upgrade --debug

echo "== 完成 =="