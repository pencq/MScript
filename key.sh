#!/bin/bash

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 权限运行此脚本！"
    exit 1
fi

# 配置文件路径
SSH_CONFIG_FILE="/etc/ssh/sshd_config"
AUTHORIZED_KEYS_FILE="$HOME/.ssh/authorized_keys"

# 检查并创建 .ssh 目录
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

# 生成 SSH 密钥
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "正在创建 SSH 密钥..."
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -q -N ""
    echo "SSH 密钥创建成功！"
else
    echo "SSH 密钥已存在，跳过创建。"
fi

# 将公钥添加到授权密钥文件
cat "$HOME/.ssh/id_rsa.pub" >> "$AUTHORIZED_KEYS_FILE"
chmod 600 "$AUTHORIZED_KEYS_FILE"

# 提示用户输入新的 SSH 端口
read -p "请输入新的 SSH 端口号 (默认: 22): " SSH_PORT
SSH_PORT=${SSH_PORT:-22}

# 修改 SSH 配置
echo "正在修改 SSH 配置..."
sudo sed -i.bak "s/^#\?Port .*/Port $SSH_PORT/" "$SSH_CONFIG_FILE"
sudo sed -i.bak "s/^#\?PasswordAuthentication.*/PasswordAuthentication no/" "$SSH_CONFIG_FILE"
sudo sed -i.bak "s/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/" "$SSH_CONFIG_FILE"

# 重启 SSH 服务
sudo systemctl restart sshd || { echo "重启 SSH 服务失败！"; exit 1; }

# 输出生成的公钥
echo "您的 SSH 公钥为："
cat "$HOME/.ssh/id_rsa.pub"

echo "SSH 配置已完成，请尝试使用 SSH 密钥连接，确保配置生效！"
