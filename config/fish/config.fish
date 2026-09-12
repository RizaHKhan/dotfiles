# Interactive Fish configuration managed by Ansible.
# Keep machine-specific credentials and overrides in ~/.config/fish/local.fish.

if test -r "$HOME/.config/fish/local.fish"
    source "$HOME/.config/fish/local.fish"
end

# Keep Homebrew and user-installed tools available in every Fish session.
fish_add_path --prepend /opt/homebrew/bin /opt/homebrew/opt/openssh/bin /opt/homebrew/opt/ruby/bin \
    "$HOME/.config/scripts" "$HOME/.local/bin" "$HOME/go/bin" "$HOME/.cargo/bin" \
    /usr/local/bin

set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx MANPAGER 'nvim +Man!'
set -gx GOBIN "$HOME/go/bin"
set -gx LUA_PATH 'lua/?.lua;lua/?/init.lua;;'

# Use Fish's native vi-style command-line editing.
fish_vi_key_bindings

# In vi normal mode, `yy` copies the command line to the system clipboard.
bind --mode default yy fish_clipboard_copy

# Shared tool integrations. Each command is optional so a partial install remains usable.
if type -q fzf
    fzf --fish | source
end
if type -q atuin
    atuin init fish | source
    # In vi normal mode, use `k` for Atuin history search. Insert-mode `k` is unchanged.
    bind --mode default k _atuin_search
end
if type -q zoxide
    zoxide init fish | source
end
if type -q mise
    mise activate fish | source
end

alias reload 'exec fish -l'
alias ld lazydocker
alias lg lazygit
alias cls clear
alias cl clear
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias cd z
alias dl 'cd ~/Downloads'
alias h history
alias ls 'eza --icons --color=always --group-directories-first'
alias ll 'eza -alF --icons --color=always --group-directories-first'
alias la 'eza -a --icons --color=always --group-directories-first'
alias l 'eza -F --icons --color=always --group-directories-first'
alias cpwd "pwd | tr -d '\n' | pbcopy"
alias cat bat
alias how tldr
alias pcopy pbcopy
alias ppaste pbpaste
alias v 'nvim .'
alias vim nvim
alias cursor cursor-agent
alias g git
alias gs 'git status'
alias gd 'git diff'
alias ga 'git add'
alias gc 'git commit'
alias gcm 'git commit -m'
alias gpush 'git push'
alias gpull 'git pull'
alias lg lazygit
alias scan 'nmap -Pn -F -sV'
alias dig doggo

function cpath
    if not test -e "$argv[1]"
        echo 'usage: cpath <file-or-directory>' >&2
        return 1
    end
    string join '' (realpath "$argv[1]") | pbcopy
end

function groot
    set -l root (git rev-parse --show-toplevel 2>/dev/null)
    and cd "$root"
end

function y
    set -l tmp (mktemp -t yazi-cwd.XXXXXX)
    yazi $argv --cwd-file="$tmp"
    if test -r "$tmp"
        set -l cwd (string collect < "$tmp")
        if test -n "$cwd"; and test "$cwd" != "$PWD"
            cd "$cwd"
        end
    end
    rm -f -- "$tmp"
end
