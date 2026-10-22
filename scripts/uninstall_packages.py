import subprocess
import sys

ADB_PATH = r"C:\platform-tools\adb.exe"

packages_to_uninstall = [
    "com.facebook.viewpoints",
    "com.facebook.pages.app",
    "com.king.candycrushsaga",
    "com.nebula.mahjongtile",
    "com.vitastudio.mahjong",
    "com.wallapers.sillysmiles.live.wallpaper",
    "com.wallpaperscraft.wallpaper",
    "com.grofers.customerapp",
    "com.zeptoconsumerapp",
    "com.done.faasos",
    "com.earnkaro"
]

print("Starting uninstallation of requested packages...")
results = {}

for pkg in packages_to_uninstall:
    # First check if package exists
    check_cmd = [ADB_PATH, "shell", f"pm path {pkg}"]
    check_res = subprocess.run(check_cmd, capture_output=True, text=True, errors="ignore")
    
    if "package:" in check_res.stdout:
        # Uninstall for user 0
        un_cmd = [ADB_PATH, "shell", f"pm uninstall --user 0 {pkg}"]
        un_res = subprocess.run(un_cmd, capture_output=True, text=True, errors="ignore").stdout.strip()
        if "Success" not in un_res:
            # Fallback with -k flag
            un_cmd_k = [ADB_PATH, "shell", f"pm uninstall -k --user 0 {pkg}"]
            un_res = subprocess.run(un_cmd_k, capture_output=True, text=True, errors="ignore").stdout.strip()
        results[pkg] = un_res
        print(f"[{pkg}] -> {un_res}")
    else:
        results[pkg] = "Not installed or already uninstalled"
        print(f"[{pkg}] -> Not installed or already uninstalled")

# Check storage after uninstalls
df_cmd = [ADB_PATH, "shell", "df -h /data"]
df_res = subprocess.run(df_cmd, capture_output=True, text=True, errors="ignore").stdout.strip()
print("\nStorage after uninstalls:")
print(df_res)
