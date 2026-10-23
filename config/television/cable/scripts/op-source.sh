#!/usr/bin/env bash
set -euo pipefail

op vault list --format json |
  jq -r '.[] | [.id, .name] | @tsv' |
  while IFS=$'\t' read -r vault_id vault_name; do
    op item list --vault "$vault_id" --format json 2>/dev/null |
      jq -r --arg vault_id "$vault_id" --arg vault_name "$vault_name" \
        '.[] | [.id, $vault_id, $vault_name, .title, .category] | @tsv'
  done
