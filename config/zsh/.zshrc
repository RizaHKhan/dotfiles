# XDG base directories keep application state out of the home-directory root.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Personal credentials and machine-specific overrides intentionally live outside
# this repository. Copy .zshrc.local.example to ~/.zshrc.local if needed.
if [[ -r "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
elif [[ -r "$HOME/.env" ]]; then
  # Compatibility for the pre-Ansible setup; move values to .zshrc.local.
  source "$HOME/.env"
fi

# Only run the interactive setup below in interactive shells.
[[ ! -o interactive ]] && return

[[ -r "$HOME/.config/alias/.alias" ]] && source "$HOME/.config/alias/.alias"
[[ -r "$HOME/.config/alias/.custom" ]] && source "$HOME/.config/alias/.custom"
[[ -r "$HOME/.config/alias/.macos" ]] && source "$HOME/.config/alias/.macos"
[[ -r "$HOME/.config/alias/.fzf" ]] && source "$HOME/.config/alias/.fzf"
[[ -r "$HOME/.config/alias/.functions" ]] && source "$HOME/.config/alias/.functions"

set -o vi
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER='nvim +Man!'

export PATH="/opt/homebrew/bin:/opt/homebrew/opt/openssh/bin:$HOME/.config/scripts:$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export GOBIN="$HOME/go/bin"
export LUA_PATH="lua/?.lua;lua/?/init.lua;;"

alias zshrc='nvim ~/.zshrc'
alias ld='lazydocker'
alias lg='lazygit'
alias t='tmux'
alias ta='tmux attach'
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -alF --icons --color=always --group-directories-first'
alias la='eza -a --icons --color=always --group-directories-first'
alias l='eza -F --icons --color=always --group-directories-first'

# zsh-autosuggestions, zsh-vi-mode, syntax highlighting, and fzf-tab.
fpath+=("/opt/homebrew/share/zsh-completions")
autoload -Uz compinit
_zcompdump_dir="${XDG_CACHE_HOME}/zsh"
[[ -d $_zcompdump_dir ]] || mkdir -p "$_zcompdump_dir"
compinit -i -d "$_zcompdump_dir/zcompdump"

[[ -r /opt/homebrew/share/fzf-tab/fzf-tab.zsh ]] && source /opt/homebrew/share/fzf-tab/fzf-tab.zsh
[[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -r /opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]] && source /opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
[[ -r /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[[ -r /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh

(( $+commands[fzf] && $+commands[bat] )) && [[ -r "$HOME/.config/fzf/fzf-git.sh" ]] && source "$HOME/.config/fzf/fzf-git.sh"
(( $+commands[fzf] && $+commands[bat] )) && [[ -r "$HOME/.config/fzf/fzf-grep.sh" ]] && source "$HOME/.config/fzf/fzf-grep.sh"

(( $+commands[atuin] )) && eval "$(atuin init zsh)"
(( $+commands[thefuck] )) && eval "$(thefuck --alias)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[mise] )) && eval "$(mise activate zsh)"
if (( $+commands[starship] )) && [[ -z "${__STARSHIP_INIT_DONE:-}" ]]; then
  eval "$(starship init zsh)"
  __STARSHIP_INIT_DONE=1
fi

zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' fzf-flags --height=30% --layout=reverse --style=minimal --preview-window=right
zstyle ':fzf-tab:*' fzf-bindings 'tab:accept'
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:complete:*' fzf-preview 'if [[ -d $realpath ]]; then eza -1 --icons --color=always --group-directories-first -- $realpath; else bat --style=numbers --color=always --line-range=:200 -- $realpath; fi'

setopt inc_append_history hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups
unsetopt share_history

y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [[ -n $cwd && $cwd != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}
