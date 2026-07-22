#!/usr/bin/env bash
# afterFileEdit (Cursor): debounce sync when an owned skill, agent definition, or tool hook changes.
set -euo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.file_path // empty')

REPO="${CURSOR_SKILLS_REPO:-${CURSOR_SKILLS_BACKUP_REPO:-$HOME/Projects/cursor-skills}}"
AGENTS_SKILLS="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
OPENCODE_SKILLS="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}"
AGENT_DEFINITIONS="${AGENT_DEFINITIONS_DIR:-${CURSOR_AGENTS_DIR:-$HOME/.cursor/agents}}"
TOOL_HOOKS_DIR="${TOOL_HOOKS_DIR:-${CURSOR_HOOKS_DIR:-$HOME/.cursor/hooks}}"
TOOL_HOOKS_JSON="${TOOL_HOOKS_JSON:-${CURSOR_HOOKS_JSON:-$HOME/.cursor/hooks.json}}"
OWNED_LIST="${OWNED_SKILLS_LIST:-${OWNED_AGENTS_SKILLS_LIST:-$REPO/owned-skills.txt}}"
SYNC_SCRIPT="${CURSOR_SKILLS_SYNC_SCRIPT:-$HOME/.cursor/hooks/sync-skills-to-backup.sh}"
LOCK_DIR="${XDG_RUNTIME_DIR:-/tmp}/cursor-skills-sync"
TRIGGER="$LOCK_DIR/pending"
DEBOUNCE_SECS="${CURSOR_SKILLS_SYNC_DEBOUNCE:-4}"

mkdir -p "$LOCK_DIR"

is_owned_skill_path() {
  local path="$1"
  local base=""
  case "$path" in
    "$AGENTS_SKILLS"/*) base="$AGENTS_SKILLS" ;;
    "$OPENCODE_SKILLS"/*) base="$OPENCODE_SKILLS" ;;
    *) return 1 ;;
  esac
  local rel="${path#"$base"/}"
  local name="${rel%%/*}"
  [[ -n "$name" && -f "$OWNED_LIST" ]] || return 1
  grep -vE '^\s*(#|$)' "$OWNED_LIST" | grep -qxF "$name"
}

case "$file_path" in
  "$AGENT_DEFINITIONS"/* | "$TOOL_HOOKS_DIR"/* | "$TOOL_HOOKS_JSON") ;;
  "$AGENTS_SKILLS"/* | "$OPENCODE_SKILLS"/*)
    if ! is_owned_skill_path "$file_path"; then
      printf '%s\n' '{}'
      exit 0
    fi
    ;;
  *)
    printf '%s\n' '{}'
    exit 0
    ;;
esac

date +%s >"$TRIGGER"

(
  exec 200>"$LOCK_DIR/lock"
  flock -n 200 || exit 0

  while true; do
    sleep "$DEBOUNCE_SECS"
    now=$(date +%s)
    last=$(cat "$TRIGGER" 2>/dev/null || echo 0)
    if ((now - last >= DEBOUNCE_SECS)); then
      break
    fi
  done

  "$SYNC_SCRIPT" || true
) >/dev/null 2>&1 &

printf '%s\n' '{}'
exit 0
