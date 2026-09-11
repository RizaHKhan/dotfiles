#!/usr/bin/env bash
set -euo pipefail

type="$1"
val="$2"

case "$type" in
  herdr)
    herdr workspace get "$val" 2>/dev/null
    ;;
  zoxide|fd-dir)
    echo "directory — select to create as herdr workspace"
    echo "Path: $val"
    echo ""
    ls -lah "$val" 2>/dev/null | head -25
    ;;
esac
