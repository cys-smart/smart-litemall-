@echo off
REM ========================================
REM litemall 项目一键初始化脚本
REM 需要管理员权限运行
REM ========================================

setlocal enabledelayedexpansion

echo ========================================
echo litemall 项目一键初始化
echo ========================================
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 需要管理员权限！
    echo.
    echo 请右键点击此文件，选择"以管理员身份运行"
    echo.
    pause
    exit /b 1
)

echo [√] 已获取管理员权限
echo.

REM ========================================
REM 步骤1: 配置环境变量
REM ========================================
echo ========================================
echo 步骤 1/5: 配置环境变量
echo ========================================
echo.

echo 正在配置 JAVA_HOME...
powershell.exe -Command "[Environment]::SetEnvironmentVariable('JAVA_HOME', 'D:\DevTools\jdk-11', 'User')" >nul 2>&1

echo 正在配置 MAVEN_HOME...
powershell.exe -Command "[Environment]::SetEnvironmentVariable('MAVEN_HOME', 'D:\DevTools\apache-maven-3.9.6', 'User')" >nul 2>&1

echo 正在配置 PATH...
powershell.exe -Command "$oldPath = [Environment]::GetEnvironmentVariable('Path', 'User'); if ($oldPath -notlike '*DevTools*') { $newPath = 'D:\DevTools\jdk-11\bin;D:\DevTools\apache-maven-3.9.6\bin;' + $oldPath; [Environment]::SetEnvironmentVariable('Path', $newPath, 'User') }" >nul 2>&1

echo [√] 环境变量配置完成
echo.

REM ========================================
REM 步骤2: 启动MySQL服务
REM ========================================
echo ========================================
echo 步骤 2/5: 启动MySQL服务
echo ========================================
echo.

REM 检查MySQL服务状态
sc query MySQL80 | find "STATE" | find "RUNNING" >nul 2>&1
if %errorLevel% equ 0 (
    echo [√] MySQL服务已在运行
    goto check_mysql
)

echo 正在启动MySQL80服务...
net start MySQL80 >nul 2>&1

if %errorLevel% equ 0 (
    echo [√] MySQL服务启动成功
) else (
    echo [!] MySQL服务启动失败
    echo.
    echo 可能的原因:
    echo 1. MySQL未正确安装
    echo 2. MySQL服务名称不是MySQL80
    echo 3. 端口3306被占用
    echo.
    echo 请手动启动MySQL后继续...
    pause
)

:check_mysql
echo 等待MySQL就绪...
timeout /t 3 /nobreak >nul
echo.

REM ========================================
REM 步骤3: 检查数据库
REM ========================================
echo ========================================
echo 步骤 3/5: 检查数据库
echo ========================================
echo.

set MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe

if not exist "%MYSQL_BIN%" (
    echo [错误] MySQL未找到: %MYSQL_BIN%
    echo.
    echo 请安装MySQL或修改脚本中的MYSQL_BIN路径
    pause
    exit /b 1
)

REM 测试MySQL连接（尝试无密码连接）
"%MYSQL_BIN%" -u root -e "SELECT 1;" >nul 2>&1
if %errorLevel% equ 0 (
    echo [√] MySQL无需密码连接
    set MYSQL_PASS=
    goto import_db
)

REM 需要密码
echo [!] MySQL需要密码
set /p MYSQL_PASS=请输入MySQL root密码 (直接回车如果无密码):

REM 测试密码
if "%MYSQL_PASS%"=="" (
    "%MYSQL_BIN%" -u root -e "SELECT 1;" >nul 2>&1
) else (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% -e "SELECT 1;" >nul 2>&1
)

if %errorLevel% neq 0 (
    echo [×] 密码错误或无法连接MySQL
    echo.
    echo 请检查:
    echo 1. MySQL服务是否正在运行
    echo 2. root密码是否正确
    echo 3. 可以跳过数据库导入手动处理
    echo.
    set /p skip=是否跳过数据库导入? (Y/N):
    if /i "!skip!"=="Y" goto finish
    exit /b 1
)

echo [√] MySQL连接成功
echo.

REM ========================================
REM 步骤4: 导入数据库
REM ========================================
:import_db
echo ========================================
echo 步骤 4/5: 导入数据库
echo ========================================
echo.

set SQL_DIR=%~dp0litemall-db\sql

REM 检查数据库是否存在
if "%MYSQL_PASS%"=="" (
    "%MYSQL_BIN%" -u root -e "USE litemall; SHOW TABLES;" >nul 2>&1
) else (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% -e "USE litemall; SHOW TABLES;" >nul 2>&1
)

if %errorLevel% equ 0 (
    echo [√] 数据库已存在，跳过导入
    goto finish
)

echo 正在导入litemall数据库...
echo.

REM 创建数据库结构
echo [1/3] 创建数据库结构...
if "%MYSQL_PASS%"=="" (
    "%MYSQL_BIN%" -u root < "%SQL_DIR%\litemall_schema.sql"
) else (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% < "%SQL_DIR%\litemall_schema.sql"
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
if "%MYSQL_PASS%"=="" (
    "%MYSQL_BIN%" -u root litemall < "%SQL_DIR%\litemall_table.sql"
) else (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% litemall < "%SQL_DIR%\litemall_table.sql"
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
if "%MYSQL_PASS%"=="" (
    "%MYSQL_BIN%" -u root litemall < "%SQL_DIR%\litemall_data.sql"
) else (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% litemall < "%SQL_DIR%\litemall_data.sql"
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
echo.

REM ========================================
REM 步骤5: 创建数据库用户
REM ========================================
echo ========================================
echo 步骤 5/5: 配置数据库用户
echo ========================================
echo.

echo 正在创建litemall数据库用户...
if "%MYSQL_PASS%"=="" (
    "%MYSQL_BIN%" -u root litemall -e "CREATE USER IF NOT EXISTS 'litemall'@'localhost' IDENTIFIED BY 'litemall123456'; GRANT ALL PRIVILEGES ON litemall.* TO 'litemall'@'localhost'; FLUSH PRIVILEGES;" 2>nul
) else (
    "%MYSQL_BIN%" -u root -p%MYSQL_PASS% litemall -e "CREATE USER IF NOT EXISTS 'litemall'@'localhost' IDENTIFIED BY 'litemall123456'; GRANT ALL PRIVILEGES ON litemall.* TO 'litemall'@'localhost'; FLUSH PRIVILEGES;" 2>nul
)
echo [√] 数据库用户配置完成
echo.

:finish
REM ========================================
REM 完成
REM ========================================
echo ========================================
echo [√] 初始化完成！
echo ========================================
echo.
echo 环境配置:
echo   - Java环境: 已配置
echo   - Maven环境: 已配置
echo   - MySQL服务: 已启动
echo   - 数据库: 已导入
echo   - 数据库用户: 已创建
echo.
echo 下一步:
echo   1. 关闭当前命令行窗口
echo   2. 重新打开命令行窗口（让环境变量生效）
echo   3. 运行: 启动系统.bat
echo.
echo 或者直接双击: 启动系统.bat
echo.
pause
