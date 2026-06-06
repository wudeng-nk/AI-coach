#!/bin/bash
# ==============================================================================
# AI Coach - 一键部署脚本
#
# 用法:
#   ./deploy.sh <服务器IP> <用户名>
#
# 示例:
#   ./deploy.sh 123.45.67.89 root
#   ./deploy.sh 123.45.67.89 ubuntu
# ==============================================================================

set -e

SERVER_IP="${1:?用法: ./deploy.sh <服务器IP> [用户名]}"
SERVER_USER="${2:-root}"
REMOTE_DIR="~/ai-coach"

echo "========================================="
echo "  AI Coach 部署"
echo "========================================="
echo "  服务器: $SERVER_USER@$SERVER_IP"
echo "  目录:   $REMOTE_DIR"
echo "========================================="

# 1. 替换 docker-compose.prod.yml 中的 <SERVER_IP>
echo ""
echo "[1/4] 替换服务器 IP..."
sed -i.bak "s/<SERVER_IP>/$SERVER_IP/g" docker-compose.prod.yml
rm -f docker-compose.prod.yml.bak

# 2. 本地构建 Flutter Web
echo ""
echo "[2/4] 构建 Flutter Web..."
cd frontend
flutter build web --release
cd ..

# 3. 打包项目
echo ""
echo "[3/4] 打包项目文件..."
tar -czf /tmp/ai-coach.tar.gz \
  --exclude='.git' \
  --exclude='__pycache__' \
  --exclude='.dart_tool' \
  --exclude='.idea' \
  --exclude='*.iml' \
  --exclude='._*' \
  --exclude='.DS_Store' \
  docker-compose.prod.yml \
  backend/ \
  frontend/Dockerfile \
  frontend/nginx.conf \
  frontend/.dockerignore \
  frontend/build/web/ \
  frontend/pubspec.yaml \
  frontend/pubspec.lock

# 4. 上传到服务器并启动
echo ""
echo "[4/4] 上传并启动..."
ssh "$SERVER_USER@$SERVER_IP" "mkdir -p $REMOTE_DIR"
scp /tmp/ai-coach.tar.gz "$SERVER_USER@$SERVER_IP:$REMOTE_DIR/"

ssh "$SERVER_USER@$SERVER_IP" << 'REMOTE'
cd ~/ai-coach

# 清理旧文件，避免残留损坏的文件
rm -rf backend alembic docker-compose.prod.yml

tar -xzf ai-coach.tar.gz

# 安装 Docker（如果未安装）
if ! command -v docker &>/dev/null; then
  echo "安装 Docker..."
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker $USER
  echo "Docker 安装完成，请重新运行此脚本"
  exit 0
fi

# 启动服务（利用 Docker 层缓存，依赖不变时跳过 pip install）
docker compose -f docker-compose.prod.yml up -d --build

echo ""
echo "等待服务启动..."
sleep 25

# 检查状态
docker compose -f docker-compose.prod.yml ps
echo ""
echo "========================================="
echo "  部署完成!"
echo "  访问: http://$(hostname -I | awk '{print $1}')"
echo "  登录: 13800000000 / 123456"
echo "========================================="
REMOTE

# 清理本地临时文件
rm -f /tmp/ai-coach.tar.gz

echo ""
echo "完成! 浏览器访问 http://$SERVER_IP 即可使用。"
