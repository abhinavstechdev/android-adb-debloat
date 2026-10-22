$adb = "C:\platform-tools\adb.exe"
$folder = Join-Path (Get-Location) ("audit-iqoo-z7pro-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $folder -Force | Out-Null
Write-Host "Creating audit in: $folder" -ForegroundColor Cyan

# Wait for device
& $adb wait-for-device

Write-Host "1/6 Capturing system properties (getprop)..."
& $adb shell "getprop" | Out-File -Encoding utf8 (Join-Path $folder "getprop.txt")

Write-Host "2/6 Capturing all packages..."
& $adb shell "pm list packages" | Out-File -Encoding utf8 (Join-Path $folder "all-packages.txt")

Write-Host "3/6 Capturing third-party packages (-3)..."
& $adb shell "pm list packages -3" | Out-File -Encoding utf8 (Join-Path $folder "third-party-packages.txt")

Write-Host "4/6 Capturing disabled packages (-d)..."
& $adb shell "pm list packages -d" | Out-File -Encoding utf8 (Join-Path $folder "disabled-packages.txt")

Write-Host "5/6 Capturing package paths (-f)..."
& $adb shell "pm list packages -f" | Out-File -Encoding utf8 (Join-Path $folder "packages-with-paths.txt")

Write-Host "6/6 Capturing battery and memory status..."
& $adb shell "dumpsys battery; dumpsys meminfo" | Out-File -Encoding utf8 (Join-Path $folder "battery-meminfo.txt")

Write-Host "Audit completed successfully!" -ForegroundColor Green
Get-ChildItem $folder | Select-Object Name, Length
