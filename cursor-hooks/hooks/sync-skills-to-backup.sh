#!/usr/bin/env bash
# Sync global Cursor skills, agents skills, and user hooks into the private backup repo and push.
set -euo pipefail

REPO="${CURSOR_SKILLS_BACKUP_REPO:-$HOME/Projects/cursor-skills}"
CURSOR_SKILLS="${CURSOR_SKILLS_DIR:-$HOME/.cursor/skills}"
AGENTS_SKILLS="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
CURSOR_HOOKS_DIR="${CURSOR_HOOKS_DIR:-$HOME/.cursor/hooks}"
CURSOR_HOOKS_JSON="${CURSOR_HOOKS_JSON:-$HOME/.cursor/hooks.json}"
LOG_DIR="${XDG_RUNTIME_DIR:-/tmp}/cursor-skills-sync"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/sync.log"

log() {
  printf '%s %s\n' "$(date -Iseconds)" "$*" >>"$LOG"
}

if [[ ! -d "$REPO/.git" ]]; then
  log "skip: backup repo missing at $REPO"
  exit 0
fi

cd "$REPO"

rsync -a --delete --exclude '.git' "$CURSOR_SKILLS/" "$REPO/cursor-skills/"
mkdir -p "$AGENTS_SKILLS"
rsync -a --delete --exclude '.git' "$AGENTS_SKILLS/" "$REPO/agents-skills/"

mkdir -p "$REPO/cursor-hooks/hooks"
if [[ -f "$CURSOR_HOOKS_JSON" ]]; then
  cp -a "$CURSOR_HOOKS_JSON" "$REPO/cursor-hooks/hooks.json"
fi
if [[ -d "$CURSOR_HOOKS_DIR" ]]; then
  rsync -a --delete --exclude '.git' "$CURSOR_HOOKS_DIR/" "$REPO/cursor-hooks/hooks/"
fi

git add cursor-skills agents-skills cursor-hooks

if git diff --cached --quiet; then
  log "noop: no skill/hook changes"
  exit 0
fi

changed=$(git diff --cached --name-only | head -20 | tr '\n' ' ')
msg="chore(skills): sync backup

Atualização automática após edição em skills/hooks globais.
Arquivos: ${changed}"

git commit -m "$msg" >/dev/null
log "commit: $(git rev-parse --short HEAD) ${changed}"

if git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
  if git push >>"$LOG" 2>&1; then
    log "push: ok"
  else
    log "push: failed"
    exit 1
  fi
else
  log "skip push: no upstream"
fi

exit 0
