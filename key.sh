#!/bin/bash

# 配置邮箱
EMAIL="pencq@outlook.com"

# 生成或覆盖SSH Key
echo "重新创建SSH Key..."
read -p "是否设置密钥密码？(y/n): " answer
if [[ $answer =~ ^[Yy]$ ]]; then
  ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -C "$EMAIL"
else
  ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N "" -C "$EMAIL"
fi
echo "SSH Key创建成功！"

# 提示输入新的 SSH 端口
read -p "请输入新的 SSH 端口号 (默认: 22): " SSH_PORT
SSH_PORT=${SSH_PORT:-22}

# 修改SSH配置
SSH_CONFIG_FILE="/etc/ssh/sshd_config"
if sudo sed -i.bak "s/^#\?Port .*/Port $SSH_PORT/g" "$SSH_CONFIG_FILE"; then
    echo "SSH 端口修改为 $SSH_PORT 成功！"
else
    echo "修改SSH端口失败，请检查！"
    exit 1
fi

# 禁用密码登录
if sudo sed -i.bak "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/g" "$SSH_CONFIG_FILE"; then
    echo "已禁用密码登录。"
else
    echo "禁用密码登录失败，请检查！"
    exit 1
fi

# 重启 SSH 服务
echo "重启 SSH 服务..."
sudo systemctl restart sshd
if ! sudo systemctl is-active sshd; then
    echo "SSH 服务重启失败，请检查！"
    exit 1
fi

# 输出公钥
echo "您的SSH公钥为："
cat "$HOME/.ssh/id_rsa.pub"
echo "您的SSH公钥为：" 
cat "$HOME/.ssh/id_rsa.pub"
echo "SSH 配置已完成，请使用 SSH 密钥进行连接，确保配置生效！"
