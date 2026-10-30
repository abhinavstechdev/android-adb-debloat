param(
    [string]$Device = "10.29.145.16:44143"
)

$adb = "C:\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
    $adb = "adb"
}

# Auto-connect if wireless debugging is used
$devCheck = & $adb devices
$connected = @($devCheck | Where-Object { $_ -match "\bdevice\b" -and $_ -notmatch "List of" })
if ($connected.Count -eq 0 -and $Device) {
    Write-Host "[*] Connecting to $Device..." -ForegroundColor Cyan
    & $adb connect $Device | Out-Null
    $devCheck = & $adb devices
    $connected = @($devCheck | Where-Object { $_ -match "\bdevice\b" -and $_ -notmatch "List of" })
}

if ($connected.Count -eq 0) {
    Write-Host "Waiting for authorized ADB device..." -ForegroundColor Yellow
    & $adb wait-for-device
    $devCheck = & $adb devices
    $connected = @($devCheck | Where-Object { $_ -match "\bdevice\b" -and $_ -notmatch "List of" })
}

$targetDevice = ($connected[0] -split '\s+')[0].Trim()
Write-Host "[+] Target device identifier: $targetDevice" -ForegroundColor Green

function adb-sh {
    param([string]$cmd)
    & $adb -s $targetDevice shell $cmd
}

$model = (adb-sh "getprop ro.product.model").Trim() -replace '\s+', '-'
$brand = (adb-sh "getprop ro.product.brand").Trim() -replace '\s+', '-'
$prefix = if ($brand -and $model) { "audit-$brand-$model-" } else { "audit-device-" }

$folder = Join-Path (Get-Location) ($prefix + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $folder -Force | Out-Null
Write-Host "Creating audit in: $folder" -ForegroundColor Cyan

Write-Host "1/6 Capturing system properties (getprop)..."
adb-sh "getprop" | Out-File -Encoding utf8 (Join-Path $folder "getprop.txt")

Write-Host "2/6 Capturing all packages..."
adb-sh "pm list packages" | Out-File -Encoding utf8 (Join-Path $folder "all-packages.txt")

Write-Host "3/6 Capturing third-party packages (-3)..."
adb-sh "pm list packages -3" | Out-File -Encoding utf8 (Join-Path $folder "third-party-packages.txt")

Write-Host "4/6 Capturing disabled packages (-d)..."
adb-sh "pm list packages -d" | Out-File -Encoding utf8 (Join-Path $folder "disabled-packages.txt")

Write-Host "5/6 Capturing package paths (-f)..."
adb-sh "pm list packages -f" | Out-File -Encoding utf8 (Join-Path $folder "packages-with-paths.txt")

Write-Host "6/6 Capturing battery and memory status..."
adb-sh "dumpsys battery; dumpsys meminfo" | Out-File -Encoding utf8 (Join-Path $folder "battery-meminfo.txt")

Write-Host "Audit completed successfully!" -ForegroundColor Green
Get-ChildItem $folder | Select-Object Name, Length
