#!/usr/bin/env bash
set -euo pipefail

# Links owned skills from this repo into local harness skill directories:
#   - ~/.agents/skills           — OpenCode / agent-skills
#   - ~/.config/opencode/skills  — OpenCode nativo (opcional)
#   - ~/.cursor/skills           — Cursor
# Cada entrada é um symlink para este repo; git pull mantém as skills atuais.
#
# Referência: https://github.com/mattpocock/skills/blob/main/scripts/link-skills.sh

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DESTS=(
  "$HOME/.agents/skills"
  "$HOME/.config/opencode/skills"
  "$HOME/.cursor/skills"
)

OWNED_LIST="$REPO/owned-skills.txt"
if [[ ! -f "$OWNED_LIST" ]]; then
  echo "error: missing $OWNED_LIST" >&2
  exit 1
fi

mapfile -t owned < <(grep -vE '^\s*(#|$)' "$OWNED_LIST")
if [[ ${#owned[@]} -eq 0 ]]; then
  echo "error: no owned skills in $OWNED_LIST" >&2
  exit 1
fi

names=()
srcs=()
for name in "${owned[@]}"; do
  src="$REPO/skills/$name"
  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "warn: skip $name (missing $src/SKILL.md)" >&2
    continue
  fi
  names+=("$name")
  srcs+=("$src")
done

for DEST in "${DESTS[@]}"; do
  if [[ -L "$DEST" ]]; then
    resolved="$(readlink -f "$DEST")"
    case "$resolved" in
      "$REPO"|"$REPO"/*)
        echo "error: $DEST is a symlink into this repo ($resolved)." >&2
        echo "Remove it (rm \"$DEST\") and re-run." >&2
        exit 1
        ;;
    esac
  fi

  mkdir -p "$DEST"

  for i in "${!names[@]}"; do
    name="${names[$i]}"
    src="${srcs[$i]}"
    target="$DEST/$name"

    if [[ -e "$target" || -L "$target" ]]; then
      if [[ -L "$target" ]]; then
        current="$(readlink -f "$target" 2>/dev/null || true)"
        if [[ "$current" == "$(readlink -f "$src")" ]]; then
          echo "ok $name ($DEST)"
          continue
        fi
      fi
      rm -rf "$target"
    fi

    ln -sfn "$src" "$target"
    echo "linked $name -> $src ($DEST)"
  done
done
