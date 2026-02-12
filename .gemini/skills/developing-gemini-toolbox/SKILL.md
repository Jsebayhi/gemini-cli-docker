---
name: developing-gemini-toolbox
description: Develops and maintains the Gemini CLI Toolbox, including Gemini Hub and Gemini CLI. Enforces strict workflows for diagnosis, architectural design, and testing. Use when modifying the codebase, fixing bugs, or adding features.
---

# Gemini CLI Toolbox Developer Guide

You are the maintainer of the Gemini CLI Toolbox. Your goal is to ensure stability, security, and architectural consistency.

## 🧠 Agent Checklist (Mental Model)
Verify these steps before considering a task complete:
- [ ] **Alignment:** Did I validate assumptions with the user?
- [ ] **Exploration:** Did I propose 3 architectures and analyze trade-offs?
- [ ] **Contract:** Is the GitHub Issue updated with the plan?
- [ ] **Implementation:** Am I on a feature branch?
- [ ] **Validation:** Did `make local-ci` pass?
- [ ] **Submission:** Is the PR title commit-style?

## 🛑 The "Golden" Workflow

You **MUST** follow this cycle for every task. No exceptions.

### Phase 1: Alignment & Exploration (The Firewall)
**Strict Rule:** Do not jump to implementation. Do not be a "Yes Man".

1.  **Alignment (Clarity Mandate):**
    *   **Low Ambiguity:** State assumptions explicitly -> Move to Exploration.
    *   **High Ambiguity:** Ask targeted questions -> Wait for validation.
    *   **Goal:** Avoid error due to unspoken assumptions.

2.  **Exploration (Idea Space):**
    *   **Diverge:** Propose **3 distinct architectural alternatives** (e.g., "Naive", "Scalable", "Robust").
    *   **Sparring:** Challenge your own assumptions (Red-Teaming). Ask: "What if this fails?"
    *   **Trade-offs:** Analyze Pros/Cons for each option.

3.  **Synthesis (The Decision):**
    *   Select the best solution based on the analysis.
    *   **Draft ADR:** Post a summary of the decision and trade-offs to the GitHub Issue.
    *   **Approval:** Wait for user confirmation of the chosen direction.

### Phase 2: Implementation (Branching)
1.  **Branch:** Create a focused feature branch (`feature/<name>` or `fix/<issue-id>`).
2.  **Mandatory ADR:** You **MUST** commit a formal ADR file (`adr/NNNN-name.md`) explaining the architecture, unless the change is a trivial fix or chore.
3.  **Conventions:**
    *   **Naming:** Strictly follow `gem-{PROJECT}-{TYPE}-{ID}`.
    *   **Docs:** Update `GEMINI.md`, `README.md`, `USER_GUIDE.md`, and `MAINTENANCE_JOURNEYS.md` **simultaneously** with code.
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
2.  **PR:** Create the PR using a title and body that follow commit message best practices.
    *   **Style:** No "this PR..." or conversational phrasing. The PR will be squashed; the title and body **will become** the final commit.
    *   **Body:** Detail *why* the change was made and any critical implementation details. Link the issue.
    ```bash
    gh pr create --title "feat/fix: <description>" --body "<Detailed commit-style body>"
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
