---
name: workspace-instructions
description: Workspace rules and harness behavior conventions for Agentbox
---

# Agentbox Workspace Instructions

Welcome to Agentbox! This workspace is preconfigured with modern developer tools and AI harness integrations.

## Core Rules for Coding Agents
1. **Explore Before Acting**: Inspect existing project files, directory structure, and dependencies before modifying or creating new files.
2. **Surgical Changes**: Make focused, minimal, and non-breaking edits. Do not refactor unrelated code.
3. **Verify and Test**: Always run tests or compile code after making changes. Use native linters and test runners available in the environment.
4. **Environment Awareness**:
   - Primary user: `agent` with passwordless `sudo`
   - Package managers: `bun`, `uv`, `brew`, `npm`, `apt`
   - AI CLIs: `claude`, `copilot`, `codex`, `pi`, `gh`

## Available Skill Templates
Templates for specialized agent tasks are located in `.agent/skills/`:
- `code-reviewer`: Guidelines for performing automated PR and diff reviews.
- `debugging`: Systematic root-cause analysis and reproduction steps.
- `test-runner`: Test execution, reporting, and coverage verification.
