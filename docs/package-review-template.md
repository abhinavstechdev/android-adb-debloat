# Android Package Review Template

Use one copy of this template per candidate package. Do not label a package safe based only on its name.

## Device context

- **Manufacturer / model:**
- **Android version:**
- **OS skin / firmware version:**
- **Region / build (if relevant):**
- **Date reviewed:**

## Package details

- **Visible app or component name:**
- **Exact package identifier:**
- **How identity was verified:** (Settings → Apps, app info, reliable documentation, other evidence)
- **Evidence links or notes:**

## Assessment

- **Identification confidence:** High / Medium / Low
- **Risk classification:** Likely optional / Investigate — model-dependent / Critical — keep
- **User goal this change supports:**
- **Likely side effects or dependencies:**
- **Features that must be tested:**
- **Recommendation:** Keep / Gather more evidence / Consider removal after approval

## Change record

Complete only after the user explicitly approves and performs the change.

- **Exact command reviewed:**
- **User approval obtained:** Yes / No
- **Command output:**
- **Post-change verification:**
- **Unexpected behavior:**
- **Restoration attempted:** Yes / No / Not needed
- **Restoration output:**

## Review quality checklist

- [ ] Package exists on the connected device.
- [ ] Visible app identity is confirmed, not guessed from the package name.
- [ ] Device model and firmware differences have been considered.
- [ ] Core phone, security, connectivity, notification, and update functions were assessed.
- [ ] Risks and limitations were explained before the change.
- [ ] The user approved the exact package.
- [ ] Only one package was changed in this step.
- [ ] Results are recorded without claiming unverified success.

## Interpretation note

A package assessment is specific to the evidence and device context above. It is not a universal recommendation for all Android devices.
