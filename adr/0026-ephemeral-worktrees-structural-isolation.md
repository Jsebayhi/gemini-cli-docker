# ADR 0026: Ephemeral Worktrees and Structural Isolation

## Status
Accepted

## Context
Users and autonomous agents need a way to perform experimental work (refactoring, feature exploration, automated patching) without polluting their primary working directory. The desired capability is "Ephemeral Workspaces" where the agent can work in high-fidelity isolation while maintaining full compatibility with host-based tools like VS Code.

### Constraints & Goals
1.  **Safety:** Experimental work must not corrupt the main repository.
2.  **Git-Centric:** This feature specifically targets Git-managed projects. The CLI will gracefully exit if run outside a Git worktree.
3.  **No Clutter:** Creating copies of the project should not clutter the user's primary workspace (e.g., no `../project-copy` sprawl).
4.  **IDE Integration:** Users must be able to open worktrees in their local IDE (e.g., VS Code).
5.  **Performance:** Context switching should be fast and avoid full clones if possible.

## Decision: Native Git Worktrees

We will use Git's native `worktree` feature as the isolation primitive.

### 1. Centralized Worktree Root
To prevent "directory sprawl," all worktrees are stored in a centralized, project-nested cache:
`$XDG_CACHE_HOME/gemini-toolbox/worktrees/${PROJECT_NAME}/${SANITIZED_BRANCH_NAME}`

*   **Standard Compliance:** This adheres to Linux standards for transient/cached data.
*   **Organization:** Grouping by `${PROJECT_NAME}` allows for bulk management of worktrees belonging to the same repo.
*   **Sanitization:** Slashes in branch names (e.g., `feat/ui`) are converted to hyphens (e.g., `feat-ui`) for the folder name to ensure filesystem compatibility and a flat structure within the project subfolder.

### 2. Surgical Mount Strategy
To ensure Git history/objects are accessible while protecting the parent repository's source code, the toolbox uses a dual-mount approach:
1.  **Parent Project:** Mounted as **Read-Only** (`:ro`). This allows the agent to see scripts/configs needed by hooks but prevents accidental modification of the primary codebase.
2.  **Parent's `.git` Directory:** Mounted as **Read-Write** (`:rw`) on top of the parent mount. This allows the agent to write commits, branches, and objects to the shared database.
3.  **Worktree Folder:** Mounted as the primary workspace root (`Read-Write`).

## Technical Constraints & Safety

*   **Empty Repositories:** Worktree creation is forbidden if the repository has zero commits (no `HEAD`), as Git cannot create a worktree from a non-existent reference.
*   **Recursive Worktrees:** Creating a worktree from *within* an existing worktree is forbidden to keep logic simple and avoid recursive metadata resolution complexity.
*   **Non-Git Projects:** The tool checks for a `.git` folder (via `git rev-parse`) and exits gracefully with an error if used in a regular directory.

## User Journeys

*   **The Parallel Multi-Tasker:** A user launches multiple agents on different branches simultaneously. Each lives in its own worktree, avoiding `index.lock` conflicts.
*   **The Safe Explorer:** A user wants to browse the code or run a quick test without creating any branch or committing to a task. The CLI creates a worktree with a **Detached HEAD**.

## Alternatives Considered (Rejected)

### 1. Project-Local Sandboxes (`.gemini/worktrees`)
*   **Idea:** Keep the worktrees inside a hidden folder within the project.
*   **Reason for Rejection:** Git worktrees cannot easily reside inside the parent worktree without recursion issues. It also pollutes the primary project directory, violating the "Zero Clutter" principle.

### 2. Relative Sibling Paths (`../project-sandbox`)
*   **Idea:** Create the worktree as a sibling directory.
*   **Reason for Rejection:** Highly fragile. The parent directory might be read-only, part of a different volume, or a disorganized "Downloads" folder. It creates "clutter sprawl" across the user's filesystem.

### 3. Pure Container Isolation (`--isolation container`)
*   **Idea:** Create the worktree inside a Docker Volume or a temporary path like `/tmp`.
*   **Reason for Rejection:** 
    *   **IDE Friction:** Prevents host-based IDEs (VS Code) from accessing the files, breaking a core mandate.
    *   **Redundancy:** `$XDG_CACHE_HOME` already provides sufficient isolation without the complexity of managing internal Docker volumes for Git operations.

### 4. Filesystem-Level Snapshots (OverlayFS / Btrfs CoW)
*   **Idea:** Use Copy-on-Write snapshots or OverlayFS mounts.
*   **Reason for Rejection:** Significant overengineering. Requires specific filesystem support or elevated privileges (`sudo`). Native `git worktree` is idiomatic, portable, and natively understands branch logic.

## Trade-offs and Arbitrages

| Feature | Decision |
| :--- | :--- |
| **Visibility** | Visible to Host (VS Code) for high fidelity |
| **Speed** | Fast (Local FS) |
| **Context** | Git-Centric (Requires a repository) |
| **Complexity** | Low (Native Git) |
