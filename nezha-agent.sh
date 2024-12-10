#!/bin/bash

# 停止所有 nezha-agent 服务
echo "Stopping all nezha-agent services..."
for service in $(systemctl list-units --type=service | grep nezha-agent | awk '{print $1}'); do
    echo "Stopping $service..."
    sudo systemctl stop "$service"
done

# 禁用所有 nezha-agent 服务
echo "Disabling all nezha-agent services..."
for service in $(systemctl list-units --type=service | grep nezha-agent | awk '{print $1}'); do
    echo "Disabling $service..."
    sudo systemctl disable "$service"
done

# 删除所有相关服务文件
echo "Deleting nezha-agent service files..."
sudo find /etc/systemd/system/ -name "nezha-agent*.service" -exec rm -f {} \;

# 删除二进制文件
echo "Deleting nezha-agent binary files..."
sudo rm -f /usr/local/bin/nezha-agent

# 删除安装目录（如果存在）
echo "Deleting installation directory (/opt/nezha)..."
sudo rm -rf /opt/nezha

# 删除 nezha.sh 脚本（如果存在）
echo "Deleting nezha.sh script..."
sudo rm -f /root/nezha.sh

# 重新加载 systemd 配置
echo "Reloading systemd configuration..."
sudo systemctl daemon-reload

# 检查是否有残留服务
echo "Checking for remaining nezha-agent services..."
systemctl list-units --type=service | grep nezha-agent

echo "Cleanup completed."
