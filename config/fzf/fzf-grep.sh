# FZF Live Grep with Tmux popup
function fzf-grep() {
	local root
	if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		if git check-ignore -q .; then
			root=$(pwd)
		else
			root=$(git rev-parse --show-toplevel)
		fi
	else
		root=$(pwd)
	fi

	local rg_cmd='rg --column --line-number --no-heading --color=always --smart-case --no-ignore-vcs --glob "!**/node_modules/**" --glob "!**/vendor/**"'

	local preview_cmd="cat {1}"
	if command -v batcat >/dev/null; then
		preview_cmd="batcat --style=numbers --color=always --highlight-line {2} {1}"
	elif command -v bat >/dev/null; then
		preview_cmd="bat --style=numbers --color=always --highlight-line {2} {1}"
	fi

	local selected
	selected=$(
		cd "$root" && \
		printf '' | FZF_DEFAULT_OPTS='' command fzf \
		--ansi \
		--tmux 80% \
		--phony \
		--query "$*" \
		--bind "start:reload:$rg_cmd -- {q}" \
		--bind "change:reload:$rg_cmd -- {q} || true" \
		--delimiter ':' \
		--preview "$preview_cmd" \
		--preview-window 'right,60%,border-left'
	)

	if [ -n "$selected" ]; then
		local clean
		clean=$(echo "$selected" | sed 's/\x1b\[[0-9;]*m//g')

		local file line
		file=$(echo "$clean" | cut -d: -f1)
		line=$(echo "$clean" | cut -d: -f2)

		[ -n "$file" ] && nvim "+$line" "$root/$file"
	fi
}

fzf-grep-widget() {
	fzf-grep
	zle reset-prompt
}
zle -N fzf-grep-widget
bindkey '^[w' fzf-grep-widget
