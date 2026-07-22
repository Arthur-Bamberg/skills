#!/usr/bin/env bash
# Sync personal Cursor skills, agents, owned agents-skills, and user hooks into the private backup repo and push.
set -euo pipefail

REPO="${CURSOR_SKILLS_BACKUP_REPO:-$HOME/Projects/cursor-skills}"
CURSOR_SKILLS="${CURSOR_SKILLS_DIR:-$HOME/.cursor/skills}"
CURSOR_AGENTS="${CURSOR_AGENTS_DIR:-$HOME/.cursor/agents}"
AGENTS_SKILLS="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
CURSOR_HOOKS_DIR="${CURSOR_HOOKS_DIR:-$HOME/.cursor/hooks}"
CURSOR_HOOKS_JSON="${CURSOR_HOOKS_JSON:-$HOME/.cursor/hooks.json}"
OWNED_LIST="${OWNED_AGENTS_SKILLS_LIST:-$REPO/owned-agents-skills.txt}"
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

# Personal Cursor skills — tudo em ~/.cursor/skills é seu
mkdir -p "$CURSOR_SKILLS"
rsync -a --delete --exclude '.git' "$CURSOR_SKILLS/" "$REPO/cursor-skills/"

# Custom Cursor agents — tudo em ~/.cursor/agents é seu
mkdir -p "$CURSOR_AGENTS" "$REPO/cursor-agents"
rsync -a --delete --exclude '.git' "$CURSOR_AGENTS/" "$REPO/cursor-agents/"

# Agents skills — só as listadas em owned-agents-skills.txt
mkdir -p "$REPO/agents-skills" "$AGENTS_SKILLS"
if [[ -f "$OWNED_LIST" ]]; then
  mapfile -t owned < <(grep -vE '^\s*(#|$)' "$OWNED_LIST")
else
  owned=()
fi

# Remove do repo qualquer agent skill que não seja owned
shopt -s nullglob
for d in "$REPO/agents-skills"/*/; do
  name=$(basename "$d")
  keep=false
  for o in "${owned[@]+"${owned[@]}"}"; do
    if [[ "$name" == "$o" ]]; then
      keep=true
      break
    fi
  done
  if [[ "$keep" != true ]]; then
    rm -rf "$d"
    log "removed non-owned from repo: agents-skills/$name"
  fi
done
shopt -u nullglob

for name in "${owned[@]+"${owned[@]}"}"; do
  src="$AGENTS_SKILLS/$name"
  dst="$REPO/agents-skills/$name"
  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    rsync -a --delete --exclude '.git' "$src/" "$dst/"
  else
    log "warn: owned agent skill missing locally: $name"
  fi
done

mkdir -p "$REPO/cursor-hooks/hooks"
if [[ -f "$CURSOR_HOOKS_JSON" ]]; then
  cp -a "$CURSOR_HOOKS_JSON" "$REPO/cursor-hooks/hooks.json"
fi
if [[ -d "$CURSOR_HOOKS_DIR" ]]; then
  rsync -a --delete --exclude '.git' "$CURSOR_HOOKS_DIR/" "$REPO/cursor-hooks/hooks/"
fi

git add -A cursor-skills cursor-agents agents-skills cursor-hooks owned-agents-skills.txt README.md

if git diff --cached --quiet; then
  log "noop: no skill/hook/agent changes"
  exit 0
fi

changed=$(git diff --cached --name-only | head -20 | tr '\n' ' ')
msg="chore(skills): sync backup

Atualização automática após edição em skills/agents/hooks pessoais.
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
