#!/usr/bin/env bash
set -euo pipefail

item_id="${1:?item id required}"
vault_id="${2:?vault id required}"
editor="${EDITOR:-${VISUAL:-vi}}"

tmp="$(mktemp -t op-item-edit.XXXXXX.json)"
cleanup() {
  rm -f "$tmp"
}
trap cleanup EXIT

op item get "$item_id" --vault "$vault_id" --format json > "$tmp"
"$editor" "$tmp"
op item edit "$item_id" --vault "$vault_id" --template "$tmp"
