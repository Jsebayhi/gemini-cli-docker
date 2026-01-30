# ADR 0012: Ephemeral Workspaces and Sandbox Root

## Status
Accepted

## Context
Users need a way to launch Gemini CLI sessions to perform experimental work (refactoring, feature exploration) without polluting their main working directory or risking data loss.
The desired capability is "Ephemeral Workspaces" or "Sandboxes" where the agent can work in isolation.

Three constraints guided this decision:
1.  **Safety:** We must not risk modifying the wrong files or accidentally deleting the user's main project.
2.  **Clutter:** Creating copies of the project should not clutter the user's primary workspace (e.g., no `../project-copy` sprawl).
3.  **Visibility:** The user must be able to easily find, inspect, and manage these sandboxes via the Gemini Hub.

## Alternatives Considered

### 1. Relative Paths (`../project-sandbox`)
*   *Idea:* Create the worktree in a sibling directory.
*   *Problem:* Extremely fragile. Users organize folders differently. `../` might point to a read-only volume, a different drive, or a messy "Downloads" folder.

### 2. Hidden Internal Folder (`.gemini/worktrees`)
*   *Idea:* Put worktrees inside the project.
*   *Problem:* Git worktrees cannot technically reside inside the main worktree (recursion issues). Even if possible, it complicates `.gitignore` and risks accidentally committing the sandbox.

### 3. Temp Directory (`/tmp/...`)
*   *Idea:* Use OS temp vars.
*   *Problem:* Ephemeral by nature. If the OS reboots, work is lost. Users cannot easily "Open in VS Code" because the path is obscure.

## Decision
We will implement **Centralized Sandbox Management** using `git worktree` and a configurable `GEMINI_WORKTREE_ROOT`.

### 1. Configuration
The user must define a "Sandbox Zone" (e.g., `~/gemini-sandboxes`).
*   Env Var: `GEMINI_WORKTREE_ROOT`
*   Profile Config: `worktree_root` in `config.yaml` (future) or just implicit via the env.

### 2. Creation Logic (`gemini-toolbox --sandbox`)
When the user runs `gemini-toolbox --sandbox [branch]`:
1.  Toolbox validates `GEMINI_WORKTREE_ROOT` exists.
2.  Toolbox calculates the target path: `${GEMINI_WORKTREE_ROOT}/${PROJECT_NAME}/${BRANCH_OR_UUID}`.
3.  Toolbox executes `git worktree add [target_path]`.
4.  Toolbox mounts `target_path` as the workspace root.

### 3. Hub Integration
The Hub is configured to scan `GEMINI_WORKTREE_ROOT` as a secondary "Root Source".
*   **Automatic Discovery:** Because the Hub scans this root, any new sandbox automatically appears as a card in the Hub.
*   **Visual Distinction:** The Hub detects if a project path lies within `GEMINI_WORKTREE_ROOT`. If so, it badges the card as "🧪 Sandbox".
*   **Lifecycle (Cleanup):**
    *   Since the Hub knows these are sandboxes, it can offer a **"Delete"** button.
    *   "Delete" executes `rm -rf [path]` AND `git worktree prune` (requires access to original repo or just lazy pruning).

## Consequences
*   **Positive:** "Zero Clutter" in the main project folder.
*   **Positive:** Sandboxes are first-class citizens in the Hub (launchable, connectable).
*   **Negative:** Requires initial setup (defining the root folder).
*   **Negative:** `git worktree` requires the repo to be clean (no unstaged changes) before creating a branch, or detached HEAD usage.
