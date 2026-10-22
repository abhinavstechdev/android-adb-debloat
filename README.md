<div align="center">

# Android ADB Debloat

**A careful, device-aware skill for inspecting and removing unwanted Android apps.**

Vivo · iQOO · Windows · Android Debug Bridge

[![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)](https://developer.android.com/tools/adb)
[![Interface](https://img.shields.io/badge/interface-CLI%20%2F%20ADB-222222?logo=windowsterminal&logoColor=white)](https://developer.android.com/tools/releases/platform-tools)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Safety](https://img.shields.io/badge/default-Inspect%20First-success)](#safety-first)

</div>

---

## Overview

Android ADB Debloat is a reusable AI-agent skill and practical runbook for identifying unnecessary preinstalled Android apps, reviewing their purpose, and removing approved packages through USB debugging. It emphasizes **Vivo and iQOO devices**, but the workflow applies broadly to Android.

The project prioritizes careful package identification, reversible user-level changes, and device-specific guidance over risky one-click debloat scripts.

> **Important:** Package names and dependencies vary across phone models, Android releases, and regional firmware. No vendor package list should be considered universally safe.

## What is included

| Path | Purpose |
|---|---|
| [`SKILL.md`](SKILL.md) | Main agent skill: workflow, safety rules, package review, and output standards |
| [`docs/windows-setup.md`](docs/windows-setup.md) | Windows setup, USB debugging, and read-only inventory commands |
| [`docs/safe-removal.md`](docs/safe-removal.md) | Package classification and cautious removal procedure |
| [`docs/recovery.md`](docs/recovery.md) | Restore commands and troubleshooting |
| [`LICENSE`](LICENSE) | MIT license |

## Quick start

### 1. Install Android Platform Tools

Download the official package from Google:

**https://developer.android.com/tools/releases/platform-tools**

Extract the ZIP and open Command Prompt inside the extracted `platform-tools` directory.

### 2. Enable USB debugging

On the phone, enable Developer options, turn on **USB debugging**, connect a data-capable cable, unlock the phone, and approve the computer's RSA authorization prompt.

### 3. Confirm the device connection

```bat
adb devices
```

Continue only when the device status is `device`. If it shows `unauthorized`, approve the prompt on the phone.

### 4. Inventory first — do not uninstall yet

```bat
adb shell pm list packages > packages.txt
adb shell pm list packages -3
adb shell pm list packages -s
```

The first command saves the package list to the current directory. Review package identity and purpose before making any change.

### 5. Remove one verified, approved package

Only after confirming exactly which app the package belongs to:

```bat
adb shell pm uninstall --user 0 PACKAGE_NAME
```

Replace `PACKAGE_NAME` with the exact package identifier. Do not paste the placeholder literally, and do not run bulk removal commands copied from another device.

### 6. Restore a preinstalled app if needed

```bat
adb shell cmd package install-existing --user 0 PACKAGE_NAME
```

This may restore a preinstalled package for user 0 if the package remains on the device. It does not work for every package or situation.

## Safety first

- **Inspect before changing.** Capture package lists and identify the app in Android Settings.
- **Remove one package at a time.** Verify phone behavior after each change.
- **Protect critical components.** Do not casually remove telephony, Settings, System UI, launchers, package installation, permission management, biometrics, emergency functionality, Google Play services, or unknown vendor services.
- **Treat vendor apps as model-dependent.** Components such as app stores, sharing tools, push services, and device security managers may support features you rely on.
- **Keep recovery commands handy.** Prefer user-level uninstall over system-partition modification.
- **Avoid performance promises.** Debloating may reduce clutter or some background activity; FPS, battery life, and stability results vary.

Read the full [safety and removal guide](docs/safe-removal.md) before removing packages.

## Intended use

Use this project when an AI assistant needs to:
- Guide a user through ADB setup and connection troubleshooting.
- Gather and interpret an Android package inventory.
- Create a device-specific list of removal candidates with confidence and side-effect notes.
- Explain reversible user-level uninstall and restoration.
- Produce a clear change audit.

This repository is a **skill and documentation project**, not an automatic debloating executable. Commands that modify the device should be reviewed and explicitly approved by the user.

## Official references

- [Android Debug Bridge (ADB)](https://developer.android.com/tools/adb)
- [SDK Platform Tools downloads](https://developer.android.com/tools/releases/platform-tools)

## Contributing

Corrections for package identifications, device versions, and troubleshooting are welcome. Please include the exact device model, Android / firmware version, observed behavior, and credible evidence. Avoid submitting universal “safe to remove” claims based only on a package name.

## License

Released under the [MIT License](LICENSE).
