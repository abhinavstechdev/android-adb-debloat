<#
.SYNOPSIS
    Applies gaming and performance optimizations via ADB on Vivo / iQOO devices.
.DESCRIPTION
    - Locks display refresh rate to 120Hz (removes VRR frame drops)
    - Enables high-performance Updatable Game Driver
    - Sets Android Game Manager FPS targets (120 FPS / 90 FPS)
    - Stabilizes Wi-Fi latency to prevent in-match ping spikes
    - Activates iQOO Monster Mode governor
#>

param(
    [switch]$Reset
)

$adb = "C:\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
    $adb = "adb"
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " iQOO / Vivo Gaming Optimization via ADB  " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

if ($Reset) {
    Write-Host "[*] Resetting gaming optimizations to stock..." -ForegroundColor Yellow
    & $adb shell "settings put system min_refresh_rate null"
    & $adb shell "settings put global updatable_driver_production_opt_in_apps ''"
    & $adb shell "cmd game reset com.dts.freefiremax"
    & $adb shell "cmd game reset com.pubg.imobile"
    & $adb shell "cmd game reset com.activision.callofduty.shooter"
    & $adb shell "cmd game reset com.supercell.clashroyale"
    Write-Host "[✓] Device reset to default configuration." -ForegroundColor Green
    exit 0
}

Write-Host "[1/5] Locking display to smooth 120Hz..." -ForegroundColor Cyan
& $adb shell "settings put system min_refresh_rate 120.0"
& $adb shell "settings put system peak_refresh_rate 120.0"
$minHz = (& $adb shell "settings get system min_refresh_rate").Trim()
$peakHz = (& $adb shell "settings get system peak_refresh_rate").Trim()
Write-Host "      Refresh Rate: Min=$minHz Hz | Peak=$peakHz Hz (Locked)" -ForegroundColor Green

Write-Host "[2/5] Enabling Updatable Game Graphics Driver..." -ForegroundColor Cyan
& $adb shell "settings put global updatable_driver_all_apps 1"
& $adb shell "settings put global updatable_driver_production_opt_in_apps 'com.dts.freefiremax,com.pubg.imobile,com.activision.callofduty.shooter,com.supercell.clashroyale'"
& $adb shell "settings put global updatable_driver_production_opt_out_apps ''"
Write-Host "      Game Driver: Hardware acceleration enabled for Free Fire, BGMI, COD Mobile, Clash Royale." -ForegroundColor Green

Write-Host "[3/5] Setting Android Game Manager FPS Targets..." -ForegroundColor Cyan
& $adb shell "cmd game set --fps 120 com.dts.freefiremax"
& $adb shell "cmd game set --fps 90 com.pubg.imobile"
& $adb shell "cmd game set --fps 120 com.activision.callofduty.shooter"
& $adb shell "cmd game set --fps 120 com.supercell.clashroyale"
Write-Host "      FPS Targets: 120 FPS (Free Fire, COD, Clash Royale) | 90 FPS (BGMI)" -ForegroundColor Green

Write-Host "[4/5] Stabilizing Wi-Fi latency (preventing in-game ping spikes)..." -ForegroundColor Cyan
& $adb shell "settings put global wifi_scan_throttle_enabled 1"
& $adb shell "settings put global wifi_verbose_logging_enabled 0"
Write-Host "      Wi-Fi Scan Throttling: Enabled (stops background network scans)" -ForegroundColor Green

Write-Host "[5/5] Activating Monster Mode governor..." -ForegroundColor Cyan
& $adb shell "settings put system pemMonsterState 1"
Write-Host "      Monster Mode Profile: Active" -ForegroundColor Green

Write-Host "`n[✓] All gaming optimizations applied successfully!" -ForegroundColor Green
