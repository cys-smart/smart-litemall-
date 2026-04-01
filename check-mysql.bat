@echo off
setlocal enabledelayedexpansion

echo ========================================
echo MySQL连接测试
echo ========================================
echo.

set MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe

echo 尝试无密码连接MySQL...
"%MYSQL_BIN%" -u root -e "SELECT VERSION();" >nul 2>&1
if %errorLevel% equ 0 (
    echo [√] MySQL可以使用无密码连接
    echo.
    goto import_db
)

echo [!] MySQL需要密码
echo.
set /p MYSQL_PASS=请输入MySQL root密码:

REM 测试密码
"%MYSQL_BIN%" -u root -p%MYSQL_PASS% -e "SELECT VERSION();" >nul 2>&1
if %errorLevel% neq 0 (
    echo [×] 密码错误，请重试
    pause
    exit /b 1
)

echo [√] 密码正确
echo.

:import_db
REM ========================================
REM 导入数据库
REM ========================================
echo ========================================
echo 导入litemall数据库
echo ========================================
echo.

set SQL_DIR=D:\Code\litemall-master\litemall-db\sql

if not exist "%SQL_DIR%\litemall_schema.sql" (
    echo [错误] 找不到SQL文件
    pause
    exit /b 1
)

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
echo ========================================
echo 数据库导入完成！
echo ========================================
echo.

REM 验证数据库
echo 验证数据库...
if defined MYSQL_PASS (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% -e "USE litemall; SHOW TABLES;" 2>nul
) else (
    "%MYSQL_BIN%" -u root -e "USE litemall; SHOW TABLES;" 2>nul
)

echo.
echo [√] 数据库配置完成！
echo.
echo 现在可以启动后端服务了：
echo   start-backend.bat
echo.
pause
