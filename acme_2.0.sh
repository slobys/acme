#!/bin/bash

# 确保脚本在遇到错误时退出
set -e

# 提示用户输入域名和电子邮件地址
read -p "请输入域名: " DOMAIN
read -p "请输入电子邮件地址: " EMAIL

# 显示选项菜单
echo "请选择要使用的证书颁发机构 (CA):"
echo "1) Let's Encrypt"
echo "2) Buypass"
echo "3) ZeroSSL"
read -p "输入选项 (1, 2, or 3): " CA_OPTION

# 根据用户选择设置CA参数
case $CA_OPTION in
    1)
        CA_SERVER="letsencrypt"
        ;;
    2)
        CA_SERVER="buypass"
        ;;
    3)
        CA_SERVER="zerossl"
        ;;
    *)
        echo "无效选项"
        exit 1
        ;;
esac

# 更新系统并安装依赖项
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl socat

# 安装 acme.sh
curl https://get.acme.sh | sh

# 使 acme.sh 脚本可用
export PATH="$HOME/.acme.sh:$PATH"

# 添加执行权限
chmod +x "$HOME/.acme.sh/acme.sh"

# 注册帐户（使用用户提供的电子邮件地址）
acme.sh --register-account -m $EMAIL --server $CA_SERVER

# 申请 SSL 证书（使用用户提供的域名）
acme.sh --issue --standalone -d $DOMAIN --server $CA_SERVER

# 安装 SSL 证书
sudo acme.sh --install-cert -d $DOMAIN \
        --key-file       /etc/ssl/private/${DOMAIN}.key \
        --fullchain-file /etc/ssl/certs/${DOMAIN}.crt

# 提示用户证书已生成
echo "SSL证书和私钥已生成:"
echo "证书: /etc/ssl/certs/${DOMAIN}.crt"
echo "私钥: /etc/ssl/private/${DOMAIN}.key"
