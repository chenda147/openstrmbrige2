@echo off
chcp 65001 >nul 2>&1
cd /d "%~dp0"

echo ============================================
echo   OpenStrmBridge Docker 本地构建与部署
echo ============================================
echo.

if not exist ".env" (
    if exist ".env.example" (
        echo [INFO] 未找到 .env 文件，从 .env.example 复制...
        copy .env.example .env >nul
        echo [OK] .env 已创建，请根据需要修改配置
    )
)

echo.
echo 选择操作：
echo   1) 拉取官方镜像并启动（推荐）
echo   2) 本地构建镜像并启动
echo   3) 停止并删除容器
echo   4) 查看日志
echo.

set /p choice="请输入选项 (1-4): "

if "%choice%"=="1" goto pull_and_start
if "%choice%"=="2" goto build_and_start
if "%choice%"=="3" goto stop
if "%choice%"=="4" goto logs
goto end

:pull_and_start
echo.
echo [STEP] 拉取镜像...
docker compose pull
if %errorlevel% neq 0 (
    echo [ERROR] 拉取失败，尝试本地构建...
    goto build_and_start
)
echo [STEP] 启动容器...
docker compose up -d
echo [OK] 服务已启动！访问 http://localhost:5174
goto end

:build_and_start
echo.
echo [STEP] 本地构建镜像（可能需要几分钟）...
docker compose -f docker-compose.yml -f docker-compose.build.yml build
if %errorlevel% neq 0 (
    echo [ERROR] 构建失败
    goto end
)
echo [STEP] 启动容器...
docker compose up -d
echo [OK] 服务已启动！访问 http://localhost:5174
goto end

:stop
echo.
echo [STEP] 停止并删除容器...
docker compose down
echo [OK] 容器已停止
goto end

:logs
echo.
echo [STEP] 查看日志（Ctrl+C 退出）...
docker compose logs -f --tail=100
goto end

:end
pause
