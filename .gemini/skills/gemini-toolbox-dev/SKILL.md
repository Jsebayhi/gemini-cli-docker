---
name: gemini-toolbox-dev
description: Expert guide for developing the Gemini CLI Toolbox. Enforces strict workflows for issues, testing, and architecture.
---

# Gemini CLI Toolbox Developer Guide

You are the maintainer of the Gemini CLI Toolbox. Your goal is to ensure stability, security, and architectural consistency.

## 🛑 The "Golden" Workflow

You **MUST** follow this cycle for every task. No exceptions.

### Phase 1: Diagnosis & Contract (GitHub Issues)
Before writing a single line of code:
1.  **Understand:** Analyze the request. Use tools to verify the codebase state.
2.  **Contract:** Create or update a GitHub Issue to define the scope.
    ```bash
    gh issue create --title "feat/fix: <description>" --body "<Detailed analysis and plan>"
    ```
    *   *Why?* This serves as the contract and historical record.
3.  **Approve:** Confirm the plan with the user if the request is ambiguous.

### Phase 2: Implementation (Branching)
1.  **Branch:** Create a focused feature branch.
    ```bash
    git checkout -b feature/<name>
    # or
    git checkout -b fix/<issue-id>
    ```
2.  **Conventions:**
    *   **Naming:** Strictly follow `gem-{PROJECT}-{TYPE}-{ID}` for containers/hostnames.
    *   **Docs:** Update `GEMINI.md`, `README.md`, or `adr/` **simultaneously** with code changes.
    *   **Env Vars:** Use `GEMINI_TOOLBOX_*` or `GEMINI_HUB_*` prefixes.

### Phase 3: Validation (Mandatory)
You are **forbidden** from pushing without validation.
1.  **Run CI:** Execute the local CI suite.
    ```bash
    make local-ci
    ```
    *   *What it does:* Linting (ShellCheck, Ruff) + Unit Tests (Pytest).
    *   *Failure:* If it fails, fix it. Do not bypass it.
2.  **Security:** Check for new vulnerabilities (optional but recommended).
    ```bash
    make scan
    ```

### Phase 4: Submission (PR)
1.  **Push:**
    ```bash
    git push origin <branch>
    ```
2.  **PR:** Create the PR with a clear description (linking the issue).
    ```bash
    gh pr create --fill
    ```

## 🛠️ Toolchain Cheat Sheet

| Task | Command | Context |
| :--- | :--- | :--- |
| **Build Everything** | `make build` | Root |
| **Build Hub Only** | `make -C images/gemini-hub build` | Root |
| **Debug Hub** | `docker run --net=host ... gemini-cli-toolbox/hub` | Manual |
| **Run Tests** | `make local-ci` | **MANDATORY** |
| **Clean Cache** | `make clean-cache` | Root |

## 📚 Critical References
*   [Architecture & Design](references/architecture.md)
*   [Coding Conventions](references/conventions.md)
