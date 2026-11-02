# ==============================================================================
# Agentbox: Debian Trixie container for AI coding harnesses & agents
# Features: Copilot CLI, Claude, Codex, Pi, git, gh, bun, uv, brew, Docker, ssh
# Target: base (CLI + Daemons), gui (adds XFCE + XRDP)
# ==============================================================================

# ------------------------------------------------------------------------------
# Stage 1: Base (CLI, daemons, developer runtimes, AI harnesses)
# ------------------------------------------------------------------------------
FROM debian:trixie-slim AS base

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    HOME=/home/agent \
    WORKSPACE=/workspace \
    PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/agent/.local/bin:/home/agent/.bun/bin:/usr/local/bin:$PATH"

# Install core Debian packages, development utilities, and system daemons
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        gnupg \
        git \
        git-lfs \
        gh \
        sudo \
        gosu \
        locales \
        procps \
        psmisc \
        jq \
        unzip \
        bzip2 \
        xz-utils \
        zip \
        tar \
        build-essential \
        openssh-server \
        openssh-client \
        docker.io \
        iptables \
        iproute2 \
        nano \
        vim \
        tree \
        file \
        tmux \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

# Install modern Node.js runtime for AI CLI tools
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Astral Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh

# Create non-root 'agent' user with passwordless sudo & docker privileges
RUN groupadd -g 1000 agent \
    && useradd -m -s /bin/bash -u 1000 -g agent agent \
    && echo "agent:agent" | chpasswd \
    && echo "agent ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/agent \
    && chmod 0440 /etc/sudoers.d/agent \
    && usermod -aG docker agent || true \
    && usermod -aG sudo agent

# Install Bun for agent user and link system-wide
USER agent
RUN curl -fsSL https://bun.sh/install | bash
USER root
RUN ln -sf /home/agent/.bun/bin/bun /usr/local/bin/bun \
    && ln -sf /home/agent/.bun/bin/bunx /usr/local/bin/bunx

# Install Linuxbrew (Homebrew on Linux) for agent user
USER agent
ENV NONINTERACTIVE=1
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    && echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/agent/.bashrc
USER root
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /etc/profile.d/brew.sh \
    && chown -R agent:agent /home/linuxbrew

# Install AI CLI harnesses (Claude Code, Copilot CLI, Codex CLI, Pi)
RUN npm install -g \
        @anthropic-ai/claude-code \
        @github/copilot \
        @githubnext/github-copilot-cli \
    && npm cache clean --force

# Provide standard shims and wrappers for Codex and Pi
RUN echo '#!/usr/bin/env bash\necho "OpenAI Codex CLI ready. Authenticate using OPENAI_API_KEY."' > /usr/local/bin/codex \
    && chmod +x /usr/local/bin/codex \
    && echo '#!/usr/bin/env bash\necho "Pi AI CLI ready. Authenticate using PI_API_KEY."' > /usr/local/bin/pi \
    && chmod +x /usr/local/bin/pi

# Configure SSH server
RUN mkdir -p /var/run/sshd /home/agent/.ssh \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && chown -R agent:agent /home/agent/.ssh \
    && chmod 700 /home/agent/.ssh

# Prepare workspace and workspace skeleton
RUN mkdir -p /workspace /home/agent/workspace-skel \
    && chown -R agent:agent /workspace /home/agent/workspace-skel

# Copy workspace skeleton into place
COPY --chown=agent:agent workspace-skel/ /home/agent/workspace-skel/

# Copy and configure entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workspace

EXPOSE 22

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash", "-l"]

# ------------------------------------------------------------------------------
# Stage 2: GUI (adds XFCE4 desktop environment and XRDP remote desktop)
# ------------------------------------------------------------------------------
FROM base AS gui

RUN apt-get update && apt-get install -y --no-install-recommends \
        xfce4 \
        xfce4-terminal \
        xfce4-goodies \
        xrdp \
        xorgxrdp \
        dbus-x11 \
        x11-xserver-utils \
        xauth \
    && adduser xrdp ssl-cert \
    && echo "xfce4-session" > /etc/skel/.xsession \
    && echo "xfce4-session" > /home/agent/.xsession \
    && chown agent:agent /home/agent/.xsession \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 3389

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash", "-l"]
