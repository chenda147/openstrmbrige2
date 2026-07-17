#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "============================================"
echo "  OpenStrmBridge Docker 本地构建与部署"
echo "============================================"
echo ""

if [ ! -f ".env" ] && [ -f ".env.example" ]; then
  echo "[INFO] 未找到 .env 文件，从 .env.example 复制..."
  cp .env.example .env
  echo "[OK] .env 已创建，请根据需要修改配置"
fi

case "${1:-}" in
  pull)
    echo "[STEP] 拉取镜像..."
    docker compose pull
    echo "[STEP] 启动容器..."
    docker compose up -d
    echo "[OK] 服务已启动！访问 http://localhost:5174"
    ;;
  build)
    echo "[STEP] 本地构建镜像（可能需要几分钟）..."
    docker compose -f docker-compose.yml -f docker-compose.build.yml build
    echo "[STEP] 启动容器..."
    docker compose up -d
    echo "[OK] 服务已启动！访问 http://localhost:5174"
    ;;
  stop)
    echo "[STEP] 停止并删除容器..."
    docker compose down
    echo "[OK] 容器已停止"
    ;;
  logs)
    docker compose logs -f --tail=100
    ;;
  *)
    echo "用法: $0 {pull|build|stop|logs}"
    echo "  pull   - 拉取官方镜像并启动"
    echo "  build  - 本地构建镜像并启动"
    echo "  stop   - 停止并删除容器"
    echo "  logs   - 查看实时日志"
    exit 1
    ;;
esac
