#!/usr/bin/env bash
set -euo pipefail

item_id="${1:?item id required}"
vault_id="${2:?vault id required}"

account_id="$(op account list --format json | jq -r '.[0].account_uuid // empty')"
if [[ -z "$account_id" ]]; then
  echo "No 1Password account found" >&2
  exit 1
fi

printf 'onepassword://open/i?a=%s&v=%s&i=%s\n' "$account_id" "$vault_id" "$item_id"
