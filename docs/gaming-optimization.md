# Comprehensive Gaming Performance & Refresh Rate Optimization Guide (iQOO / Vivo)

> **Target Device:** iQOO Z7 Pro 5G (`I2301`)  
> **SoC:** MediaTek Dimensity 7200 (4nm, Mali-G610 MC4)  
> **Display:** 6.78-inch 120Hz FHD+ AMOLED (2400 x 1080)  
> **Firmware:** Funtouch OS 15 (`PD2285CF_EX_A_15.2.21.3.W30`, Android 15)  
> **Optimization Scope:** High Refresh Rate, GPU Rendering, Frame Pacing, Touch Response, Latency, & Visual Fidelity

---

## Executive Summary

Default Android and OEM firmware configurations prioritize battery preservation and thermal conservatism, introducing variable refresh rate downshifting (VRR drops to 60Hz/30Hz), background Wi-Fi channel scans (200–500ms ping spikes), runtime JIT compilation overhead, and aggressive power-saving idle throttling.

Through deep forensic examination of Android 15 namespaces (`settings system`, `secure`, `global`, and `device_config`), this guide outlines **10 Deep Architectural Optimizations** organized across **5 Performance Pillars**.

---

## The 5 Pillars of Gaming Performance

```
+-----------------------------------------------------------------------------------+
|                           5 PILLARS OF GAMING OPTIMIZATION                        |
+-----------------------------------------------------------------------------------+
| 1. DISPLAY & REFRESH RATE  --> 120Hz Constant Lock & DisplayManager Unclamp       |
| 2. GRAPHICS & GPU DRIVER   --> Production Game Driver & Vivo Hawkeye Visual Mode  |
| 3. KERNEL & VIVO GAMECUBE  --> More FPS Engine, Promotion Mode & Monster Governor|
| 4. JIT IMMUNITY & POWER    --> Ahead-Of-Time (AOT) Machine Code & Idle Whitelist  |
| 5. TOUCH & LOW-LATENCY NET --> 300ms Hold Timeout & Background Wi-Fi Scan Killer  |
+-----------------------------------------------------------------------------------+
```

---

## Pillar 1: Display & 120Hz High Refresh Rate Lock

### 1. Constant 120.0Hz Refresh Rate Lock
* **The Problem:** Funtouch OS employs dynamic Variable Refresh Rate (VRR) by default. Whenever touch input stops for 1–2 seconds (e.g. while scoping, waiting in ambush, or watching a cutscene), the display drops to 60Hz or 30Hz. When the player touches the screen again, ramping back to 120Hz takes several frames, resulting in perceptible judder and missed inputs.
* **The Tweak:** Force both `min_refresh_rate` and `peak_refresh_rate` to **120.0 Hz**.
```bat
adb shell settings put system min_refresh_rate 120.0
adb shell settings put system peak_refresh_rate 120.0
```

### 2. DisplayManager Thermal Clamper & Idle Timeout Unclamping
* **The Problem:** Android 15's internal `display_manager` service contains flags that deliberately override user display preferences:
  1. `enable_power_throttling_clamper = true`: Forces the panel down to 60Hz when device temperature rises slightly.
  2. `idle_screen_refresh_rate_timeout = true`: Drops refresh rate on idle frames.
  3. `ignore_app_preferred_refresh_rate_request = true`: Prevents game engines from requesting high refresh rate buffers.
* **The Tweak:** Unclamp `display_manager` via Android's internal `device_config`:
```bat
adb shell /system/bin/device_config set_sync_disabled_for_tests persistent
adb shell /system/bin/device_config put display_manager com.android.server.display.feature.flags.enable_power_throttling_clamper false
adb shell /system/bin/device_config put display_manager com.android.server.display.feature.flags.idle_screen_refresh_rate_timeout false
adb shell /system/bin/device_config put display_manager com.android.server.display.feature.flags.ignore_app_preferred_refresh_rate_request false
```

---

## Pillar 2: Graphics, GPU Drivers & Visual Fidelity

### 3. Production Game Driver Hardware Routing
* **The Problem:** By default on Funtouch OS, titles like *Free Fire MAX* and *Call of Duty* were placed in the system driver's opt-out list (`updatable_driver_production_opt_out_apps`), forcing generic software rendering paths instead of direct hardware acceleration on the Mali-G610 GPU.
* **The Tweak:** Clear the opt-out list, enable the updatable driver globally, and explicitly opt-in target games:
```bat
adb shell settings put global updatable_driver_all_apps 1
adb shell settings put global updatable_driver_production_opt_in_apps 'com.dts.freefiremax,com.pubg.imobile,com.activision.callofduty.shooter,com.supercell.clashroyale'
adb shell settings put global updatable_driver_production_opt_out_apps ''
```

### 4. Vivo Hawkeye Visual Mode & DCI-P3 Color Gamut
* **The Problem:** Stock display modes can exhibit muted contrasts in dark scenes, making opponents difficult to spot in shadows or foliage (especially in *BGMI* and *Free Fire*).
* **The Tweak:** Activate Vivo GameCube's internal Hawkeye image enhancement filter and set display color tuning to Mode 2 (Vivid / DCI-P3 wide gamut):
```bat
adb shell settings put system gamecube_hawkeye_effective 1
adb shell settings put system game_4d_shock_enabled 1
adb shell settings put system vivo_display_color_mode 2
adb shell settings put system vivo_display_color_mode_setting 2
```

---

## Pillar 3: Vivo GameCube & Kernel Scheduling

### 5. Native Android Game Manager FPS Overrides
* **The Problem:** Games without explicit Android 15 intervention flags fall back to the standard 60 FPS profile.
* **The Tweak:** Override the Game Manager target framerate using Android's native intervention engine (`cmd game`):
```bat
adb shell cmd game set --fps 120 com.dts.freefiremax
adb shell cmd game set --fps 90 com.pubg.imobile
adb shell cmd game set --fps 120 com.activision.callofduty.shooter
adb shell cmd game set --fps 120 com.supercell.clashroyale
```

### 6. Vivo GameCube "More FPS" Engine & Standard Promotion Mode
* **The Problem:** Funtouch OS contains internal scene acceleration flags (`game_scene_more_fps` and `game_standard_promotion_mode`) that are disabled (`0`) on stock firmware.
* **The Tweak:** Enable Vivo's in-engine framerate booster, promotion governor, and GameWatch VCS (Vivo Cooling System / Frame Rate Stabilization):
```bat
adb shell settings put system game_scene_more_fps 1
adb shell settings put system game_standard_promotion_mode 1
adb shell settings put system is_game_mode 1
adb shell settings put system pemMonsterState 1
adb shell settings put secure gamewatch_vcs_mode 1
```

### 7. Vivo Hardware Scheduler Game Whitelists
* **The Problem:** The MediaTek Dimensity 7200 CPU scheduler dynamically allocates big Cortex-A715 performance cores based on OEM whitelists (`perf_game_list`, `enabled_performance_optimization`, and `pem_ddc_open_game_list`). Several popular games were missing from these lists.
* **The Tweak:** Register all user games into Vivo's performance lists:
```bat
adb shell settings put system perf_game_list 'com.dts.freefiremax:com.pubg.imobile:com.activision.callofduty.shooter:com.supercell.clashroyale:com.tencent.ig:com.garena.game.codm:'
adb shell settings put system enabled_performance_optimization 'com.dts.freefiremax:com.pubg.imobile:com.activision.callofduty.shooter:com.supercell.clashroyale:'
adb shell settings put system pem_ddc_open_game_list 'com.dts.freefiremax:com.pubg.imobile:com.activision.callofduty.shooter:com.supercell.clashroyale:'
```

---

## Pillar 4: Runtime JIT Stutter Immunity & Power Standby Whitelisting

### 8. Power & CPU Standby Exemption (`dumpsys deviceidle whitelist`)
* **The Problem:** Android's Doze / DeviceIdle manager treats apps running continuously for extended sessions as battery drains, eventually throttling CPU affinity and delaying network sockets.
* **The Tweak:** Whitelist games from battery/CPU throttling and unconstrain the Android 15 Phantom Process Killer so companion voice apps (Discord) never get terminated:
```bat
adb shell dumpsys deviceidle whitelist +com.dts.freefiremax
adb shell dumpsys deviceidle whitelist +com.pubg.imobile
adb shell dumpsys deviceidle whitelist +com.activision.callofduty.shooter
adb shell dumpsys deviceidle whitelist +com.supercell.clashroyale
adb shell /system/bin/device_config put activity_manager max_phantom_processes 2147483647
```

### 9. Ahead-Of-Time (AOT) ARM Machine Code Compilation (`-m speed -f`)
* **The Problem:** Default Android Just-In-Time (JIT) runtime compilation occurs dynamically during gameplay. When a sudden explosion, vehicle, smoke grenade, or new 3D asset enters the scene, background JIT compiler threads consume CPU cycles, causing micro-freezes.
* **The Tweak:** Pre-compile all dex bytecode directly into optimized native ARM machine code:
```bat
adb shell cmd package compile -m speed -f com.dts.freefiremax
adb shell cmd package compile -m speed -f com.pubg.imobile
adb shell cmd package compile -m speed -f com.activision.callofduty.shooter
adb shell cmd package compile -m speed -f com.supercell.clashroyale
```

---

## Pillar 5: Touch Latency & Network Ping Stabilization

### 10. Touch Hold Latency Tuning & Wi-Fi Ping Stabilization
* **The Problem:**
  1. Default touch hold recognition (`long_press_timeout`) is 400ms, creating noticeable delay when initiating long-press actions, scoping, or rapid weapon swaps.
  2. Background Wi-Fi scanning (`wifi_scan_always_enabled = 1`) allows apps to scan for surrounding networks every 30–60 seconds even while connected, causing periodic 200–500ms ping spikes.
* **The Tweak:** Reduce touch hold delay to 300ms, set pointer speed to maximum (7), disable persistent background Wi-Fi scanning, and enable zero-packet-loss mobile data handover:
```bat
adb shell settings put secure long_press_timeout 300
adb shell settings put system pointer_speed 7
adb shell settings put global wifi_scan_always_enabled 0
adb shell settings put global wifi_scan_throttle_enabled 1
adb shell settings put global wifi_verbose_logging_enabled 0
adb shell settings put global mobile_data_always_on 1
```

---

## Complete Verification & Status Table

| Subsystem | Setting / Parameter | Default | Optimized | Impact |
|---|---|---|---|---|
| **Display** | `min_refresh_rate` | `null` (Dynamic) | `120.0` | Locks minimum panel refresh rate |
| **Display** | `peak_refresh_rate` | `120.0` | `120.0` | Locks maximum panel refresh rate |
| **Display** | `enable_power_throttling_clamper` | `true` | `false` | Prevents thermal refresh downshifting |
| **Display** | `idle_screen_refresh_rate_timeout` | `true` | `false` | Prevents 60Hz drop on static scenes |
| **Display** | `ignore_app_preferred_refresh_rate` | `true` | `false` | Honors high-FPS game requests |
| **GPU Driver** | `updatable_driver_all_apps` | `0` | `1` | Forces Production Game Driver |
| **GPU Driver** | `updatable_driver_production_opt_in_apps` | Empty | User Games | Direct hardware-accelerated pipeline |
| **GPU Driver** | `updatable_driver_production_opt_out_apps` | FreeFire, COD | Purged (Empty) | Removes games from software fallback list |
| **Visuals** | `gamecube_hawkeye_effective` | `0` | `1` | Sharpens enemy textures & shadow contrast |
| **Visuals** | `vivo_display_color_mode` | `0` (Standard) | `2` (Vivid) | DCI-P3 wide color gamut |
| **Game Manager** | Framerate Override | 60 FPS | 90 / 120 FPS | Unlocks game engine render limits |
| **Vivo Scheduler** | `game_scene_more_fps` | `0` | `1` | Enables Vivo high-FPS scene mode |
| **Vivo Scheduler** | `game_standard_promotion_mode` | `0` | `1` | Promotes games to high-priority governor |
| **Vivo Scheduler** | `pemMonsterState` | `0` | `1` | Activates iQOO Monster Mode profile |
| **Vivo Scheduler** | `gamewatch_vcs_mode` | `0` | `1` | Stabilizes frame pacing & thermals |
| **Hardware List** | `perf_game_list` | Incomplete | Complete | Allocates Dimensity 7200 A715 cores |
| **Runtime** | ART Compilation Filter | JIT / Profile | `speed` (AOT) | Zero JIT compiler thread stutter |
| **Power** | `dumpsys deviceidle whitelist` | Not Listed | Whitelisted | Exempt from OS background throttling |
| **Power** | `max_phantom_processes` | 32 | `2147483647` | Voice chat & overlays never killed |
| **Memory** | `zram_enabled` | `1` | `0` | Disables flash memory swapping micro-stutters |
| **Touch** | `long_press_timeout` | `400ms` | `300ms` | 25% faster touch-hold recognition |
| **Touch** | `pointer_speed` | `0` | `7` (Max) | Maximum aim and swipe responsiveness |
| **Network** | `wifi_scan_always_enabled` | `1` | `0` | Eliminates periodic ping spikes |
| **Network** | `wifi_scan_throttle_enabled` | `0` | `1` | Prevents background radio interruptions |
| **Network** | `wifi_wakeup_enabled` | `1` | `0` | Disables background Wi-Fi geofence wakeups |
| **Network** | `wifi_power_save` | `120` | `0` | Disables radio power sleep packet queuing |
| **Network** | `ble_scan_always_enabled` | `1` | `0` | Eliminates 2.4GHz Bluetooth beacon interference |
| **Network** | `tcp_default_init_rwnd` | `null` | `60` | Expands initial TCP window for faster socket transfer |
| **Network** | `mobile_data_always_on` | `0` | `1` | Zero packet-loss network handover |
| **DNS** | `private_dns_specifier` | `adguard` | `one.one.one.one` | Lowest roundtrip latency for matchmaking |
| **Game Overlay** | `device_config game_overlay` | Default | Mode 2/3 (120/90 FPS) | Direct OS-level game engine framerate injection |

---

## Automation Script

### To Apply All 10 Steps:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/optimize_gaming.ps1
```

### To Reset Device to Stock:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/optimize_gaming.ps1 -Reset
```
