@echo off
REM ========================================
REM litemall 系统诊断脚本
REM ========================================

setlocal enabledelayedexpansion

set JAVA_HOME=D:\DevTools\jdk-11
set MAVEN_HOME=D:\DevTools\apache-maven-3.9.6
set PROJECT_DIR=D:\Code\litemall-master

echo ========================================
echo litemall 系统诊断
echo ========================================
echo.

REM ========================================
REM 1. 检查Java
REM ========================================
echo [检查 1/6] Java环境
echo ---------------------------
if exist "%JAVA_HOME%\bin\java.exe" (
    echo [√] JDK已安装: %JAVA_HOME%
    "%JAVA_HOME%\bin\java.exe" -version 2>&1 | findstr "version"
) else (
    echo [×] JDK未找到: %JAVA_HOME%
)
echo.

REM ========================================
REM 2. 检查Maven
REM ========================================
echo [检查 2/6] Maven环境
echo ---------------------------
if exist "%MAVEN_HOME%\bin\mvn.cmd" (
    echo [√] Maven已安装: %MAVEN_HOME%
    call "%MAVEN_HOME%\bin\mvn.cmd" -version | findstr "Apache Maven"
) else (
    echo [×] Maven未找到: %MAVEN_HOME%
)
echo.

REM ========================================
REM 3. 检查环境变量
REM ========================================
echo [检查 3/6] 系统环境变量
echo ---------------------------
if defined JAVA_HOME (
    echo [√] JAVA_HOME: %JAVA_HOME%
) else (
    echo [×] JAVA_HOME未设置
)

if defined MAVEN_HOME (
    echo [√] MAVEN_HOME: %MAVEN_HOME%
) else (
    echo [×] MAVEN_HOME未设置
)

echo %PATH% | findstr "DevTools" >nul 2>&1
if %errorLevel% equ 0 (
    echo [√] PATH包含DevTools
) else (
    echo [×] PATH不包含DevTools
)
echo.

REM ========================================
REM 4. 检查MySQL服务
REM ========================================
echo [检查 4/6] MySQL服务
echo ---------------------------
sc query MySQL80 | find "STATE" | find "RUNNING" >nul 2>&1
if %errorLevel% equ 0 (
    echo [√] MySQL80服务正在运行
) else (
    echo [×] MySQL80服务未运行
    sc query MySQL80 | find "STATE"
)
echo.

REM ========================================
REM 5. 检查MySQL连接
REM ========================================
echo [检查 5/6] MySQL连接
echo ---------------------------
set MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe
if exist "%MYSQL_BIN%" (
    echo [√] MySQL客户端存在: %MYSQL_BIN%
    "%MYSQL_BIN%" -u root -e "SELECT 1;" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [√] MySQL无密码连接成功
    ) else (
        echo [!] MySQL需要密码
    )
) else (
    echo [×] MySQL客户端未找到
)
echo.

REM ========================================
REM 6. 检查数据库
REM ========================================
echo [检查 6/6] litemall数据库
echo ---------------------------
"%MYSQL_BIN%" -u root -e "USE litemall; SHOW TABLES;" >nul 2>&1
if %errorLevel% equ 0 (
    echo [√] litemall数据库已存在
    "%MYSQL_BIN%" -u root -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='litemall';" 2>nul
) else (
    echo [×] litemall数据库不存在
)
echo.

REM ========================================
REM 7. 检查项目文件
REM ========================================
echo [检查 7/7] 项目文件
echo ---------------------------
set JAR_FILE=%PROJECT_DIR%\litemall-all\target\litemall-all-0.1.0-exec.jar
if exist "%JAR_FILE%" (
    echo [√] 后端JAR已构建
    dir "%JAR_FILE%" | find "litemall-all"
) else (
    echo [×] 后端JAR未找到
    echo     位置: %JAR_FILE%
)

if exist "%PROJECT_DIR%\litemall-admin\package.json" (
    echo [√] 管理后台前端存在
) else (
    echo [×] 管理后台前端未找到
)

if exist "%PROJECT_DIR%\litemall-vue\package.json" (
    echo [√] Vue移动端存在
) else (
    echo [×] Vue移动端未找到
)
echo.

REM ========================================
REM 诊断结果
REM ========================================
echo ========================================
echo 诊断完成
echo ========================================
echo.

REM 统计问题
set /a issues=0

if not exist "%JAVA_HOME%\bin\java.exe" set /a issues+=1
if not exist "%MAVEN_HOME%\bin\mvn.cmd" set /a issues+=1
sc query MySQL80 | find "STATE" | find "RUNNING" >nul 2>&1
if %errorLevel% neq 0 set /a issues+=1
"%MYSQL_BIN%" -u root -e "USE litemall; SHOW TABLES;" >nul 2>&1
if %errorLevel% neq 0 set /a issues+=1
if not exist "%JAR_FILE%" set /a issues+=1

if %issues% equ 0 (
    echo [√] 系统状态良好，可以启动项目！
    echo.
    echo 运行: 启动系统.bat
) else (
    echo [!] 发现 %issues% 个问题需要处理
    echo.
    echo 建议操作:
    if not exist "%JAVA_HOME%\bin\java.exe" echo   - 安装JDK
    if not exist "%MAVEN_HOME%\bin\mvn.cmd" echo   - 安装Maven
    sc query MySQL80 | find "STATE" | find "RUNNING" >nul 2>&1
    if %errorLevel% neq 0 echo   - 启动MySQL服务: net start MySQL80
    "%MYSQL_BIN%" -u root -e "USE litemall; SHOW TABLES;" >nul 2>&1
    if %errorLevel% neq 0 echo   - 导入数据库: 运行 一键初始化.bat
    if not exist "%JAR_FILE%" echo   - 构建项目: mvn clean package -DskipTests
    echo.
    echo 或者运行: 一键初始化.bat
)
echo.
pause
