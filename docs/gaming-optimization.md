# Gaming & Performance Optimization Guide via ADB (Vivo / iQOO)

This guide documents the system configurations and ADB commands applied to optimize gaming performance, reduce touch/render latency, lock display framerates, and stabilize network ping on **iQOO Z7 Pro 5G** and Funtouch OS devices.

---

## Optimizations Applied

### 1. 120Hz Display Refresh Rate Lock (Eliminates Frame Stutter)
Funtouch OS employs dynamic Variable Refresh Rate (VRR) by default, dropping down to 60Hz or 30Hz whenever touch contact stops or during micro-pauses. In competitive games, this causes noticeable judder and frame pacing drops.

- **Min Refresh Rate:** `120.0 Hz`
- **Peak Refresh Rate:** `120.0 Hz`
```bat
adb shell settings put system min_refresh_rate 120.0
adb shell settings put system peak_refresh_rate 120.0
```

### 2. Updatable Game Graphics Driver Routing
By default, games like Free Fire MAX and Call of Duty: Mobile were on the system driver's opt-out list (`updatable_driver_production_opt_out_apps`), forcing generic software-composited graphics paths.

- **Driver Policy:** Forced production Game Driver for primary gaming packages.
```bat
adb shell settings put global updatable_driver_all_apps 1
adb shell settings put global updatable_driver_production_opt_in_apps 'com.dts.freefiremax,com.pubg.imobile,com.activision.callofduty.shooter,com.supercell.clashroyale'
adb shell settings put global updatable_driver_production_opt_out_apps ''
```

### 3. Native Android Game Manager FPS Overrides
Using Android's official Game Intervention Engine (`cmd game`), the OS render targets have been unlocked to high refresh rate profiles:
- **Free Fire MAX (`com.dts.freefiremax`):** `120 FPS`
- **BGMI / PUBG Mobile (`com.pubg.imobile`):** `90 FPS`
- **Call of Duty: Mobile (`com.activision.callofduty.shooter`):** `120 FPS`
- **Clash Royale (`com.supercell.clashroyale`):** `120 FPS`

```bat
adb shell cmd game set --fps 120 com.dts.freefiremax
adb shell cmd game set --fps 90 com.pubg.imobile
adb shell cmd game set --fps 120 com.activision.callofduty.shooter
adb shell cmd game set --fps 120 com.supercell.clashroyale
```

### 4. Wi-Fi Ping Spike & Latency Prevention
In online competitive games, periodic 200–500ms ping spikes are caused by Android scanning for nearby Wi-Fi APs in the background while matches are ongoing.
- Enabled Wi-Fi scan throttling to block background scans during gameplay.
- Disabled verbose driver logging to reduce CPU interruption overhead.

```bat
adb shell settings put global wifi_scan_throttle_enabled 1
adb shell settings put global wifi_verbose_logging_enabled 0
```

### 5. iQOO Monster Mode Governor
Activates iQOO's high-performance CPU/GPU scheduler profile:
```bat
adb shell settings put system pemMonsterState 1
```

### 6. Ahead-Of-Time (AOT) Native Code Compilation (`speed` filter)
Eliminates Android Runtime (ART) Just-In-Time (JIT) compilation spikes during gameplay. Dex bytecode is pre-compiled into direct ARM machine code, preventing frame drops during explosions, asset loading, or sudden combat encounters:
```bat
adb shell cmd package compile -m speed -f com.dts.freefiremax
adb shell cmd package compile -m speed -f com.pubg.imobile
adb shell cmd package compile -m speed -f com.activision.callofduty.shooter
adb shell cmd package compile -m speed -f com.supercell.clashroyale
```

### 7. Power & Thermal Standby Whitelist (`deviceidle`)
Exempts primary game processes from aggressive OS battery throttling and background socket suspension:
```bat
adb shell dumpsys deviceidle whitelist +com.dts.freefiremax
adb shell dumpsys deviceidle whitelist +com.pubg.imobile
adb shell dumpsys deviceidle whitelist +com.activision.callofduty.shooter
adb shell dumpsys deviceidle whitelist +com.supercell.clashroyale
```

### 8. Touch Response & Hold Latency Tuning
Reduces hold-gesture detection threshold from standard 400ms to 300ms for faster trigger reaction and scope response:
```bat
adb shell settings put secure long_press_timeout 300
adb shell settings put system pointer_speed 7
```

---


## One-Click Script

To re-apply or reset these optimizations at any time:

### Apply:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/optimize_gaming.ps1
```

### Reset to Default:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/optimize_gaming.ps1 -Reset
```
