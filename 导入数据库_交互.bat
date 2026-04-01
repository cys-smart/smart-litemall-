@echo off
setlocal enabledelayedexpansion

echo ========================================
echo litemall 数据库导入工具
echo ========================================
echo.
echo 请确保MySQL服务正在运行！
echo.

REM 检查MySQL服务
sc query MySQL80 | find "RUNNING" >nul
if %errorLevel% neq 0 (
    echo [!] MySQL服务未运行，正在启动...
    net start MySQL80
    if %errorLevel% neq 0 (
        echo [×] MySQL启动失败
        pause
        exit /b 1
    )
    echo [√] MySQL服务已启动
    echo.
)

set MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe
set SQL_DIR=D:\Code\litemall-master\litemall-db\sql

echo 尝试使用密码 123456 连接MySQL...
echo.

REM 测试连接
"%MYSQL_BIN%" -u root -p123456 -e "SELECT 1;" >nul 2>&1
if %errorLevel% equ 0 (
    echo [√] 密码 123456 连接成功！
    set MYSQL_PASS=123456
    goto import_success
)

echo [!] 密码 123456 无法连接
echo.
echo 请选择:
echo 1. 手动输入密码
echo 2. 尝试无密码连接
echo 3. 退出
echo.
set /p choice=请输入选择 (1-3):

if "%choice%"=="1" goto manual_password
if "%choice%"=="2" goto no_password
if "%choice%"=="3" exit /b 0

:manual_password
echo.
set /p MYSQL_PASS=请输入MySQL root密码:

REM 测试密码
"%MYSQL_BIN%" -u root -p%MYSQL_PASS% -e "SELECT 1;" >nul 2>&1
if %errorLevel% neq 0 (
    echo [×] 密码错误
    pause
    exit /b 1
)

echo [√] 密码正确
goto import_success

:no_password
set MYSQL_PASS=
echo 尝试无密码连接...
"%MYSQL_BIN%" -u root -e "SELECT 1;" >nul 2>&1
if %errorLevel% neq 0 (
    echo [×] 无密码连接失败
    pause
    exit /b 1
)
echo [√] 无密码连接成功

:import_success
echo.
echo ========================================
echo 开始导入数据库
echo ========================================
echo.

REM [1/3] 创建数据库结构
echo [1/3] 创建数据库结构...
if defined MYSQL_PASS (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% < "%SQL_DIR%\litemall_schema.sql" 2>&1 | findstr /V "Warning"
) else (
    "%MYSQL_BIN%" -u root < "%SQL_DIR%\litemall_schema.sql" 2>&1 | findstr /V "Warning"
)

if %errorLevel% equ 0 (
    echo [√] 数据库结构创建成功
) else (
    echo [×] 数据库结构创建失败
    pause
    exit /b 1
)

REM [2/3] 创建数据表
echo.
echo [2/3] 创建数据表...
if defined MYSQL_PASS (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% litemall < "%SQL_DIR%\litemall_table.sql" 2>&1 | findstr /V "Warning"
) else (
    "%MYSQL_BIN%" -u root litemall < "%SQL_DIR%\litemall_table.sql" 2>&1 | findstr /V "Warning"
)

if %errorLevel% equ 0 (
    echo [√] 数据表创建成功
) else (
    echo [×] 数据表创建失败
    pause
    exit /b 1
)

REM [3/3] 导入初始数据
echo.
echo [3/3] 导入初始数据...
if defined MYSQL_PASS (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% litemall < "%SQL_DIR%\litemall_data.sql" 2>&1 | findstr /V "Warning"
) else (
    "%MYSQL_BIN%" -u root litemall < "%SQL_DIR%\litemall_data.sql" 2>&1 | findstr /V "Warning"
)

if %errorLevel% equ 0 (
    echo [√] 初始数据导入成功
) else (
    echo [×] 初始数据导入失败
    pause
    exit /b 1
)

echo.
echo ========================================
echo 验证数据库
echo ========================================
echo.

if defined MYSQL_PASS (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% -e "USE litemall; SHOW TABLES;" 2>nul
) else (
    "%MYSQL_BIN%" -u root -e "USE litemall; SHOW TABLES;" 2>nul
)

echo.
echo ========================================
echo 恭喜！数据库导入完成！
echo ========================================
echo.
echo 现在可以启动后端服务了：
echo   start-backend.bat
echo.
echo 或者：
echo   java -jar litemall-all\target\litemall-all-0.1.0-exec.jar
echo.
pause
