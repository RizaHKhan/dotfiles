#!/usr/bin/env bash
set -euo pipefail

type="$1"
val="$2"

case "$type" in
  herdr)
    herdr workspace close "$val"
    ;;
  zoxide|fd-dir)
    ;;
esac
