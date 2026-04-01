@echo off
REM ========================================
REM litemall 管理后台快速启动脚本
REM ========================================

echo ========================================
echo litemall 管理后台启动
echo ========================================
echo.

cd /d "%~dp0\litemall-admin"

if not exist "node_modules" (
    echo 首次运行，正在安装依赖...
    call npm install
    echo.
)

echo 正在启动管理后台...
echo 访问地址: http://localhost:9527
echo.
echo 按 Ctrl+C 停止服务
echo.

call npm run dev

pause
