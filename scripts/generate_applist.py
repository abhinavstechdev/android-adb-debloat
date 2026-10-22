import subprocess
import sys
import os
import re

ADB_PATH = r"C:\platform-tools\adb.exe"

def run_adb(cmd):
    full_cmd = [ADB_PATH, "shell"] + cmd.split()
    res = subprocess.run(full_cmd, capture_output=True, text=True, encoding="utf-8", errors="ignore")
    return res.stdout.strip()

def get_package_list(cmd):
    output = run_adb(cmd)
    pkgs = set()
    for line in output.splitlines():
        line = line.strip()
        if line.startswith("package:"):
            pkgs.add(line[8:].strip())
    return pkgs

# Human readable name dictionary for common packages
NAME_MAP = {
    # AI & Productivity
    "com.openai.chatgpt": ("ChatGPT", "AI Assistant by OpenAI"),
    "ai.perplexity.app.android": ("Perplexity AI", "Perplexity AI Search"),
    "ai.perplexity.comet": ("Perplexity Comet", "Perplexity Comet Assistant"),
    "ai.x.grok": ("Grok", "Grok AI by xAI"),
    "com.deepseek.chat": ("DeepSeek", "DeepSeek AI Assistant"),
    "com.moonshot.kimichat": ("Kimi AI", "Moonshot Kimi Chat"),
    "com.moonshot.kimiclaw": ("Kimi Claw", "Kimi AI Automation"),
    "com.tongyi.intl": ("Qwen / Tongyi", "Alibaba Tongyi / Qwen AI"),
    "ai.qwenlm.chat.android": ("Qwen Chat", "Qwen Language Model Client"),
    "com.google.android.apps.bard": ("Google Gemini", "Google Gemini AI Assistant"),
    "com.google.android.apps.labs.language.tailwind": ("NotebookLM / Tailwind", "Google Labs AI Notebook"),
    "com.google.android.apps.labs.whisk": ("Google Labs Whisk", "Google Labs Experimental App"),
    "com.wispr.flowapp": ("Flow", "Voice-to-Text Productivity"),
    "md.obsidian": ("Obsidian", "Markdown Knowledge Base & Notes"),
    "com.canva.editor": ("Canva", "Graphic Design & Publishing"),
    "com.adobe.scan.android": ("Adobe Scan", "PDF Document Scanner"),
    "com.hassaneltantawy.sqliteviewer": ("SQLite Viewer", "Database Inspection Tool"),
    "com.devx_foxtale_app": ("Foxtale", "Productivity / Utility"),

    # Social & Messaging
    "com.whatsapp": ("WhatsApp", "Instant Messaging by Meta"),
    "org.telegram.messenger": ("Telegram", "Cloud-based Messaging"),
    "ir.ilmili.telegraph": ("Telegraph", "Telegram Client / Mod"),
    "com.twitter.android": ("X (formerly Twitter)", "Social Networking"),
    "xyz.blueskyweb.app": ("Bluesky", "Decentralized Social Network"),
    "com.instagram.barcelona": ("Threads", "Threads by Instagram"),
    "com.instagram.basel": ("Instagram Basel", "Internal / Beta Instagram Client"),
    "com.reddit.frontpage": ("Reddit", "Discussion Communities"),
    "com.discord": ("Discord", "Voice & Chat Gaming Communities"),
    "com.snapchat.android": ("Snapchat", "Multimedia Messaging"),
    "com.pinterest": ("Pinterest", "Visual Discovery Engine"),
    "ellipi.messenger": ("Element / Ellipi", "Matrix Decentralized Chat"),
    "com.snowcorp.stickerly.android": ("Sticker.ly", "Sticker Maker for WhatsApp"),
    "com.facebook.katana": ("Facebook", "Social Media"),
    "com.facebook.viewpoints": ("Meta Viewpoints", "Meta Research / Survey App"),

    # Browsers & Utilities
    "com.brave.browser": ("Brave Browser", "Privacy-focused Web Browser"),
    "com.opera.browser": ("Opera Browser", "Web Browser with VPN"),
    "com.android.chrome": ("Google Chrome", "Standard Google Web Browser"),
    "hub.browser.video.downloader.saver": ("Video Downloader Hub", "Media Saver & Downloader"),
    "com.snaptube.premium": ("SnapTube Premium", "Video & Audio Downloader"),
    "io.github.xiaoyouchr.ghostdownloader": ("Ghost Downloader", "Media Downloader Utility"),
    "com.utorrent.client": ("µTorrent", "BitTorrent Client"),
    "pl.solidexplorer2": ("Solid Explorer", "Dual-pane File Manager"),
    "ru.zdevs.zarchiver": ("ZArchiver", "Archive Manager (Zip, 7z, Rar)"),
    "ru.zdevs.zarchivercloud": ("ZArchiver Cloud", "ZArchiver Cloud Storage Plugin"),
    "org.localsend.localsend_app": ("LocalSend", "Cross-platform Local File Sharing"),
    "com.yablio.sendfilestotv": ("Send Files to TV", "Local Network File Transfer"),
    "moe.shizuku.privileged.api": ("Shizuku", "Elevated ADB Permission Bridge"),
    "com.wuliang.xapkinstaller": ("XAPK Installer", "APK/XAPK Package Installer"),
    "com.ytheekshana.deviceinfo": ("Device Info", "Hardware & System Diagnostics"),
    "com.starnest.arruler.ruler": ("AR Ruler", "Augmented Reality Tape Measure"),
    "ru.tech.imageresizershrinker": ("Image Toolbox", "Image Resizer & Shrinker"),
    "com.camerasideas.instashot": ("InShot Video Editor", "Mobile Video Editing Tool"),
    "com.wallpaperscraft.wallpaper": ("Wallcraft", "HD Wallpapers"),
    "com.sparkine.muvizedge": ("Muviz Edge", "Audio Visualizer & Edge Lighting"),
    "timeshunt.malayalam.calendar": ("Malayalam Calendar", "Regional Calendar Utility"),

    # Developer & Coding
    "com.termux": ("Termux", "Linux Terminal Emulator for Android"),
    "com.server.auditor.ssh.client": ("Termius", "SSH & Telnet Client"),
    "com.venter.hopweb": ("HopWeb", "HTML/CSS/JS IDE"),
    "com.foxdebug.acodefree": ("Acode", "Code & Text Editor"),
    "com.fazil.htmleditor": ("HTML Editor", "Web Development Editor"),
    "io.spck": ("Spck Editor", "Mobile Code Editor / Git Client"),
    "ru.iiec.pydroid3": ("Pydroid 3", "Python 3 IDE for Android"),
    "ru.iiec.pydroid3.quickinstallrepo": ("Pydroid Repo Plugin", "Python Package Repository Plugin"),
    "com.kvassyu.coding.py": ("Coding Python", "Python Learning & Coding Tool"),
    "bin.mt.plus": ("MT Manager", "Advanced APK Editor & Reverse Engineering Tool"),
    "bin.mt.termex": ("MT Termex", "Terminal Utility for MT Manager"),
    "juloo.keyboard2": ("Unexpected Keyboard", "Programmer Keyboard with Symbols"),

    # VPN & Networking
    "free.vpn.unblock.proxy.turbovpn": ("Turbo VPN", "Free Proxy & VPN"),
    "com.security.xvpn.z35kb": ("X-VPN", "Proxy & VPN Service"),
    "net.openvpn.openvpn": ("OpenVPN Connect", "OpenVPN Client"),
    "com.cloudflare.onedotonedotonedotone": ("1.1.1.1 + WARP", "Cloudflare DNS & WARP"),
    "com.privatevpn.internetaccess": ("PrivateVPN", "VPN Client"),
    "com.unlimited.hotspot.vpnbrazil.secure.proxy": ("Brazil VPN Proxy", "VPN Service"),

    # Gaming & Entertainment
    "com.dts.freefiremax": ("Free Fire MAX", "Battle Royale Game by Garena"),
    "com.pubg.imobile": ("BGMI (Battlegrounds Mobile India)", "Battle Royale Game by Krafton"),
    "com.supercell.clashroyale": ("Clash Royale", "PvP Strategy Game by Supercell"),
    "nullsroyale.rel.free": ("Null's Royale", "Private Server Clash Royale"),
    "com.activision.callofduty.shooter": ("Call of Duty: Mobile", "FPS Game by Activision"),
    "com.king.candycrushsaga": ("Candy Crush Saga", "Match-3 Puzzle Game by King"),
    "com.chess": ("Chess.com", "Online Chess"),
    "com.riotgames.mobile.leagueconnect": ("Riot Mobile", "League of Legends Companion"),
    "com.valvesoftware.android.steam.community": ("Steam Mobile", "Valve Steam Community App"),
    "com.xiaoji.egggame": ("Egg NS Emulator", "Console Game Emulator"),
    "com.appsomniacs.mmc": ("Mini Militia", "Classic 2D Multiplayer Shooter"),
    "com.maximko.cuber": ("Cube Solver", "Rubik's Cube Solver"),
    "com.vitastudio.mahjong": ("Vita Mahjong", "Tile Matching Game"),
    "com.block.juggle": ("Block Juggle", "Arcade Casual Game"),

    # Media & Streaming
    "org.videolan.vlc": ("VLC Media Player", "Open Source Media Player"),
    "com.dywx.larkplayer": ("Lark Player", "Offline Music & Video Player"),
    "com.ttee.leeplayer": ("Lee Player", "Video Playback Tool"),
    "tv.accedo.airtel.wynk": ("Wynk Music", "Music Streaming by Airtel"),
    "in.startv.hotstar": ("Disney+ Hotstar", "Movies & Live Sports Streaming"),
    "com.prism.live": ("PRISM Live Studio", "Live Broadcasting & Streaming Studio"),
    "com.shazam.android": ("Shazam", "Music Recognition by Apple"),
    "com.vidiq.app": ("vidIQ", "YouTube SEO & Analytics Tool"),

    # Shopping, Food & Travel
    "in.amazon.mShop.android.shopping": ("Amazon Shopping", "E-Commerce Shopping App"),
    "com.flipkart.android": ("Flipkart", "E-Commerce Online Shopping"),
    "in.swiggy.android": ("Swiggy", "Food Delivery & Dining"),
    "in.swiggy.android.toing": ("Swiggy Toing / Dineout", "Swiggy Dining & Offers"),
    "in.swiggy.android.instamart": ("Swiggy Instamart", "Quick Grocery Delivery"),
    "com.zeptoconsumerapp": ("Zepto", "10-Minute Grocery Delivery"),
    "com.grofers.customerapp": ("Blinkit (Grofers)", "Quick Grocery Delivery"),
    "com.application.zomato": ("Zomato", "Food Delivery & Restaurants"),
    "com.done.faasos": ("EatSure (Faasos)", "Food Ordering App"),
    "com.ubercab.uberlite": ("Uber Lite", "Ride Sharing App"),
    "in.redbus.android": ("redBus", "Bus & Train Ticket Booking"),
    "com.whereismytrain.android": ("Where is my Train", "Live Train Status & Offline Schedules"),
    "com.magicpin.local": ("magicpin", "Local Savings & Rewards"),
    "com.cashkaro": ("CashKaro", "Cashback & Coupon App"),
    "com.earnkaro": ("EarnKaro", "Deal Sharing & Affiliate App"),

    # Finance & Crypto
    "com.google.android.apps.nbu.paisa.user": ("Google Pay (GPay)", "UPI & Digital Payments"),
    "com.paypal.android.p2pmobile": ("PayPal", "International Payments"),
    "io.metamask": ("MetaMask", "Web3 Ethereum Crypto Wallet"),
    "pro.bingx.app": ("BingX", "Crypto Trading Exchange"),
    "pro.bingbon.app": ("BingX Pro", "Crypto Trading Exchange Pro"),
    "com.cryptomus.bundle": ("Cryptomus", "Cryptocurrency Payment Gateway"),
    "com.app.speedwallet": ("Speed Wallet", "Bitcoin Lightning Wallet"),
    "io.swashapp.mobile": ("Swash", "Data Monetization App"),
    "com.iproyal.android": ("IPRoyal Pawns", "Passive Income / Bandwidth Share"),
    "io.carv.mobileapp": ("CARV", "Web3 Gaming Identity & Data"),
    "com.rs.mirae": ("Mirae Asset m.Stock", "Stock Trading & Demat Account"),
    "com.iexceed.appzillon.ippbMB": ("IPPB Mobile Banking", "India Post Payments Bank"),
    "com.aistudio.quickbill.abcd": ("QuickBill", "Invoicing & Billing Tool"),
    "com.aistudio.quickshare.xwqt": ("QuickShare Tool", "Utility File Sharing"),

    # Government & Identity
    "in.gov.uidai.mAadhaarPlus": ("mAadhaar", "Official UIDAI Aadhaar Digital Identity"),
    "com.digilocker.android": ("DigiLocker", "Government Document Wallet"),
    "com.prasarbharati.android": ("Prasar Bharati News", "Official Indian Public Broadcaster"),
    "com.myairtelapp": ("Airtel Thanks", "Telecom & Utility Recharges"),
    "com.motorola.motobuds": ("Moto Buds", "Earbuds Companion App"),
    "com.motorola.mobiledesktop": ("Ready For / Mobile Desktop", "Desktop Mode Bridge"),
    "tech.butterfly.app": ("Butterfly App", "Community & Social App"),
    "com.whop.whopapp": ("Whop", "Creator Marketplace & Community"),
    "com.timbuktu": ("Timbuktu", "Utility / Community App"),
}

# Vivo / Funtouch OS specific mapping
VIVO_MAP = {
    "com.vivo.browser": ("Vivo Browser", "Stock Vivo Web Browser (Debloated)"),
    "com.vivo.browser.overlay": ("Vivo Browser Overlay", "Theme Overlay for Browser (Debloated)"),
    "com.facebook.appmanager": ("Meta App Manager", "Facebook Telemetry & Update Stub (Debloated)"),
    "com.facebook.services": ("Meta Services", "Facebook Background Service (Debloated)"),
    "com.facebook.system": ("Meta System Installer", "Facebook Background Installer (Debloated)"),
    "com.yozo.vivo.office": ("Yozo Office", "Bundled Office Document Viewer (Debloated)"),
    "com.yozo.vivo.office.overlay": ("Yozo Office Overlay", "Yozo Office Theme Resources (Debloated)"),
    "com.vivo.unionpay": ("China UnionPay", "UnionPay Payment Plugin (Debloated)"),
    "com.vivo.doubletimezoneclock": ("Dual Timezone Clock", "Clock Widget (Debloated)"),
    "com.bbk.iqoo.logsystem": ("iQOO Log System", "Diagnostic Bug & Telemetry Collector (Debloated)"),
    "com.android.bbklog": ("BBK Log Daemon", "OEM Error Logging Tool (Debloated)"),
    "com.vivo.Tips": ("Vivo Tips", "Promotional Tutorials & Tips (Debloated)"),
    "com.vivo.feedback": ("Vivo Feedback", "Diagnostic Feedback Reporter (Debloated)"),
    "com.vivo.nps": ("Vivo NPS", "Net Promoter Score Daemon (Debloated)"),
    "com.vivo.nps.overlay": ("Vivo NPS Overlay", "NPS Resources (Debloated)"),
    "com.vivo.livewallpaper.ocean": ("Ocean Live Wallpaper", "Stock Live Wallpaper (Debloated)"),
    "com.vivo.livewallpaper.oceanvertical": ("Vertical Ocean Wallpaper", "Stock Live Wallpaper (Debloated)"),
    "com.vivo.livewallpaper.plant": ("Plant Live Wallpaper", "Stock Live Wallpaper (Debloated)"),
    "com.vivo.livewallpaper.behavior": ("Behavior Live Wallpaper", "Behavior Animation Engine (Debloated)"),
    "com.vivo.livewallpaper.behaviormountain": ("Mountain Live Wallpaper", "Mountain Live Wallpaper (Debloated)"),
    "com.bbk.cloud.overlay": ("Vivo Cloud Overlay", "Cloud Theme Resources (Debloated)"),
    "com.bbk.account.overlay": ("BBK Account Overlay", "Account Theme Resources (Debloated)"),
    "android.autoinstalls.config.vivo.devices": ("Vivo Auto-Installs", "Carrier/Partner Auto-Install Stub (Debloated)"),
    "com.vivo.floatingball": ("Easy Touch / Floating Ball", "Screen Navigation Shortcut (Debloated)"),

    # Protected & Core Vivo Apps
    "com.vivo.imanager": ("iManager", "Vivo System Optimizer, Security & Battery Center"),
    "com.vivo.gallery": ("Vivo Album / Gallery", "Stock Photo & Video Viewer"),
    "com.vivo.globalsearch": ("Vivo Global Search", "Swipe-down Device & Web Search Bar"),
    "com.bbk.cloud": ("Vivo Cloud", "Vivo Cloud Sync & Backup Service"),
    "com.bbk.account": ("Vivo Account", "BBK / Vivo User Profile Account"),
    "com.vivo.assistant": ("Jovi / Vivo Assistant", "Vivo AI Assistant Framework"),
    "com.vivo.assistantfunction": ("Jovi Assistant Functions", "Voice & Smart Scene Plugin"),
    "com.vivo.hiboard": ("Jovi Home / HiBoard", "-1 Screen Left Shelf Cards"),
    "com.vivo.magazine": ("Lockscreen Poster / Magazine", "Dynamic Lockscreen Wallpapers"),
    "com.vivo.game": ("Vivo Game Center", "Game Launcher & Store"),
    "com.vivo.gamecube": ("Ultra Game Mode", "In-game Performance & Shortcut Overlay"),
    "com.vivo.gamepad": ("Vivo Gamepad", "Game Controller Driver Support"),
    "com.vivo.gamewatch": ("Vivo Game Watch", "Game Monitoring Daemon"),
    "com.vivo.easyshare": ("EasyShare", "Vivo File Transfer & Phone Clone"),
    "com.vivo.appstore": ("V-Appstore", "Vivo Official Application Store"),
    "com.vivo.smartshot": ("S-capture / Smartshot", "Enhanced Screenshot & Screen Recorder"),
    "com.vivo.soundrecorder": ("Sound Recorder", "Built-in Voice Recording App"),
    "com.vivo.videoeditor": ("Vivo Video Editor", "Stock Gallery Video Editing Tool"),
    "com.vivo.weather": ("Vivo Weather", "Stock Weather Forecast Widget & App"),
    "com.vivo.notes": ("Vivo Notes", "Stock Note-taking & Memo Application"),
    "com.vivo.tws.vivotws": ("Vivo TWS Companion", "Bluetooth Earbuds Management"),
    "com.vivo.vtouch": ("Vivo Touch / Gestures", "Touch Gestures & System Input Engine"),
    "com.vivo.fingerprintui": ("In-Display Fingerprint UI", "Optical Fingerprint Scanner Animation"),
    "com.vivo.fingerprintvit": ("Fingerprint VIT Service", "Biometric Authentication Service"),
    "com.vivo.nightpearl": ("Always On Display (AOD)", "AOD Clock & Graphic Styles"),
    "com.vivo.desktopstickers": ("Desktop Stickers", "Home Screen Widget Engine"),
    "com.vivo.fuelsummary": ("Battery Fuel Gauge", "Battery Statistics Engine"),
    "com.bbk.SuperPowerSave": ("Super Power Saver", "Ultra Battery Saver Launcher"),
}

print("Querying device via ADB...")
active_pkgs = get_package_list("pm list packages")
third_party_pkgs = get_package_list("pm list packages -3")
system_pkgs = get_package_list("pm list packages -s")
disabled_pkgs = get_package_list("pm list packages -d")
all_with_uninstalled = get_package_list("pm list packages -u")

# Debloated (uninstalled for user 0) = in uninstalled list but NOT in active installed list
debloated_pkgs = all_with_uninstalled - active_pkgs

print(f"Total current active packages: {len(active_pkgs)}")
print(f"3rd-party user packages: {len(third_party_pkgs)}")
print(f"System packages: {len(system_pkgs)}")
print(f"Debloated / uninstalled packages: {len(debloated_pkgs)}")
print(f"Disabled packages: {len(disabled_pkgs)}")

def format_row(pkg, name, role):
    return f"| `{pkg}` | **{name}** | {role} |"

lines = []
lines.append("# Complete Application Inventory — iQOO Z7 Pro 5G")
lines.append("")
lines.append("> **Device:** iQOO Z7 Pro 5G (`I2301`)  ")
lines.append("> **Operating System:** Funtouch OS 15 (`ro.vivo.os.version: 6.0`, Android 15)  ")
lines.append("> **Build:** `PD2285CF_EX_A_15.2.21.3.W30`  ")
lines.append("> **Generated Date:** 2026-10-23  ")
lines.append("")
lines.append("---")
lines.append("")
lines.append("## Executive Summary")
lines.append("")
lines.append("| Category | Count | Status |")
lines.append("|---|---|---|")
lines.append(f"| **Total Packages Registered** | `{len(all_with_uninstalled)}` | Total system & user packages present in firmware |")
lines.append(f"| **Active Packages (User 0)** | `{len(active_pkgs)}` | Running / accessible in primary profile |")
lines.append(f"| **User-Installed Apps (3rd-Party)** | `{len(third_party_pkgs)}` | Apps installed by user |")
lines.append(f"| **System & OEM Packages** | `{len(system_pkgs)}` | Pre-installed Vivo, Google, MediaTek, & Android packages |")
lines.append(f"| **Debloated / Uninstalled (Tier 1)** | `{len(debloated_pkgs)}` | Safely uninstalled for User 0 via ADB |")
lines.append(f"| **Disabled Packages** | `{len(disabled_pkgs)}` | System packages currently disabled |")
lines.append("")
lines.append("---")
lines.append("")

# Table of Contents
lines.append("## Table of Contents")
lines.append("1. [User-Installed Applications (3rd-Party)](#1-user-installed-applications-3rd-party)")
lines.append("2. [Debloated / Uninstalled Packages (Tier 1)](#2-debloated--uninstalled-packages-tier-1)")
lines.append("3. [Vivo & Funtouch OS System Packages](#3-vivo--funtouch-os-system-packages)")
lines.append("4. [Google Mobile Services (GMS) & Android Core Packages](#4-google-mobile-services-gms--android-core-packages)")
lines.append("5. [Hardware, MediaTek SoC & Carrier Drivers](#5-hardware-mediatek-soc--carrier-drivers)")
lines.append("6. [Restoration & Management Reference](#6-restoration--management-reference)")
lines.append("")
lines.append("---")
lines.append("")

# Section 1: User-Installed Apps (3rd-Party)
lines.append("## 1. User-Installed Applications (3rd-Party)")
lines.append("")
lines.append(f"Total: **{len(third_party_pkgs)} applications** installed by the user.")
lines.append("")
lines.append("| Package Name | Application Name | Category / Description |")
lines.append("|---|---|---|")

# Sort third-party packages alphabetically
for pkg in sorted(third_party_pkgs):
    if pkg in NAME_MAP:
        app_name, desc = NAME_MAP[pkg]
    elif pkg in VIVO_MAP:
        app_name, desc = VIVO_MAP[pkg]
    else:
        # Generate friendly name from package identifier
        parts = pkg.split(".")
        candidate = parts[-1].capitalize() if parts else pkg
        app_name = candidate
        desc = "User Installed Application"
    lines.append(format_row(pkg, app_name, desc))

lines.append("")
lines.append("---")
lines.append("")

# Section 2: Debloated / Uninstalled Packages
lines.append("## 2. Debloated / Uninstalled Packages (Tier 1)")
lines.append("")
lines.append(f"Total: **{len(debloated_pkgs)} packages** safely uninstalled for User 0 without root.")
lines.append("")
lines.append("| Package Name | Component Name | Role / Debloat Justification | Status |")
lines.append("|---|---|---|---|")

for pkg in sorted(debloated_pkgs):
    if pkg in VIVO_MAP:
        app_name, desc = VIVO_MAP[pkg]
    elif pkg in NAME_MAP:
        app_name, desc = NAME_MAP[pkg]
    else:
        app_name = pkg.split(".")[-1].capitalize()
        desc = "Uninstalled OEM / System Stub"
    lines.append(f"| `{pkg}` | **{app_name}** | {desc} | `Uninstalled (User 0)` |")

lines.append("")
lines.append("---")
lines.append("")

# Section 3: Vivo & Funtouch OS Packages (Active)
vivo_active = [p for p in active_pkgs if ("vivo" in p or "bbk" in p or "iqoo" in p)]
lines.append("## 3. Vivo & Funtouch OS System Packages")
lines.append("")
lines.append(f"Total: **{len(vivo_active)} active packages** comprising Funtouch OS framework, OEM system UI, camera, and utilities.")
lines.append("")
lines.append("| Package Name | Feature / Component | Description |")
lines.append("|---|---|---|")

for pkg in sorted(vivo_active):
    if pkg in VIVO_MAP:
        app_name, desc = VIVO_MAP[pkg]
    else:
        parts = pkg.split(".")
        app_name = parts[-1].capitalize()
        desc = "Vivo / Funtouch OS System Component"
    lines.append(format_row(pkg, app_name, desc))

lines.append("")
lines.append("---")
lines.append("")

# Section 4: Google & GMS Packages
google_active = [p for p in active_pkgs if "google" in p or "android.gms" in p or "android.vending" in p or "com.android.chrome" in p]
lines.append("## 4. Google Mobile Services (GMS) & Android Core Packages")
lines.append("")
lines.append(f"Total: **{len(google_active)} active Google packages**.")
lines.append("")
lines.append("| Package Name | Google Service / App | Description |")
lines.append("|---|---|---|")

for pkg in sorted(google_active):
    if pkg in NAME_MAP:
        app_name, desc = NAME_MAP[pkg]
    else:
        parts = pkg.split(".")
        app_name = parts[-1].capitalize()
        desc = "Google Services / AOSP Component"
    lines.append(format_row(pkg, app_name, desc))

lines.append("")
lines.append("---")
lines.append("")

# Section 5: Hardware & MediaTek Drivers
hw_active = [p for p in active_pkgs if ("mediatek" in p or "goodix" in p or "touchscreen" in p or "trustonic" in p)]
lines.append("## 5. Hardware, MediaTek SoC & Carrier Drivers")
lines.append("")
lines.append(f"Total: **{len(hw_active)} low-level hardware & driver packages**.")
lines.append("")
lines.append("| Package Name | Hardware Module | Description |")
lines.append("|---|---|---|")

for pkg in sorted(hw_active):
    parts = pkg.split(".")
    app_name = parts[-1].capitalize()
    desc = "Hardware HAL / MediaTek Dimensity SoC Driver"
    lines.append(format_row(pkg, app_name, desc))

lines.append("")
lines.append("---")
lines.append("")

# Section 6: Restoration & Management Reference
lines.append("## 6. Restoration & Management Reference")
lines.append("")
lines.append("### To Restore Any Debloated App:")
lines.append("```bat")
lines.append("adb shell cmd package install-existing --user 0 <PACKAGE_NAME>")
lines.append("```")
lines.append("")
lines.append("### To Uninstall Any Additional App for User 0:")
lines.append("```bat")
lines.append("adb shell pm uninstall -k --user 0 <PACKAGE_NAME>")
lines.append("```")
lines.append("")
lines.append("### To Clear Cache for Any App:")
lines.append("```bat")
lines.append("adb shell pm trim-caches 200G internal")
lines.append("```")

output_path = r"c:\project\phonemanager\applist.md"
with open(output_path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines))

print(f"applist.md successfully generated at {output_path} with {len(lines)} lines.")
