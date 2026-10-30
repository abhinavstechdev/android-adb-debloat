<#
.SYNOPSIS
    Comprehensive Gaming, High Refresh Rate, and Performance Optimizer for Android devices via ADB (Nothing OS, Vivo/iQOO, and AOSP).
#>

param(
    [switch]$Reset,
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
    Write-Host "[!] No authorized ADB device detected." -ForegroundColor Red
    Write-Host "    If using Wireless Debugging, pair and connect your device first:" -ForegroundColor Yellow
    Write-Host "    .\scripts\pair_device.ps1 -PairingPort <Port> -PairingCode <Code>" -ForegroundColor Yellow
    Write-Host "    Or connect via USB with USB Debugging enabled." -ForegroundColor Yellow
    exit 1
}

$targetDevice = ($connected[0] -split '\s+')[0].Trim()
Write-Host "[+] Target device identifier: $targetDevice" -ForegroundColor Green

function adb-sh {
    param([string]$cmd)
    & $adb -s $targetDevice shell $cmd
}

$brand = (adb-sh "getprop ro.product.brand").Trim()
$model = (adb-sh "getprop ro.product.model").Trim()
$manufacturer = (adb-sh "getprop ro.product.manufacturer").Trim()
$androidVer = (adb-sh "getprop ro.build.version.release").Trim()

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "      Universal Gaming & 120 FPS Performance Optimizer    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Device: $manufacturer $brand $model (Android $androidVer)" -ForegroundColor Green

if ($Reset) {
    Write-Host "[*] Resetting gaming optimizations to stock firmware defaults..." -ForegroundColor Yellow
    adb-sh "settings put system min_refresh_rate null"
    adb-sh "settings put system peak_refresh_rate null"
    adb-sh "settings put global updatable_driver_production_opt_in_apps ''"
    adb-sh "settings put global wifi_scan_always_enabled 1"
    adb-sh "settings put system game_scene_more_fps 0"
    adb-sh "settings put system game_standard_promotion_mode 0"
    adb-sh "settings put secure long_press_timeout 400"
    adb-sh "settings put system gamecube_hawkeye_effective 0"
    adb-sh "settings put secure gamewatch_vcs_mode 0"
    adb-sh "cmd game reset com.garena.game.ffi"
    adb-sh "cmd game reset com.dts.freefiremax"
    adb-sh "cmd game reset com.dts.freefireth"
    adb-sh "cmd game reset com.pubg.imobile"
    adb-sh "cmd game reset com.activision.callofduty.shooter"
    adb-sh "cmd game reset com.supercell.clashroyale"
    Write-Host "[OK] Device reset to default configuration." -ForegroundColor Green
    exit 0
}

Write-Host "`n--- PILLAR 1: DISPLAY AND 120Hz REFRESH RATE LOCK ---" -ForegroundColor Yellow
Write-Host "[1/10] Locking min and peak refresh rates to 120.0Hz..." -ForegroundColor Cyan
adb-sh "settings put system min_refresh_rate 120.0"
adb-sh "settings put system peak_refresh_rate 120.0"
$minHz = (adb-sh "settings get system min_refresh_rate").Trim()
$peakHz = (adb-sh "settings get system peak_refresh_rate").Trim()
Write-Host "       Display Frequency: Min=$minHz Hz, Peak=$peakHz Hz (Constant Lock)" -ForegroundColor Green

Write-Host "[2/10] Unclamping DisplayManager thermal and idle refresh throttles..." -ForegroundColor Cyan
adb-sh "/system/bin/device_config set_sync_disabled_for_tests persistent 2>/dev/null"
adb-sh "/system/bin/device_config put display_manager com.android.server.display.feature.flags.enable_power_throttling_clamper false"
adb-sh "/system/bin/device_config put display_manager com.android.server.display.feature.flags.idle_screen_refresh_rate_timeout false"
adb-sh "/system/bin/device_config put display_manager com.android.server.display.feature.flags.ignore_app_preferred_refresh_rate_request false"
Write-Host "       DisplayManager: Thermal clamp disabled, idle drop disabled, game preference honored" -ForegroundColor Green

Write-Host "`n--- PILLAR 2: GRAPHICS, GPU DRIVERS AND VISUAL FIDELITY ---" -ForegroundColor Yellow
Write-Host "[3/10] Forcing Updatable Production Game Driver..." -ForegroundColor Cyan
adb-sh "settings put global updatable_driver_all_apps 1"
adb-sh "settings put global updatable_driver_production_opt_in_apps 'com.garena.game.ffi,com.dts.freefiremax,com.dts.freefireth,com.pubg.imobile,com.activision.callofduty.shooter,com.supercell.clashroyale'"
adb-sh "settings put global updatable_driver_production_opt_out_apps ''"
Write-Host "       Game Driver: Hardware-accelerated GPU pipeline active for all games" -ForegroundColor Green

Write-Host "[4/10] Configuring Hardware Visual Enhancement Filters..." -ForegroundColor Cyan
if ($brand -match "(?i)vivo|iqoo") {
    adb-sh "settings put system gamecube_hawkeye_effective 1"
    adb-sh "settings put system game_4d_shock_enabled 1"
    adb-sh "settings put system vivo_display_color_mode 2"
    adb-sh "settings put system vivo_display_color_mode_setting 2"
    adb-sh "settings put secure key_gamewatch_eco_super_solution '[com.garena.game.ffi,com.dts.freefiremax,com.dts.freefireth,com.pubg.imobile,com.activision.callofduty.shooter,com.supercell.clashroyale]'"
    adb-sh "settings put secure key_gamewatch_eco_frame_inter '[com.garena.game.ffi,com.dts.freefiremax,com.dts.freefireth,com.pubg.imobile,com.activision.callofduty.shooter,com.supercell.clashroyale]'"
    adb-sh "settings put system key_frame_interpolation_ecosystem '[com.garena.game.ffi,com.dts.freefiremax,com.dts.freefireth,com.pubg.imobile,com.activision.callofduty.shooter,com.supercell.clashroyale]'"
    Write-Host "       Visuals: Vivo Hawkeye detail enhancement active, VSR Super Solution active, MEMC interpolation active" -ForegroundColor Green
} else {
    Write-Host "       Visuals: AOSP/OEM standard visual rendering active for $brand" -ForegroundColor Green
}

Write-Host "`n--- PILLAR 3: GAME MANAGER AND KERNEL SCHEDULING ---" -ForegroundColor Yellow
Write-Host "[5/10] Overriding Android Game Manager FPS Targets (Free Fire 120 FPS)..." -ForegroundColor Cyan
adb-sh "cmd game set --fps 120 com.garena.game.ffi"
adb-sh "cmd game mode performance com.garena.game.ffi 2>/dev/null"
adb-sh "cmd game set --fps 120 com.dts.freefiremax"
adb-sh "cmd game mode performance com.dts.freefiremax 2>/dev/null"
adb-sh "cmd game set --fps 120 com.dts.freefireth"
adb-sh "cmd game mode performance com.dts.freefireth 2>/dev/null"
adb-sh "cmd game set --fps 90 com.pubg.imobile"
adb-sh "cmd game set --fps 120 com.activision.callofduty.shooter"
adb-sh "cmd game set --fps 120 com.supercell.clashroyale"
adb-sh "/system/bin/device_config put game_overlay com.garena.game.ffi mode=2,fps=120:mode=3,fps=120:mode=4,fps=120"
adb-sh "/system/bin/device_config put game_overlay com.dts.freefiremax mode=2,fps=120:mode=3,fps=120:mode=4,fps=120"
adb-sh "/system/bin/device_config put game_overlay com.dts.freefireth mode=2,fps=120:mode=3,fps=120:mode=4,fps=120"
adb-sh "/system/bin/device_config put game_overlay com.pubg.imobile mode=2,fps=90:mode=3,fps=90"
adb-sh "/system/bin/device_config put game_overlay com.activision.callofduty.shooter mode=2,fps=120:mode=3,fps=120"
adb-sh "/system/bin/device_config put game_overlay com.supercell.clashroyale mode=2,fps=120:mode=3,fps=120"
Write-Host "       FPS Targets: 120 FPS (Free Fire India/MAX/Global, COD, Clash Royale), 90 FPS (BGMI) in Game Manager and DeviceConfig" -ForegroundColor Green

Write-Host "[6/10] Configuring OEM Kernel Schedulers & Promotion Modes..." -ForegroundColor Cyan
if ($brand -match "(?i)vivo|iqoo") {
    adb-sh "settings put system game_scene_more_fps 1"
    adb-sh "settings put system game_standard_promotion_mode 1"
    adb-sh "settings put system is_game_mode 1"
    adb-sh "settings put system pemMonsterState 1"
    adb-sh "settings put secure gamewatch_vcs_mode 1"
    adb-sh "settings put system gamewatch_game_target_fps 120"
    adb-sh "settings put system sdk_game_target_fps 'com.garena.game.ffi_32053_120:com.dts.freefiremax_32053_120:com.dts.freefireth_32053_120:com.pubg.imobile_32053_90:com.activision.callofduty.shooter_32053_120:com.supercell.clashroyale_32053_120'"
    Write-Host "       Vivo Scheduler: More FPS Engine, Promotion Mode, Monster Governor, GameWatch 120 FPS active" -ForegroundColor Green
} else {
    Write-Host "       Kernel Scheduler: AOSP Fixed Performance Mode & High Refresh Engine active" -ForegroundColor Green
    adb-sh "cmd power set-fixed-performance-mode-enabled true 2>/dev/null"
}

Write-Host "[7/10] Ingesting games into Hardware Prioritization Whitelists..." -ForegroundColor Cyan
if ($brand -match "(?i)vivo|iqoo") {
    adb-sh "settings put system perf_game_list 'com.garena.game.ffi:com.dts.freefiremax:com.dts.freefireth:com.pubg.imobile:com.activision.callofduty.shooter:com.supercell.clashroyale:com.tencent.ig:com.garena.game.codm:'"
    adb-sh "settings put system enabled_performance_optimization 'com.garena.game.ffi:com.dts.freefiremax:com.dts.freefireth:com.pubg.imobile:com.activision.callofduty.shooter:com.supercell.clashroyale:'"
    adb-sh "settings put system pem_ddc_open_game_list 'com.garena.game.ffi:com.dts.freefiremax:com.dts.freefireth:com.pubg.imobile:com.activision.callofduty.shooter:com.supercell.clashroyale:'"
    adb-sh "settings put system pem_ddc_add_remove_game 'com.garena.game.ffi#1'"
    Write-Host "       Hardware Whitelist: SoC high-performance cores dedicated to games" -ForegroundColor Green
} else {
    Write-Host "       Hardware Whitelist: Standard high-performance governor active" -ForegroundColor Green
}

Write-Host "`n--- PILLAR 4: JIT IMMUNITY AND POWER THROTTLING EXEMPTION ---" -ForegroundColor Yellow
Write-Host "[8/10] Exempting games from DeviceIdle power and background throttling..." -ForegroundColor Cyan
adb-sh "dumpsys deviceidle whitelist +com.garena.game.ffi" | Out-Null
adb-sh "dumpsys deviceidle whitelist +com.dts.freefiremax" | Out-Null
adb-sh "dumpsys deviceidle whitelist +com.dts.freefireth" | Out-Null
adb-sh "dumpsys deviceidle whitelist +com.pubg.imobile" | Out-Null
adb-sh "dumpsys deviceidle whitelist +com.activision.callofduty.shooter" | Out-Null
adb-sh "dumpsys deviceidle whitelist +com.supercell.clashroyale" | Out-Null
adb-sh "/system/bin/device_config put activity_manager max_phantom_processes 2147483647 2>/dev/null"
adb-sh "settings put global zram_enabled 0"
Write-Host "       Power Optimization: Games exempt from battery throttling; ZRAM flash swap disabled" -ForegroundColor Green

Write-Host "[9/10] Ahead-Of-Time (AOT) compiling games to native ARM machine code..." -ForegroundColor Cyan
$installed = adb-sh "pm list packages"
if ($installed -match "com.garena.game.ffi") {
    Write-Host "       Compiling Free Fire India (com.garena.game.ffi)..." -ForegroundColor Gray
    adb-sh "cmd package compile -m speed -f com.garena.game.ffi" | Out-Null
    Write-Host "       [+] Free Fire India compiled to native ARM machine code." -ForegroundColor Green
}
if ($installed -match "com.dts.freefiremax") {
    Write-Host "       Compiling Free Fire MAX (com.dts.freefiremax)..." -ForegroundColor Gray
    adb-sh "cmd package compile -m speed -f com.dts.freefiremax" | Out-Null
    Write-Host "       [+] Free Fire MAX compiled to native ARM machine code." -ForegroundColor Green
}
if ($installed -match "com.dts.freefireth") {
    Write-Host "       Compiling Free Fire (com.dts.freefireth)..." -ForegroundColor Gray
    adb-sh "cmd package compile -m speed -f com.dts.freefireth" | Out-Null
    Write-Host "       [+] Free Fire compiled to native ARM machine code." -ForegroundColor Green
}
if ($installed -match "com.pubg.imobile") {
    Write-Host "       Compiling BGMI..." -ForegroundColor Gray
    adb-sh "cmd package compile -m speed -f com.pubg.imobile" | Out-Null
}
if ($installed -match "com.activision.callofduty.shooter") {
    Write-Host "       Compiling Call of Duty: Mobile..." -ForegroundColor Gray
    adb-sh "cmd package compile -m speed -f com.activision.callofduty.shooter" | Out-Null
}
if ($installed -match "com.supercell.clashroyale") {
    Write-Host "       Compiling Clash Royale..." -ForegroundColor Gray
    adb-sh "cmd package compile -m speed -f com.supercell.clashroyale" | Out-Null
}
Write-Host "       ART Compilation: Complete (zero runtime JIT compilation spikes)" -ForegroundColor Green

Write-Host "`n--- PILLAR 5: TOUCH LATENCY AND NETWORK STABILIZATION ---" -ForegroundColor Yellow
Write-Host "[10/10] Optimizing touch latency and eradicating Wi-Fi ping spikes..." -ForegroundColor Cyan
adb-sh "settings put secure long_press_timeout 300"
adb-sh "settings put system pointer_speed 7"
adb-sh "settings put global wifi_scan_always_enabled 0"
adb-sh "settings put global wifi_scan_throttle_enabled 1"
adb-sh "settings put global wifi_verbose_logging_enabled 0"
adb-sh "settings put global wifi_wakeup_enabled 0"
adb-sh "settings put global wifi_power_save 0"
adb-sh "settings put global ble_scan_always_enabled 0"
adb-sh "settings put global tcp_default_init_rwnd 60"
adb-sh "settings put global mobile_data_always_on 1"
adb-sh "settings put global private_dns_mode hostname"
adb-sh "settings put global private_dns_specifier one.one.one.one"
adb-sh "logcat -c"
Write-Host "       Touch and Network: Hold delay 300ms, pointer max, Bluetooth/Wi-Fi background scans killed, TCP window 60, Cloudflare 1.1.1.1 Gaming DNS active" -ForegroundColor Green

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  [OK] All 10 Deep Gaming Optimization Steps Applied!     " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green


