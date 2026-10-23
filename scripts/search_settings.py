import os
import re

out_dir = r"c:\project\phonemanager\audit-iqoo-z7pro-20261023-043350"

def search_file(filename, keywords):
    filepath = os.path.join(out_dir, filename)
    matches = []
    if not os.path.exists(filepath):
        return matches
    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line_str = line.strip()
            if any(re.search(kw, line_str, re.IGNORECASE) for kw in keywords):
                matches.append(line_str)
    return matches

keywords = [
    r"game", r"refresh", r"fps", r"touch", r"mali", r"gpu", r"render",
    r"hwui", r"color", r"hdr", r"motion", r"smooth", r"display",
    r"hawkeye", r"super_solution", r"interpolation", r"eco", r"ddc",
    r"latency", r"boost", r"perf", r"wifi", r"dns", r"buffer", r"animation"
]

print("Searching system settings...")
sys_m = search_file("settings-system-full.txt", keywords)

print("Searching secure settings...")
sec_m = search_file("settings-secure-full.txt", keywords)

print("Searching global settings...")
glo_m = search_file("settings-global-full.txt", keywords)

print(f"\nFound {len(sys_m)} in system, {len(sec_m)} in secure, {len(glo_m)} in global.\n")

with open(os.path.join(out_dir, "deep-search-gaming-candidates.txt"), "w", encoding="utf-8") as f:
    f.write("=== SYSTEM SETTINGS MATCHES ===\n" + "\n".join(sys_m) + "\n\n")
    f.write("=== SECURE SETTINGS MATCHES ===\n" + "\n".join(sec_m) + "\n\n")
    f.write("=== GLOBAL SETTINGS MATCHES ===\n" + "\n".join(glo_m) + "\n\n")

print("Saved to deep-search-gaming-candidates.txt")
