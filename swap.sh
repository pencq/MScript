#!/bin/bash

# 检查是否已有SWAP空间
echo "检查当前SWAP状态..."
sudo swapon --show

# 创建一个SWAP文件（默认1GB，可调整大小）
echo "创建1GB SWAP文件..."
sudo fallocate -l 1G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=1024

# 设置SWAP文件权限
echo "设置SWAP文件权限..."
sudo chmod 600 /swapfile

# 将文件转换为SWAP空间
echo "将文件转换为SWAP空间..."
sudo mkswap /swapfile

# 启用SWAP文件
echo "启用SWAP文件..."
sudo swapon /swapfile

# 验证SWAP是否启用
echo "验证SWAP是否成功添加..."
sudo swapon --show

# 设置开机自动挂载SWAP
echo "设置开机自动挂载SWAP..."
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# 可选：调整SWAP优先级（swappiness）
echo "调整系统SWAP使用优先级..."
sudo sysctl vm.swappiness=10
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

echo "SWAP添加完成！"
