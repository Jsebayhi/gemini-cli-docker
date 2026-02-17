# DevSecOps & Security Governance

This document defines the mandatory security practices and risk governance models for the Gemini CLI Toolbox.

## 1. The "Shift Left" Mandate
Security is not a final step; it is an integrated part of development.
*   **Local Scans:** You MUST run `make scan` locally before opening a PR.
*   **Component Ownership:** Every component Makefile MUST implement a `scan` target that targets its specific image tag and respects the root `.trivyignore`.

## 2. Vulnerability Management (.trivyignore)
Suppressing a vulnerability is a **governed risk decision**, not a shortcut.

### 2.1 The TTL Policy (Time-To-Live)
Every entry in the project-wide `.trivyignore` MUST be auditable and tool-enforced.
*   **Per-CVE Governance:** Each CVE must be listed individually.
*   **Enforceable Expiry:** Every entry MUST use Trivy's native expiry syntax: `CVE-XXXX exp:YYYY-MM-DD`. This ensures that the ignore is automatically revoked after the date, preventing permanent security debt.
*   **Cycle:** Use a **90-day** review cycle from the date of detection/suppression.

### 2.2 Justification Requirements
A suppression is only valid if it includes three components in preceding comments:
1.  **Header:** The library name and vulnerability title (e.g., `# brace-expansion: DoS in index.js`).
2.  **Risk Explanation:** A description of the potential impact and why it is low in our context.
3.  **Ignore Reason:** Why a fix is not currently possible (e.g., Unfixable Upstream, OS-Level Delay).

Example:
```text
# brace-expansion: juliangruber brace-expansion index.js expand redos (LOW)
# Risk: Denial of Service in local CLI (low impact). 
# Reason: Upstream fix pending in @google/gemini-cli.
CVE-2026-24001 exp:2026-05-17
```

## 3. Transparency & Documentation
*   **The .trivyignore Source of Truth:** The `.trivyignore` file is the exclusive repository for security risk acceptance. 
*   **Justification:** Every suppression MUST include a concise justification directly in the `.trivyignore` file, explaining why the risk is acceptable (e.g., "unfixable upstream").
*   **Visibility:** Refer users to `.trivyignore` in high-level documentation if they wish to audit the project's security exceptions.

## 4. CI/CD Integration
*   **Delegation:** The GitHub Action MUST delegate scanning to the `make scan` target of each component. Do not use hardcoded Trivy actions with separate logic.
*   **Failure Policy:** CI MUST fail on any **CRITICAL** or **HIGH** severity vulnerability that is not explicitly suppressed with a valid TTL.
