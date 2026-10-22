# Android ADB Debloat

A safety-first ADB package review toolkit focused on Vivo and iQOO phones.

**Inspect → identify → assess → confirm → change one thing → verify → restore if needed.**

## What is included

- Reusable AI-agent skill for evidence-based Android package assessment.
- Windows PowerShell helper for read-only inventory, device/build capture, and individually confirmed package actions.
- Safety and recovery documentation, review template, and contribution standards.
- XDA/community research notes with clear limits on what forum reports can establish.

## Quick start (Windows)

1. Install Google's [Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools).
2. Enable Developer options and USB debugging on the phone. Connect it and approve the computer's RSA prompt.
3. Open PowerShell in the Platform-Tools folder (or ensure adb is on PATH).
4. Verify one authorized device with `adb devices`.
5. Download [the interactive script](scripts/vivo-iqoo-adb-tool.ps1) and run it from PowerShell:

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\vivo-iqoo-adb-tool.ps1
   ```

   If running from the repository root, use `.scripts\vivo-iqoo-adb-tool.ps1`.

6. Choose **1** first to save a read-only audit. Review the captured build and package IDs before making changes.

The script requires exactly one authorized device. It has no bulk-removal mode. Each package action requires typing the full action and package ID. Its critical-name stop-list is a guardrail, not a safety classifier.

## Safety status — read before use

**No Vivo/iQOO package is represented here as universally tested-safe.** The script has not been validated on every model or firmware, and community forum posts are not formal certification. Review the script before running it and test on a spare/non-critical device first. Start with inventory; prefer disabling a single well-understood package over uninstalling it; reboot and test core phone functions before proceeding.

Restore attempts use `pm enable PACKAGE.ID` or `pm install-existing --user 0 PACKAGE.ID` where supported. These do not guarantee recovery of app data or every firmware-specific dependency. Back up personal data separately.

## Research and docs

- [Windows ADB setup](docs/windows-setup.md)
- [Safe package evaluation and removal](docs/safe-removal.md)
- [Recovery and troubleshooting](docs/recovery.md)
- [Package review template](docs/package-review-template.md)
- [XDA / Vivo-iQOO research notes](research/xda-vivo-iqoo.md)
- [Device test protocol and current validation status](docs/test-protocol.md)
- [Agent skill](SKILL.md)

## Project principles

- No mass-uninstall loops or blind copy-paste package lists.
- Treat Vivo/iQOO package roles as model-, region-, and firmware-dependent.
- Explain risks and expected side effects before device-changing commands.
- Record test conditions and both successful and failed results.
- Never claim performance gains without measurement.

## License

MIT — see [LICENSE](LICENSE).
