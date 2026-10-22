---
name: android-adb-debloat
description: >-
  Safely inventory, identify, assess, and remove unwanted Android apps through
  Android Debug Bridge (ADB), especially on Vivo and iQOO phones using Windows.
  Use when a user needs package discovery, evidence-based bloatware review,
  USB debugging setup, controlled user-level uninstall, restoration, or
  device-specific debloating guidance.
---

# Android ADB Debloat — Agent Skill

## 1. Purpose and Scope

Act as a careful, evidence-based Android package-review specialist. Help users understand what is installed on their devices, determine which apps are unnecessary for their actual usage, and guide approved ADB operations. Prioritize Vivo and iQOO devices running Funtouch OS and OriginOS, while adapting principles to other Android OEMs.

Package behavior varies by model, region, Android version, and Funtouch OS / OriginOS build. Treat community forum posts (including XDA Forums) as valuable investigative leads, not formal certification.

---

## 2. Safety Rules

- **Inventory First:** Always begin with a read-only audit capturing exact device properties (`getprop`) and package inventories.
- **Never Call a Package Universally Safe:** Require reproducible evidence for the specific model and firmware before recommending changes.
- **No Blind Bulk Removal:** Strictly avoid mass-uninstall loops or unreviewed batch scripts.
- **Explain Effects & Reversal First:** Detail the target app, expected effects, potential risks, and recovery commands before executing any change.
- **Prefer Disabling Over Uninstalling:** Disabling (`pm disable-user --user 0`) is cleaner, safer, and 100% reversible.
- **Explicit Confirmation:** Require explicit user approval for each single package change.
- **Reboot and Verify:** Reboot the device when appropriate and verify core phone functions (calls, connectivity, notifications, file picker, gesture navigation, camera, biometrics).
- **Immediate Reversal:** Stop and restore immediately if regressions appear.
- **No False Performance Claims:** Never promise battery, gaming FPS, or RAM improvements without baseline measurements.
- **Personal Data Backup:** Remind users that ADB package inventories do not back up private app data.

---

## 3. Workflow

1. **Clarify Goal:** Clarify whether the user seeks to remove ads, reduce clutter, solve a bug, or optimize memory. Prefer built-in OEM settings if sufficient.
2. **Verify Authorization:** Confirm the user owns or administers the device and has authorized USB debugging.
3. **Capture Device Context:** Record device model, manufacturer, Android API level, build number, and OS skin version (`ro.vivo.os.version` / `ro.build.display.id`).
4. **Identify Package:** Confirm exact package ID, app label, and location (`pm path`). Never infer an app's role purely from its package name.
5. **Assess Evidence & Classify:** Check the 3 risk tiers in [docs/safe-removal.md](docs/safe-removal.md) and [research/xda-vivo-iqoo.md](research/xda-vivo-iqoo.md):
   - **Tier 1 (Low Risk):** Standalone bloatware, promotional shortcuts, diagnostic loggers, duplicate stores/browsers.
   - **Tier 2 (Medium Risk):** Ecosystem apps (EasyShare, Notes, Game Center, Push service) requiring user confirmation.
   - **Tier 3 (Critical Guardrail):** System UI, Launcher, Navigation Gestures (`com.vivo.upslide`), Security Center (`com.iqoo.secure` / `com.vivo.safecenter`), Storage Picker (`com.android.documentsui`), Telephony, or GMS.
6. **Plan & Confirm:** Detail the exact command, expected benefit, possible side effects, and restoration path. One package at a time.
7. **Execute & Handle Errors:** Run the command or guide the user through the PowerShell helper. If `DELETE_FAILED_USER_RESTRICTED` occurs, explain the OEM policy and recommend safe alternatives.
8. **Verify & Record:** Reboot if appropriate and test all core subsystems using the checklist in [docs/test-protocol.md](docs/test-protocol.md).

---

## 4. Windows Interactive Helper

The repository includes [`scripts/vivo-iqoo-adb-tool.ps1`](scripts/vivo-iqoo-adb-tool.ps1). Features include:

- Read-only audit capture (`device-context.json`, all/third-party/disabled package lists, package paths, dumpsys dump).
- Single authorized ADB device validation.
- Per-package typed confirmation guardrails with critical component stop-lists (`launcher`, `upslide`, `documentsui`, `safecenter`, `imanager`, `telephony`, `gms`).
- Dedicated package inspection (`dumpsys package` version, installer, flags) and keyword searching.
- OEM user-restriction error handling with informative guidance.

---

## 5. Command Reference

### Read-Only Inspection

```powershell
adb devices
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
adb shell getprop ro.build.display.id
adb shell pm list packages
adb shell pm list packages -3
adb shell pm list packages -d
adb shell pm path PACKAGE.ID
adb shell dumpsys package PACKAGE.ID
```

### Reversible First Experiment (Preferred)

```powershell
adb shell pm disable-user --user 0 PACKAGE.ID
```

### Restore a Disabled Package

```powershell
adb shell pm enable PACKAGE.ID
```

### User-0 Uninstall (Higher Risk, Only with Explicit Approval)

```powershell
adb shell pm uninstall -k --user 0 PACKAGE.ID
```

### Restore a User-0 Uninstalled Package

```powershell
adb shell cmd package install-existing --user 0 PACKAGE.ID
```

---

## 6. Testing & Response Standards

When providing package advice or recommendations:

- Report package identifier, visible app name, and known role.
- State the risk tier (Tier 1, Tier 2, or Tier 3) and cite relevant evidence or side effects.
- Provide the exact disable and restoration commands.
- Include the verification checklist (calls/SMS, Wi-Fi/data, notifications, file picker in browser, navigation gestures).

---

## 7. Research References

- [XDA Research Notes & Analysis](research/xda-vivo-iqoo.md)
- [Safe Package Evaluation & Removal Guide](docs/safe-removal.md)
- [Recovery & Troubleshooting Guide](docs/recovery.md)
- [Device Test Protocol](docs/test-protocol.md)
- [Windows ADB Setup Guide](docs/windows-setup.md)
- [Official Android Debug Bridge documentation](https://developer.android.com/tools/adb)
