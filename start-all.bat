@echo off
REM ========================================
REM litemall 完整启动脚本
REM ========================================

setlocal enabledelayedexpansion

echo ========================================
echo litemall 项目完整启动
echo ========================================
echo.

REM 设置路径
set MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe
set SQL_DIR=D:\Code\litemall-master\litemall-db\sql
set PROJECT_DIR=D:\Code\litemall-master

REM ========================================
REM 步骤1: 检查数据库
REM ========================================
echo [步骤 1/4] 检查MySQL数据库...
echo.

REM 测试MySQL连接
"%MYSQL_BIN%" -u root -e "SELECT 1;" >nul 2>&1
if %errorLevel% equ 0 (
    echo [√] MySQL无需密码连接
    set MYSQL_PASS=
    goto import_database
)

REM 需要密码
echo [!] MySQL需要密码
set /p MYSQL_PASS=请输入MySQL root密码 (直接回车如果无密码):

REM 测试密码
"%MYSQL_BIN%" -u root -p%MYSQL_PASS% -e "SELECT 1;" >nul 2>&1
if %errorLevel% neq 0 (
    echo [×] 密码错误，无法连接MySQL
    echo.
    echo 请检查MySQL是否正在运行，密码是否正确
    echo 可以跳过数据库导入，但后端可能无法正常启动
    echo.
    set /p skip=是否跳过数据库导入? (Y/N):
    if /i "!skip!"=="Y" goto start_backend
    pause
    exit /b 1
)

echo [√] MySQL连接成功
echo.

:import_database
REM ========================================
REM 步骤2: 导入数据库
REM ========================================
echo [步骤 2/4] 导入litemall数据库...
echo.

REM 检查数据库是否存在
if defined MYSQL_PASS (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% -e "USE litemall; SHOW TABLES;" >nul 2>&1
) else (
    "%MYSQL_BIN%" -u root -e "USE litemall; SHOW TABLES;" >nul 2>&1
)

if %errorLevel% equ 0 (
    echo [√] 数据库已存在，跳过导入
    goto start_backend
)

echo 正在导入数据库...
echo.

REM 创建数据库结构
echo [1/3] 创建数据库结构...
if defined MYSQL_PASS (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% < "%SQL_DIR%\litemall_schema.sql"
) else (
    "%MYSQL_BIN%" -u root < "%SQL_DIR%\litemall_schema.sql"
)
if %errorLevel% equ 0 (
    echo [√] 数据库结构创建成功
) else (
    echo [×] 数据库结构创建失败
    pause
    exit /b 1
)

REM 创建表
echo.
echo [2/3] 创建数据表...
if defined MYSQL_PASS (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% litemall < "%SQL_DIR%\litemall_table.sql"
) else (
    "%MYSQL_BIN%" -u root litemall < "%SQL_DIR%\litemall_table.sql"
)
if %errorLevel% equ 0 (
    echo [√] 数据表创建成功
) else (
    echo [×] 数据表创建失败
    pause
    exit /b 1
)

REM 导入数据
echo.
echo [3/3] 导入初始数据...
if defined MYSQL_PASS (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% litemall < "%SQL_DIR%\litemall_data.sql"
) else (
    "%MYSQL_BIN%" -u root litemall < "%SQL_DIR%\litemall_data.sql"
)
if %errorLevel% equ 0 (
    echo [√] 初始数据导入成功
) else (
    echo [×] 初始数据导入失败
    pause
    exit /b 1
)

echo.
echo [√] 数据库导入完成！

:start_backend
REM ========================================
REM 步骤3: 启动后端
REM ========================================
echo.
echo [步骤 3/4] 启动后端服务...
echo.

REM 检查后端是否已在运行
netstat -ano | findstr ":8080" >nul 2>&1
if %errorLevel% equ 0 (
    echo [!] 后端服务已在运行 (端口8080)
    goto start_frontend
)

echo 正在启动后端服务...
echo 提示: 后端启动需要10-20秒
echo.

REM 在新窗口启动后端
start "litemall-backend" cmd /k "cd /d %PROJECT_DIR% && title litemall后端服务 && echo 正在启动后端... && java -jar litemall-all\target\litemall-all-0.1.0-exec.jar"

REM 等待后端启动
echo 等待后端启动...
timeout /t 15 /nobreak >nul

echo [√] 后端服务启动完成
echo.

:start_frontend
REM ========================================
REM 步骤4: 启动前端
REM ========================================
echo [步骤 4/4] 启动前端服务...
echo.

REM 启动管理后台
echo 正在启动管理后台...
start "litemall-admin" cmd /k "cd /d %PROJECT_DIR%\litemall-admin && title litemall管理后台 && echo 正在启动管理后台... && echo 访问地址: http://localhost:9527 && echo. && npm run dev"

REM 启动Vue移动端
echo 正在启动Vue移动端...
start "litemall-vue" cmd /k "cd /d %PROJECT_DIR%\litemall-vue && title litemall移动端 && echo 正在启动Vue移动端... && echo 访问地址: http://localhost:6255 && echo. && npm run dev"

echo.
echo ========================================
echo 🎉 litemall项目启动完成！
echo ========================================
echo.
echo 服务访问地址:
echo.
echo   后端API:
echo     - 管理后台API: http://localhost:8080/admin
echo     - 微信小程序API: http://localhost:8080/wx
echo     - API文档: http://localhost:8080/doc.html
echo.
echo   前端页面:
echo     - 管理后台: http://localhost:9527
echo       账号: admin123 / admin123
echo.
echo     - Vue移动端: http://localhost:6255
echo       建议使用Chrome手机模式
echo.
echo   微信小程序:
echo     - 使用微信开发者工具打开: %PROJECT_DIR%\litemall-wx
echo.
echo 按任意键关闭此窗口（服务将继续运行）...
pause >nul
