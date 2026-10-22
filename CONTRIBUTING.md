# Contributing

Thank you for helping improve Android ADB Debloat. Contributions should make package analysis safer, clearer, and more reproducible.

## What is useful

- Corrections to ADB setup and troubleshooting.
- Improvements to skill workflow, clarity, and response structure.
- Device-specific package observations supported by evidence.
- Documentation improvements and typo fixes.
- Safer recovery guidance and reproducible test cases.

## Package claims require context

When proposing a package classification, include as much of the following as is appropriate:

1. Exact device manufacturer and model.
2. Android version and Funtouch OS / OriginOS or other firmware version.
3. Exact package identifier and visible app name.
4. How the package identity was verified.
5. Observed behavior before and after a change.
6. Relevant official or otherwise credible documentation.

Do not submit a package as universally safe based only on its name or on a list intended for another phone. If evidence is incomplete, describe it as a hypothesis or an item to investigate.

## Safety requirements

- Do not add mass-uninstall scripts or commands that remove a broad set of packages without per-package review.
- Do not recommend deleting files from protected system partitions as normal debloating.
- Keep read-only discovery separate from device-changing operations.
- Explain likely side effects and recovery limitations.
- Do not promise performance improvements without measurements and context.
- Do not include personal identifiers, account data, IMEI, serial numbers, tokens, or private logs.

## Documentation style

- Use descriptive headings and concise instructions.
- Prefer official Android documentation for ADB behavior.
- Mark placeholders clearly and explain what users must replace.
- Test command syntax where practical.
- Keep links relative when they point to files in this repository.
- Update the README when adding or renaming major documentation.

## Pull request checklist

- [ ] The change has a clear purpose and scope.
- [ ] Technical claims are accurate and appropriately qualified.
- [ ] Risky operations include warnings and recovery notes.
- [ ] Package guidance is tied to device-specific evidence.
- [ ] Documentation links and command placeholders are correct.
- [ ] No secrets or personal device identifiers are included.
