@echo off
REM ========================================
REM litemall 后端快速启动脚本
REM ========================================

echo ========================================
echo litemall 后端服务启动
echo ========================================
echo.

REM 检查环境变量
if not defined JAVA_HOME (
    set JAVA_HOME=D:\DevTools\jdk-11
)

echo 正在启动后端服务...
echo JAR文件: litemall-all\target\litemall-all-0.1.0-exec.jar
echo.
echo 按 Ctrl+C 停止服务
echo.

cd /d "%~dp0"
java -Dfile.encoding=UTF-8 -jar litemall-all\target\litemall-all-0.1.0-exec.jar

pause
