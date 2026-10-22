# Research notes: Vivo / iQOO ADB debloating

## Important conclusion

There is no universal, independently verified “safe Vivo/iQOO debloat list” that can be applied to every model and firmware. XDA posts are useful leads and experience reports, not certification. Do not label packages tested-safe unless the exact model, region, Android/Funtouch OS/OriginOS build, test procedure, and post-change checks are recorded.

## Sources reviewed

- [XDA: Vivo X50, iManager / V-Appstore behavior after updates](https://xdaforums.com/t/how-to-root-unlock-bootloader.4682583/) — a user reports prior ADB removal no longer worked after an update. This supports firmware-specific caution, not a universal package verdict.
- [XDA: iQOO Neo 6 file picker problem after ADB package changes](https://xdaforums.com/t/files-from-storage-are-not-being-selected-from-any-browser.4725248/) — a user reports file selection failures after removing or disabling packages. It illustrates dependency risk but does not establish a universal cause.
- [XDA: general ADB debloating discussion](https://xdaforums.com/t/debloating-stock-rom-no-root-better-battery-performance.3896326/) — community commands are examples, not a current Vivo/iQOO test matrix.
- [Official Android Debug Bridge documentation](https://developer.android.com/tools/adb).
- [Official ADB shell command reference](https://developer.android.com/tools/adb#shellcommands).

## What the tool implements

- Read-only inventory and device-build capture before changes.
- One-package-at-a-time actions with exact typed confirmation.
- Reversible disable/enable as the preferred first experiment.
- Optional user-0 uninstall only after explicit confirmation.
- Restore attempt with pm install-existing --user 0 PACKAGE.
- A conservative stop-list for package names resembling critical system components.
- No bulk-removal list and no claim that other packages are automatically safe.

## Device test protocol

Record exact model/region/build/OS; package ID and app role; pre-change inventory and backup status; one change only; reboot; test calls/SMS, mobile data, Wi-Fi, Bluetooth, notifications, app installation/update, camera, file picker, sharing, biometrics, launcher, settings, system updates, and the target feature; observe performance/battery over a defined period; restore and repeat checks. Record failures as well as successes.

Until a report includes this evidence from a real device, label the package **unverified** or **model-dependent**, not safe or tested.
