#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="${SOURCE_ROOT:-$SCRIPT_DIR/templates/workspace}"
WORKSPACE_ROOT="${PWD}"
APPLY_CHANGES=0
FORCE_OVERWRITE=0
SETUP_VSCODE_MULTIREPO=0

print_help() {
  cat <<'EOF'
Usage: bootstrap-agent-setup.sh [options]

Safely installs portable agent instruction files.
Defaults to dry-run mode and never overwrites existing files unless approved.

Options:
  --workspace <path>      Workspace root to install files into (default: current directory)
  --source-root <path>    Root containing AGENTS.md, CLAUDE.md and .github/copilot-instructions.md
                          (default: templates/workspace under this script folder)
  --setup-vscode-multirepo
                          Install .vscode/settings.json for multi-repository detection
  --apply                 Apply changes (otherwise dry-run only)
  --force                 Overwrite existing files without per-file prompt (only with --apply)
  --help                  Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace)
      WORKSPACE_ROOT="$2"
      shift 2
      ;;
    --source-root)
      SOURCE_ROOT="$2"
      shift 2
      ;;
    --setup-vscode-multirepo)
      SETUP_VSCODE_MULTIREPO=1
      shift
      ;;
    --apply)
      APPLY_CHANGES=1
      shift
      ;;
    --force)
      FORCE_OVERWRITE=1
      shift
      ;;
    --help)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      print_help
      exit 1
      ;;
  esac
done

if [[ "$FORCE_OVERWRITE" -eq 1 && "$APPLY_CHANGES" -ne 1 ]]; then
  echo "--force requires --apply" >&2
  exit 1
fi

WORKSPACE_ROOT="$(cd "$WORKSPACE_ROOT" && pwd)"

SRC_AGENTS="$SOURCE_ROOT/AGENTS.md"
SRC_CLAUDE="$SOURCE_ROOT/CLAUDE.md"
SRC_COPILOT="$SOURCE_ROOT/.github/copilot-instructions.md"
SRC_VSCODE_SETTINGS="$SOURCE_ROOT/.vscode/settings.json"

for src in "$SRC_AGENTS" "$SRC_CLAUDE" "$SRC_COPILOT"; do
  if [[ ! -f "$src" ]]; then
    echo "Missing source file: $src" >&2
    exit 1
  fi
done

if [[ "$SETUP_VSCODE_MULTIREPO" -eq 1 && ! -f "$SRC_VSCODE_SETTINGS" ]]; then
  echo "Missing source file: $SRC_VSCODE_SETTINGS" >&2
  exit 1
fi

copy_with_safety() {
  local src="$1"
  local dest="$2"

  case "$dest" in
    "$WORKSPACE_ROOT"|"$WORKSPACE_ROOT"/*)
      ;;
    *)
      echo "Refusing to write outside workspace: $dest" >&2
      exit 1
      ;;
  esac

  if [[ "$APPLY_CHANGES" -ne 1 ]]; then
    echo "[dry-run] Would install: $dest"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ -f "$dest" ]]; then
    if cmp -s "$src" "$dest"; then
      echo "[skip] Unchanged: $dest"
      return 0
    fi

    if [[ "$FORCE_OVERWRITE" -eq 1 ]]; then
      cp "$src" "$dest"
      echo "[overwrite] Updated: $dest"
      return 0
    fi

    if [[ -t 0 ]]; then
      while true; do
        printf "File exists: %s\nChoose: [s]kip, [o]verwrite, [b]ackup+overwrite, [q]uit: " "$dest"
        read -r choice
        case "$choice" in
          s|S)
            echo "[skip] Kept existing: $dest"
            return 0
            ;;
          o|O)
            cp "$src" "$dest"
            echo "[overwrite] Updated: $dest"
            return 0
            ;;
          b|B)
            local backup
            backup="$dest.bak.$(date +%Y%m%d-%H%M%S)"
            cp "$dest" "$backup"
            cp "$src" "$dest"
            echo "[backup] Saved: $backup"
            echo "[overwrite] Updated: $dest"
            return 0
            ;;
          q|Q)
            echo "Aborted by user."
            exit 1
            ;;
          *)
            echo "Invalid choice."
            ;;
        esac
      done
    else
      echo "[skip] Non-interactive session; existing file left unchanged: $dest"
      return 0
    fi
  fi

  cp "$src" "$dest"
  echo "[create] Installed: $dest"
}

echo "Source root:    $SOURCE_ROOT"
echo "Workspace root: $WORKSPACE_ROOT"
if [[ "$APPLY_CHANGES" -ne 1 ]]; then
  echo "Mode:           dry-run"
else
  echo "Mode:           apply"
fi
if [[ "$SETUP_VSCODE_MULTIREPO" -eq 1 ]]; then
  echo "VS Code setup:  multi-repo enabled"
else
  echo "VS Code setup:  unchanged"
fi

copy_with_safety "$SRC_AGENTS" "$WORKSPACE_ROOT/AGENTS.md"
copy_with_safety "$SRC_CLAUDE" "$WORKSPACE_ROOT/CLAUDE.md"
copy_with_safety "$SRC_COPILOT" "$WORKSPACE_ROOT/.github/copilot-instructions.md"

if [[ "$SETUP_VSCODE_MULTIREPO" -eq 1 ]]; then
  copy_with_safety "$SRC_VSCODE_SETTINGS" "$WORKSPACE_ROOT/.vscode/settings.json"
fi

echo "Done."
