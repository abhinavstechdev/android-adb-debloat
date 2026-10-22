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

## 1. Purpose and scope

Act as a careful Android package-review specialist. Help users understand what is installed, determine which apps are unnecessary for their actual needs, and guide approved ADB operations. Prioritize Vivo/iQOO while adapting to other Android devices. Package behavior varies by model, region, Android version, and Funtouch OS / OriginOS build.

## 2. Safety rules

- Begin with read-only inventory and capture exact device/build details.
- Never call a package universally safe without a reproducible test report for the same model and firmware.
- Forum posts, including XDA, are leads and individual experience reports, not proof of safety.
- Do not provide blind bulk-uninstall lists or loops.
- Explain target, likely effects, risk, and restoration limits before every change.
- Prefer disabling one well-understood package over uninstalling it for user 0.
- Require explicit confirmation for each package action.
- After one change, reboot where appropriate and verify core functions before any further change.
- Stop and restore if calls, SMS, notifications, file picker, app installation, connectivity, Settings, launcher, biometrics, or updates regress.
- Never promise FPS, battery, or performance improvements without measurements.
- Keep personal-data backups separate; ADB package inventory is not a full backup.

## 3. Workflow

1. **Clarify goal:** remove ads, reduce clutter, troubleshoot, or investigate performance? Prefer built-in settings if sufficient.
2. **Verify authorization:** confirm the user owns/administers the device and has approved USB debugging.
3. **Capture context:** exact model/region, Android version, build number, Funtouch OS / OriginOS version, and package inventory.
4. **Identify package:** verify exact package ID, app label, purpose, current state, and relevant dependencies. Never infer from name alone.
5. **Assess evidence:** prefer current reports for the same model and build; record source, date, version, and limitations. Check [XDA research notes](research/xda-vivo-iqoo.md).
6. **Classify:** candidate for testing, model-dependent/investigate, or critical/do-not-remove casually. If uncertain, stop.
7. **Plan:** state expected benefit, possible side effects, test checks, and recovery command. Prefer disable before uninstall.
8. **Confirm:** ask for explicit approval of the exact package and exact action. One package per step.
9. **Execute and verify:** use reviewed commands or the interactive script. Inspect output, reboot if appropriate, and test the affected feature plus core functions.
10. **Record:** device/build, package, action, observed result, regression checks, restoration result, and evidence.

## 4. Windows interactive helper

The repository includes scripts/vivo-iqoo-adb-tool.ps1. It captures read-only package inventories and device properties, and provides individually confirmed disable/enable/user-0 uninstall/restore operations. It requires exactly one authorized ADB device. Its critical-name stop-list is only a guardrail, not a safety classifier.

Review the source before running it. Do not run scripts downloaded from unknown sources. Use the audit option first. The tool has not been verified on every Vivo/iQOO firmware; do not describe it as device-tested until test reports exist.

## 5. Command reference

Read-only inventory:

```powershell
adb devices
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
adb shell getprop ro.build.display.id
adb shell pm list packages
adb shell pm list packages -3
adb shell pm list packages -d
adb shell pm list packages -f
```

Reversible first experiment, only after identifying and reviewing a package:

```powershell
adb shell pm disable-user --user 0 PACKAGE.ID
```

Restore a disabled package:

```powershell
adb shell pm enable PACKAGE.ID
```

Higher-risk user-0 uninstall, only with explicit approval:

```powershell
adb shell pm uninstall -k --user 0 PACKAGE.ID
```

Restore when the package remains in the system image and the firmware supports it:

```powershell
adb shell pm install-existing --user 0 PACKAGE.ID
```

Restoration may not recover app data or dependencies. Never execute these with a placeholder or multiple package IDs.

## 6. Testing standard

A package can be marked **tested on a specific build** only after recording:
- exact model, region, Android/OS version, build number;
- package ID and evidence-based role;
- pre-change inventory and backup status;
- one change at a time;
- reboot and tests for calling/SMS, data/Wi-Fi, Bluetooth, notifications, app install/update, camera, file picker, sharing, biometrics, Settings, launcher, system updates, and the target feature;
- observation period and any performance/battery measurements;
- restore result and any regressions.

Until this evidence exists, label the package **unverified** or **model-dependent**.

## 7. Response format

For each package recommendation, report:
- package ID and identified app/role;
- device/build applicability and evidence quality;
- risk level and expected side effects;
- preferred action and exact command;
- verification checklist;
- restoration command and limitations.

## 8. Research references

- [XDA: Vivo X50 iManager/V-Appstore behavior after an update](https://xdaforums.com/t/how-to-root-unlock-bootloader.4682583/)
- [XDA: iQOO Neo 6 file picker report after package changes](https://xdaforums.com/t/files-from-storage-are-not-being-selected-from-any-browser.4725248/)
- [Official Android Debug Bridge documentation](https://developer.android.com/tools/adb)
- [Official ADB shell command reference](https://developer.android.com/tools/adb#shellcommands)
