# ADR 0028: Intelligent Context Resolution

## Status
Accepted

## Context
When a user launches a session with `--worktree`, the tool needs to decide which Git reference (branch) to use and what task the agent should perform. We want a "Just Works" experience that minimizes manual typing while avoiding the brittleness of hardcoded keyword lists.

### Constraints & Goals
1.  **Semantic Clarity:** Use AI to name branches when the user provides a task description.
2.  **Orthogonality:** Decouple the **Environment** (`--worktree`) from the **Context** (`--branch`) and the **Intent** (Task).
3.  **Low Friction:** Avoid requiring the user to use standard CLI terminators like `--` for common cases.

## Decision: Smart Resolution Priority

We have implemented a deterministic resolution hierarchy that combines explicit flags, auto-detection, and AI-powered inference.

### 1. The Priority Matrix
When `--worktree` is enabled, the Git reference is resolved using the following order:

| Input Pattern | Logic Applied | Resulting Branch | Resulting Task |
| :--- | :--- | :--- | :--- |
| `--branch X ...` | **Explicit Override** | `X` | Remaining Args |
| `[Existing Branch] ...` | **Auto-Detection** | `[Existing Branch]` | Remaining Args |
| `[Task String] ...` | **AI Naming** | `ai-generated-slug` | `[Task String]` |
| (No arguments) | **Safe Default** | `Detached HEAD` | None |

### 2. The Syntactic Heuristic (Non-Consuming Peek)
To avoid brittle keyword lists (which require constant updates as the `gemini-cli` grows), the parser uses a "strongest signal" heuristic:
1.  **Peak:** The tool checks if the first positional argument matches an existing local branch (via `git show-ref`).
2.  **Consume:** If a match is found, it is treated as the **Context** and removed from the agent's task list.
3.  **Infer:** If no match is found (or if the arg contains spaces), the entire argument list is treated as the **Intent**, triggering the Pre-Flight AI naming logic.

### 3. Pre-Flight AI Naming
When a task is provided without an explicit branch, the CLI performs a one-shot call to **Gemini 2.5 Flash**.
*   **System Instruction:** *"You are a git branch naming utility. Slugify the input task into a concise branch name. Return ONLY the slug. Do not analyze the codebase or provide explanations."*
*   **Performance:** Using a "Flash" model ensures this naming step adds minimal latency (sub-second) to the session startup.
*   **Resumability:** If the AI generates a name that already exists in the worktree cache, the tool automatically reuses the existing worktree, enabling resumable multi-session tasks.

## User Journeys

*   **The Fresh Start:** `gemini-toolbox --worktree "Refactor auth"` -> AI creates `refactor-auth` branch.
*   **The PR Repair:** `gemini-toolbox --worktree fix/bug-123` -> Tool detects branch, sets up worktree.
*   **The Explicit Context:** `gemini-toolbox --worktree --branch feat/ui "Fix buttons"` -> Guaranteed context.
*   **The Monitoring Session:** `gemini-toolbox --worktree "Monitor logs"` -> Named workspace for interactive session.

## Alternatives Considered (Rejected)

### 1. Brittle Keyword Lists
*   **Idea:** Ignore common CLI commands like `chat` or `hooks` when parsing branches.
*   **Reason for Rejection:** Hard to maintain and easily broken by new upstream subcommands.

### 2. Mandatory Terminator (`--`)
*   **Idea:** Force users to separate branch from prompt using `--`.
*   **Reason for Rejection:** Poor UX. Users often forget the terminator, leading to unintended branches (e.g., a branch named `chat`).

### 3. UUID-Only Naming
*   **Idea:** Generate random branch names for every worktree.
*   **Reason for Rejection:** Impossible for humans to navigate the cache or the Hub. Semantic names provide critical context for developers.

## Trade-offs and Arbitrages

| Feature | Decision |
| :--- | :--- |
| **Logic** | Heuristic (Strongest Signal) |
| **Model** | Fast/Flash (Low latency) |
| **UX** | Seamless (Minimal delimiters) |
| **Safety** | High (Explicit `--branch` always wins) |
