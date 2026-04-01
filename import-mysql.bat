@echo off
REM ========================================
REM 导入litemall数据库
REM ========================================

echo ========================================
echo 导入litemall数据库
echo ========================================
echo.

set MYSQL_BIN=D:\DevTools\mysql-8.0.40-winx64\bin
set SQL_DIR=D:\Code\litemall-master\litemall-db\sql

echo 正在检查SQL文件...
if not exist "%SQL_DIR%\litemall_schema.sql" (
    echo [错误] 找不到 litemall_schema.sql
    pause
    exit /b 1
)

echo.
echo [1/3] 创建数据库结构...
"%MYSQL_BIN%\mysql.exe" -u root < "%SQL_DIR%\litemall_schema.sql"
if %errorLevel% equ 0 (
    echo [√] 数据库结构创建成功
) else (
    echo [×] 数据库结构创建失败
    pause
    exit /b 1
)

echo.
echo [2/3] 创建数据表...
"%MYSQL_BIN%\mysql.exe" -u root litemall < "%SQL_DIR%\litemall_table.sql"
if %errorLevel% equ 0 (
    echo [√] 数据表创建成功
) else (
    echo [×] 数据表创建失败
    pause
    exit /b 1
)

echo.
echo [3/3] 导入初始数据...
"%MYSQL_BIN%\mysql.exe" -u root litemall < "%SQL_DIR%\litemall_data.sql"
if %errorLevel% equ 0 (
    echo [√] 初始数据导入成功
) else (
    echo [×] 初始数据导入失败
    pause
    exit /b 1
)

echo.
echo ========================================
echo litemall数据库导入完成！
echo ========================================
echo.
echo 数据库信息:
echo   数据库名: litemall
echo   用户: root (无密码)
echo.
echo 验证数据库:
echo   "%MYSQL_BIN%\mysql" -u root -e "USE litemall; SHOW TABLES;"
echo.
pause
