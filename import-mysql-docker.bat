@echo off
REM ========================================
REM 导入litemall数据库到Docker容器
REM ========================================

echo ========================================
echo 导入litemall数据库 (Docker)
echo ========================================
echo.

set SQL_DIR=D:\Code\litemall-master\litemall-db\sql
set CONTAINER=litemall-mysql

echo 正在检查Docker容器...
docker ps | findstr "%CONTAINER%" >nul
if %errorLevel% neq 0 (
    echo [错误] MySQL容器未运行
    echo 请先运行 install-mysql.bat 选择Docker选项
    pause
    exit /b 1
)

echo.
echo [1/3] 创建数据库结构...
type "%SQL_DIR%\litemall_schema.sql" | docker exec -i %CONTAINER% mysql -uroot litemall
if %errorLevel% equ 0 (
    echo [√] 数据库结构创建成功
) else (
    echo [×] 数据库结构创建失败
    pause
    exit /b 1
)

echo.
echo [2/3] 创建数据表...
type "%SQL_DIR%\litemall_table.sql" | docker exec -i %CONTAINER% mysql -uroot litemall
if %errorLevel% equ 0 (
    echo [√] 数据表创建成功
) else (
    echo [×] 数据表创建失败
    pause
    exit /b 1
)

echo.
echo [3/3] 导入初始数据...
type "%SQL_DIR%\litemall_data.sql" | docker exec -i %CONTAINER% mysql -uroot litemall
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
echo 验证数据库:
echo   docker exec -it litemall-mysql mysql -uroot -e "USE litemall; SHOW TABLES;"
echo.
pause
