#!/bin/sh
set -eu

log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/herdr"
mkdir -p "$log_dir"
exec 2>"$log_dir/directory-pane.log"
trap 'status=$?; if [ "$status" -ne 0 ]; then printf "Opening pane failed (exit %s). See %s/directory-pane.log\nPress Enter to close." "$status" "$log_dir"; read -r ignored || :; fi' EXIT
set -x

directory=${1:?Missing directory}

# Popup context can identify the popup itself. Resolve the underlying UI instead.
context=$(herdr workspace list | jq -er '
  .result.workspaces[] | select(.focused == true)
  | [.workspace_id, .active_tab_id] | @tsv
')
workspace=$(printf '%s\n' "$context" | cut -f1)
tab=$(printf '%s\n' "$context" | cut -f2)
pane=$(herdr pane list --workspace "$workspace" | jq -er \
  --arg tab "$tab" '
  [.result.panes[] | select(.tab_id == $tab)]
  | (map(select(.focused == true))[0] // .[0])
  | .pane_id // empty
')

herdr pane split --pane "$pane" --direction right --cwd "$directory" --focus
