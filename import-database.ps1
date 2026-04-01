# MySQL数据库导入脚本

Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "litemall 数据库导入" -ForegroundColor Cyan
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host ""

$MySQLBin = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
$SqlDir = "D:\Code\litemall-master\litemall-db\sql"

# 检查文件是否存在
if (-not (Test-Path $MySQLBin)) {
    Write-Host "[错误] 找不到MySQL客户端" -ForegroundColor Red
    Write-Host "路径: $MySQLBin"
    pause
    exit 1
}

if (-not (Test-Path "$SqlDir\litemall_schema.sql")) {
    Write-Host "[错误] 找不到SQL文件" -ForegroundColor Red
    pause
    exit 1
}

# 测试无密码连接
Write-Host "测试MySQL连接..." -ForegroundColor Yellow
& $MySQLBin -u root -e "SELECT 1;" 2>$null | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "[√] MySQL可以使用无密码连接" -ForegroundColor Green
    $MySqlPass = ""
} else {
    Write-Host "[!] MySQL需要密码" -ForegroundColor Yellow
    $MySqlPass = Read-Host "请输入MySQL root密码"

    # 测试密码
    & $MySQLBin -u root -p$MySqlPass -e "SELECT 1;" 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[×] 密码错误，请重试" -ForegroundColor Red
        pause
        exit 1
    }
    Write-Host "[√] 密码正确" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "开始导入数据库" -ForegroundColor Cyan
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host ""

# 导入函数
function Import-SqlFile {
    param($FileName, $Step, $Total)

    Write-Host "[$Step/$Total] $FileName..." -ForegroundColor Cyan

    $Arguments = @("-u", "root")
    if ($MySqlPass -ne "") {
        $Arguments += "-p$MySqlPass"
    }

    if ($FileName -eq "litemall_schema.sql") {
        & $MySQLBin $Arguments "<" "$SqlDir\$FileName" 2>&1 | Out-Null
    } else {
        & $MySQLBin $Arguments "litemall" "<" "$SqlDir\$FileName" 2>&1 | Out-Null
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[√] $FileName 导入成功" -ForegroundColor Green
        return $true
    } else {
        Write-Host "[×] $FileName 导入失败" -ForegroundColor Red
        return $false
    }
}

# 导入数据库
if (-not (Import-SqlFile "litemall_schema.sql" 1 3)) { pause; exit 1 }
Write-Host ""

if (-not (Import-SqlFile "litemall_table.sql" 2 3)) { pause; exit 1 }
Write-Host ""

if (-not (Import-SqlFile "litemall_data.sql" 3 3)) { pause; exit 1 }
Write-Host ""

Write-Host "========================================"  -ForegroundColor Green
Write-Host "数据库导入完成！" -ForegroundColor Green
Write-Host "========================================"  -ForegroundColor Green
Write-Host ""

# 验证数据库
Write-Host "验证数据库..." -ForegroundColor Yellow
$Arguments = @("-u", "root")
if ($MySqlPass -ne "") {
    $Arguments += "-p$MySqlPass"
}
$Arguments += "-e", "USE litemall; SHOW TABLES;"

& $MySQLBin $Arguments 2>$null | Out-Host

Write-Host ""
Write-Host "[√] 数据库配置完成！" -ForegroundColor Green
Write-Host ""
Write-Host "下一步: 启动后端服务" -ForegroundColor Cyan
Write-Host "  运行: start-backend.bat" -ForegroundColor White
Write-Host ""
Write-Host "或直接运行Java:" -ForegroundColor Cyan
Write-Host "  cd D:\Code\litemall-master" -ForegroundColor White
Write-Host "  java -jar litemall-all\target\litemall-all-0.1.0-exec.jar" -ForegroundColor White
Write-Host ""

Read-Host "按回车键退出"
