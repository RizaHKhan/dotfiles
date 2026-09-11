#!/usr/bin/env bash

set -euo pipefail

INSTALL_MISSING=0

for arg in "$@"; do
  case "$arg" in
    --install)
      INSTALL_MISSING=1
      ;;
    -h|--help)
      cat <<'EOF'
Usage: bootstrap-tv-deps.sh [--install]

Creates idempotent local symlinks needed by television defaults:
  - fd      -> fdfind
  - bat     -> batcat

Options:
  --install   Install missing dependencies via apt (fd-find, bat, ripgrep)
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

install_if_missing() {
  if [ "$INSTALL_MISSING" -eq 1 ]; then
    sudo apt update
    sudo apt install -y fd-find bat ripgrep
  fi
}

ensure_symlink() {
  local source_bin="$1"
  local target_name="$2"
  local source_path

  source_path="$(command -v "$source_bin" || true)"
  if [ -z "$source_path" ]; then
    echo "[warn] Missing required source binary: $source_bin"
    return 1
  fi

  mkdir -p "$HOME/.local/bin"
  ln -sf "$source_path" "$HOME/.local/bin/$target_name"
  echo "[ok] $target_name -> $source_path"
  return 0
}

install_if_missing

fd_ok=0
bat_ok=0

if ensure_symlink "fdfind" "fd"; then
  fd_ok=1
fi

if ensure_symlink "batcat" "bat"; then
  bat_ok=1
fi

echo ""
echo "Verification:"
command -v rg >/dev/null 2>&1 && echo "[ok] rg: $(command -v rg)" || echo "[warn] rg not found"
command -v fdfind >/dev/null 2>&1 && echo "[ok] fdfind: $(command -v fdfind)" || echo "[warn] fdfind not found"
command -v fd >/dev/null 2>&1 && echo "[ok] fd: $(command -v fd)" || echo "[warn] fd not found"
command -v batcat >/dev/null 2>&1 && echo "[ok] batcat: $(command -v batcat)" || echo "[warn] batcat not found"
command -v bat >/dev/null 2>&1 && echo "[ok] bat: $(command -v bat)" || echo "[warn] bat not found"

if [ "$fd_ok" -eq 1 ] && [ "$bat_ok" -eq 1 ]; then
  echo ""
  echo "Done. If needed, ensure $HOME/.local/bin is in PATH."
  exit 0
fi

echo ""
echo "Some links could not be created. Re-run with --install or install missing packages manually." >&2
exit 1
