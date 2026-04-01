@echo off
REM ========================================
REM MySQL Root密码重置工具
REM ========================================

echo ========================================
echo MySQL Root密码重置
echo ========================================
echo.
echo 此工具将：
echo 1. 停止MySQL服务
echo 2. 以安全模式启动MySQL（无密码）
echo 3. 重置root密码
echo 4. 重启MySQL服务
echo.
echo 警告: 需要管理员权限！
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 需要管理员权限！
    echo 请右键点击此文件，选择"以管理员身份运行"
    echo.
    pause
    exit /b 1
)

echo [√] 已获得管理员权限
echo.

REM 询问新密码
echo 请设置新的MySQL root密码
echo.
set /p NEW_PASS=新密码 (直接回车设置为无密码):

echo.
echo ========================================
echo 步骤 1/5: 停止MySQL服务
echo ========================================
echo.

net stop MySQL80
if %errorLevel% neq 0 (
    echo [错误] 停止MySQL服务失败
    pause
    exit /b 1
)

echo [√] MySQL服务已停止
echo.

REM 创建SQL脚本
echo 步骤 2/5: 创建密码重置脚本...
echo.

set RESET_SQL=%TEMP%\reset_mysql.sql

echo FLUSH PRIVILEGES; > "%RESET_SQL%"

if defined NEW_PASS (
    if "%NEW_PASS%"=="" (
        echo ALTER USER 'root'@'localhost' IDENTIFIED BY ''; >> "%RESET_SQL%"
    ) else (
        echo ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '%NEW_PASS%'; >> "%RESET_SQL%"
    )
) else (
    echo ALTER USER 'root'@'localhost' IDENTIFIED BY ''; >> "%RESET_SQL%"
)

echo FLUSH PRIVILEGES; >> "%RESET_SQL%"

echo [√] 密码重置脚本已创建
echo.

echo ========================================
echo 步骤 3/5: 启动MySQL安全模式
echo ========================================
echo.
echo 正在启动MySQL（跳过权限验证）...
echo 请稍候...
echo.

start /B "" "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqld.exe" --skip-grant-tables --shared-memory --console

REM 等待MySQL启动
timeout /t 10 /nobreak >nul

echo [√] MySQL已以安全模式启动
echo.

echo ========================================
echo 步骤 4/5: 重置密码
echo ========================================
echo.

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root < "%RESET_SQL%"

if %errorLevel% equ 0 (
    echo [√] 密码重置成功
) else (
    echo [×] 密码重置失败
    goto cleanup
)

echo.

REM 停止安全模式MySQL
echo 步骤 5/5: 重启MySQL服务...
echo.

taskkill /F /IM mysqld.exe >nul 2>&1
timeout /t 3 /nobreak >nul

net start MySQL80

if %errorLevel% equ 0 (
    echo [√] MySQL服务已启动
) else (
    echo [×] MySQL服务启动失败
)

echo.
echo ========================================
echo 密码重置完成！
echo ========================================
echo.

if defined NEW_PASS (
    if "%NEW_PASS%"=="" (
        echo MySQL root密码已设置为: [无密码]
    ) else (
        echo MySQL root密码已设置为: %NEW_PASS%
    )
) else (
    echo MySQL root密码已设置为: [无密码]
)

echo.
echo 验证新密码...
echo.

if defined NEW_PASS (
    if "%NEW_PASS%"=="" (
        "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -e "SELECT '成功连接' as status;"
    ) else (
        "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p%NEW_PASS% -e "SELECT '成功连接' as status;"
    )
) else (
    "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -e "SELECT '成功连接' as status;"
)

echo.
echo ========================================
echo 下一步
echo ========================================
echo.
echo 1. 导入litemall数据库
echo    运行: 导入数据库_交互.bat
echo.
echo 2. 启动后端服务
echo    运行: start-backend.bat
echo.

:cleanup
REM 清理临时文件
if exist "%RESET_SQL%" del "%RESET_SQL%"

pause
