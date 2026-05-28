#!/usr/bin/env bash
# Install OrchestratorSwarm skill for Claude Code / Cursor / Codex-compatible layouts
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="OrchestratorSwarm"

usage() {
  cat <<EOF
Usage: $0 [--target DIR] [--dry-run]

Install OrchestratorSwarm agent skill.

Options:
  --target DIR   Install into DIR/OrchestratorSwarm (default: ~/.claude/skills)
  --dry-run      Print actions without copying
  -h, --help     Show this help

Examples:
  curl -fsSL https://raw.githubusercontent.com/USER/orchestrator-swarm/main/install.sh | bash
  $0 --target ~/.cursor/skills-cursor
EOF
}

TARGET="${HOME}/.claude/skills"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

DEST="${TARGET}/${SKILL_NAME}"
mkdir -p "$TARGET"

copy_tree() {
  local src="$1" dst="$2"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] would sync $src -> $dst"
    return
  fi
  mkdir -p "$dst"
  rsync -a --delete \
    --exclude '.git' \
    --exclude 'install.sh' \
    --exclude 'README.md' \
    --exclude 'LICENSE' \
    --exclude 'AGENTS.md' \
    "$src/" "$dst/"
}

echo "Installing OrchestratorSwarm to: $DEST"
copy_tree "$REPO_ROOT" "$DEST"

if [[ "$DRY_RUN" -eq 0 ]]; then
  echo "Done. Invoke with:"
  echo "  Claude Code / Gemini: /OrchestratorSwarm"
  echo "  Codex: \$OrchestratorSwarm"
  echo ""
  echo "Prerequisites: ntm, beads (br/bv), Agent Mail — see docs/ECOSYSTEM.md"
fi
