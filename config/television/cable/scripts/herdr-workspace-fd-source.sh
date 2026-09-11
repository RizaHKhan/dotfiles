#!/usr/bin/env bash
set -euo pipefail

herdr_cwds=$(
  herdr pane list 2>/dev/null \
    | jq -r '[.result.panes[].cwd // ""] | unique | .[]' \
    | python3 -c 'import sys,os; [print(os.path.realpath(p.strip())) for p in sys.stdin if p.strip()]' 2>/dev/null
)

find ~/camcloud ~/configs ~/labspend -maxdepth 3 -type d -exec test -d '{}/.git' \; -print 2>/dev/null \
  | while IFS= read -r d; do
      rd=$(python3 -c "import os; print(os.path.realpath('${d//\'/\\\'}'))" 2>/dev/null || echo "$d")
      if echo "$herdr_cwds" | grep -qxF "$rd"; then continue; fi
      base=$(basename "$d")
      printf 'fd-dir|%s|◇ %s  (%s)\n' "$d" "$base" "$d"
    done
