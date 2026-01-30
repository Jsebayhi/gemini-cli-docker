# 4. Remote Shutdown Strategy

Date: 2026-01-29

## Status

Proposed

## Context

The Gemini Hub provides a dashboard to discover and connect to Gemini CLI sessions running on the Tailscale network. Currently, users can see these sessions but cannot stop them from the Hub UI.

We investigated adding a "Stop" button to the Hub. The initial assumption was to use `docker stop`.

### The Problem with `docker stop`
Using `docker stop` works **only** if the target container is running on the same physical host as the Hub (Local Mode).
*   **Remote Scenario:** If the Hub is on a Laptop and the CLI session is on a Desktop (connected via VPN), the Hub has no access to the Desktop's Docker daemon.
*   **Result:** A `docker stop` based solution would fail for ~50% of use cases, creating an inconsistent user experience.

## Decision

We will implement a **Hybrid "Network-First" Shutdown Strategy**.

### 1. The Lifecycle Agent (Primary Mechanism)
We will inject a lightweight "Lifecycle Agent" into the `gemini-cli` container.
*   **Technology:** A minimal Python HTTP server (using `http.server`, no external dependencies).
*   **Port:** Listens on a specific port (e.g., `54321`) on the Tailscale interface.
*   **Endpoint:** `POST /shutdown`.
*   **Action:** When triggered, it executes `tmux kill-session -t gemini`.
*   **Chain Reaction:** The existing `docker-entrypoint.sh` monitors the `tmux` session. When `tmux` dies, the entrypoint exits cleanly, stopping the container.
*   **Scope:** This works universally for **both** local and remote instances, as long as they are on the VPN.

### 2. Local Fallback (Fail-Safe)
To ensure robustness, the Hub will implement a fallback:
1.  **Try Network:** Send `POST /shutdown` to the instance's Tailscale IP.
2.  **On Failure:** If the request times out (e.g., agent crashed) **AND** the instance is detected as local (via `docker ps`), execute `docker stop <container_name>`.

## Consequences

### Positive
*   **Universal Control:** Users can stop any session they see in the Hub, regardless of physical location.
*   **Clean Shutdown:** The `tmux kill-session` approach allows the entrypoint to perform cleanup (deregistering from Tailscale, etc.) naturally.
*   **No New Dependencies:** The agent uses Python's standard library.

### Negative
*   **Complexity:** Requires maintaining a sidecar process (`agent.py`) inside the container.
*   **Attack Surface:** Opens an internal HTTP port (though strictly bound to the VPN interface, reducing risk).
