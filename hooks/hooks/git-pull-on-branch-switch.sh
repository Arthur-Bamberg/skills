#!/bin/bash

is_branch_switch_command() {
  local cmd="$1"

  if [[ "$cmd" =~ git[[:space:]]+switch ]]; then
    return 0
  fi

  if [[ ! "$cmd" =~ git[[:space:]]+checkout ]]; then
    return 1
  fi

  if [[ "$cmd" =~ git[[:space:]]+checkout[[:space:]]+-- ]]; then
    return 1
  fi

  if [[ "$cmd" =~ -p|--patch ]]; then
    return 1
  fi

  return 0
}

input=$(cat)
command=$(echo "$input" | jq -r '.command // empty')
workspace_root=$(echo "$input" | jq -r '.workspace_roots[0] // empty')

if [ -z "$command" ]; then
  exit 0
fi

if ! is_branch_switch_command "$command"; then
  exit 0
fi

if [ -n "$workspace_root" ] && [ -d "$workspace_root/.git" ]; then
  cd "$workspace_root" || exit 0
fi

git pull
exit 0
