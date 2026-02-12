# System Architecture

## Overview
The Gemini CLI Toolbox is a "Containerized Agent Harness". It wraps the official `@google/gemini-cli` in a secure, portable, and feature-rich environment.

## Components

### 1. The Wrapper (`bin/gemini-toolbox`)
*   **Role:** Orchestrator.
*   **Responsibility:**
    *   Detects host environment (OS, VS Code, Docker).
    *   Constructs the complex `docker run` command.
    *   Handles volume mounts (project, caches, config).
    *   Manages the "Hybrid Mode" network binding (`-p 127.0.0.1:0:3000`).

### 2. The Core Image (`images/gemini-cli`)
*   **Base:** Debian Bookworm (via `images/gemini-base`).
*   **Key Feature:** Permission Mapping.
    *   Uses `gosu` to switch from `root` to a user matching the host's UID/GID.
    *   Ensures files created by the agent are owned by the user.
*   **Integration:** Docker-out-of-Docker (DooD) allows the agent to control the host's Docker daemon.

### 3. The Hub (`images/gemini-hub`)
*   **Role:** Discovery & Connectivity.
*   **Stack:** Python (Flask) + Tailscale.
*   **Network:** Runs with `--net=host` to participate in the Tailscale mesh.
*   **Discovery:**
    *   **Remote:** Queries Tailscale API for peers starting with `gem-`.
    *   **Local (Hybrid):** Queries local Docker daemon (`docker ps`) for containers mapping port 3000.

## Networking

### Remote Access (VPN)
*   Containers join a private Tailscale network.
*   Each session gets a unique hostname: `gem-{PROJECT}-{TYPE}-{ID}`.
*   Users access the app via the VPN IP.

### Hybrid Mode (Localhost)
*   When running remotely, the CLI *also* binds port 3000 to a random ephemeral port on localhost.
*   The Hub detects this mapping and offers a "LOCAL" link.
*   Traffic flows directly: `Host Browser -> Host Loopback -> Container Port 3000`.

## File System Strategy
*   **Project Mount:** The project directory is mounted at the *exact same path* inside the container as on the host. This satisfies VS Code security checks.
*   **Config Mount:** `~/.gemini` (Host) -> `/home/gemini/.gemini` (Container).
