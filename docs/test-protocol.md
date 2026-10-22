# Device Test Protocol & Validation Status

## 1. Current Validation Status

- **XDA & Community Research:** Comprehensive analysis of reported package behaviors across Funtouch OS 11 through 15 and OriginOS, including documented issues on iQOO 7, iQOO Neo 6, Vivo X50/X60, and general BBK firmware (see [research/xda-vivo-iqoo.md](../research/xda-vivo-iqoo.md)).
- **Script Behavioral Review:** Verified read-only audit generation, single-device requirement, per-package typed confirmation guardrail, critical package stop-list (`com.vivo.launcher`, `com.vivo.upslide`, `com.iqoo.secure`, `com.vivo.safecenter`, `com.android.documentsui`, Telephony, GMS), keyword searching, and OEM restriction error handling.
- **PowerShell Syntax & Parser Test:** **Verified and Passed** on Windows with Windows PowerShell 5.1 and PowerShell 7+. Abstract Syntax Tree (AST) validation completed with zero parser errors; script startup and dependency checks verified.
- **Physical-Device Validation:** In progress. Because of modern Vivo/iQOO permanently locked bootloaders and firmware diversity, individual firmware builds require independent testing and documentation using the protocol below.
- **Safety Stance:** Do not treat any debloat list as universally safe. Every operation must follow the protocol: audit → inspect → change one package → reboot → verify core functions.

---

## 2. Standardized Device Test Protocol

Copy this template into a new test record in `research/` or an issue thread for each unique hardware model and firmware build. **Do not combine different models or firmware versions into one report.**

### Test Report Template

| Field | Value / Details |
| --- | --- |
| **Device Model & Codename** | *e.g., iQOO Neo 7 Pro / Vivo X100 Pro* |
| **Sales Region / Market** | *e.g., India Retail, Global, or China Domestic* |
| **Android Version & API Level** | *e.g., Android 14 (API 34)* |
| **Skin & OS Build Number** | *e.g., Funtouch OS 14 (PD2232BF_EX_A_14.0.5.0)* |
| **Security Patch Level** | *e.g., 2026-09-01* |
| **Host Environment** | *e.g., Windows 11, ADB 35.0.2* |
| **Target Package Identifier** | *e.g., com.vivo.browser* |
| **Visible App Label & Role** | *e.g., Vivo Browser (Stock internet browser)* |
| **Initial Package State** | *e.g., Enabled / System app* |
| **Read-Only Audit Saved** | *Yes (Folder path / timestamp)* |
| **Action Executed** | *Disable (`pm disable-user --user 0`) / Uninstall (`pm uninstall -k --user 0`)* |
| **Exact Command Output** | *e.g., Package com.vivo.browser new state: disabled-user* |
| **Device Reboot Completed** | *Yes / No* |
| **Call & SMS Functionality** | *Pass / Fail / Notes* |
| **Mobile Data, Wi-Fi & Hotspot** | *Pass / Fail / Notes* |
| **Bluetooth Audio & Remote Pairing** | *Pass / Fail / Notes* |
| **Push Notifications (WhatsApp, Gmail)** | *Pass / Fail / Notes* |
| **Browser File Picker & Uploads** | *Pass / Fail (Tested file selection in Chrome/Brave)* |
| **Navigation Gestures & Recent Apps** | *Pass / Fail (Swipe up to Home / Multitasking)* |
| **Camera Shutter & Album Preview** | *Pass / Fail (Photo capture and thumbnail preview)* |
| **Runtime Permission Prompts** | *Pass / Fail (App prompts for Camera/Location grant)* |
| **Streaming Media Playback** | *Pass / Fail (Continuous YouTube/Spotify playback without pausing)* |
| **Target Feature Verification** | *Observed result for the removed app* |
| **Reversal / Restoration Test** | *Pass / Fail (`pm enable` or `pm install-existing`)* |
| **Observed Regressions / Notes** | *Any side effects or quirks encountered* |
| **Tester & Date** | *Name / GitHub handle, YYYY-MM-DD* |

---

## 3. Minimum Testing Workflow

1. **Prerequisites:** Use a device you administer; perform a full personal-data backup before modifying system packages.
2. **Read-Only Snapshot:** Run `scripts/vivo-iqoo-adb-tool.ps1` (Option 1) to capture device properties, complete package inventories, and package paths.
3. **Inspect Before Action:** Use Option 7 (`Inspect package details`) to check package location, installer origin, and current state.
4. **Single-Action Rule:** Change only **one package at a time**. Do not execute batch removals.
5. **Prefer Disabling:** Always attempt `pm disable-user --user 0` before attempting `pm uninstall -k --user 0`.
6. **Reboot and Check:** Restart the device. Verify all items on the verification checklist (calls, connectivity, notifications, gestures, file picker, and permissions).
7. **Immediate Restoration on Failure:** If any subsystem regresses, restore the package immediately using Option 4 or Option 6. Do not continue experimenting on an unstable system.
8. **Record Everything:** Document both successful removals and unexpected side effects.

---

## 4. Important Reminders

- ADB package inventories capture application lists, not private user data or database state.
- Re-enabling or reinstalling an app for user 0 reconnects the system APK, but cannot recover deleted app databases or custom user preferences.
- Because bootloaders on modern Vivo and iQOO devices cannot be unlocked via fastboot, severe system errors must be resolved through Stock Recovery "Clear all data". Conservative testing is essential.
