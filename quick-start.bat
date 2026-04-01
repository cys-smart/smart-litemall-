@echo off
REM ========================================
REM litemall 快速启动（跳过数据库导入）
REM ========================================

echo ========================================
echo litemall 快速启动
echo ========================================
echo.

set PROJECT_DIR=D:\Code\litemall-master

echo [!] 注意: 请确保已导入litemall数据库
echo 如果未导入，请运行: import-mysql.bat
echo.

REM 检查端口占用
echo 检查端口...
netstat -ano | findstr ":8080" >nul 2>&1
if %errorLevel% equ 0 (
    echo [!] 端口8080已被占用，后端可能已运行
) else (
    echo [1/3] 启动后端服务...
    start "litemall-backend" cmd /k "cd /d %PROJECT_DIR% && title litemall后端 && java -jar litemall-all\target\litemall-all-0.1.0-exec.jar"
    echo     后端启动中...
)

netstat -ano | findstr ":9527" >nul 2>&1
if %errorLevel% equ 0 (
    echo [!] 端口9527已被占用，管理后台可能已运行
) else (
    echo [2/3] 启动管理后台...
    start "litemall-admin" cmd /k "cd /d %PROJECT_DIR%\litemall-admin && title litemall管理后台 && npm run dev"
    echo     管理后台启动中...
)

netstat -ano | findstr ":6255" >nul 2>&1
if %errorLevel% equ 0 (
    echo [!] 端口6255已被占用，Vue移动端可能已运行
) else (
    echo [3/3] 启动Vue移动端...
    start "litemall-vue" cmd /k "cd /d %PROJECT_DIR%\litemall-vue && title litemall移动端 && npm run dev"
    echo     Vue移动端启动中...
)

echo.
echo ========================================
echo 启动完成！
echo ========================================
echo.
echo 访问地址:
echo   - 管理后台: http://localhost:9527
echo     账号: admin123 / admin123
echo.
echo   - Vue移动端: http://localhost:6255
echo.
echo   - 后端API: http://localhost:8080
echo.
echo 提示:
echo   1. 首次启动前端需要安装依赖，请耐心等待
echo   2. 如果后端报错连接数据库，请先导入数据库
echo.
pause
