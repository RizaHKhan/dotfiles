#!user/bin/env bash

sesh connect "$(
	sesh list --icons --hide-duplicates | fzf --no-border \
		--ansi \
		--no-sort --prompt 'sesh > ' \
		--preview-window 'right:70%' \
		--preview 'sesh preview {}'
)"
