@echo off
REM ========================================
REM MySQL 快速下载和安装脚本
REM ========================================

echo ========================================
echo MySQL 8.0 安装向导
echo ========================================
echo.
echo 请选择安装方式:
echo.
echo [1] 使用MySQL Installer (推荐 - 简单)
echo     - 图形界面安装
echo     - 自动配置
echo     - 需要下载约450MB
echo.
echo [2] 下载MySQL ZIP版 (正在运行)
echo     - 无需安装，解压即用
echo     - 需要手动配置
echo     - 需要下载约230MB
echo.
echo [3] 使用Docker (最快)
echo     - 需要先安装Docker
echo     - 一键启动
echo.
echo [4] 跳过，稍后手动安装
echo.
set /p choice=请输入选择 (1-4):

if "%choice%"=="1" goto installer
if "%choice%"=="2" goto zip
if "%choice%"=="3" goto docker
if "%choice%"=="4" goto manual

:installer
echo.
echo 正在打开MySQL下载页面...
echo.
echo 请按以下步骤操作:
echo 1. 下载 MySQL Installer
echo 2. 运行安装程序
echo 3. 选择 "Developer Default"
echo 4. 设置root密码（可选）
echo 5. 完成安装后运行 import-mysql.bat
echo.
start https://dev.mysql.com/downloads/installer/
pause
exit /b 0

:zip
echo.
echo 正在下载MySQL ZIP版...
echo 下载地址（可手动复制到浏览器）:
echo https://mirrors.aliyun.com/mysql/MySQL-8.0/mysql-8.0.40-winx64.zip
echo.
echo 或者使用以下镜像:
echo - 清华大学: https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-8.0/
echo - 中科大: https://mirrors.ustc.edu.cn/mysql-Downloads/MySQL-8.0/
echo.
echo 下载后请将文件放到 D:\DevTools\ 目录
echo 然后运行 init-mysql.bat 进行初始化
echo.
pause
exit /b 0

:docker
echo.
echo 检查Docker是否安装...
docker --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 未检测到Docker
    echo 请先安装Docker Desktop: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo 正在启动MySQL容器...
docker run --name litemall-mysql ^
  -e MYSQL_ROOT_PASSWORD= ^
  -e MYSQL_DATABASE=litemall ^
  -p 3306:3306 ^
  -v D:/DevTools/mysql-docker:/var/lib/mysql ^
  -d mysql:8.0

if %errorLevel% equ 0 (
    echo.
    echo ========================================
    echo MySQL Docker容器启动成功！
    echo ========================================
    echo.
    echo 容器信息:
    echo   名称: litemall-mysql
    echo   端口: 3306
    echo   密码: (无密码)
    echo.
    echo 常用命令:
    echo   停止: docker stop litemall-mysql
    echo   启动: docker start litemall-mysql
    echo   删除: docker rm litemall-mysql
    echo.
    echo 现在可以运行 import-mysql-docker.bat 导入数据库
    echo.
) else (
    echo [错误] Docker容器启动失败
)

pause
exit /b 0

:manual
echo.
echo 跳过MySQL安装。
echo.
echo 请稍后手动安装MySQL，然后运行:
echo   D:\Code\litemall-master\import-mysql.bat
echo.
echo 详细指南请查看:
echo   D:\DevTools\MySQL安装指南.md
echo.
pause
exit /b 0
