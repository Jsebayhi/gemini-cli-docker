# ADR Best Practices: Architecture Governance

Architecture Decision Records (ADRs) are the primary mechanism for technical governance in the Gemini CLI Toolbox. They capture the "Why" behind significant changes, ensuring the project's evolution is intentional and documented.

## 1. The Immutability Mandate
**Rule:** An ADR is an immutable historical log. Once a decision is "Accepted" and merged into the main branch, it must **never** be edited to reflect a change in technical direction.

### Why Immutability?
*   **Context Preservation:** It allows future maintainers to understand why a decision was made given the constraints *at that time*.
*   **Traceability:** It provides a clear audit trail of the project's evolution.
*   **Agent Safety:** AI agents rely on these logs to build a mental model of the project. Erasing history creates "blind spots" where an agent might repeat past mistakes.

## 2. The "Supersede" Pattern
When a previous architectural decision is changed or refined:

1.  **Do NOT Edit the Old ADR:** Leave the "Decision" and "Context" sections untouched.
2.  **Create a NEW ADR:** Document the new direction in a fresh file (e.g., `adr/0038-new-thing.md`).
3.  **Update Status Chains:**
    *   In the **OLD** ADR: Change `Status: Accepted` to `Status: Superseded by [ADR-XXXX](link)`.
    *   In the **NEW** ADR: Set `Status: Proposed` or `Accepted` and include a line `Supersedes [ADR-YYYY](link)`.
4.  **Preserve Historical Chains:** If an ADR already superseded something else, keep that line.
    *   **Correct Status Example:**
        ```markdown
        ## Status
        Supersedes [ADR-0001](./0001-foo.md)
        Superseded by [ADR-0038](./0038-bar.md)
        ```

## 3. Alternative Analysis Requirements
**Mandate:** Every ADR must analyze at least **3 distinct alternatives** before converging on a solution.

*   **Divergent Thinking:** Force yourself to think beyond the obvious "Simple" vs "Complex" choices. Consider "Novel," "Minimalist," or "High-Performance" variations.
*   **Explicit Rejection:** You MUST clearly define the "Reason for Rejection" for every non-selected alternative. This prevents future agents from proposing the same failed ideas.

## 4. Required Structure
Every ADR must follow this logical flow:

| Section | Purpose |
| :--- | :--- |
| **Status** | Current state and historical links (Supersedes/Superseded by). |
| **Context** | The problem, the constraints, and the "Forces" at play. |
| **Alternatives** | Comparison of at least 3 options with Pros/Cons. |
| **Decision** | The chosen path and the rationale for selection. |
| **Consequences** | Both Positive and Negative impacts of the decision. |

## 5. Relationship with GitHub Issues
*   **Alignment Phase:** The problem is explored in a GitHub Issue.
*   **Architecture Phase:** The solution is designed in an ADR.
*   **Reference:** The ADR should be linked in the GitHub Issue comment where the architecture is proposed.
