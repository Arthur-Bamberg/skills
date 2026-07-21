#!/usr/bin/env bash
# afterFileEdit: if a global skill or user hook changed, debounce then sync backup repo.
set -euo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.file_path // empty')

CURSOR_SKILLS="${CURSOR_SKILLS_DIR:-$HOME/.cursor/skills}"
AGENTS_SKILLS="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
CURSOR_HOOKS_DIR="${CURSOR_HOOKS_DIR:-$HOME/.cursor/hooks}"
CURSOR_HOOKS_JSON="${CURSOR_HOOKS_JSON:-$HOME/.cursor/hooks.json}"
SYNC_SCRIPT="$HOME/.cursor/hooks/sync-skills-to-backup.sh"
LOCK_DIR="${XDG_RUNTIME_DIR:-/tmp}/cursor-skills-sync"
TRIGGER="$LOCK_DIR/pending"
DEBOUNCE_SECS="${CURSOR_SKILLS_SYNC_DEBOUNCE:-4}"

mkdir -p "$LOCK_DIR"

case "$file_path" in
  "$CURSOR_SKILLS"/* | "$AGENTS_SKILLS"/* | "$CURSOR_HOOKS_DIR"/* | "$CURSOR_HOOKS_JSON") ;;
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
