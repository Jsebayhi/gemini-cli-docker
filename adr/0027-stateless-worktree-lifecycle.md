# ADR 0027: Stateless Lifecycle Management

## Status
Accepted

## Context
Ephemeral worktrees created in the cache directory (`$XDG_CACHE_HOME/gemini-toolbox/worktrees`) can accumulate over time, consuming significant disk space. We need a way to clean up these workspaces without introducing a stateful database or complex management overhead.

### Constraints & Goals
1.  **Statelessness:** The Gemini Hub and Toolbox must not rely on a database to track worktrees.
2.  **Automation:** Cleanup should be passive and require no user intervention.
3.  **Safety:** We must not delete worktrees that are currently being used or were recently modified.

## Decision: mtime-Based "Stateless Reaper"

We will implement a cleanup strategy based on standard Unix directory modification times (`mtime`).

### 1. The Reaper Policy
Any worktree directory that has not been modified for more than **30 days** is considered stale and is eligible for removal.

### 2. Implementation Mechanism
The Gemini Hub periodically executes a "Reaper" routine:
1.  **Scan:** It recursively scans the project-level worktree folders.
2.  **Identify:** It identifies directories with an `mtime` older than 30 days.
3.  **Remove:** It executes `rm -rf` on the stale directory.
4.  **Prune:** It follows up with a `git worktree prune` in the main repository (if accessible) to clean up Git's internal metadata references.

### 3. Orphan Handling
This stateless approach naturally handles "orphaned" worktrees (where the main repository was deleted or moved). Since the Reaper only looks at the timestamp of the worktree folder itself, it will eventually remove any leftover directories regardless of whether their parent Git repository still exists.

## Alternatives Considered (Rejected)

### 1. SQLite Tracking Database
*   **Idea:** Maintain a centralized list of all active worktrees.
*   **Reason for Rejection:** Violates the "Stateless Hub" mandate. Adds complexity regarding database migration, corruption, and sync-drift between the DB and the actual filesystem.

### 2. Marker Files (`.gemini-touch`)
*   **Idea:** Every session `touch`es a specific file to update the "last used" time.
*   **Reason for Rejection:** Redundant. The directory's own `mtime` is automatically updated by the OS whenever files inside are changed, providing a reliable "Last Used" signal for free.

### 3. Manual Cleanup Only
*   **Idea:** Provide a `gemini-toolbox prune` command.
*   **Reason for Rejection:** Poor UX. Users will forget to run it until they run out of disk space. Automated background cleanup is more robust.

## Trade-offs and Arbitrages

| Feature | Decision |
| :--- | :--- |
| **State** | Stateless (Filesystem is the DB) |
| **Reliability** | High (Unix standard `mtime`) |
| **Precision** | Lower (Coarse 30-day window) |
| **Overhead** | Minimal (Periodic `find` command) |
