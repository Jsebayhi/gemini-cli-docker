# 🛠️ Internal Maintenance Journeys (QA Matrix)

This document tracks the supported user paths and variants. It serves as a checklist for regression testing.

## 🧪 Test Matrix

### 1. Local Core (The Happy Paths)
| ID | Journey | Command / Action | Expected Result |
|:---|:---|:---|:---|
| **L1** | Standard Chat | `gemini-toolbox` | Interactive Gemini CLI opens in current folder. |
| **L2** | One-shot Query | `gemini-toolbox "hello"` | Agent responds and exits. |
| **L3** | Interactive Prompt | `gemini-toolbox -i "hello"` | Agent responds and keeps session open. |
| **L4** | Bash Mode | `gemini-toolbox --bash` | Dropped into `bash` inside container. |
| **L5** | Bash Command | `gemini-toolbox --bash -c "ls -la"` | Lists container files and exits. |

### 2. VS Code Integration
| ID | Journey | Command / Action | Expected Result |
|:---|:---|:---|:---|
| **V1** | Integrated Terminal | Run `gemini-toolbox` inside VS Code terminal. | CLI detects `TERM_PROGRAM=vscode` and connects to host extension. |
| **V2** | Context Fetch | Ask "Explain selected code". | Agent reads selection from host IDE. |

### 3. Configuration & Profiles
| ID | Journey | Command / Action | Expected Result |
|:---|:---|:---|:---|
| **P1** | Legacy Config | `gemini-toolbox --config /tmp/conf` | Session history saved in `/tmp/conf`. |
| **P2** | Profile Mode | `gemini-toolbox --profile /tmp/prof` | Session history saved in `/tmp/prof/.gemini`. |
| **P3** | Persistent Flags | Create `/tmp/prof/extra-args` with `--no-docker`. Run **P2**. | Docker socket is NOT mounted (flag applied). |

### 4. Remote Access & Hub (VPN)
| ID | Journey | Command / Action | Expected Result |
|:---|:---|:---|:---|
| **R1** | Desktop Start | `gemini-toolbox --remote` | Container starts, Hub starts. URL `http://localhost:8888` accessible. |
| **R2** | Mobile Connect | Open Hub URL on phone. Tap card. | `ttyd` terminal opens. Interaction works. |
| **R3** | Hybrid Connect | Open Hub on Desktop. Click "VPN" badge. | Connects via Tailscale IP (simulating remote). |
| **R4** | Local Optimization | Open Hub on Desktop. Click Main Link. | Connects via `localhost` (zero latency). |

### 5. Hub-Initiated Sessions (Remote Job Runner)
| ID | Journey | Command / Action | Expected Result |
|:---|:---|:---|:---|
| **H1** | New Session (CLI) | Hub > New Session > Select Root > Launch. | New CLI container starts. Hub refreshes list. |
| **H2** | New Session (Bash) | Hub > New Session > Select Bash > Launch. | New Bash container starts. |
| **H3** | Autonomous Bot | Hub > New Session > Task: "Echo hi" > Uncheck Interactive. | Container runs, prints "hi", and exits. Log visible in UI. |
| **H4** | Interactive Bot | Hub > New Session > Task: "Hi" > Check Interactive. | Container runs, executes task, stays open for connection. |

### 6. Session Transitions (Attach/Resume)
| ID | Journey | Command / Action | Expected Result |
|:---|:---|:---|:---|
| **T1** | CLI Attach | `gemini-toolbox connect <gem-id>` | Attaches to existing `tmux` session of CLI. |
| **T2** | Bash Attach | `gemini-toolbox connect <gem-bash-id>` | Execs new `bash` shell in existing container. |
| **T3** | Stop Hub | `gemini-toolbox stop-hub` | Hub container stops. |

### 7. Sandboxing & Security
| ID | Journey | Command / Action | Expected Result |
|:---|:---|:---|:---|
| **S1** | Strict Sandbox | `gemini-toolbox --no-docker` | `docker ps` inside container fails (Socket missing). |
| **S2** | No IDE | `gemini-toolbox --no-ide` | `GEMINI_CLI_IDE_*` env vars are missing. |
| **S3** | Custom Project | `gemini-toolbox --project /tmp/data` | CWD is `/tmp/data`. `$PWD` matches. |

### 8. Maintenance & Updates
| ID | Journey | Command / Action | Expected Result |
|:---|:---|:---|:---|
| **M1** | Self-Update | `gemini-toolbox update` | Pulls latest image from registry. |
| **M2** | Preview Channel | `gemini-toolbox --preview` | Runs `gemini-cli-preview` image. |