#!/bin/sh
set -eu

# zi is a shell function that changes directory; query prints the selection.
dir=$(zoxide query --interactive) || exit 0
 
if [ -n "$dir" ]; then
  if [ -d "$dir" ]; then
    base=$(basename "$dir")

    session_id=$(rex ls --json | jq -r --arg label "$base" \
      '[.sessions[] | select(.label == $label)][0].session_id // empty')
    if [ -n "$session_id" ]; then
      rex do session.select session_id="$session_id"
      exit 0
    fi


    session_id=$(rex new "$base" --cwd "$dir" --json | jq -er '.session_id')
    rex do session.select session_id="$session_id"
  fi
fi
