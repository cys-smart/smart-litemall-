@echo off
REM ========================================
REM 修复并设置环境变量
REM ========================================

echo ========================================
echo 修复环境变量
echo ========================================
echo.

REM 设置JAVA_HOME
echo [1/4] 设置 JAVA_HOME...
setx JAVA_HOME "D:\DevTools\jdk-11"
echo [√] JAVA_HOME = D:\DevTools\jdk-11
echo.

REM 设置MAVEN_HOME
echo [2/4] 设置 MAVEN_HOME...
setx MAVEN_HOME "D:\DevTools\apache-maven-3.9.6"
echo [√] MAVEN_HOME = D:\DevTools\apache-maven-3.9.6
echo.

REM 获取当前PATH
echo [3/4] 检查 PATH...
for /f "tokens=2*" %%a in ('reg query HKCU\Environment /v Path 2^>nul') do set "CURRENT_PATH=%%b"
echo 当前PATH前200字符:
echo %CURRENT_PATH:~0,200%
echo.

REM 添加到PATH
echo [4/4] 更新 PATH...
powershell -Command "$old = [Environment]::GetEnvironmentVariable('Path', 'User'); $new = 'D:\DevTools\jdk-11\bin;D:\DevTools\apache-maven-3.9.6\bin'; if ($old -notlike '*DevTools*') { [Environment]::SetEnvironmentVariable('Path', $old + ';' + $new, 'User'); Write-Host '已添加DevTools路径' } else { Write-Host 'PATH已包含DevTools' }"
echo.

echo ========================================
echo 环境变量设置完成！
echo ========================================
echo.
echo 重要: 请关闭所有PowerShell和命令行窗口
echo 然后重新打开才能生效！
echo.
echo 验证命令:
echo   D:\DevTools\jdk-11\bin\java.exe -version
echo   D:\DevTools\apache-maven-3.9.6\bin\mvn.cmd -version
echo.
pause
