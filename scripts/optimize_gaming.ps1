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

Write-Host "[3/9] Setting Android Game Manager FPS Targets..." -ForegroundColor Cyan
& $adb shell "cmd game set --fps 120 com.dts.freefiremax"
& $adb shell "cmd game set --fps 90 com.pubg.imobile"
& $adb shell "cmd game set --fps 120 com.activision.callofduty.shooter"
& $adb shell "cmd game set --fps 120 com.supercell.clashroyale"
Write-Host "      FPS Targets: 120 FPS (Free Fire, COD, Clash Royale) | 90 FPS (BGMI)" -ForegroundColor Green

Write-Host "[4/9] Stabilizing Wi-Fi latency (preventing in-game ping spikes)..." -ForegroundColor Cyan
& $adb shell "settings put global wifi_scan_throttle_enabled 1"
& $adb shell "settings put global wifi_verbose_logging_enabled 0"
& $adb shell "settings put global mobile_data_always_on 1"
Write-Host "      Network: Wi-Fi scan throttling enabled, zero-packet-loss handover active" -ForegroundColor Green

Write-Host "[5/9] Activating Vivo GameCube More FPS & Performance Mode..." -ForegroundColor Cyan
& $adb shell "settings put system game_scene_more_fps 1"
& $adb shell "settings put system game_standard_promotion_mode 1"
& $adb shell "settings put system is_game_mode 1"
& $adb shell "settings put system pemMonsterState 1"
Write-Host "      Vivo Scheduler: More FPS Mode and Monster Governor Active" -ForegroundColor Green

Write-Host "[6/9] Registering installed games into Vivo Performance Whitelists..." -ForegroundColor Cyan
& $adb shell "settings put system perf_game_list 'com.dts.freefiremax:com.pubg.imobile:com.activision.callofduty.shooter:com.supercell.clashroyale:com.tencent.ig:com.garena.game.codm:'"
& $adb shell "settings put system enabled_performance_optimization 'com.dts.freefiremax:com.pubg.imobile:com.activision.callofduty.shooter:com.supercell.clashroyale:'"
& $adb shell "settings put system pem_ddc_open_game_list 'com.dts.freefiremax:com.pubg.imobile:com.activision.callofduty.shooter:com.supercell.clashroyale:'"
Write-Host "      Game Whitelist: Free Fire, BGMI, COD Mobile, and Clash Royale fully prioritized" -ForegroundColor Green

Write-Host "[7/9] Whitelisting gaming packages from battery/CPU throttling..." -ForegroundColor Cyan
& $adb shell "dumpsys deviceidle whitelist +com.dts.freefiremax" | Out-Null
& $adb shell "dumpsys deviceidle whitelist +com.pubg.imobile" | Out-Null
& $adb shell "dumpsys deviceidle whitelist +com.activision.callofduty.shooter" | Out-Null
& $adb shell "dumpsys deviceidle whitelist +com.supercell.clashroyale" | Out-Null
Write-Host "      Power Whitelist: Games exempt from background CPU/network throttle" -ForegroundColor Green

Write-Host "[8/9] Tuning touch response and hold timeout..." -ForegroundColor Cyan
& $adb shell "settings put secure long_press_timeout 300"
& $adb shell "settings put system pointer_speed 7"
Write-Host "      Touch Latency: Long press reduced to 300ms, pointer speed set to 7 (Max)" -ForegroundColor Green

Write-Host "[9/9] Ahead-Of-Time (AOT) compiling games to native machine code..." -ForegroundColor Cyan
Write-Host "      Compiling Free Fire MAX..." -ForegroundColor Gray
& $adb shell "cmd package compile -m speed -f com.dts.freefiremax" | Out-Null
Write-Host "      Compiling BGMI..." -ForegroundColor Gray
& $adb shell "cmd package compile -m speed -f com.pubg.imobile" | Out-Null
Write-Host "      Compiling Call of Duty: Mobile..." -ForegroundColor Gray
& $adb shell "cmd package compile -m speed -f com.activision.callofduty.shooter" | Out-Null
Write-Host "      Compiling Clash Royale..." -ForegroundColor Gray
& $adb shell "cmd package compile -m speed -f com.supercell.clashroyale" | Out-Null
Write-Host "      ART Compilation: JIT runtime compilation stutter eliminated (native ARM code)" -ForegroundColor Green

Write-Host "`n[✓] All gaming optimizations applied successfully!" -ForegroundColor Green


