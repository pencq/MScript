#!/bin/bash

# 版本
VERSION=1.0
EMAIL="pencq@outlook.com"
SSH_CONFIG_FILE="/etc/ssh/sshd_config"
AUTHORIZED_KEYS_FILE="$HOME/.ssh/authorized_keys"
SWAP_SIZE="1G"  # 你可以根据需要调整交换空间的大小

# 创建 .ssh 目录
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

# 生成 SSH Key
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
  echo "创建SSH Key..."
  read -p "是否设置密钥密码？(y/n): " answer
  if [[ $answer =~ ^[Yy]$ ]]; then
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -C "$EMAIL"
  else
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N "" -C "$EMAIL"
  fi
  # 检查是否成功生成密钥
  if [ $? -ne 0 ]; then
    echo "生成SSH密钥失败，请检查！"
    exit 1
  fi
  echo "SSH Key创建成功！"
else
  echo "SSH Key已存在，跳过创建。"
fi

# 添加公钥到授权密钥
cat "$HOME/.ssh/id_rsa.pub" >> "$AUTHORIZED_KEYS_FILE"
chmod 600 "$AUTHORIZED_KEYS_FILE"

# 提示输入新的 SSH 端口号
read -p "请输入新的 SSH 端口号 (默认: 22): " SSH_PORT
SSH_PORT=${SSH_PORT:-22}  # 未输入则默认 22

# 修改 SSH 配置
echo "正在修改 SSH 配置..."
if ! sudo sed -i.bak "s/^#\?Port .*/Port $SSH_PORT/g" "$SSH_CONFIG_FILE"; then
  echo "修改SSH端口失败，请检查！"
  exit 1
fi

if ! sudo sed -i "s/^#\?PasswordAuthentication.*/PasswordAuthentication no/g" "$SSH_CONFIG_FILE"; then
  echo "禁用密码登录失败，请检查！"
  exit 1
fi

# 检查并创建交换空间
if [ ! -f /swapfile ]; then
  echo "正在创建交换空间..."
  sudo fallocate -l $SWAP_SIZE /swapfile
  if [ $? -ne 0 ]; then
    echo "创建交换空间失败，请检查！"
    exit 1
  fi
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  echo "交换空间创建并启用成功！"
else
  echo "交换空间已存在，跳过创建。"
fi

# 重启 SSH 服务
echo "重启 SSH 服务..."
sudo systemctl restart sshd
if ! systemctl is-active --quiet sshd; then
  echo "重启 SSH 服务失败，请检查！"
  exit 1
fi

# 输出生成的公钥
echo "您的SSH公钥为："
cat "$HOME/.ssh/id_rsa.pub"

echo "SSH 配置已完成，请尝试使用 SSH 密钥连接，确保配置生效！"
