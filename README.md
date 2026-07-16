# Portable Agent Profile

This folder contains a safe bootstrap for sharing the same agent working style across workspaces and machines.

## Canonical baseline
- Workspace baseline source: templates/workspace/AGENTS.md
- Workspace shims source: templates/workspace/CLAUDE.md and templates/workspace/.github/copilot-instructions.md

## What it installs
- Workspace baseline: AGENTS.md
- Copilot shim: .github/copilot-instructions.md
- Claude shim: CLAUDE.md
- Optional VS Code multi-repo settings: .vscode/settings.json (with flag)

## Repository overlay pattern
- Template: templates/repo/repository-overlay.instructions.md
- Use this for service-specific deltas only.
- Keep it minimal and avoid repeating baseline content.

## Safety behaviour
- Default mode is dry-run.
- No file is overwritten unless you run with --apply.
- Existing files prompt with skip/overwrite/backup+overwrite/quit.
- Non-interactive sessions never overwrite existing files unless --force is used with --apply.
- Script refuses to write outside the selected workspace root.

## Usage
From this folder:

./bootstrap-agent-setup.sh
./bootstrap-agent-setup.sh --apply
./bootstrap-agent-setup.sh --setup-vscode-multirepo --apply

Install into another workspace:

./bootstrap-agent-setup.sh --workspace /path/to/workspace --apply

Install with explicit source root:

./bootstrap-agent-setup.sh --source-root /path/to/portable-root --workspace /path/to/workspace --apply

## Machine portability
1. Put this folder in a private repository.
2. Clone it on each machine.
3. Run the script in dry-run first, then with --apply.
