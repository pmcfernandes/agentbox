# Agentbox

Agentbox is a Debian Trixie container purpose-built for AI coding harnesses and autonomous development agents. It comes preloaded with modern developer runtimes, package managers, and AI assistants, with optional Docker, SSH, and XFCE RDP desktop services controlled via environment variables.

---

## Highlights

- **Base OS**: Debian Trixie (`debian:trixie-slim`)
- **Preinstalled AI CLIs**:
  - **Copilot CLI** (`@github/copilot`, `gh extension`)
  - **Claude** (`@anthropic-ai/claude-code`)
  - **Codex** (`codex` CLI shim)
  - **Pi** (`pi` CLI shim)
- **Developer Tools**:
  - `git`, `git-lfs`, `gh` (GitHub CLI)
  - `bun` (JavaScript / TypeScript runtime)
  - `uv` (Astral fast Python package manager)
  - `brew` (Homebrew on Linux)
  - `nodejs` (Node.js 22 LTS), `npm`
  - `tmux`, `build-essential`, `sudo`, `jq`, `unzip`, `curl`
- **User & Permissions**:
  - User `agent` (UID/GID 1000) with passwordless `sudo`
  - Password for `agent` is initialized to `agent` (for SSH/RDP)
- **Workspace Auto-Initialization**:
  - Workspace skeleton located at `/home/agent/workspace-skel`
  - Synchronized into `/workspace` upon container startup without clobbering existing files (`cp -rn`)
  - Bundles ready-to-use `SKILL.md` templates for agent code reviews, debugging, and test runs
- **Selective Daemons (all default to `false`)**:
  - `ENABLE_DOCKER`: Starts the Docker daemon (DinD)
  - `ENABLE_SSH`: Starts OpenSSH server on port 22
  - `ENABLE_RDP`: Starts XRDP and XFCE desktop environment on port 3389

---

## Build Targets

The `Dockerfile` is structured as a multi-stage build:

| Target | Description | Exposed Ports |
| :--- | :--- | :--- |
| `base` | Fast, lightweight CLI image containing all developer tools, AI harnesses, and daemons (Docker, SSH). | `22` |
| `gui` | Includes everything in `base` plus XFCE4 desktop environment and XRDP remote desktop server. | `22`, `3389` |

### Building the Images

```bash
# Build base CLI image
docker build --target base -t agentbox:latest .

# Build GUI (RDP + XFCE) image
docker build --target gui -t agentbox:gui .
```

---

## Running Agentbox

### Quick Run (Interactive Shell)

```bash
docker run -it --rm \
  -v agentbox_workspace:/workspace \
  -e ANTHROPIC_API_KEY="your-key" \
  -e OPENAI_API_KEY="your-key" \
  agentbox:latest
```

### Enabling Services via Environment Variables

All services default to disabled (`false`). Enable only what you need:

```bash
# Run with Docker-in-Docker and SSH enabled:
docker run -d \
  --name agentbox \
  --privileged \
  -p 2222:22 \
  -e ENABLE_DOCKER=true \
  -e ENABLE_SSH=true \
  -v agentbox_workspace:/workspace \
  agentbox:latest

# Run GUI image with Remote Desktop (RDP) enabled:
docker run -d \
  --name agentbox-gui \
  -p 3389:3389 \
  -e ENABLE_RDP=true \
  -v agentbox_workspace:/workspace \
  agentbox:gui
```

### Connecting to Services

- **SSH**:
  ```bash
  ssh agent@localhost -p 2222
  # Default password: agent
  ```
- **RDP (Remote Desktop)**:
  - Connect your RDP client (mstsc, Remmina, Microsoft Remote Desktop) to `localhost:3389`.
  - Username: `agent`
  - Password: `agent`
  - Session starts an XFCE4 desktop session.

---

## Running with Docker Compose

A preconfigured `docker-compose.yml` is included:

```bash
# Launch CLI service
docker compose up -d agentbox

# Launch GUI service with RDP
docker compose up -d agentbox-gui

# Open a shell in the running container
docker compose exec -it agentbox /bin/bash
```

---

## Workspace Skeleton & `SKILL.md`

On first launch, `/workspace` is populated from `/home/agent/workspace-skel/`:

```
/workspace/
├── SKILL.md                 # Primary workspace behavioral instructions
├── README.md                # Workspace overview
├── .gitignore               # Sensible defaults for Python, Node, and IDEs
└── .agent/
    └── skills/
        ├── code-reviewer/
        │   └── SKILL.md     # Code review checklist & table format
        ├── debugging/
        │   └── SKILL.md     # Defect reproduction & root-cause protocol
        └── test-runner/
            └── SKILL.md     # Automated test discovery and run instructions
```

Existing files in `/workspace` are preserved and never overwritten by subsequent container restarts.
