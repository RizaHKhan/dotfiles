#!/usr/bin/env zsh
############################
# Render ~/.config/nvim/.env from 1Password (`op read`).
# Mirrors ansible/roles/dotfiles/templates/nvim-env.j2 so `make nvim-env`
# produces the same file without running the playbook.
############################

set -euo pipefail

ENV_FILE="${NVIM_ENV_FILE:-$HOME/.config/nvim/.env}"
DOTFILES="${DOTFILES:-$HOME/dotfiles}"
VARS_FILE="$DOTFILES/ansible/group_vars/all/defaults.yml"

if ! command -v op >/dev/null 2>&1; then
    print -P "%F{red}error:%f 1Password CLI (\`op\`) not found in PATH" >&2
    exit 1
fi

if [[ ! -f "$VARS_FILE" ]]; then
    print -P "%F{red}error:%f vars file not found: $VARS_FILE" >&2
    exit 1
fi

# Parse the atlas block out of defaults.yml into KEY=VALUE lines.
# Keep this script in sync with ansible vars instead of duplicating refs.
ATLAS_VARS="$(
    awk '/^atlas:/ { in_atlas=1; next }
        in_atlas && /^  [a-z]+:/ { section=$1; next }
        in_atlas && /:/ {
            line=$0; sub(/^[[:space:]]+/, "", line)
            key=line; sub(/:.*/, "", key)
            val=line; sub(/^[^:]+:[[:space:]]*/, "", val)
            gsub(/^"|"$/, "", val)
            print section key ":" val
        }' "$VARS_FILE"
)"
get_var() { print "$ATLAS_VARS" | sed -n "s/^$1://p" | head -1; }

BITBUCKET_USER="$(get_var bitbucket:user)"
BITBUCKET_OP_REF="$(get_var bitbucket:credential_op_ref)"
JIRA_OP_REF="$(get_var jira:credential_op_ref)"
JIRA_BASE_URL="$(get_var jira:base_url)"
JIRA_EMAIL="$(get_var jira:email)"

if [[ -z "$BITBUCKET_USER" || -z "$BITBUCKET_OP_REF" ]]; then
    print -P "%F{red}error:%f could not parse atlas vars from $VARS_FILE" >&2
    exit 1
fi

print "Reading secrets from 1Password..."
BITBUCKET_TOKEN="$(op read "$BITBUCKET_OP_REF" --no-newline 2>/dev/null || true)"
JIRA_TOKEN="$(op read "$JIRA_OP_REF" --no-newline 2>/dev/null || true)"

# Empty values are omitted so the vim.env fallback in atlas.lua still works.
{
    print "BITBUCKET_USER=\"$BITBUCKET_USER\""
    [[ -n "$BITBUCKET_TOKEN" ]] && print "BITBUCKET_TOKEN=\"$BITBUCKET_TOKEN\""
    [[ -n "$JIRA_BASE_URL" ]] && print "JIRA_BASE_URL=\"$JIRA_BASE_URL\""
    [[ -n "$JIRA_EMAIL" ]] && print "JIRA_EMAIL=\"$JIRA_EMAIL\""
    [[ -n "$JIRA_TOKEN" ]] && print "JIRA_TOKEN=\"$JIRA_TOKEN\""
} > "$ENV_FILE"
chmod 600 "$ENV_FILE"

print -P "%F{green}wrote%f $ENV_FILE"
print "  BITBUCKET_USER=$BITBUCKET_USER"
[[ -n "$BITBUCKET_TOKEN" ]] && print "  BITBUCKET_TOKEN=${BITBUCKET_TOKEN:0:12}… (${#BITBUCKET_TOKEN} chars)"
[[ -n "$JIRA_BASE_URL" ]] && print "  JIRA_BASE_URL=$JIRA_BASE_URL"
[[ -n "$JIRA_EMAIL" ]] && print "  JIRA_EMAIL=$JIRA_EMAIL"
[[ -n "$JIRA_TOKEN" ]] && print "  JIRA_TOKEN=${JIRA_TOKEN:0:12}… (${#JIRA_TOKEN} chars)"
print -P "%F{yellow}note:%f restart nvim for atlas.nvim to pick up changes"