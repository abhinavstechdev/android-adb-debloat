# Safe Package Evaluation & Removal

ADB can remove an app from a particular Android user without directly deleting its system image. This can be easier to reverse than modifying protected system partitions, but package removal can still break dependent functionality.

## Risk categories

### Likely optional

Use this classification only when the package's purpose and optional status are clear on the user's exact device. Examples may include a redundant browser, tips app, weather app, or promotional application.

### Model-dependent — investigate

Use for vendor services, preinstalled app stores, file-transfer tools, notification services, or packages with unclear dependencies. Identify the exact app and inspect credible model-specific evidence before considering removal.

### Critical — do not remove casually

Examples include telephony, Settings, System UI, launcher, package installer, permission controller, biometrics, emergency functionality, Google Play services, operating-system update components, and unknown vendor services.

## Vivo / iQOO caution list

The following are **not universal safe-removal recommendations**:

| Package identifier | Possible role | Why to investigate |
|---|---|---|
| `com.vivo.appstore` | Vendor app store | May affect app distribution or updates |
| `com.vivo.easyshare` | Device-to-device file transfer | May disable a transfer feature |
| `com.vivo.pushservice` | Push notification service | May affect notifications or vendor apps |
| `com.iqoo.secure` | Security / iManager-related component on some builds | May affect device management or security features |

Presence and purpose can vary by firmware. Do not remove a package merely because its name looks familiar or because a guide for another phone recommends it.

## Controlled removal procedure

First, verify the package exists and identify its visible app name. After reviewing the side effects and approving the change, execute **one** command:

```bat
adb shell pm uninstall --user 0 PACKAGE_NAME
```

Replace `PACKAGE_NAME` with the exact package identifier. Do not include angle brackets or paste a placeholder directly.

Do not use bulk loops, wildcards, or scripts that uninstall an entire guessed package list. Check the result, test relevant phone features, and only then consider another package.

### What this command means

- `adb shell` runs a command on the connected Android device.
- `pm uninstall` requests package removal for the specified user.
- `--user 0` targets Android user 0, commonly the primary phone user.

This normally does **not** delete the app from the system partition. It may not be appropriate for every package, and some system components should not be removed.

## Verification after each change

Test the feature associated with the removed app, plus any related notifications, settings, updates, sharing, security, or gaming functions. If an unexpected problem appears, stop and consult [Recovery](recovery.md).

## Performance expectations

Debloating can reduce clutter and may reduce activity from selected apps, but it is not a guaranteed FPS, battery, memory, or thermal optimization. Measure changes on the actual device instead of relying on blanket claims.
