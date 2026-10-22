# Device Test Protocol and Current Validation Status

## Current status

- **XDA research:** reviewed individual posts listed in [research/xda-vivo-iqoo.md](../research/xda-vivo-iqoo.md).
- **Script behavior review:** source checked for read-only inventory first, exactly-one-authorized-device check, per-package typed confirmation, a critical-name stop-list, and no bulk action.
- **PowerShell parser test:** not run in this environment because Windows PowerShell / PowerShell 7 is unavailable.
- **Physical-device test:** not performed. No Vivo/iQOO model or firmware has been certified by this repository.
- **Safety conclusion:** do not treat the helper or any package as proven safe. The helper is conservative by design, but mistakes, firmware-specific dependencies, and PowerShell/ADB differences remain possible.

## Test report template

Copy this section into a new report for each device/build. Do not combine different models or firmware versions into one result.

| Field | Value |
|---|---|
| Device model and region | |
| Android version | |
| Funtouch OS / OriginOS version | |
| Full build number / security patch | |
| ADB version and host OS | |
| Package ID and displayed app name | |
| Package role evidence / links and dates | |
| Initial package state | |
| Backup completed and verified | |
| Action (one package only) | |
| Command output | |
| Reboot completed | |
| Calls / SMS / mobile data | |
| Wi-Fi / Bluetooth | |
| Notifications / push messages | |
| File picker / file sharing | |
| Camera / biometrics / launcher / Settings | |
| App installation / updates / OS updates | |
| Target feature after change | |
| Observation period and measured results | |
| Restore attempted and result | |
| Regressions / limitations | |
| Tester and test date | |

## Minimum test procedure

1. Use a device you own/control; keep a separate personal-data backup.
2. Record device/build details and create the script's read-only audit.
3. Confirm the exact package's identity and purpose using the installed app info and model/build-specific evidence.
4. Prefer disabling one package over uninstalling it. Record the exact command and output.
5. Reboot and test the target feature and all relevant core functions in the table above.
6. If anything breaks, restore immediately and stop further changes.
7. Record both positive and negative outcomes. Do not infer battery or FPS gains without measurements and a repeatable baseline.
8. Only label a package “tested on [exact build]” after a complete report. Do not generalize a result to another firmware.

## Important

ADB package inventory is not a full phone backup. Restore commands may not restore app data, settings, or dependent services. Some failures may require a factory reset or official firmware recovery.
