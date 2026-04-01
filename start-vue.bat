@echo off
REM ========================================
REM litemall Vue移动端快速启动脚本
REM ========================================

echo ========================================
echo litemall Vue移动端启动
echo ========================================
echo.

cd /d "%~dp0\litemall-vue"

if not exist "node_modules" (
    echo 首次运行，正在安装依赖...
    call npm install
    echo.
)

echo 正在启动Vue移动端...
echo 访问地址: http://localhost:6255
echo 建议使用Chrome手机模式浏览
echo.
echo 按 Ctrl+C 停止服务
echo.

call npm run dev

pause
