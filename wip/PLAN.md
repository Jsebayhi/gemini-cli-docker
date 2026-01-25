# Hub Launcher: Implementation Plan

This plan details the steps to transform the Gemini Hub from a read-only dashboard into an active session launcher.

## Phase 1: Infrastructure & Dependencies
*Goal: Enable the Hub container to control the host's Docker daemon and run the toolbox script.*

1.  **Hub Environment (`images/gemini-hub`):**
    *   **Dockerfile:** Install `docker-ce-cli`, `git`, `bash`.
    *   **Dockerfile:** Copy `bin/gemini-toolbox` into the image at `/usr/local/bin/` (Build-time copy via Makefile).
2.  **Host Script (`bin/gemini-toolbox`):**
    *   Update Hub launch command to mount `/var/run/docker.sock`.

## Phase 2: Configuration & Path Logic (Multi-Root)
*Goal: Allow the Hub to see and browse multiple host directories and config profiles.*

1.  **Toolbox Script Update:**
    *   **Args:** Accept multiple `--workspace <path>` arguments.
    *   **Args:** Accept `--config-root <path>` (Default: `~/.gemini/configs`).
    *   **Mounts:** Mirror-mount ALL workspace roots individually.
    *   **Mounts:** Mirror-mount the Config Root.
    *   **Env:** Pass `HUB_ROOTS` (list) and `HOST_CONFIG_ROOT` to the Hub container.
    *   **Headless Support:** Add `--detached` flag to `gemini-toolbox`. When set, the script starts the container but **skips** the final `docker attach` / `tmux attach` step, exiting immediately after launch.

## Phase 3: Backend Logic (Script Reuse)
*Goal: Use the existing `gemini-toolbox` script to launch sessions.*

1.  **File Browser API:**
    *   `/api/roots`: Returns the list of `HUB_ROOTS`.
    *   `/api/configs`: Lists subdirectories in `HOST_CONFIG_ROOT`.
    *   `/api/browse?path=...`: Returns subdirectories of the given path (filtered to directories only).
        *   *Security:* Validate path starts with a known root.
2.  **Launch Execution:**
    *   `/api/launch` (POST): Accepts `project_path` and `config_profile`.
    *   Executes:
        ```python
        subprocess.run(
            ["gemini-toolbox", "--remote", AUTH_KEY, "--detached", "--config", profile_path],
            cwd=target_project_path,
            env={...os.environ, "HOME": host_home_path}
        )
        ```

## Phase 4: Frontend UI (New Session Wizard)
*Goal: A touch-friendly mobile file browser.*

1.  **Dashboard Update:** "Start New Session" button.
2.  **Wizard Step 1: Browse:**
    *   List Workspace Roots.
    *   Drill down into folders (Folder icons only).
    *   "Select This Folder" button.
3.  **Wizard Step 2: Configure:**
    *   Dropdown: "Select Config Profile" (scanned from Config Root).
4.  **Launch:**
    *   Show loading state.
    *   Auto-refresh main list on success.

## Phase 5: Verification
1.  **Volume Check:** Ensure the launched session has the correct host files mounted.
2.  **Connectivity Check:** Verify the launched session joins the Tailscale mesh.
3.  **Attach Check:** Verify that a user can manually `docker exec ... tmux attach` from the host later.
