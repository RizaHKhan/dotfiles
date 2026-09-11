#!/usr/bin/env bash
set -euo pipefail

type="$1"
val="$2"

case "$type" in
  herdr)
    herdr workspace focus "$val"
    ;;
  zoxide|fd-dir)
    label=$(basename "$val")
    herdr workspace create --cwd "$val" --label "$label" --focus
    ;;
esac
