#!/usr/bin/env bash
set -eo pipefail

HERDR_WORKSPACE_ID=$(herdr workspace list 2>/dev/null | jq -r '.result.workspaces[] | select(.focused == true) | .workspace_id')

PANES=$(herdr pane list --workspace "$HERDR_WORKSPACE_ID" 2>/dev/null | jq -r '.result.panes[] | .pane_id')

printf '%s\n' $PANES
