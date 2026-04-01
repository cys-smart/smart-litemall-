# Environment Variable Configuration Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Environment Variables Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check User Environment Variables
Write-Host "[User Environment Variables]" -ForegroundColor Yellow
Write-Host ""

$javaHome = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'User')
if ($javaHome) {
    Write-Host "JAVA_HOME = $javaHome" -ForegroundColor Green
} else {
    Write-Host "JAVA_HOME = (not set)" -ForegroundColor Red
    Write-Host "Setting JAVA_HOME..."
    [Environment]::SetEnvironmentVariable('JAVA_HOME', 'D:\DevTools\jdk-11', 'User')
    Write-Host "JAVA_HOME set to: D:\DevTools\jdk-11" -ForegroundColor Green
}

Write-Host ""

$mavenHome = [Environment]::GetEnvironmentVariable('MAVEN_HOME', 'User')
if ($mavenHome) {
    Write-Host "MAVEN_HOME = $mavenHome" -ForegroundColor Green
} else {
    Write-Host "MAVEN_HOME = (not set)" -ForegroundColor Red
    Write-Host "Setting MAVEN_HOME..."
    [Environment]::SetEnvironmentVariable('MAVEN_HOME', 'D:\DevTools\apache-maven-3.9.6', 'User')
    Write-Host "MAVEN_HOME set to: D:\DevTools\apache-maven-3.9.6" -ForegroundColor Green
}

Write-Host ""
Write-Host "[PATH Environment Variable]" -ForegroundColor Yellow
Write-Host ""

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$pathEntries = $userPath -split ';'

$hasJdkBin = $false
$hasMavenBin = $false

foreach ($entry in $pathEntries) {
    if ($entry -like '*jdk-11\bin*') {
        Write-Host "  Found: $entry" -ForegroundColor Green
        $hasJdkBin = $true
    }
    if ($entry -like '*apache-maven-3.9.6\bin*') {
        Write-Host "  Found: $entry" -ForegroundColor Green
        $hasMavenBin = $true
    }
}

if (-not $hasJdkBin) {
    Write-Host "Missing: D:\DevTools\jdk-11\bin" -ForegroundColor Red
    Write-Host "Adding..."
    $newPath = "D:\DevTools\jdk-11\bin;" + $userPath
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "Added JDK bin to PATH" -ForegroundColor Green
}

if (-not $hasMavenBin) {
    Write-Host "Missing: D:\DevTools\apache-maven-3.9.6\bin" -ForegroundColor Red
    Write-Host "Adding..."
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $newPath = "D:\DevTools\apache-maven-3.9.6\bin;" + $userPath
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "Added Maven bin to PATH" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Important:" -ForegroundColor Yellow
Write-Host "1. Close all command line windows" -ForegroundColor White
Write-Host "2. Open a new command line window" -ForegroundColor White
Write-Host "3. Verify with commands:" -ForegroundColor White
Write-Host "   java -version" -ForegroundColor Cyan
Write-Host "   mvn -version" -ForegroundColor Cyan
Write-Host ""
Write-Host "Then run: Start-System.bat" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
