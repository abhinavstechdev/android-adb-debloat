# Recovery & Troubleshooting

Keep this guide available before making any package change.

## Restore a preinstalled package

If you removed a built-in package for user 0 and the package remains on the device, try:

```bat
adb shell cmd package install-existing --user 0 PACKAGE_NAME
```

Replace the placeholder with the exact package identifier used in the uninstall command.

A successful response means the package was re-enabled / installed for that user according to Android's package manager. Verify the app appears and its functionality works as expected.

This method does not restore every kind of app. It generally cannot reinstall an ordinary user-installed app whose APK is no longer present on the device. Reinstall such apps through a trusted app store or the developer's official source.

## If removal fails

1. Save the complete error message.
2. Confirm the correct phone is connected with `adb devices`.
3. Check whether the package exists using `adb shell pm list packages PACKAGE_NAME`.
4. Recheck the package's purpose and device/firmware compatibility.
5. Stop instead of trying more invasive commands without a specific diagnosis.

## If a feature breaks

1. Stop removing additional packages.
2. Identify the package most recently changed.
3. Try the `install-existing` command above if the package is preinstalled and still available.
4. Reboot only if appropriate after restoration, then test the affected feature.
5. If the problem persists, collect the exact device model, OS version, command output, and observed symptom before deciding the next step.

Do not jump directly to factory reset, bootloader unlocking, root, firmware flashing, or system-partition editing. These are higher-risk operations and are not normal debloat recovery steps.

## USB connection troubleshooting

| Symptom | What to check |
|---|---|
| `adb` is not recognized | Open terminal in Platform Tools directory or configure PATH |
| No device in `adb devices` | Cable, port, USB mode, OEM driver |
| `unauthorized` | Approve the prompt on the unlocked phone |
| Package not found | Verify the exact identifier and device |
| Restore command fails | Preserve error output and confirm package state |

Official documentation: https://developer.android.com/tools/adb
