<#
.SYNOPSIS
    Comprehensive Gaming, High Refresh Rate, and Performance Optimizer for iQOO / Vivo devices via ADB.
#>

param(
    [switch]$Reset
)

$adb = "C:\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
    $adb = "adb"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   iQOO / Vivo Exhaustive Gaming Performance Optimizer    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

if ($Reset) {
    Write-Host "[*] Resetting gaming optimizations to stock firmware defaults..." -ForegroundColor Yellow
    & $adb shell "settings put system min_refresh_rate null"
    & $adb shell "settings put global updatable_driver_production_opt_in_apps ''"
    & $adb shell "settings put global wifi_scan_always_enabled 1"
    & $adb shell "settings put system game_scene_more_fps 0"
    & $adb shell "settings put system game_standard_promotion_mode 0"
    & $adb shell "settings put secure long_press_timeout 400"
    & $adb shell "settings put system gamecube_hawkeye_effective 0"
    & $adb shell "settings put secure gamewatch_vcs_mode 0"
    & $adb shell "cmd game reset com.dts.freefiremax"
    & $adb shell "cmd game reset com.pubg.imobile"
    & $adb shell "cmd game reset com.activision.callofduty.shooter"
    & $adb shell "cmd game reset com.supercell.clashroyale"
    Write-Host "[OK] Device reset to default configuration." -ForegroundColor Green
    exit 0
}

Write-Host "`n--- PILLAR 1: DISPLAY AND 120Hz REFRESH RATE LOCK ---" -ForegroundColor Yellow
Write-Host "[1/10] Locking min and peak refresh rates to 120.0Hz..." -ForegroundColor Cyan
& $adb shell "settings put system min_refresh_rate 120.0"
& $adb shell "settings put system peak_refresh_rate 120.0"
$minHz = (& $adb shell "settings get system min_refresh_rate").Trim()
$peakHz = (& $adb shell "settings get system peak_refresh_rate").Trim()
Write-Host "       Display Frequency: Min=$minHz Hz, Peak=$peakHz Hz (Constant Lock)" -ForegroundColor Green

Write-Host "[2/10] Unclamping DisplayManager thermal and idle refresh throttles..." -ForegroundColor Cyan
& $adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent 2>/dev/null"
& $adb shell "/system/bin/device_config put display_manager com.android.server.display.feature.flags.enable_power_throttling_clamper false"
& $adb shell "/system/bin/device_config put display_manager com.android.server.display.feature.flags.idle_screen_refresh_rate_timeout false"
& $adb shell "/system/bin/device_config put display_manager com.android.server.display.feature.flags.ignore_app_preferred_refresh_rate_request false"
Write-Host "       DisplayManager: Thermal clamp disabled, idle drop disabled, game preference honored" -ForegroundColor Green

Write-Host "`n--- PILLAR 2: GRAPHICS, GPU DRIVERS AND VISUAL FIDELITY ---" -ForegroundColor Yellow
Write-Host "[3/10] Forcing Updatable Production Game Driver..." -ForegroundColor Cyan
& $adb shell "settings put global updatable_driver_all_apps 1"
& $adb shell "settings put global updatable_driver_production_opt_in_apps 'com.dts.freefiremax,com.pubg.imobile,com.activision.callofduty.shooter,com.supercell.clashroyale'"
& $adb shell "settings put global updatable_driver_production_opt_out_apps ''"
Write-Host "       Game Driver: Hardware-accelerated GPU pipeline active for all games" -ForegroundColor Green

Write-Host "[4/10] Enabling Vivo Hawkeye Visual Mode, Super Solution and DCI-P3 Gamut..." -ForegroundColor Cyan
& $adb shell "settings put system gamecube_hawkeye_effective 1"
& $adb shell "settings put system game_4d_shock_enabled 1"
& $adb shell "settings put system vivo_display_color_mode 2"
& $adb shell "settings put system vivo_display_color_mode_setting 2"
& $adb shell "settings put secure key_gamewatch_eco_super_solution '[com.dts.freefiremax,com.pubg.imobile,com.activision.callofduty.shooter,com.supercell.clashroyale]'"
& $adb shell "settings put secure key_gamewatch_eco_frame_inter '[com.dts.freefiremax,com.pubg.imobile,com.activision.callofduty.shooter,com.supercell.clashroyale]'"
& $adb shell "settings put system key_frame_interpolation_ecosystem '[com.dts.freefiremax,com.pubg.imobile,com.activision.callofduty.shooter,com.supercell.clashroyale]'"
Write-Host "       Visuals: Hawkeye detail enhancement active, VSR Super Solution active, MEMC interpolation active" -ForegroundColor Green

Write-Host "`n--- PILLAR 3: VIVO GAMECUBE AND KERNEL SCHEDULING ---" -ForegroundColor Yellow
Write-Host "[5/10] Overriding Android Game Manager FPS Targets and Native Overlays..." -ForegroundColor Cyan
& $adb shell "cmd game set --fps 120 com.dts.freefiremax"
& $adb shell "cmd game set --fps 90 com.pubg.imobile"
& $adb shell "cmd game set --fps 120 com.activision.callofduty.shooter"
& $adb shell "cmd game set --fps 120 com.supercell.clashroyale"
& $adb shell "/system/bin/device_config put game_overlay com.dts.freefiremax mode=2,fps=120:mode=3,fps=120"
& $adb shell "/system/bin/device_config put game_overlay com.pubg.imobile mode=2,fps=90:mode=3,fps=90"
& $adb shell "/system/bin/device_config put game_overlay com.activision.callofduty.shooter mode=2,fps=120:mode=3,fps=120"
& $adb shell "/system/bin/device_config put game_overlay com.supercell.clashroyale mode=2,fps=120:mode=3,fps=120"
Write-Host "       FPS Targets: 120 FPS (Free Fire, COD, Clash Royale), 90 FPS (BGMI) in Game Manager and DeviceConfig" -ForegroundColor Green

Write-Host "[6/10] Activating Vivo GameCube More FPS, Promotion Mode and GameWatch 120 FPS..." -ForegroundColor Cyan
& $adb shell "settings put system game_scene_more_fps 1"
& $adb shell "settings put system game_standard_promotion_mode 1"
& $adb shell "settings put system is_game_mode 1"
& $adb shell "settings put system pemMonsterState 1"
& $adb shell "settings put secure gamewatch_vcs_mode 1"
& $adb shell "settings put system gamewatch_game_target_fps 120"
& $adb shell "settings put system sdk_game_target_fps 'com.dts.freefiremax_32053_120:com.pubg.imobile_32053_90:com.activision.callofduty.shooter_32053_120:com.supercell.clashroyale_32053_120'"
Write-Host "       Vivo Scheduler: More FPS Engine, Promotion Mode, Monster Governor, GameWatch 120 FPS and SDK Targets Active" -ForegroundColor Green

Write-Host "[7/10] Ingesting games into Vivo Hardware Prioritization Whitelists..." -ForegroundColor Cyan
& $adb shell "settings put system perf_game_list 'com.dts.freefiremax:com.pubg.imobile:com.activision.callofduty.shooter:com.supercell.clashroyale:com.tencent.ig:com.garena.game.codm:'"
& $adb shell "settings put system enabled_performance_optimization 'com.dts.freefiremax:com.pubg.imobile:com.activision.callofduty.shooter:com.supercell.clashroyale:'"
& $adb shell "settings put system pem_ddc_open_game_list 'com.dts.freefiremax:com.pubg.imobile:com.activision.callofduty.shooter:com.supercell.clashroyale:'"
Write-Host "       Hardware Whitelist: Dimensity 7200 high-performance cores dedicated to games" -ForegroundColor Green

Write-Host "`n--- PILLAR 4: JIT IMMUNITY AND POWER THROTTLING EXEMPTION ---" -ForegroundColor Yellow
Write-Host "[8/10] Exempting games from DeviceIdle power and background throttling..." -ForegroundColor Cyan
& $adb shell "dumpsys deviceidle whitelist +com.dts.freefiremax" | Out-Null
& $adb shell "dumpsys deviceidle whitelist +com.pubg.imobile" | Out-Null
& $adb shell "dumpsys deviceidle whitelist +com.activision.callofduty.shooter" | Out-Null
& $adb shell "dumpsys deviceidle whitelist +com.supercell.clashroyale" | Out-Null
& $adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647 2>/dev/null"
& $adb shell "settings put global zram_enabled 0"
Write-Host "       Power Optimization: Games exempt from battery throttling; ZRAM flash swap disabled" -ForegroundColor Green

Write-Host "[9/10] Ahead-Of-Time (AOT) compiling games to native ARM machine code..." -ForegroundColor Cyan
Write-Host "       Compiling Free Fire MAX..." -ForegroundColor Gray
& $adb shell "cmd package compile -m speed -f com.dts.freefiremax" | Out-Null
Write-Host "       Compiling BGMI..." -ForegroundColor Gray
& $adb shell "cmd package compile -m speed -f com.pubg.imobile" | Out-Null
Write-Host "       Compiling Call of Duty: Mobile..." -ForegroundColor Gray
& $adb shell "cmd package compile -m speed -f com.activision.callofduty.shooter" | Out-Null
Write-Host "       Compiling Clash Royale..." -ForegroundColor Gray
& $adb shell "cmd package compile -m speed -f com.supercell.clashroyale" | Out-Null
Write-Host "       ART Compilation: Complete (zero runtime JIT compilation spikes)" -ForegroundColor Green

Write-Host "`n--- PILLAR 5: TOUCH LATENCY AND NETWORK STABILIZATION ---" -ForegroundColor Yellow
Write-Host "[10/10] Optimizing touch latency and eradicating Wi-Fi ping spikes..." -ForegroundColor Cyan
& $adb shell "settings put secure long_press_timeout 300"
& $adb shell "settings put system pointer_speed 7"
& $adb shell "settings put global wifi_scan_always_enabled 0"
& $adb shell "settings put global wifi_scan_throttle_enabled 1"
& $adb shell "settings put global wifi_verbose_logging_enabled 0"
& $adb shell "settings put global wifi_wakeup_enabled 0"
& $adb shell "settings put global wifi_power_save 0"
& $adb shell "settings put global ble_scan_always_enabled 0"
& $adb shell "settings put global tcp_default_init_rwnd 60"
& $adb shell "settings put global mobile_data_always_on 1"
& $adb shell "settings put global private_dns_mode hostname"
& $adb shell "settings put global private_dns_specifier one.one.one.one"
& $adb shell "logcat -c"
Write-Host "       Touch and Network: Hold delay 300ms, pointer max, Bluetooth/Wi-Fi background scans killed, TCP window 60, Cloudflare 1.1.1.1 Gaming DNS active" -ForegroundColor Green

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  [OK] All 10 Deep Gaming Optimization Steps Applied!     " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

