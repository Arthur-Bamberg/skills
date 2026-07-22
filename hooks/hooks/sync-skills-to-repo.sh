#!/usr/bin/env bash
# Sync side folders into the skills repo and commit/push.
# Skills live in the repo (source of truth); this script does not copy skills from home.
set -euo pipefail

REPO="${SKILLS_REPO:-${CURSOR_SKILLS_REPO:-${CURSOR_SKILLS_BACKUP_REPO:-$HOME/Projects/skills}}}"
AGENT_DEFINITIONS="${AGENT_DEFINITIONS_DIR:-${CURSOR_AGENTS_DIR:-$HOME/.cursor/agents}}"
TOOL_HOOKS_DIR="${TOOL_HOOKS_DIR:-${CURSOR_HOOKS_DIR:-$HOME/.cursor/hooks}}"
TOOL_HOOKS_JSON="${TOOL_HOOKS_JSON:-${CURSOR_HOOKS_JSON:-$HOME/.cursor/hooks.json}}"
OWNED_LIST="${OWNED_SKILLS_LIST:-${OWNED_AGENTS_SKILLS_LIST:-$REPO/owned-skills.txt}}"
LOG_DIR="${XDG_RUNTIME_DIR:-/tmp}/skills-sync"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/sync.log"

log() {
  printf '%s %s\n' "$(date -Iseconds)" "$*" >>"$LOG"
}

if [[ ! -d "$REPO/.git" ]]; then
  log "skip: skills repo missing at $REPO"
  exit 0
fi

cd "$REPO"

# Side folder: agent definitions (Cursor subagents)
if [[ -d "$AGENT_DEFINITIONS" ]]; then
  mkdir -p "$REPO/agents"
  rsync -a --delete --exclude '.git' "$AGENT_DEFINITIONS/" "$REPO/agents/"
fi

# Drop non-owned skill folders that may have landed in the repo
mkdir -p "$REPO/skills"
if [[ -f "$OWNED_LIST" ]]; then
  mapfile -t owned < <(grep -vE '^\s*(#|$)' "$OWNED_LIST")
else
  owned=()
fi

for legacy in cursor-skills agents-skills cursor-agents cursor-hooks; do
  if [[ -d "$REPO/$legacy" ]]; then
    rm -rf "$REPO/$legacy"
    log "removed legacy: $legacy/"
  fi
done

shopt -s nullglob
for d in "$REPO/skills"/*/; do
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
    log "removed non-owned from repo: skills/$name"
  fi
done
shopt -u nullglob

# Side folder: tool hooks
mkdir -p "$REPO/hooks/hooks"
if [[ -f "$TOOL_HOOKS_JSON" ]]; then
  cp -a "$TOOL_HOOKS_JSON" "$REPO/hooks/hooks.json"
fi
if [[ -d "$TOOL_HOOKS_DIR" ]]; then
  rsync -a --delete --exclude '.git' "$TOOL_HOOKS_DIR/" "$REPO/hooks/hooks/"
fi

git add -A skills agents hooks owned-skills.txt README.md AGENTS.md CONTEXT.md .agents .cursor/rules/ user-rules.md canvases scripts

for legacy in cursor-skills agents-skills cursor-agents cursor-hooks cursor-user-rules.md owned-agents-skills.txt; do
  if git ls-files --error-unmatch "$legacy" >/dev/null 2>&1; then
    git rm -rf "$legacy" >/dev/null 2>&1 || true
  fi
done

if git diff --cached --quiet; then
  log "noop: no skill/side-folder changes"
  exit 0
fi

changed=$(git diff --cached --name-only | head -20 | tr '\n' ' ')
msg="chore(skills): sync

Atualização automática (skills source of truth + side folders).
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
