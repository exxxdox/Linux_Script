#!/bin/bash
# 用法: ./smb-mount.sh <server_ip> <share_name> <mount_point> <username> <password>
#
# @参数说明
#   server_ip     必填   SMB 服务器地址，IP 或主机名
#   share_name    必填   共享名，只写共享名，不带 // 前缀
#   mount_point   必填   本地挂载目录，不存在时自动创建
#   username      必填   SMB 账号，写入 /etc/samba/creds_<server>_<share>
#   password      必填   SMB 密码，同上写入凭据文件（权限 600）
#
# 注意: 密码经命令行传入，会留在 shell history 与 ps 输出中

SERVER="$1"
SHARE="$2"
MOUNT_POINT="$3"
USER="$4"
PASS="$5"
CRED_FILE="/etc/samba/creds_${SERVER}_${SHARE}"

# 检查参数
if [ $# -lt 5 ]; then
    echo "用法: $0 <server_ip> <share_name> <mount_point> <username> <password>"
    exit 1
fi

# 安装依赖
if ! dpkg -s cifs-utils >/dev/null 2>&1; then
    echo "正在安装 cifs-utils..."
    sudo apt update && sudo apt install -y cifs-utils
fi

# 创建挂载点
if [ ! -d "$MOUNT_POINT" ]; then
    echo "创建挂载点: $MOUNT_POINT"
    sudo mkdir -p "$MOUNT_POINT"
fi

# 写凭据文件
echo "生成凭据文件: $CRED_FILE"
sudo mkdir -p /etc/samba
echo "username=$USER" | sudo tee "$CRED_FILE" > /dev/null
echo "password=$PASS" | sudo tee -a "$CRED_FILE" > /dev/null
sudo chmod 600 "$CRED_FILE"

# 挂载（永久挂载到 /etc/fstab）
FSTAB_LINE="//$SERVER/$SHARE $MOUNT_POINT cifs credentials=$CRED_FILE,vers=3.0,iocharset=utf8,uid=$(id -u),gid=$(id -g),nofail 0 0"
echo "正在写入 /etc/fstab 挂载项..."
if ! grep -qs "//$SERVER/$SHARE" /etc/fstab; then
    echo "$FSTAB_LINE" | sudo tee -a /etc/fstab > /dev/null
    echo "已添加挂载项到 /etc/fstab"
else
    echo "挂载项已存在于 /etc/fstab，无需重复添加"
fi
echo "正在挂载所有 /etc/fstab 项..."
sudo mount -a

# 检查是否成功
if mount | grep -q "$MOUNT_POINT"; then
    echo "✅ 挂载成功: //$SERVER/$SHARE -> $MOUNT_POINT"
else
    echo "❌ 挂载失败，请检查服务器地址/账号/密码/协议版本"
fi
