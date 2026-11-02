#!/usr/bin/env bash
set -eo pipefail

# ==============================================================================
# Agentbox Entrypoint
# Checks ENABLE_DOCKER, ENABLE_SSH, and ENABLE_RDP (all default to false).
# Initializes /workspace from /home/agent/workspace-skel without overwriting.
# ==============================================================================

ENABLE_DOCKER="${ENABLE_DOCKER:-false}"
ENABLE_SSH="${ENABLE_SSH:-false}"
ENABLE_RDP="${ENABLE_RDP:-false}"

is_true() {
    case "${1,,}" in
        1|true|yes|on) return 0 ;;
        *) return 1 ;;
    esac
}

echo "=== [agentbox] Initializing container environment ==="

# ------------------------------------------------------------------------------
# 1. Initialize /workspace from skeleton without overwriting
# ------------------------------------------------------------------------------
if [ -d "/home/agent/workspace-skel" ]; then
    mkdir -p /workspace
    echo "[agentbox] Syncing workspace skeleton to /workspace (no overwrite)..."
    # -r recursive, -n no-clobber (do not overwrite existing files)
    cp -rn /home/agent/workspace-skel/. /workspace/ 2>/dev/null || true
    chown -R agent:agent /workspace 2>/dev/null || true
fi

# Ensure workspace ownership and permissions
chown agent:agent /workspace 2>/dev/null || true

# ------------------------------------------------------------------------------
# 2. Docker Daemon (ENABLE_DOCKER)
# ------------------------------------------------------------------------------
if is_true "$ENABLE_DOCKER"; then
    echo "[agentbox] Starting Docker daemon (ENABLE_DOCKER=true)..."
    if command -v dockerd >/dev/null 2>&1; then
        # Ensure cgroup and runtime directories exist
        mkdir -p /var/run /var/log
        if [ ! -S /var/run/docker.sock ]; then
            dockerd > /var/log/dockerd.log 2>&1 &
            # Wait for socket readiness (up to 15 seconds)
            for i in $(seq 1 15); do
                if [ -S /var/run/docker.sock ]; then
                    echo "[agentbox] Docker daemon started successfully."
                    break
                fi
                sleep 1
            done
        else
            echo "[agentbox] Docker socket already present."
        fi
        # Ensure agent user can access docker socket
        if [ -S /var/run/docker.sock ]; then
            chmod 666 /var/run/docker.sock || true
        fi
    else
        echo "[agentbox] Warning: dockerd executable not found."
    fi
else
    echo "[agentbox] Docker daemon disabled (ENABLE_DOCKER=false)."
fi

# ------------------------------------------------------------------------------
# 3. OpenSSH Server (ENABLE_SSH)
# ------------------------------------------------------------------------------
if is_true "$ENABLE_SSH"; then
    echo "[agentbox] Starting OpenSSH server (ENABLE_SSH=true)..."
    if command -v sshd >/dev/null 2>&1; then
        mkdir -p /var/run/sshd
        # Generate host keys if not present
        ssh-keygen -A 2>/dev/null || true

        # Ensure agent's .ssh dir exists with right permissions
        mkdir -p /home/agent/.ssh
        chown -R agent:agent /home/agent/.ssh
        chmod 700 /home/agent/.ssh
        if [ -f /home/agent/.ssh/authorized_keys ]; then
            chmod 600 /home/agent/.ssh/authorized_keys
        fi

        /usr/sbin/sshd
        echo "[agentbox] SSH server running on port 22."
    else
        echo "[agentbox] Warning: sshd not found."
    fi
else
    echo "[agentbox] SSH server disabled (ENABLE_SSH=false)."
fi

# ------------------------------------------------------------------------------
# 4. XRDP / GUI Desktop (ENABLE_RDP)
# ------------------------------------------------------------------------------
if is_true "$ENABLE_RDP"; then
    echo "[agentbox] Starting XRDP & XFCE (ENABLE_RDP=true)..."
    if command -v xrdp >/dev/null 2>&1; then
        # Clean any stale lock/pid files
        rm -f /var/run/xrdp/xrdp.pid /var/run/xrdp/xrdp-sesman.pid /var/run/xrdp.pid

        # Start xrdp-sesman then xrdp
        if command -v xrdp-sesman >/dev/null 2>&1; then
            xrdp-sesman
        fi
        xrdp
        echo "[agentbox] RDP server running on port 3389."
    else
        echo "[agentbox] Warning: xrdp is not installed in this image layer. Use the 'gui' image target to enable RDP."
    fi
else
    echo "[agentbox] RDP desktop disabled (ENABLE_RDP=false)."
fi

# ------------------------------------------------------------------------------
# 5. Execute Command as 'agent' User
# ------------------------------------------------------------------------------
cd /workspace

if [ "$(id -u)" = "0" ]; then
    if [ $# -eq 0 ]; then
        exec gosu agent /bin/bash -l
    else
        exec gosu agent "$@"
    fi
else
    if [ $# -eq 0 ]; then
        exec /bin/bash -l
    else
        exec "$@"
    fi
fi
