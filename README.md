# Android ADB Debloat

A safety-first ADB package review toolkit and AI agent skill focused on **Vivo and iQOO smartphones** (Funtouch OS & OriginOS).

**Inspect → Identify → Assess → Confirm → Change One Package → Verify → Restore if Needed.**

---

## What is Included

- **AI Agent Skill (`SKILL.md`):** Complete workflow instructions for LLM coding agents to conduct evidence-based Android package analysis, risk assessment, and safe debloating.
- **Windows Interactive PowerShell Tool (`scripts/vivo-iqoo-adb-tool.ps1`):** A safe, menu-driven PowerShell utility supporting read-only audits, package inspection, keyword searching, individually confirmed actions, critical package stop-lists, and Funtouch OS restriction handling.
- **Verified Package Catalog & Risk Tiers (`docs/safe-removal.md`):** Evidence-based categorization of Vivo, iQOO, BBK, Meta, and Google packages across Tier 1 (Low Risk), Tier 2 (Medium Risk), and Tier 3 (Critical System Guardrails).
- **Recovery & Troubleshooting Protocols (`docs/recovery.md`):** Exact recovery procedures for real-world regressions documented on XDA Forums (broken file pickers, navigation gesture failure, permission prompt crashes, and locked bootloader recovery).
- **XDA Community Research Dossier (`research/xda-vivo-iqoo.md`):** Technical analysis of community findings across Funtouch OS 11 through 15, `DELETE_FAILED_USER_RESTRICTED` binder policies, and bootloader recovery constraints.
- **Reproducible Test Protocol (`docs/test-protocol.md`):** Standardized reporting template for recording device-specific test results with regression checklists.

---

## Quick Start (Windows)

1. Download and extract Google's official [Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools) (e.g., to `C:\platform-tools`).
2. On your Vivo/iQOO phone:
   - Go to **Settings → About phone** and tap **Build number** 7 times.
   - Go to **Developer options** and turn on **USB debugging**.
   - Connect the phone via USB and select **File Transfer (MTP)** mode.
   - Unlock the phone and approve the computer's RSA debugging prompt.
3. Open PowerShell in the repository folder:

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\scripts\vivo-iqoo-adb-tool.ps1
   ```

4. Choose **Option 1 (Create read-only audit snapshot)** first. Review your captured device properties and package lists before making any changes.
5. Use **Option 7 (Inspect package)** and **Option 8 (Search packages)** to evaluate candidate apps.
6. Prefer **Option 3 (Disable package)** over uninstalling. Disabling is 100% reversible and avoids package database corruption.

---

## Safety Status — Read Before Use

- **No package is universally safe on every device:** Firmware differences between Funtouch OS (Global/India) and OriginOS (China) mean that package roles and dependencies vary.
- **Modern Vivo and iQOO devices have permanently locked bootloaders:** Fastboot flashing is not available. If a critical component like the launcher or gesture engine is removed, recovery requires a full factory reset via stock recovery mode.
- **Never use automated bulk-uninstall scripts:** Batch deletions make it impossible to isolate which package broke a feature. Always change one package at a time and reboot to verify.

---

## Documentation Index

- [Comprehensive Gaming & High Refresh Rate Optimization Guide](docs/gaming-optimization.md)
- [Gaming Settings & Tools Evaluation Matrix (Helpful vs. Harmful)](docs/gaming-settings-and-tools-audit.md)
- [Complete Device Application Inventory (applist.md)](applist.md)
- [Safe Package Evaluation & Removal Guide](docs/safe-removal.md)
- [Recovery & Troubleshooting Guide](docs/recovery.md)
- [XDA Research Notes & Analysis](research/xda-vivo-iqoo.md)
- [Device Test Protocol & Current Status](docs/test-protocol.md)
- [Windows ADB Setup Guide](docs/windows-setup.md)
- [Package Review Template](docs/package-review-template.md)
- [Agent Skill Guide](SKILL.md)

---

## Gaming & Performance Optimization Tool

To apply all 10 deep gaming optimizations (120Hz lock, DisplayManager unclamp, Game Driver, Vivo GameCube More FPS, AOT machine compilation, power whitelist, touch & ping stabilization):

```powershell
powershell -ExecutionPolicy Bypass -File scripts/optimize_gaming.ps1
```

To revert to stock defaults:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/optimize_gaming.ps1 -Reset
```

---


## Project Principles

- **Safety Guardrails:** Hardcoded stop-lists protect launchers, navigation gestures (`upslide`), storage pickers (`documentsui`), and security centers (`imanager`/`safecenter`).
- **No Mass Uninstalls:** We deliberately avoid bulk-removal lists and blind copy-paste command blocks.
- **Reversibility First:** Disable before uninstalling; test before keeping.
- **No Unmeasured Claims:** We never promise FPS, battery, or RAM gains without baseline benchmarks.

---

## License

MIT — see [LICENSE](LICENSE).
