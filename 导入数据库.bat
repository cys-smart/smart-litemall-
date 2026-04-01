@echo off
REM ========================================
REM litemall 数据库快速导入
REM ========================================

echo ========================================
echo litemall 数据库导入
echo ========================================
echo.
echo 此脚本将：
echo 1. 测试MySQL连接
echo 2. 创建litemall数据库
echo 3. 导入数据表和初始数据
echo.
echo 请确保MySQL服务正在运行
echo.
pause

cls
echo ========================================
echo 步骤 1/3: 测试MySQL连接
echo ========================================
echo.

set MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe

REM 测试无密码连接
"%MYSQL_BIN%" -u root -e "SELECT 1;" >nul 2>&1
if %errorLevel% equ 0 (
    echo [√] MySQL可以使用无密码连接
    set MYSQL_PASS=
    goto do_import
)

echo [!] MySQL需要密码
echo.
set /p MYSQL_PASS=请输入MySQL root密码:

REM 测试密码
"%MYSQL_BIN%" -u root -p%MYSQL_PASS% -e "SELECT 1;" >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo [×] 密码错误，无法连接MySQL
    echo.
    echo 请检查：
    echo 1. MySQL服务是否正在运行
    echo 2. 密码是否正确
    echo 3. 可以通过以下命令检查：
    echo    net start MySQL80
    echo.
    pause
    exit /b 1
)

echo [√] 密码正确，MySQL连接成功
echo.

:do_import
cls
echo ========================================
echo 步骤 2/3: 导入数据库
echo ========================================
echo.

set SQL_DIR=D:\Code\litemall-master\litemall-db\sql

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

cls
echo ========================================
echo 步骤 3/3: 验证数据库
echo ========================================
echo.

echo 检查数据库...
if defined MYSQL_PASS (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% -e "USE litemall; SELECT COUNT(*) as '表数量' FROM information_schema.tables WHERE table_schema='litemall';"
) else (
    "%MYSQL_BIN%" -u root -e "USE litemall; SELECT COUNT(*) as '表数量' FROM information_schema.tables WHERE table_schema='litemall';"
)

echo.
echo ========================================
echo 恭喜！数据库导入完成！
echo ========================================
echo.
echo 数据库信息:
echo   数据库名: litemall
echo   用户: root
echo.
echo 下一步:
echo.
echo 1. 启动后端服务:
echo    start-backend.bat
echo.
echo 2. 访问管理后台:
echo    http://localhost:9527
echo    账号: admin123 / admin123
echo.
echo 3. 查看API文档:
echo    http://localhost:8080/doc.html
echo.
pause
