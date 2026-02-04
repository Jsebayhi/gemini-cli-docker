# ADR 0026: Ephemeral Worktrees and Isolation

## Status
Proposed

## Context
Users and autonomous agents need a way to perform experimental work (refactoring, feature exploration, automated patching) without polluting their primary working directory. We are implementing this using Git's native `worktree` feature to provide isolation while maintaining IDE compatibility.

### Constraints & Goals
1.  **Safety:** Experimental work must not corrupt the main repository.
2.  **Git-Centric:** This feature specifically targets Git-managed projects.
3.  **Statelessness:** The Gemini Hub remains stateless, using directory metadata for management.
4.  **IDE Integration:** Users must be able to open worktrees in their local IDE (e.g., VS Code).
5.  **Disk Management:** Automated cleanup for stale worktrees based on modification time.

## User Journeys

The worktree feature is designed to support the following high-level workflows:

1.  **The Fresh Start (New Feature):** A user wants to start work on a new branch in an isolated folder. The CLI handles branch creation (`git worktree add -b`) automatically.
    *   *Command:* `gemini-toolbox --worktree feat/ui-v2 chat`
2.  **The PR Repair (Existing Branch):** An agent (or human) needs to fix a bug in an existing branch. The CLI detects the branch and sets up the worktree correctly.
    *   *Command:* `gemini-toolbox --worktree fix/bug-123 chat`
3.  **The Autonomous Task (Non-Interactive):** An agent is launched with a specific instruction. It works in an ephemeral worktree to avoid locking the user's main working directory.
    *   *Command:* `gemini-toolbox --worktree "Refactor auth logic in app/models.py"`
4.  **The Parallel Multi-Tasker:** A user launches multiple agents on different branches simultaneously. Each lives in its own worktree.
5.  **The Risky Reviewer:** A user wants to inspect a PR with potential side effects. Using `--isolation container` ensures the worktree remains entirely within a Docker volume.
    *   *Command:* `gemini-toolbox --worktree fix/vuln --isolation container chat`

## Proposed Decision: Smart Branching Logic

To ensure a seamless UX, the branching logic is **built into the `gemini-toolbox` wrapper**.

### Branch Resolution Protocol:
1.  **Explicit Branch Provided:** If the user provides a valid branch name (e.g., `feat/ui`), the CLI uses it directly: `git worktree add [path] [branch]`.
2.  **Task Provided (Pre-Flight Naming):** If the user provides a descriptive task instead of a branch name:
    *   The CLI performs a "Pre-Flight" one-shot call to the Gemini API using the current profile.
    *   **Prompt:** "Summarize the following task into a concise, slugified Git branch name. Return ONLY the slug: '$TASK'".
    *   The resulting slug is used to create the branch and the worktree folder.
    *   **Fallback:** If the API call fails, the CLI falls back to a UUID-based name or a simple slug of the first few words.
3.  **No Input Provided:**
    *   Uses a `detached HEAD` for purely ephemeral exploration.

## Proposed Decision: Dual-Mode Isolation

We will implement a unified `--worktree` flag that supports two distinct modes:

### 1. `disk` Mode (Default for Interactive Sessions)
Designed for human developers.
*   **Location:** Defaults to `$XDG_CACHE_HOME/gemini-toolbox/worktrees/${PROJECT_NAME}/${BRANCH_OR_UUID}`. This adheres to Linux standards for cached/transient data. Users can override this by setting `GEMINI_WORKTREE_ROOT`.
*   The Toolbox automatically mounts this path into the container.
*   **Cleanup:** The Hub will implement a "Stateless Reaper" protocol.
    *   **Mechanism:** Standard directory timestamp monitoring (`mtime`).
    *   The Hub periodically scans the root folder for directories with an `mtime` older than 30 days.
    *   Stale directories are removed, followed by a `git worktree prune`.

### 2. `container` Mode (Default for Autonomous Sessions)
Designed for ephemeral, automated tasks.
*   **Mechanism:** Worktree created within the container environment (using a dedicated volume).
*   **Pros:** Truly ephemeral. No host disk clutter.
*   **Cons:** No local IDE access.

## Trade-offs and Arbitrages

| Feature | `disk` Mode | `container` Mode |
| :--- | :--- | :--- |
| **Visibility** | Visible to Host (VS Code) | Hidden (Internal to Docker) |
| **Cleanup** | Scheduled Reaper (mtime) | Automatic on Container/Vol exit |
| **Speed** | Fast (Local FS) | Variable (Volume Overhead) |
| **Risk** | Low (Centralized Root) | Zero (Isolated Vol) |

## Remaining Questions / Risks
*   **Orphaned Worktrees:** If a user deletes the main repository, the worktree entries in the root become "ghosts". The Reaper must be robust enough to handle directory removal even if the parent Git repo is missing.
*   **Branch Pollution:** Should automated tasks always use `detached HEAD` unless a branch name is explicitly provided?