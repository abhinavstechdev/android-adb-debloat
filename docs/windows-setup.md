# Windows ADB Setup & Package Inventory

This guide covers the initial connection and read-only package discovery workflow for Windows 10 and Windows 11.

## 1. Download Platform Tools

Use the official Google download page:

<https://developer.android.com/tools/releases/platform-tools>

Extract the downloaded ZIP to a stable location, for example:

`C:\platform-tools`

Do not download repackaged ADB binaries from unknown websites.

## 2. Enable USB debugging

On the Android phone:

1. Open **Settings → About phone**.
2. Find **Build number** or the software-version entry. The exact menu differs by manufacturer.
3. Tap the relevant build entry seven times if needed to enable Developer options.
4. Return to Settings, open **Developer options**, and enable **USB debugging**.
5. Connect a data-capable USB cable and unlock the phone.
6. Approve the RSA key prompt for this computer.

Only authorize computers you trust. Revoke debugging authorizations in Developer options when finished if appropriate.

## 3. Open Command Prompt in Platform Tools

Open the extracted folder in File Explorer, click the address bar, type `cmd`, then press Enter.

Verify ADB:

```bat
adb --version
adb devices
```

The device should appear with status `device`.

### Common connection errors

- **No device:** use another data-capable cable or USB port; check the phone's USB mode; install the relevant OEM driver where required.
- **Unauthorized:** unlock the phone and accept the on-device prompt. Do not try to bypass it.
- **Multiple devices:** inspect the output and specify the correct device serial only when necessary. Avoid sharing serial numbers publicly.
- **ADB not recognized:** run commands from the Platform Tools folder or add that folder to the Windows PATH.

## 4. Save package inventories

These commands are read-only:

```bat
adb shell pm list packages > packages.txt
adb shell pm list packages -3
adb shell pm list packages -s
```

- The first command writes a text file on the computer.
- `-3` requests third-party packages.
- `-s` requests system packages.

Filter terms in Command Prompt:

```bat
adb shell pm list packages | findstr /i "vivo iqoo browser weather"
```

This filter only matches package identifiers; it does not prove a match is bloatware.

Check one exact candidate:

```bat
adb shell pm list packages com.example.package
```

The example identifier is a placeholder. Replace it with a package name from your actual inventory.

## 5. Before you remove anything

1. Identify the visible app via Settings → Apps → app details.
2. Confirm its role on the exact model and firmware.
3. Decide whether dependent features matter.
4. Keep the original inventory file.
5. Review the per-package removal command before executing it.

See [Safe Removal](safe-removal.md) and [Recovery](recovery.md).
