# Safe Package Evaluation & Removal

ADB can disable an app for Android user 0 or remove its availability for that user without directly deleting its system image. These changes can still break dependent functionality. A successful command is not evidence that the phone remains healthy.

## Risk categories

- **Candidate for testing:** purpose is understood, app is not required for the user's use case, and model/build-specific evidence exists. This is not a guarantee.
- **Model-dependent — investigate:** vendor services, app stores, file-transfer tools, notification services, and unclear packages.
- **Critical — do not remove casually:** telephony, Settings, System UI, launcher, package installer, permission controller, biometrics, emergency functionality, Google Play services, operating-system update components, and unknown vendor services.

## Vivo / iQOO caution list

These are investigation targets, **not safe-removal recommendations**. Names and roles vary by firmware.

| Package identifier | Possible role | Status |
|---|---|---|
| com.vivo.appstore | Vendor app store | Unverified; may affect app distribution or updates |
| com.vivo.easyshare | Device-to-device file transfer | Unverified; may affect file transfer |
| com.vivo.pushservice | Push notification service | Unverified; may affect vendor-app notifications |
| com.iqoo.secure | Security / device-management related on some builds | Unverified; may affect device-management features |

Do not uninstall a package merely because its name looks familiar or because a guide targets a different model.

## Preferred workflow

1. Record exact model, region, Android version, build number, and Funtouch OS / OriginOS version.
2. Create a read-only audit using the Windows helper at scripts/vivo-iqoo-adb-tool.ps1 or the commands in [Windows setup](windows-setup.md).
3. Research the exact package ID and inspect its app label, path, permissions/dependencies where feasible, and model/build-specific reports.
4. Prefer **disable one package** before user-level uninstall. Reboot and test the phone before considering another change.
5. If a feature breaks, restore immediately; do not continue experimenting.
6. Record the result using the [package review template](package-review-template.md).

## Reversal commands

Re-enable a disabled package:

```powershell
adb shell pm enable PACKAGE.ID
```

Restore a package uninstalled only for user 0, if its APK is still available on the device:

```powershell
adb shell pm install-existing --user 0 PACKAGE.ID
```

These commands are not guaranteed to work for every package/build and do not restore app data, settings, or dependencies. A factory reset or firmware reinstall may be required for some failures. Keep a separate backup of personal data.

## Community research and limits

Read [XDA's Vivo X50 discussion about iManager/V-Appstore behavior after an update](https://xdaforums.com/t/how-to-root-unlock-bootloader.4682583/) and [XDA's iQOO Neo 6 report of file-picker issues after ADB package changes](https://xdaforums.com/t/files-from-storage-are-not-being-selected-from-any-browser.4725248/). These are individual reports, not verified universal package verdicts. They illustrate why firmware/build and post-change testing must be documented. See [research notes](../research/xda-vivo-iqoo.md) for the protocol and official ADB references.

## Safety requirements

- Never run an unreviewed bulk uninstall list.
- Never promise that debloating increases FPS, battery life, or performance.
- Never call a package tested-safe without a reproducible test report for the same device/build.
- Keep a before-state inventory and change one package at a time.
- Stop if the device shows boot, calling, notification, storage picker, Settings, launcher, update, or connectivity regressions.
