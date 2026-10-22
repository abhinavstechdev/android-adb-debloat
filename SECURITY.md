# Security Policy

## Scope

This repository provides documentation and an AI-agent skill for Android ADB package review. It is not a device-management service and does not directly connect to or control a user's phone.

Report issues involving:

- Commands that could unexpectedly damage a device or impair core functionality.
- Incorrect or overconfident package-removal guidance.
- Unsafe recovery instructions.
- Documentation that encourages bypassing USB debugging authorization or exposing sensitive information.

## Reporting an issue

Open a GitHub issue with a clear description and reproducible steps. Include the relevant device model and Android / firmware version when needed, but **do not include IMEI, serial numbers, account credentials, access tokens, or other sensitive identifiers**.

If a report contains private or security-sensitive information, do not publish those details in a public issue. Remove secrets from logs before sharing them.

## Safety stance

- A package list from one device is not automatically valid for another.
- Device-changing commands should be reviewed and explicitly approved.
- Critical Android and vendor services should not be removed casually.
- Recovery commands have limitations and must not be represented as guaranteed.
- This project does not promise that debloating improves performance, battery life, or stability.
