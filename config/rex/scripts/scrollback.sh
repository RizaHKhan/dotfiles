#!/bin/sh
set -eu

# Explicit IDs keep capture pointed at the original pane after the float takes focus.
session=$1
block=$2
snapshot=$(mktemp "${TMPDIR:-/tmp}/rex-scrollback.XXXXXXXX")
trap 'rm -f "$snapshot"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

rex capture --session "$session" --block "$block" --trim --unwrap > "$snapshot"

# Use the captured pane's project, not the floating shell's default directory.
process=$(rex block call --session "$session" --block "$block" process)
cwd=$(printf '%s' "$process" | jq -r '.foreground.cwd // empty')
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
    cd "$cwd"
fi

# Reviewr needs an explicit pairing to target the original agent, not the float.
REX_SCROLLBACK_AGENT=$(printf '%s' "$process" | jq -r '
    [.foreground | .argv0, .name, .command | strings | split("/")[-1]
     | select(. == "claude" or . == "codex" or . == "opencode" or
              . == "aider" or . == "goose" or . == "cline" or . == "pi")][0] // empty')
export REX_SCROLLBACK_AGENT
export REX_SCROLLBACK_SESSION="$session" REX_SCROLLBACK_BLOCK="$block"
nvim -R -n -i NONE \
    --cmd 'lua local name = vim.env.REX_SCROLLBACK_AGENT; if name and name ~= "" then vim.g.reviewr_agent = { session = vim.env.REX_SCROLLBACK_SESSION, block = vim.env.REX_SCROLLBACK_BLOCK, name = name } end' \
    -c 'set clipboard+=unnamedplus' \
    -c 'setlocal buftype=nofile noswapfile nomodifiable' \
    -c 'lua vim.b.rex_scrollback = true; vim.b.reviewr_file = "[Rex terminal scrollback]"' \
    -c 'normal! G' \
    "$snapshot"
