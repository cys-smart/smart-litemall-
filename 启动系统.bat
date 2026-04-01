@echo off
REM ========================================
REM litemall 系统启动脚本（自动配置环境）
REM ========================================

setlocal enabledelayedexpansion

REM 设置Java和Maven路径（使用绝对路径）
set JAVA_HOME=D:\DevTools\jdk-11
set MAVEN_HOME=D:\DevTools\apache-maven-3.9.6
set PATH=%JAVA_HOME%\bin;%MAVEN_HOME%\bin;%PATH%

REM 项目路径
set PROJECT_DIR=D:\Code\litemall-master
set JAR_FILE=%PROJECT_DIR%\litemall-all\target\litemall-all-0.1.0-exec.jar
set JAVA_BIN=%JAVA_HOME%\bin\java.exe

echo ========================================
echo litemall 系统启动
echo ========================================
echo.
echo Java: %JAVA_HOME%
echo Maven: %MAVEN_HOME%
echo.

REM 检查Java是否存在
if not exist "%JAVA_BIN%" (
    echo [错误] Java未找到: %JAVA_BIN%
    echo.
    echo 请确保JDK已安装在: %JAVA_HOME%
    echo 或者运行: 一键初始化.bat
    echo.
    pause
    exit /b 1
)

REM 验证Java版本
"%JAVA_BIN%" -version >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] Java无法运行
    echo 请检查JDK安装
    echo.
    pause
    exit /b 1
)

echo [√] Java环境检查通过
echo.

REM 检查JAR文件
if not exist "%JAR_FILE%" (
    echo [错误] JAR文件不存在: %JAR_FILE%
    echo.
    echo 请先运行以下命令构建项目:
    echo   cd %PROJECT_DIR%
    echo   mvn clean package -DskipTests
    echo.
    pause
    exit /b 1
)

echo ========================================
echo 请选择启动选项:
echo ========================================
echo.
echo [1] 启动后端服务 (端口 8080)
echo [2] 启动管理后台前端 (端口 9527)
echo [3] 启动Vue移动端 (端口 6255)
echo [4] 全部启动
echo [5] 仅启动后端和管理后台
echo.
set /p choice=请输入选择 (1-5):

if "%choice%"=="1" goto backend
if "%choice%"=="2" goto admin
if "%choice%"=="3" goto vue
if "%choice%"=="4" goto all
if "%choice%"=="5" goto backend_admin

:backend
echo.
echo [启动] 后端服务...
start "litemall-backend" cmd /k "cd /d %PROJECT_DIR% && title litemall后端服务 && set PATH=%JAVA_HOME%\bin;%PATH% && echo 正在启动后端... && echo 访问地址: http://localhost:8080 && echo. && "%JAVA_BIN%" -jar %JAR_FILE%"
echo [√] 后端服务已在单独窗口启动
echo.
pause
exit /b 0

:admin
echo.
echo [启动] 管理后台前端...
start "litemall-admin" cmd /k "cd /d %PROJECT_DIR%\litemall-admin && title litemall管理后台 && echo 正在启动管理后台... && echo 访问地址: http://localhost:9527 && echo 默认账号: admin123 / admin123 && echo. && npm run dev"
echo [√] 管理后台已在单独窗口启动
echo.
pause
exit /b 0

:vue
echo.
echo [启动] Vue移动端...
start "litemall-vue" cmd /k "cd /d %PROJECT_DIR%\litemall-vue && title litemall移动端 && echo 正在启动Vue移动端... && echo 访问地址: http://localhost:6255 && echo. && npm run dev"
echo [√] Vue移动端已在单独窗口启动
echo.
pause
exit /b 0

:backend_admin
echo.
echo [启动] 后端服务...
start "litemall-backend" cmd /k "cd /d %PROJECT_DIR% && title litemall后端服务 && set PATH=%JAVA_HOME%\bin;%PATH% && echo 正在启动后端... && echo 访问地址: http://localhost:8080 && echo. && "%JAVA_BIN%" -jar %JAR_FILE%"
timeout /t 3 /nobreak >nul
echo.
echo [启动] 管理后台前端...
start "litemall-admin" cmd /k "cd /d %PROJECT_DIR%\litemall-admin && title litemall管理后台 && echo 正在启动管理后台... && echo 访问地址: http://localhost:9527 && echo 默认账号: admin123 / admin123 && echo. && npm run dev"
echo [√] 后端和管理后台已启动
echo.
pause
exit /b 0

:all
echo.
echo [启动] 后端服务...
start "litemall-backend" cmd /k "cd /d %PROJECT_DIR% && title litemall后端服务 && set PATH=%JAVA_HOME%\bin;%PATH% && echo 正在启动后端... && echo 访问地址: http://localhost:8080 && echo. && "%JAVA_BIN%" -jar %JAR_FILE%"
timeout /t 3 /nobreak >nul
echo.
echo [启动] 管理后台前端...
start "litemall-admin" cmd /k "cd /d %PROJECT_DIR%\litemall-admin && title litemall管理后台 && echo 正在启动管理后台... && echo 访问地址: http://localhost:9527 && echo 默认账号: admin123 / admin123 && echo. && npm run dev"
timeout /t 2 /nobreak >nul
echo.
echo [启动] Vue移动端...
start "litemall-vue" cmd /k "cd /d %PROJECT_DIR%\litemall-vue && title litemall移动端 && echo 正在启动Vue移动端... && echo 访问地址: http://localhost:6255 && echo. && npm run dev"
echo.
echo ========================================
echo [√] 所有服务已启动！
echo ========================================
echo.
echo 服务访问地址:
echo   - 后端API: http://localhost:8080
echo   - 管理后台: http://localhost:9527 (admin123/admin123)
echo   - Vue移动端: http://localhost:6255
echo   - API文档: http://localhost:8080/doc.html
echo.
echo 按任意键关闭此窗口...
pause >nul
exit /b 0
