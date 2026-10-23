import subprocess
import os

ADB_PATH = r"C:\platform-tools\adb.exe"

def run_adb(cmd):
    full_cmd = [ADB_PATH, "shell", cmd]
    res = subprocess.run(full_cmd, capture_output=True, text=True, errors="ignore")
    return res.stdout

print("[1] Dumping all DeviceConfig namespaces...")
namespaces_raw = run_adb("device_config list_namespaces")
namespaces = [ns.strip() for ns in namespaces_raw.splitlines() if ns.strip()]
print(f"Found {len(namespaces)} device_config namespaces.")

relevant_ns = [ns for ns in namespaces if any(k in ns.lower() for k in [
    'game', 'display', 'graphics', 'input', 'surface', 'activity', 'power', 'runtime', 'net', 'connectivity'
])]
print(f"Relevant namespaces: {relevant_ns}")

dc_results = {}
for ns in relevant_ns:
    out = run_adb(f"device_config list {ns}")
    if out.strip():
        dc_results[ns] = out.strip()

print("[2] Dumping settings list (system, secure, global)...")
system_settings = run_adb("settings list system")
secure_settings = run_adb("settings list secure")
global_settings = run_adb("settings list global")

print("[3] Dumping display modes...")
display_modes = run_adb("dumpsys display | grep -E 'mSupportedModes|mBaseDisplayInfo|colorMode|refreshRate|fps'")

print("[4] Dumping getprop gaming & display properties...")
props = run_adb("getprop | grep -iE 'refresh|fps|game|touch|gpu|mali|mtk.perf|surfaceflinger|render|hwui'")

out_dir = r"c:\project\phonemanager\audit-iqoo-z7pro-20261023-043350"
with open(os.path.join(out_dir, "deep-search-device-config.txt"), "w", encoding="utf-8") as f:
    for ns, content in dc_results.items():
        f.write(f"=== NAMESPACE: {ns} ===\n{content}\n\n")

with open(os.path.join(out_dir, "settings-system-full.txt"), "w", encoding="utf-8") as f:
    f.write(system_settings)

with open(os.path.join(out_dir, "settings-secure-full.txt"), "w", encoding="utf-8") as f:
    f.write(secure_settings)

with open(os.path.join(out_dir, "settings-global-full.txt"), "w", encoding="utf-8") as f:
    f.write(global_settings)

with open(os.path.join(out_dir, "deep-search-props.txt"), "w", encoding="utf-8") as f:
    f.write(props)

with open(os.path.join(out_dir, "dumpsys-display-modes.txt"), "w", encoding="utf-8") as f:
    f.write(display_modes)

print("All deep-search dumps saved successfully!")
