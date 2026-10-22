# Debloat Action Record — iQOO Z7 Pro 5G (PD2285CF_EX_A_15.2.21.3.W30)

Date: 2026-10-23
Device: iQOO Z7 Pro 5G (`I2301`)
OS: Funtouch OS 15 (`ro.vivo.os.version: 6.0`)
Build: `PD2285CF_EX_A_15.2.21.3.W30`

---

## 1. Successfully Uninstalled Packages (User 0)

A total of **24 Tier-1 packages** were safely uninstalled for Android user 0:

| Package Identifier | Component / App Role | Result |
|---|---|---|
| `com.vivo.browser` | Vivo Stock Internet Browser | `Success` |
| `com.vivo.browser.overlay` | Vivo Browser Overlay Resources | `Success` |
| `com.facebook.appmanager` | Meta / Facebook Background App Manager | `Success` |
| `com.facebook.services` | Meta / Facebook Telemetry Service | `Success` |
| `com.facebook.system` | Meta / Facebook System Installer Stub | `Success` |
| `com.yozo.vivo.office` | Bundled Yozo Office / Doc Viewer | `Success` |
| `com.yozo.vivo.office.overlay` | Yozo Office Theme Overlay | `Success` |
| `com.vivo.unionpay` | China UnionPay Payment Plugin | `Success` |
| `com.vivo.doubletimezoneclock` | Dual Timezone Clock Widget | `Success` |
| `com.bbk.iqoo.logsystem` | iQOO Diagnostic Log Collector | `Success` |
| `com.android.bbklog` | Android BBK Bug Reporter | `Success` |
| `com.vivo.Tips` | Vivo Tips & Tutorials App | `Success` |
| `com.vivo.feedback` | Vivo Feedback & Diagnostic Reporting | `Success` |
| `com.vivo.nps` | Vivo NPS Feedback Daemon | `Success` |
| `com.vivo.nps.overlay` | Vivo NPS Overlay Resources | `Success` |
| `com.vivo.livewallpaper.ocean` | Stock Ocean Live Wallpaper | `Success` |
| `com.vivo.livewallpaper.oceanvertical` | Vertical Ocean Live Wallpaper | `Success` |
| `com.vivo.livewallpaper.plant` | Plant Live Wallpaper | `Success` |
| `com.vivo.livewallpaper.behavior` | Behavior Live Wallpaper Engine | `Success` |
| `com.vivo.livewallpaper.behaviormountain` | Mountain Behavior Live Wallpaper | `Success` |
| `com.bbk.cloud.overlay` | Vivo Cloud Resource Overlay | `Success` |
| `com.bbk.account.overlay` | BBK Account Resource Overlay | `Success` |
| `android.autoinstalls.config.vivo.devices` | Auto-Install Bloatware Configuration | `Success` |
| `com.vivo.floatingball` | Assistive Floating Shortcut Ball | `Success` |

---

## 2. Protected Packages (Funtouch OS 15 Enterprise Policy)

The following packages are protected by Vivo's OEM policy and returned `DELETE_FAILED_USER_RESTRICTED` or `DELETE_FAILED_INTERNAL_ERROR`. As per repository safety principles, these were **safely left untouched**:
- `com.iqoo.website`
- `com.vivo.globalsearch`
- `com.bbk.cloud`
- `com.bbk.account`
- `com.vivo.assistant`
- `com.vivo.assistantfunction`
- `com.vivo.hiboard`
- `com.vivo.magazine`
- `com.vivo.livewallpaper.box`

---

## 3. How to Restore Any Uninstalled Package

To bring back any of the above packages at any time, run:
```bat
adb shell cmd package install-existing --user 0 <PACKAGE_IDENTIFIER>
```
Example:
```bat
adb shell cmd package install-existing --user 0 com.vivo.browser
```

---

## 4. Temporary Files & Cache Cleanup

A full discovery and safe purge of unneeded temporary data was performed via ADB:

- **OS / App Caches Trimmed:** `adb shell pm trim-caches 200G internal` (flushed unneeded app cache buffers without affecting user app data or settings)
- **Thumbnail Caches Purged:** `rm -rf /sdcard/Pictures/.thumbnails/* /sdcard/Movies/.thumbnails/*` (reclaimed ~110 MB of stale image/video thumbnails)
- **System Log Buffers Cleared:** `adb shell logcat -c` (reset accumulated system ring logs)

### Storage Comparison (Before vs. After)

| Metric | Before Cleanup | After Cleanup | Difference / Reclaimed |
|---|---|---|---|
| **Used Storage** | **162 GB** (170,231,092 KB) | **158 GB** (165,339,392 KB) | **-4.89 GB (-4,891,700 KB)** |
| **Available Storage** | **63 GB** (66,081,160 KB) | **68 GB** (70,972,860 KB) | **+4.89 GB (+4,891,700 KB)** |
| **Storage Utilization** | **73%** | **70%** | **3% Total Storage Saved** |

---

## 5. User-Selected App Uninstalls (Session 2)

The following 11 apps were uninstalled as per user request:

| Package Identifier | Application Name | Category | Result |
|---|---|---|---|
| `com.facebook.viewpoints` | Meta Viewpoints | Meta Surveys / Tracking | `Success` |
| `com.facebook.pages.app` | Meta Business Suite | Facebook Pages Manager | `Success` |
| `com.king.candycrushsaga` | Candy Crush Saga | Casual Game | `Success` |
| `com.nebula.mahjongtile` | Mahjong Tile | Casual Game | `Success` |
| `com.vitastudio.mahjong` | Vita Mahjong | Casual Game | `Success` |
| `com.wallapers.sillysmiles.live.wallpaper` | Silly Smiles Live Wallpaper | Wallpaper App | `Success` |
| `com.wallpaperscraft.wallpaper` | Wallcraft | Wallpaper App | `Success` |
| `com.grofers.customerapp` | Blinkit (Grofers) | Grocery Delivery | `Success` |
| `com.zeptoconsumerapp` | Zepto | Grocery Delivery | `Success` |
| `com.done.faasos` | EatSure (Faasos) | Food Delivery | `Success` |
| `com.earnkaro` | EarnKaro | Affiliate Deals App | `Success` |

### Current Overall Device Storage

| Metric | Baseline | After Session 1 (Tier-1 + Cache Trim) | After Session 2 (11 Apps Uninstalled) | Total Reclaimed |
|---|---|---|---|---|
| **Used Space** | **162 GB** | **158 GB** | **155 GB** | **-7 GB** |
| **Available Space** | **63 GB** | **68 GB** | **70 GB** | **+7 GB Free Space** |
| **Utilization** | **73%** | **70%** | **69%** | **4% Space Saved** |


