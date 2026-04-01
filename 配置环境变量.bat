@echo off
REM ========================================
REM 配置Java和Maven环境变量（需要管理员权限）
REM ========================================

echo ========================================
echo 配置Java和Maven环境变量
echo ========================================
echo.
echo 此脚本将配置以下环境变量:
echo   JAVA_HOME=D:\DevTools\jdk-11
echo   MAVEN_HOME=D:\DevTools\apache-maven-3.9.6
echo   添加到PATH: %%JAVA_HOME%%\bin 和 %%MAVEN_HOME%%\bin
echo.
echo 注意: 需要管理员权限运行
echo.

REM 检查是否有管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 需要管理员权限！
    echo.
    echo 请右键点击此文件，选择"以管理员身份运行"
    echo.
    pause
    exit /b 1
)

echo 正在配置环境变量...
echo.

REM 使用PowerShell设置用户环境变量
powershell.exe -Command "& { [Environment]::SetEnvironmentVariable('JAVA_HOME', 'D:\DevTools\jdk-11', 'User'); [Environment]::SetEnvironmentVariable('MAVEN_HOME', 'D:\DevTools\apache-maven-3.9.6', 'User'); $oldPath = [Environment]::GetEnvironmentVariable('Path', 'User'); if ($oldPath -notlike '*DevTools*') { $newPath = 'D:\DevTools\jdk-11\bin;D:\DevTools\apache-maven-3.9.6\bin;' + $oldPath; [Environment]::SetEnvironmentVariable('Path', $newPath, 'User'); Write-Host 'PATH已更新' -ForegroundColor Green } else { Write-Host 'PATH已包含DevTools' -ForegroundColor Yellow } }"

echo.
echo ========================================
echo [√] 环境变量配置完成！
echo ========================================
echo.
echo 重要提示:
echo 1. 请关闭当前命令行窗口
echo 2. 重新打开新的命令行窗口
echo 3. 验证环境: java -version 和 mvn -version
echo.
echo 然后运行: 启动系统.bat
echo.
pause
