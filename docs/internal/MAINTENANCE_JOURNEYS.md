# 🛠️ Internal Maintenance Journeys (QA Matrix)

This document tracks all supported user paths and variants to ensure no regressions during updates.

## 🧪 Test Matrix

### J1: Local Default
1. Run `gemini-toolbox`.
2. Verify interactive Gemini CLI opens in the current folder.
3. Verify state is saved in `~/.gemini`.

### J2: Local Profile
1. Run `gemini-toolbox --profile /tmp/prof`.
2. Verify state is saved in `/tmp/prof/.gemini` (nested).

### J3: Remote Default
1. Run `gemini-toolbox --remote`.
2. Verify Hub starts and is accessible via `http://localhost:8888`.
3. Verify session is accessible via Tailscale IP.

### J4: Remote Profile
1. Run `gemini-toolbox --remote --profile /tmp/prof`.
2. Verify remote connectivity using isolated profile storage.

### J5: Hub Launch
1. Open Hub UI.
2. Use "New Session" wizard to launch a container.
3. Verify new session appears in the list and is connectable.

### M1: Strict Sandbox
1. Run `gemini-toolbox --no-docker`.
2. Verify `docker ps` fails inside the container (socket not mounted).

### M2: No IDE
1. Run `gemini-toolbox --no-ide`.
2. Verify `GEMINI_CLI_IDE_*` environment variables are missing.

### M3: Bash Mode
1. Run `gemini-toolbox --bash`.
2. Verify you are dropped into a raw `bash` shell instead of Gemini.

### M4: Preview Channel
1. Run `gemini-toolbox --preview`.
2. Verify the Docker image tag used is `...:latest-preview`.

### M5: One-Shot Task
1. Run `gemini-toolbox "say hello"`.
2. Verify agent responds and the container exits immediately.

### M6: Interactive Task
1. Run `gemini-toolbox -i "say hello"`.
2. Verify agent responds and the session remains open.

### M7: Legacy Config
1. Run `gemini-toolbox --config /tmp/conf`.
2. Verify state is saved directly in `/tmp/conf` (no nesting).

### T1: Attach (CLI)
1. Launch a session.
2. Run `gemini-toolbox connect <ID>`.
3. Verify you attach to the existing `tmux` session.

### T2: Attach (Bash)
1. Launch a bash session.
2. Run `gemini-toolbox connect <ID>`.
3. Verify you enter the existing container.

### T3: Hub Smart Restart
1. Launch a remote session in `/dirA`.
2. Launch another remote session in `/dirB`.
3. Verify Hub prompts to "Merge and Restart" to include the new path.

### T4: Stop Hub
1. Run `gemini-toolbox stop-hub`.
2. Verify the Hub container is stopped and removed.

### E1: Profile Persistence
1. Add a flag (e.g., `--no-ide`) to `/tmp/prof/extra-args`.
2. Run `gemini-toolbox --profile /tmp/prof`.
3. Verify the flag is automatically applied.

### E2: Hub Bot
1. Launch an "Autonomous Bot" from the Hub UI.
2. Verify it executes the task and handles the interactive toggle correctly.

### E3: Hybrid Access (Localhost)
1. Access Hub via `localhost:8888`.
2. Verify the primary link uses `localhost` and a "VPN" badge is shown as fallback.
