# Safe Package Evaluation & Removal Guide (Vivo / iQOO & Android)

Android Debug Bridge (ADB) allows disabling or uninstalled packages for Android user profile 0 without modifying the physical read-only system partition. However, **a successful command exit does not mean the system is unharmed**. Subsystem dependencies, system intent handlers, and security services can silently degrade.

---

## 1. Risk Categories

Every candidate package must be evaluated against three defined tiers before any action is approved:

### Tier 1: Candidate for Testing (Low Risk)

Standalone user-facing bloatware, promotional links, diagnostic loggers, duplicate stores/browsers, and commercial preloads. Removing these rarely causes bootloops or core system failures, though features provided by that specific app will naturally cease to function.

### Tier 2: Medium Risk — Functional Loss / App Dependencies

Features integrated with other OEM apps or services. Disabling them does not cause bootloops, but can lead to loss of specific capabilities (e.g., losing custom lockscreen posters, broken media sharing, loss of split-screen gestures, or lack of push notifications for OEM apps).

### Tier 3: Critical — Do Not Remove Casually (Severe Risk of Bootloop or System Failure)

Components tied to core Android architecture, system navigation, telephony, permission management, or recovery. Disabling or uninstalling these can cause catastrophic failures, bootloops, or force a complete factory reset.

---

## 2. Vivo & iQOO Package Catalog

*Note: Package availability and names vary depending on region (Global/India vs. China), Android version (11 through 15), and interface (Funtouch OS vs. OriginOS). Treat these as documented observations, not universal guarantees.*

### Tier 1: Safe / Low Risk Candidates (Bloatware, Commercial Preloads, Duplicate Utilities)

| Package Identifier | Visible Name / Component | Role & XDA Context | Expected Side Effects |
| --- | --- | --- | --- |
| `com.vivo.browser` / `com.android.browser` | Vivo Browser | Stock OEM internet browser. Frequently targeted on XDA. | Default browser defaults to Chrome or user-selected browser. |
| `com.vivo.assistant` | Jovi Assistant / Smart Scene | Built-in smart assistant suggestions and cards. | Jovi smart assistant prompts disabled. Google Assistant unaffected. |
| `com.vivo.hiboard` | Jovi Home / HiBoard | Left-most home screen widget feed (negative-one screen). | Left swipe on default launcher becomes inactive or hides. |
| `com.bbk.cloud` / `com.bbk.cloud.overlay` | Vivo Cloud | Cloud backup for contacts, notes, and photos. | Vivo cloud backup stops. Google Drive / Photos unaffected. |
| `com.bbk.account` / `com.bbk.account.overlay` | Vivo Account | Account management for Vivo ecosystem services. | Cannot sign into Vivo ID / cloud services. |
| `com.vivo.globalsearch` | Global Search | Pull-down local search for apps, contacts, and web. | Swipe down on home screen for global search disabled. |
| `com.vivo.magazine` | Lockscreen Poster | Dynamic lock screen wallpaper rotation and ads. | Lockscreen shows static default wallpaper only. |
| `com.vivo.demovideo` | Demo Video | Built-in retail store demonstration video loop. | None on consumer devices; frees minor space. |
| `com.yozo.vivo.office` | Vivo Doc Reader / Yozo Office | Bundled document viewer for Office and PDF files. | Use Google Docs, Microsoft 365, or WPS Office instead. |
| `com.vivo.feedback` | Feedback App | User feedback, bug submission tool to Vivo servers. | Cannot submit diagnostic feedback directly to Vivo. |
| `com.vivo.Tips` | Tips & Tutorials | First-time user tutorial guides and tips. | None. |
| `com.vivo.website` / `com.iqoo.website` | Brand Portal Shortcut | Desktop shortcut opening official brand web store. | Web shortcut removed from launcher. |
| `com.vivo.doubletimezoneclock` | Dual Timezone Widget | Home screen clock widget showing dual time zones. | Clock widget disappears from widget selection menu. |
| `com.vivo.favorite` | Jovi Favorites | System bookmarking service for articles and media. | Favorite card bookmarks within Jovi disabled. |
| `com.vlife.vivo.wallpaper` | Live Wallpaper Engine | Bundled live/animated wallpaper packages. | Animated stock wallpapers unavailable; third-party live wallpapers work. |
| `com.bbk.iqoo.logsystem` / `com.android.bbklog` | System Log Collector | Internal bug reporting and crash log aggregator. | Background diagnostic logging stops; saves battery and memory. |
| `com.facebook.appmanager` | Meta App Manager | Facebook background updater and install tracker. | Facebook background analytics stopped. |
| `com.facebook.services` | Meta App Services | Facebook background synchronization services. | Meta background telemetry stopped. |
| `com.facebook.system` | Meta System Installer | Pre-installed Facebook installer stub. | None; prevents automatic background Meta updates. |
| `com.netflix.partner.activation` | Netflix Activation Stub | Pre-installed partner activation provider. | None. User can still install and run Netflix from Play Store. |

### Tier 2: Medium Risk Candidates (Functional Loss / Needs Explicit Approval)

| Package Identifier | Visible Name / Component | Role & XDA Context | Expected Side Effects |
| --- | --- | --- | --- |
| `com.vivo.appstore` / `com.bbk.appstore` | V-Appstore | Official OEM App Store. | **Caution:** While removing it is common to stop notifications, on some firmware, stock camera and album app updates are distributed through V-Appstore rather than Play Store. |
| `com.vivo.easyshare` | EasyShare | Device-to-device migration and Wi-Fi file transfer. | EasyShare phone clone and file transfer unavailable. Use Nearby Share / Quick Share instead. |
| `com.vivo.pushservice` | Vivo Push Service | Vendor push notification notification dispatcher. | May delay or drop push notifications for Chinese or OEM apps that rely on Vivo Push rather than Google FCM. |
| `com.vivo.game` | Game Center / Game Space | Gaming dashboard, overlay, and optimization toggles. | In-game shortcut bar, 4D vibration, and performance modes disabled. |
| `com.vivo.notes` | Vivo Notes | Stock notes application. | **Warning:** User notes must be backed up first before removal. |
| `com.vivo.doubleinstance` | App Clone | Dual instance feature for WhatsApp, Instagram, etc. | Cannot run two copies of cloned social apps. |
| `com.vivo.smartshot` | Super Screenshot | Long screenshot, screen recorder, and shaped snips. | Quick settings screenshot panel replaced by stock Android screenshot. |
| `com.vivo.smartmultiwindow` | Split Screen Helper | Floating window and multi-window gesture helper. | Gestures to trigger split screen may become unresponsive. |
| `com.vivo.fuelsummary` | Battery / Fuel Summary | Battery usage stats and hardware power consumption. | Detailed per-app battery graph in Settings may reset or glitch. |
| `com.vivo.gallery` | Stock Album / Gallery | Default photo and video gallery viewer. | **Warning:** Do not remove unless a third-party gallery (like Google Photos) is installed and set as default. Can break camera shutter preview. |
| `com.vivo.pem` | Power Expense Management | Deep sleep and aggressive background RAM management. | Advanced tweak discussed on XDA. Restores stock Android background behavior but can slightly affect standby battery life. |

### Tier 3: Critical Guardrails — DO NOT REMOVE CASUALLY (Bootloop & System Failure Risk)

| Package Identifier | Visible Name / Component | Why It Must Be Protected |
| --- | --- | --- |
| `com.vivo.launcher` | Vivo Home / Default Launcher | **Severe Bootloop Risk:** Removing or disabling without an active, verified third-party launcher (set as default Home) causes immediate bootloop or black screen on reboot. |
| `com.vivo.upslide` | Gesture Navigation / Control Center | **Navigation Failure:** Manages swipe-up navigation gestures and the recent apps multitasking view on Funtouch OS. Removing it breaks gesture navigation. |
| `com.iqoo.secure` / `com.vivo.safecenter` / `com.vivo.imanager` | iManager / Security Center | **System Dependency:** Removing breaks status bar network speed indicator, and on many builds breaks runtime permission prompt dialogues and package installer security popups. |
| `com.android.documentsui` | Android Documents UI | **File Picker Failure (XDA 4725248):** Removing breaks the system storage picker, causing browsers (Chrome, Brave) and apps to freeze when selecting or uploading files. |
| `com.google.android.gms` | Google Play Services | Core runtime framework for push notifications, Google accounts, Play Store, location, and banking apps. |
| `com.android.systemui` | System UI | Status bar, notifications shade, lock screen, and navigation bar. |
| `com.android.settings` | Android Settings | Core device configuration menu and connectivity toggles. |
| `com.android.phone` / `com.android.server.telecom` | Telephony / Phone Services | SIM card communication, mobile calls, SMS, and emergency dialer. |
| `com.google.android.packageinstaller` / `com.android.packageinstaller` | Package Installer | Handles installation and uninstallation of APK files. |

---

## 3. Handling Funtouch OS Restriction Errors

When running ADB commands on Funtouch OS 12, 13, 14, or 15, you may encounter:

```text
Failure [DELETE_FAILED_USER_RESTRICTED]
```

or

```text
java.lang.SecurityException: Cannot disable a protected package
```

### Why this happens

Vivo's OEM implementation incorporates strict enterprise device policies (`UserManager.DISALLOW_APPS_CONTROL`). The OEM has flagged these specific packages as protected.

### Recommended Safety Protocol

1. **Never force-delete protected packages blindly:** If Android returns `DELETE_FAILED_USER_RESTRICTED`, do not attempt raw, unverified binder transaction commands unless you are on a test device with confirmed firmware transaction numbers.
2. **Attempt reversible disabling:**

   ```powershell
   adb shell pm disable-user --user 0 PACKAGE.ID
   ```

3. **If disabling is blocked:**
   - Stop and leave the package alone.
   - Revoke unwanted app permissions (Camera, Location, Contacts, Notifications) via **Settings → Apps**.
   - Restrict background battery usage in **Settings → Battery → Background power consumption management**.

---

## 4. Preferred Step-by-Step Workflow

1. **Audit First:** Generate a full read-only snapshot using `scripts/vivo-iqoo-adb-tool.ps1` (Option 1).
2. **One Change at a Time:** Never use batch loops. Evaluate a single candidate package.
3. **Prefer Disable Over Uninstall:** Disabling is 100% reversible and avoids registry corruption.
4. **Reboot and Verify:** Reboot the phone after a package change and verify core functions:
   - Voice calls and SMS (send and receive)
   - Wi-Fi, Mobile Data, and Bluetooth
   - Push notifications
   - File picker in web browser (upload a photo/file)
   - Camera and gallery preview
   - Swipe gestures and recent apps multitasking
   - Settings and Developer Options
5. **Restore if Anything Regresses:** If an issue arises, restore the package immediately.

---

## 5. Reversal Commands

### To Re-enable a Disabled Package

```powershell
adb shell pm enable PACKAGE.ID
```

### To Restore an App Uninstalled for User 0

```powershell
adb shell cmd package install-existing --user 0 PACKAGE.ID
```

*Note: These commands re-link the existing system image APK. They cannot recover user app data or settings that were cleared.*
