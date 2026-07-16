# Portable Agent Profile

This folder contains a bootstrap for sharing the same agent working style across workspaces and machines. It has been largely created with the support of Github Copilot.

This repository captures some of my preferences for working with AI in a relatively concise (i.e. token-efficient) way, and I expect to maintain and improve it over time. Suggestions are welcomed.

## License
I have no significant legal understanding of how copyright and licensing operates when AI is involved in creating something. To the extent that this is possible you may choose to operate within either the included CC-BY 4.0 license or MIT license. My intent is to be permissive and enable use in a broad range of settings. If you decide you love this project so much that you need a special license for your circumstances, email me.

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

## What else should I use if I like the idea but not the execution
I don't know for sure, but you might get on well with https://github.com/yzhao062/anywhere-agents instead. It's a lot more full-fledged but it's also harder to understand and might use a couple more tokens. This repo *is* a weekend project.

If this repo is too much then I'd suggest you make your own, or suffer with the default behaviour, up to you.