#!/bin/bash

input=$(cat)
workspace="${CURSOR_PROJECT_DIR:-}"

if [ -z "$workspace" ]; then
  workspace=$(echo "$input" | jq -r '.workspace_roots[0] // empty')
fi

if [ -z "$workspace" ] || [ ! -e "$workspace/.git" ]; then
  echo '{}'
  exit 0
fi

cd "$workspace" || {
  echo '{}'
  exit 0
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo '{}'
  exit 0
fi

if ! git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
  jq -n '{
    additional_context: "sessionStart: repositório sem upstream; git pull não executado."
  }'
  exit 0
fi

pull_output=$(git pull 2>&1)
pull_status=$?

context=$(printf 'Git pull ao iniciar o agent (%s):\n%s' "$workspace" "$pull_output")
if [ "$pull_status" -ne 0 ]; then
  context=$(printf '%s\n(exit code: %s)' "$context" "$pull_status")
fi

jq -n --arg ctx "$context" '{ additional_context: $ctx }'
exit 0
