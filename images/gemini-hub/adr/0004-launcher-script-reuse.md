# 4. Hub Launcher via Script Reuse

Date: 2026-01-25

## Status

Accepted (Refines [ADR-0003](./0003-launcher-path-mirroring.md))

## Context

In [ADR-0003](./0003-launcher-path-mirroring.md), we decided to enable the Hub to launch new sessions by mirroring the host's filesystem path. The initial assumption was that the Hub would reimplement the `docker run` logic in Python to spawn sibling containers.

However, the `gemini-toolbox` bash script already contains complex, production-hardened logic for:
*   Generating consistent session IDs (ADR-0003).
*   Handling environment variables.
*   Mounting user configuration and caches.
*   Resolving image tags (local vs remote).

Reimplementing this logic in Python creates a maintenance burden (two sources of truth) and risk of drift.

## Decision

We will bundle the `gemini-toolbox` script into the Hub container at **build time**.

### 1. Build-Time Copy
We cannot rely on runtime mounting of the script because:
*   The script on the host might be a symlink (difficult to mount correctly).
*   It introduces a loose dependency on the host's state.

Instead, we will:
1.  Use the `Makefile` to copy `bin/gemini-toolbox` into the `images/gemini-hub/` context before building.
2.  `COPY` it into the image at `/usr/local/bin/gemini-toolbox`.

### 2. Environment Mirroring
To make the script believe it is running on the Host (so it generates correct Host paths for Docker-out-of-Docker mounts), we must mirror the relevant environment at runtime:

*   **Workspace:** Mirror mounted (as per ADR-0003).
*   **Home Directory:** We must set the `HOME` environment variable inside the Hub container to match the Host's `HOME` path (e.g., `/home/user`).
    *   *Why?* The script uses `~` or `$HOME` to locate config (`~/.gemini`) and cache (`~/.m2`).
    *   *The Trick:* If the Hub container's `$HOME` is `/root` (internal), the script would generate `-v /root/.gemini:/...`. The Host Daemon would then look for `/root/.gemini` *on the Host*, which is wrong.
    *   *The Fix:* By setting `HOME=/home/user`, the script generates `-v /home/user/.gemini:/...`, which is the correct Host path.

### 3. Execution Flow
1.  User clicks "Launch" in Hub UI for path `/home/user/projects/foo`.
2.  Hub Python Backend sets `cwd="/home/user/projects/foo"`.
3.  Hub Python Backend sets `env["HOME"] = "/home/user"`.
4.  Hub executes `subprocess.run(["gemini-toolbox", "--remote", ...])`.
5.  The script runs inside the container:
    *   It sees `pwd` as `/home/user/projects/foo` (valid inside due to mirror mount).
    *   It sees `HOME` as `/home/user`.
    *   It constructs the `docker run` command using these paths.
6.  The Host Docker Daemon executes the command successfully because the paths match the Host filesystem.

## Consequences

### Positive
*   **Reliability:** The script is baked into the image, eliminating "missing file" or "broken symlink" errors at runtime.
*   **Consistency:** The Hub uses the exact version of the script it was built with.
*   **DRY:** Updates to session ID logic or default flags in the toolbox script automatically apply to the Hub.

### Negative
*   **Rebuild Requirement:** Updating the `gemini-toolbox` script requires rebuilding the Hub image to propagate the changes. This is acceptable as it adheres to the immutable infrastructure pattern.
