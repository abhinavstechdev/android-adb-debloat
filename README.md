<div align="center">

# Android ADB Debloat

### A safety-first Android package review skill

**Inspect. Identify. Assess risk. Confirm. Change. Verify.**

[![Android](https://img.shields.io/badge/Android-ADB-3DDC84?logo=android&logoColor=white)](https://developer.android.com/tools/adb)
[![Focus](https://img.shields.io/badge/device%20focus-Vivo%20%7C%20iQOO-5267DF)](#overview)
[![Workflow](https://img.shields.io/badge/workflow-Inspect%20first-success)](#operating-principles)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A reusable AI-agent skill and practical documentation set for identifying unwanted Android apps and safely guiding user-approved ADB changes.

</div>

---

## Overview

Android ADB Debloat helps an AI assistant guide a user through package inventory, app identification, risk assessment, and carefully controlled removal using Android Debug Bridge over USB. The project focuses on Vivo and iQOO devices while using a workflow that can be adapted to other Android phones.

It is a **skill and documentation project**, not an automated debloating executable. It does not run commands on a phone by itself. The user remains in control of device-changing operations.

## At a glance

- **Inventory before action:** start with read-only ADB commands.
- **Evidence-based identification:** don't infer an app's purpose from a package name alone.
- **Risk classification:** distinguish likely optional apps from model-dependent and critical components.
- **Explicit confirmation:** explain effects before recommending destructive commands.
- **Recoverability:** document restore paths and their limitations.
- **No blanket performance claims:** results depend on the device, firmware, and apps involved.

## Repository map

| File | Purpose |
|---|---|
| [SKILL.md](SKILL.md) | Main agent instructions, decision workflow, safety policy, and response format |
| [docs/windows-setup.md](docs/windows-setup.md) | Windows setup, USB authorization, and read-only inventory |
| [docs/safe-removal.md](docs/safe-removal.md) | Risk assessment and controlled package removal |
| [docs/recovery.md](docs/recovery.md) | Restoration, troubleshooting, and stop conditions |
| [docs/package-review-template.md](docs/package-review-template.md) | Reusable template for evaluating a package |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution and evidence standards |
| [SECURITY.md](SECURITY.md) | Responsible reporting and safety scope |
| [LICENSE](LICENSE) | MIT license |

## Quick start: Windows

### 1. Install official Android Platform Tools

Download from Google:  
https://developer.android.com/tools/releases/platform-tools

Extract the ZIP and open Command Prompt in the extracted platform-tools directory.

### 2. Enable USB debugging

On the phone, enable Developer options and USB debugging. Connect a data-capable USB cable, unlock the phone, and approve the RSA authorization prompt. Only authorize a computer you trust.

### 3. Confirm the connection

~~~bat
adb devices
~~~

Proceed when the device status is **device**. If it says **unauthorized**, approve the prompt on the phone.

### 4. Create a read-only package inventory

~~~bat
adb shell pm list packages > packages.txt
adb shell pm list packages -3
adb shell pm list packages -s
~~~

The first command saves a package list to the current directory on your computer. The other commands list third-party and system packages.

### 5. Review before removing

Identify the visible app in Android Settings and assess its purpose, dependencies, and importance on the exact model and firmware. See the [safe-removal guide](docs/safe-removal.md).

Only after reviewing and approving one exact package, a user-level removal may look like:

~~~bat
adb shell pm uninstall --user 0 PACKAGE_NAME
~~~

Replace **PACKAGE_NAME** with the verified identifier. Never run the placeholder literally or use an unreviewed bulk-removal script.

## Operating principles

1. **Read-only first.** Gather device context and package inventory before changes.
2. **Identify with evidence.** Package names are clues, not proof.
3. **Assess consequences.** Document confidence, risk, and affected features.
4. **Ask before changing.** Make the exact command and effect clear.
5. **Change one package at a time.** Verify behavior after each change.
6. **Keep a recovery path.** A preinstalled package may sometimes be restored with the install-existing command, but this is not guaranteed.
7. **Stop when uncertain.** Unknown vendor services and core system components are not debloat targets by default.

## Safety notes

Package availability and behavior vary by phone model, region, Android release, and Funtouch OS / OriginOS version. Vendor apps that appear optional on one phone may support notifications, sharing, app updates, security tools, or other functions on another.

Do not casually remove telephony, Settings, System UI, launcher, package installer, permission controller, biometric services, emergency functionality, Google Play services, update components, or unidentified vendor services.

ADB debloating is not guaranteed to improve FPS, battery life, memory usage, or thermals. Measure results on the actual device.

## Official references

- [Android Debug Bridge documentation](https://developer.android.com/tools/adb)
- [Android SDK Platform Tools](https://developer.android.com/tools/releases/platform-tools)

## Contributing

Contributions should include the exact device model, Android / firmware version, package identifier, observed behavior, and credible evidence. Please read [CONTRIBUTING.md](CONTRIBUTING.md). Avoid universal “safe to remove” claims based only on a package name.

## License

Released under the [MIT License](LICENSE).
