#!/bin/bash

global_hooks_path="$HOME/.githooks"

mkdir -p "$global_hooks_path"

current_hooks_path=$(git config --global --get core.hooksPath || true)
if [ "$current_hooks_path" = "$global_hooks_path" ]; then
  exit 0
fi

git config --global core.hooksPath "$global_hooks_path"
exit 0
