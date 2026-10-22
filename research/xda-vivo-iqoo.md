# Research Notes: Vivo / iQOO ADB Debloating & XDA Community Analysis

## 1. Executive Summary & Important Conclusion

There is no universal, independently certified "safe Vivo/iQOO debloat list" that applies indiscriminately across all devices and firmwares. While forum threads on XDA Forums, Reddit, and GitHub issue trackers offer valuable community experience reports and debugging leads, they **do not constitute safety certification**.

Package behavior, dependency trees, and system tolerance vary significantly by:

1. **Device hardware architecture:** Vivo X-series (flagship), V-series (mid-range), Y-series (budget), and iQOO Neo/Number/Z-series.
2. **Software branch:** **Funtouch OS** (Global and Indian retail units) vs. **OriginOS** (Chinese domestic units).
3. **Android API generation:** Android 11 (Funtouch OS 11) through Android 15 (Funtouch OS 15 / OriginOS 5).
4. **Security patch level & OEM policy:** Newer updates enforce strict user-space app control restrictions.

**Core Rule:** Never label any package "tested-safe" unless the exact device model, region, OS build number, test sequence, and post-reboot regression checks have been documented with reproducible evidence.

---

## 2. Key XDA Threads & Community Investigations Reviewed

### A. iQOO 7 Funtouch OS 11/13 Debloat Guide

* **Thread Title:** *[How To Guide] Debloat FunTouch OS 11/13 - IQOO 7* (Author: *RockStar8*)
* **Source:** XDA Forums — iQOO 7 Community
* **Key Findings:**
  * Cataloged extensive lists of non-critical Vivo/BBK apps (`com.vivo.browser`, `com.vivo.assistant`, `com.vivo.hiboard`, `com.vivo.magazine`, `com.vivo.globalsearch`, `com.bbk.cloud`, `com.bbk.account`, `com.vivo.appstore`, `com.vivo.Tips`, `com.yozo.vivo.office`).
  * Preloaded third-party partner bloatware: Facebook background daemons (`com.facebook.appmanager`, `com.facebook.services`, `com.facebook.system`) and Netflix partner stubs (`com.netflix.partner.activation`).
  * **Observed Regression (Media Playback Bug):** Community contributors discovered that aggressively disabling background power/multimedia services can cause an unintended bug where audio or video in streaming apps (such as YouTube, Spotify) pauses spontaneously. Restoring background power management services resolved the issue.

### B. iQOO Neo 6 File Picker Failure After Package Changes

* **Thread Title:** *Files from storage are not being selected from any browser*
* **Reference:** [XDA Thread 4725248](https://xdaforums.com/t/files-from-storage-are-not-being-selected-from-any-browser.4725248/)
* **Key Findings:**
  * After executing ADB debloat commands, the user lost the ability to select, attach, or upload files from internal storage in web browsers (Chrome, Brave) and third-party apps. Clicking "Choose File" or "Upload" froze or crashed the browser.
  * **Root Cause:** Accidental removal or disabling of system storage provider / document management components (`com.android.documentsui` or OEM file picker wrappers).
  * **Recovery:** Restoring the missing DocumentsUI package using `adb shell pm install-existing --user 0 com.android.documentsui` immediately restored storage intent resolution.

### C. Gesture Navigation Breakage with `com.vivo.upslide`

* **Sources:** XDA Funtouch OS Navigation & Debloat Discussions
* **Key Findings:**
  * Several naive debloat lists targeted `com.vivo.upslide` as "Vivo bloat".
  * **Critical Dependency:** `com.vivo.upslide` manages system swipe-up gesture navigation, control center triggers, and the recent apps multitasking switcher. Disabling or removing this package disables swipe-up gestures or leaves the device unable to switch between active tasks.

### D. Security Center & Permission Prompt Conflicts (`com.iqoo.secure` / `com.vivo.safecenter` / `com.vivo.imanager`)

* **Sources:** XDA Vivo X50, X60, and iQOO Optimization Threads
* **Key Findings:**
  * Vivo's built-in **iManager** is packaged under `com.iqoo.secure` or `com.vivo.imanager` / `com.vivo.safecenter`.
  * While users often seek to disable it because of its aggressive background process killing and push notification throttling, removing it has critical consequences:
    1. Removes the network traffic speed indicator from the status bar.
    2. On certain Funtouch OS builds, removing the security center breaks runtime permission confirmation popups and package installer authorization dialogues, preventing the user from granting permissions to new apps.
    3. Breaks Game Space performance profiles and thermal throttling toggles.

### E. Vivo X50 / X60 Series Updates & Package Persistence

* **Sources:** XDA Vivo X-Series Discussions
* **Key Findings:**
  * Major OTA updates (e.g., from Android 10 to Android 11, or Funtouch OS 12 to 13) frequently re-install or re-enable packages previously disabled or uninstalled for user 0.
  * Debloating cannot be treated as a permanent ROM-level modification; it must be re-audited and selectively reapplied after each system upgrade.

---

## 3. Technical Analysis of `DELETE_FAILED_USER_RESTRICTED`

Starting in Funtouch OS 12 and continuing through Funtouch OS 13, 14, and 15, standard ADB user uninstall commands:

```bash
adb shell pm uninstall -k --user 0 com.bbk.cloud
```

frequently fail with:

```text
Failure [DELETE_FAILED_USER_RESTRICTED]
```

or disabling fails with:

```text
java.lang.SecurityException: Cannot disable a protected package
```

### Technical Cause

Vivo's OEM implementation of Android's `UserManager` enforces `DISALLOW_APPS_CONTROL` or vendor-specific protected package lists inside `PackageManagerService`. When a high-level `pm` shell command is called, the service checks this policy and rejects the command for designated system applications (such as Vivo Cloud, V-Appstore, and Jovi Assistant).

### The XDA Binder Service Call Workaround

On XDA forums and related communities, advanced users discovered that calling the raw binder transaction for `IPackageManager.setSystemAppInstallState` directly bypasses the high-level policy check:

```bash
# Example syntax documented for Android 13:
adb shell service call package 131 s16 PACKAGE_NAME i32 0 i32 0

# Example syntax documented for Android 12:
adb shell service call package 134 s16 PACKAGE_NAME i32 0 i32 0
```

A return parcel ending in `00000001` indicates that the binder call was accepted.

### Project Verdict & Caution on Service Calls

**This repository does NOT automatically execute raw binder service calls**, for the following critical reasons:

1. **Transaction ID Instability:** Binder transaction codes (e.g., 131, 134) are not part of Android's public API. They change between Android versions, sub-builds, and OEM security patches. Sending the wrong transaction ID invokes a completely different internal method in `PackageManager`, risking unexpected state corruption or system crash.
2. **Intentional OEM Protection:** When a package triggers `DELETE_FAILED_USER_RESTRICTED`, the OEM firmware has marked it as protected. Bypassing this protection forcefully increases the risk of bootloop or crashing system services.
3. **Safe Alternative:** Prefer non-invasive options first:
   * Try `pm disable-user --user 0 <pkg>`.
   * If disabled via permissions or in-app toggles, use those instead.
   * If the firmware refuses removal, leave the package alone and revoke its network permissions or background execution via Settings.

---

## 4. Bootloader Locking & Recovery Constraints on Vivo / iQOO

On many Android devices (such as Google Pixel, Motorola, or older Xiaomi), a bricked or bootlooping device can easily be recovered via Fastboot (`fastboot flash` or `fastboot boot recovery`).

**On modern Vivo and iQOO smartphones:**

* **Permanently Locked Bootloader:** Modern global and Indian Vivo and iQOO devices (Funtouch OS 12/13/14/15) **do not support official bootloader unlocking**. Fastboot commands like `fastboot oem unlock` or `fastboot flashing unlock` are disabled.
* **No Custom Recovery / EDL Access:** There are no official TWRP builds, and Emergency Download (EDL) flashing requires authenticated Vivo service account credentials.
* **Consequence of a Bootloop:** If a critical package is uninstalled via ADB and the phone gets stuck in a bootloop before the ADB daemon initializes, **the only recovery path is entering stock recovery mode (Power + Volume Up) and selecting "Clear all data" (factory reset)**. All personal data is lost.

This makes conservative guardrails, read-only inventories, and one-by-one verification mandatory when debloating Vivo and iQOO phones.

---

## 5. Ecosystem & Namespace Architecture (Funtouch OS vs. OriginOS)

When reviewing package inventories on Vivo and iQOO devices, packages generally fall into five distinct namespace families:

| Namespace | Origin / Role | Example Packages | Typical Community Status |
| --- | --- | --- | --- |
| `com.vivo.*` | Vivo proprietary applications & framework extensions | `com.vivo.browser`, `com.vivo.appstore`, `com.vivo.magazine`, `com.vivo.upslide` | Mixed: frontend apps often safe to disable; framework/navigation critical |
| `com.iqoo.*` | iQOO brand specifics, security centers, and utilities | `com.iqoo.secure`, `com.iqoo.website`, `com.iqoo.engineermode` | Caution: `com.iqoo.secure` handles system security & permissions |
| `com.bbk.*` | BBK Electronics shared infrastructure (Vivo/Oppo/Realme/iQOO) | `com.bbk.cloud`, `com.bbk.account`, `com.bbk.iqoo.logsystem` | Account/cloud services frequently removable; system loggers removable |
| `com.vlife.*` | Third-party wallpaper & lockscreen themes engine | `com.vlife.vivo.wallpaper` | Safe candidate for removal if custom wallpapers are unused |
| `com.yozo.*` | Document viewer software bundled on Funtouch OS | `com.yozo.vivo.office` | Safe candidate if third-party office apps (Docs/WPS) are preferred |

---

## 6. Official References & Documentation

1. [Official Android Debug Bridge (ADB) Guide](https://developer.android.com/tools/adb)
2. [Official ADB Shell Command Reference](https://developer.android.com/tools/adb#shellcommands)
3. [Android SDK Platform-Tools Releases](https://developer.android.com/tools/releases/platform-tools)
4. [Universal Android Debloater Next Generation (UAD-ng) OEM Lists](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation)
5. [XDA Thread 4725248: Browser File Picker Failure Investigation](https://xdaforums.com/t/files-from-storage-are-not-being-selected-from-any-browser.4725248/)
6. [XDA General ADB Debloating Discussion (Thread 3896326)](https://xdaforums.com/t/debloating-stock-rom-no-root-better-battery-performance.3896326/)
