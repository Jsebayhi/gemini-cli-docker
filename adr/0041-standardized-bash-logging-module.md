# 0041. Standardized Bash Logging Module

## Status
Accepted

## Context
The project's Bash scripts (toolbox, hub, and entrypoints) previously used inconsistent methods for reporting status and errors, primarily relying on raw `echo` and manual redirection to `stderr`. This led to several issues:
1. **Stdout Corruption:** Functions that return values via `stdout` (like `setup_worktree`) would occasionally leak status messages into captured variables, leading to critical failures in volume mounting.
2. **Inconsistent Formatting:** "Information" messages (`>> ...`) were hardcoded and sometimes lacked proper redirection.
3. **Lack of Granularity:** There was no way for users to control the verbosity of the CLI (e.g., a `DEBUG` mode for entrypoints).

## Alternatives Considered

### [Alternative 1: Raw Redirection (Status Quo)]
*   **Description:** Continue using `echo ... >&2` manually for every status message.
*   **Pros:** Zero overhead, no new functions.
*   **Cons:** Extremely error-prone; easy to forget a redirection, leading to regressions. No level control.
*   **Status:** Rejected
*   **Reason for Rejection:** Does not scale and was the direct cause of the reported regressions.

### [Alternative 2: Custom File Descriptors (FD 3)]
*   **Description:** Use `exec 3>&1` to create an alias for the parent's `stdout` and redirect all UI messages to `>&3`.
*   **Pros:** Bypasses subshell captures reliably.
*   **Cons:** Non-standard; breaks downstream tools (like Hub dashboard or CI) that only capture FD 1 and FD 2. High cognitive load for maintainers.
*   **Status:** Rejected
*   **Reason for Rejection:** Violated the Principle of Least Astonishment and introduced compatibility risks with external log aggregators.

### [Alternative 3: Level-Based Logging Module (Selected)]
*   **Description:** Implement a centralized logging function (`_log`) that defaults to `stderr` and respects a `LOG_LEVEL` variable.
*   **Pros:** Standard-compliant (uses FD 2 for metadata); provide granularity (ERROR, WARN, INFO, DEBUG); prevents `stdout` pollution by design.
*   **Cons:** Small boilerplate required in each script.
*   **Status:** Selected
*   **Reason for Selection:** Best balance of Unix-orthodoxy, robustness, and modern CLI features.

## Decision
Implement a modular logging system in all Bash scripts. All status messages must use `log_info`, `log_warn`, or `log_debug`, which are guaranteed to write to `stderr`. `stdout` is strictly reserved for data/results.

## Consequences
*   **Positive:** Dramatically reduced risk of variable corruption; easier debugging via `LOG_LEVEL=3`; consistent UI across the toolbox.
*   **Negative:** Developers must remember to use `log_*` functions instead of raw `echo`.
