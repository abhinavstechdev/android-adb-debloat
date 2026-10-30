<#
.SYNOPSIS
    Pairs and connects an Android device over Wireless Debugging (Android 11+).
.EXAMPLE
    .\scripts\pair_device.ps1 -PairingPort 38241 -PairingCode 123456 -ConnectPort 44143
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$PairingPort,

    [Parameter(Mandatory=$true)]
    [string]$PairingCode,

    [string]$IP = "10.29.145.16",

    [string]$ConnectPort = "44143"
)

$adb = "C:\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
    $adb = "adb"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       Android Wireless Debugging Pairing Assistant       " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

Write-Host "[1/2] Pairing with $IP`:$PairingPort using code $PairingCode..." -ForegroundColor Cyan
$pairResult = & $adb pair "$IP`:$PairingPort" $PairingCode 2>&1
Write-Host ($pairResult -join "`n")

if ($LASTEXITCODE -ne 0 -or ($pairResult -match "Failed" -or $pairResult -match "error")) {
    Write-Host "[!] Pairing failed. Check that the pairing dialog is still active on your phone screen." -ForegroundColor Red
    exit 1
}

Write-Host "`n[2/2] Connecting to $IP`:$ConnectPort..." -ForegroundColor Cyan
$connectResult = & $adb connect "$IP`:$ConnectPort" 2>&1
Write-Host ($connectResult -join "`n")

Write-Host "`n[+] Current connected ADB devices:" -ForegroundColor Green
& $adb devices -l

