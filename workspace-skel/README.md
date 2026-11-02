# Workspace

This is your persistent Agentbox workspace directory (`/workspace`).

- On container startup, any template or configuration file present in `/home/agent/workspace-skel` is synced here **without** overwriting existing files (`cp -rn`).
- Check [SKILL.md](./SKILL.md) and [.agent/skills/](./.agent/skills/) for agent templates and behavioral guidelines.
- Preinstalled tools available to your scripts: `bun`, `uv`, `brew`, `git`, `gh`, `claude`, `copilot`, `docker`, and more.
