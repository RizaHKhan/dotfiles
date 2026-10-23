#!/usr/bin/env bash
set -euo pipefail

item_id="${1:?item id required}"
vault_id="${2:?vault id required}"
delay="${OP_AUTOFILL_DELAY:-1.5}"

url="$(op item get "$item_id" --vault "$vault_id" --format json | jq -r '(.urls[0].href // .url // empty)')"
if [[ -z "$url" ]]; then
  echo "No URL found on item" >&2
  exit 1
fi

open "$url"

# Trigger the 1Password browser extension's fill shortcut (⌘.).
# Requires the 1Password browser extension to be installed/unlocked and the
# shortcut to be enabled for the active browser.
sleep "$delay"
osascript -e 'tell application "System Events" to keystroke "." using command down'
