# 检查和配置环境变量脚本
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "环境变量配置检查" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查用户环境变量
Write-Host "【用户环境变量】" -ForegroundColor Yellow
Write-Host ""

$javaHome = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'User')
if ($javaHome) {
    Write-Host "JAVA_HOME = $javaHome" -ForegroundColor Green
} else {
    Write-Host "JAVA_HOME = (未设置)" -ForegroundColor Red
    Write-Host "正在设置 JAVA_HOME..."
    [Environment]::SetEnvironmentVariable('JAVA_HOME', 'D:\DevTools\jdk-11', 'User')
    Write-Host "JAVA_HOME 已设置为: D:\DevTools\jdk-11" -ForegroundColor Green
}

Write-Host ""

$mavenHome = [Environment]::GetEnvironmentVariable('MAVEN_HOME', 'User')
if ($mavenHome) {
    Write-Host "MAVEN_HOME = $mavenHome" -ForegroundColor Green
} else {
    Write-Host "MAVEN_HOME = (未设置)" -ForegroundColor Red
    Write-Host "正在设置 MAVEN_HOME..."
    [Environment]::SetEnvironmentVariable('MAVEN_HOME', 'D:\DevTools\apache-maven-3.9.6', 'User')
    Write-Host "MAVEN_HOME 已设置为: D:\DevTools\apache-maven-3.9.6" -ForegroundColor Green
}

Write-Host ""
Write-Host "【PATH环境变量】" -ForegroundColor Yellow
Write-Host ""

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$pathEntries = $userPath -split ';'

$hasJdkBin = $false
$hasMavenBin = $false

foreach ($entry in $pathEntries) {
    if ($entry -like '*jdk-11\bin*') {
        Write-Host "  - $entry" -ForegroundColor Green
        $hasJdkBin = $true
    }
    if ($entry -like '*apache-maven-3.9.6\bin*') {
        Write-Host "  - $entry" -ForegroundColor Green
        $hasMavenBin = $true
    }
}

if (-not $hasJdkBin) {
    Write-Host "缺少: D:\DevTools\jdk-11\bin" -ForegroundColor Red
    Write-Host "正在添加..."
    $newPath = "D:\DevTools\jdk-11\bin;" + $userPath
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "已添加 JDK bin 到 PATH" -ForegroundColor Green
}

if (-not $hasMavenBin) {
    Write-Host "缺少: D:\DevTools\apache-maven-3.9.6\bin" -ForegroundColor Red
    Write-Host "正在添加..."
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $newPath = "D:\DevTools\apache-maven-3.9.6\bin;" + $userPath
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "已添加 Maven bin 到 PATH" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "配置完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "重要提示:" -ForegroundColor Yellow
Write-Host "1. 请关闭当前所有命令行窗口" -ForegroundColor White
Write-Host "2. 重新打开命令行窗口" -ForegroundColor White
Write-Host "3. 运行以下命令验证:" -ForegroundColor White
Write-Host "   java -version" -ForegroundColor Cyan
Write-Host "   mvn -version" -ForegroundColor Cyan
Write-Host ""
Write-Host "然后可以运行: 启动系统.bat" -ForegroundColor Green
Write-Host ""
Read-Host "按回车键退出"
