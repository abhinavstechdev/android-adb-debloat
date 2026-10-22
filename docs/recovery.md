# Recovery & Troubleshooting Guide (Vivo / iQOO & Android)

Keep this reference open whenever evaluating or executing ADB package changes.

---

## 1. Quick Reversal Reference

### A. Re-enable a Disabled Package

If a package was disabled using `pm disable-user --user 0`:

```bat
adb shell pm enable PACKAGE.ID
```

Expected output: `Package PACKAGE.ID new state: enabled`.

### B. Restore a User-0 Uninstalled Package

If a built-in pre-installed package was removed with `pm uninstall -k --user 0`:

```bat
adb shell cmd package install-existing --user 0 PACKAGE.ID
```

Expected output: `Package PACKAGE.ID installed for user: 0`.

*Limitations:* This command re-links the read-only APK from the physical `/system` or `/vendor` partition. It **cannot restore personal app data, cached databases, or third-party apps that were not preloaded in firmware**.

---

## 2. Solutions for Specific Regressions Documented on XDA

### Scenario A: Web Browser Freezes on File Selection / Upload

* **Symptoms:** Clicking "Attach File," "Choose File," or "Upload Photo" in Chrome, Brave, WhatsApp, or banking apps causes the app to freeze, crash, or show an empty dialog.
* **Root Cause (XDA Thread 4725248):** Accidental disabling or removal of Android's storage documents provider (`DocumentsUI`).
* **Fix Command:**

  ```bat
  adb shell cmd package install-existing --user 0 com.android.documentsui
  adb shell pm enable com.android.documentsui
  ```

  After restoring, reboot the phone and test uploading a photo in your browser.

### Scenario B: Swipe-Up Gestures or Recent Apps Switcher Fails

* **Symptoms:** Swiping up from the bottom of the screen does not return to Home or fails to open the multitasking Recent Apps list.
* **Root Cause:** Removal or disabling of Vivo's navigation gesture service (`com.vivo.upslide`).
* **Fix Command:**

  ```bat
  adb shell cmd package install-existing --user 0 com.vivo.upslide
  adb shell pm enable com.vivo.upslide
  ```

  Reboot the phone to rebind gesture event hooks.

### Scenario C: Permission Prompt Dialogs or App Installer Hangs

* **Symptoms:** Newly installed apps cannot prompt for runtime permissions (Camera, Storage, Microphone), or clicking an APK in File Manager shows a blank screen.
* **Root Cause:** Removal or disabling of Vivo/iQOO Security Center (`com.iqoo.secure`, `com.vivo.safecenter`, or `com.vivo.imanager`).
* **Fix Command:**

  ```bat
  adb shell cmd package install-existing --user 0 com.iqoo.secure
  adb shell pm enable com.iqoo.secure
  adb shell cmd package install-existing --user 0 com.vivo.safecenter
  adb shell pm enable com.vivo.safecenter
  adb shell cmd package install-existing --user 0 com.vivo.imanager
  adb shell pm enable com.vivo.imanager
  ```

### Scenario D: Streaming Audio or Video Spontaneously Pauses

* **Symptoms:** YouTube, Spotify, or media playback pauses randomly every few minutes.
* **Root Cause:** Aggressive removal of power management or background task scheduling daemons (`com.vivo.pem` or multimedia daemons).
* **Fix Command:**

  ```bat
  adb shell cmd package install-existing --user 0 com.vivo.pem
  adb shell pm enable com.vivo.pem
  ```

---

## 3. Resolving `DELETE_FAILED_USER_RESTRICTED` & `SecurityException`

If a package command exits with:

```text
Failure [DELETE_FAILED_USER_RESTRICTED]
```

or

```text
java.lang.SecurityException: Cannot disable a protected package
```

1. **Do not attempt raw binder injections blindly:** Calling `adb shell service call package ...` with unverified transaction IDs risks kernel panics or invoking unintended methods.
2. **Diagnosis:** The firmware has enforced an OEM security flag on that specific package.
3. **Safe Workaround:**
   * Leave the package installed.
   * Go to **Settings → Apps → [App Name]**.
   * Tap **Permissions** and revoke all granted permissions (Camera, Location, Contacts, Microphone, Files).
   * Turn off **Allow background activity** in **Settings → Battery**.
   * Turn off notifications in **Settings → Notifications**.
   * The app remains frozen and dormant without violating system integrity.

---

## 4. Emergency Bootloop Recovery (Locked Bootloaders)

Because modern Vivo and iQOO devices have **permanently locked bootloaders** without Fastboot flashing capabilities, a bootloop requires specific emergency handling:

### Step 1: Check if ADB Responds During Boot

Sometimes during the boot sequence, the ADB daemon initializes for 10–30 seconds before the crash happens:

1. Keep the phone plugged into your PC with a Command Prompt running:

   ```bat
   adb devices
   ```

2. If the device appears as `device`, immediately run the restore command for the last package changed:

   ```bat
   adb shell cmd package install-existing --user 0 LAST_PACKAGE_NAME
   adb shell pm enable LAST_PACKAGE_NAME
   ```

3. If this completes, force reboot with `adb reboot`.

### Step 2: Stock Recovery Mode (Last Resort)

If ADB cannot connect and the phone continuously reboots:

1. Disconnect the USB cable and power off the phone (hold Power + Volume Down or Power + Volume Up for 10–15 seconds until the screen goes black).
2. Press and hold **Power + Volume Up** simultaneously until the **Fastboot / Recovery** screen appears.
3. Use the Volume keys to navigate to **Recovery Mode** and press the Power button to select.
4. In Vivo Stock Recovery, select **Clear Data** → **Clear all data**.
5. Confirm the action. This restores the phone to factory state with all preinstalled system packages active.
6. Select **Restart phone**.

---

## 5. Connection Troubleshooting Matrix

| Issue | Probable Cause | Action |
| --- | --- | --- |
| `adb : The term 'adb' is not recognized` | ADB is not in system PATH or current directory. | Run commands from the `platform-tools` folder or add it to Windows PATH. |
| `adb devices` shows empty list | USB debugging off, bad cable, or wrong USB mode. | Set USB connection mode to **File Transfer (MTP)** on the phone; try another port or cable. |
| `adb devices` shows `unauthorized` | Computer RSA key prompt not approved on phone. | Unlock the phone screen, check "Always allow from this computer," and tap **Allow**. |
| Package not found | Typo in package identifier or already uninstalled. | Run `adb shell pm list packages \| findstr /i "keyword"` to verify the exact ID. |
| `Failure [not installed for 0]` | Package was already uninstalled for user 0. | Run `adb shell cmd package install-existing --user 0 <pkg>` to restore. |
