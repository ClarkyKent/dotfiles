# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# === Missing tools notification system ===
typeset -ga __missing_tools=()

_check_tool() {
    local tool=$1
    local install_hint=$2
    if ! command -v "$tool" &>/dev/null; then
        __missing_tools+=("$tool|$install_hint")
        return 1
    fi
    return 0
}

_show_missing_tools() {
    if [[ ${#__missing_tools[@]} -gt 0 ]]; then
        print -P "\n%F{yellow}⚠ Missing tools detected:%f"
        for entry in "${__missing_tools[@]}"; do
            local tool="${entry%%|*}"
            local hint="${entry#*|}"
            print -P "  %F{red}•%f $tool %F{8}($hint)%f"
        done
        print ""
        __missing_tools=()
        add-zsh-hook -d precmd _show_missing_tools
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _show_missing_tools

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
export PATH="$PATH:$HOME/.local/bin"
# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone --quiet https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::pip
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Check tools used in aliases
_check_tool eza "brew install eza"
_check_tool nvim "brew install neovim"

# Aliases: editor
alias e="$EDITOR"
alias E="sudo -e"

# Aliases: ls
alias l='eza -GA --group-directories-first --color=always --icons=auto --git-ignore'
alias ls='l'
alias la='l -l --time-style="+%Y-%m-%d %H:%M" --no-permissions --octal-permissions'
alias tree='l --tree'

# Aliases: git
alias ga='git add'
alias gap='ga --patch'
alias gb='git branch'
alias gba='gb --all'
alias gc='git commit'
alias gca='gc --amend --no-edit'
alias gce='gc --amend'
alias gco='git checkout'
alias gcl='git clone --recursive'
alias gd='git diff --output-indicator-new=" " --output-indicator-old=" "'
alias gds='gd --staged'
alias gi='git init'
alias gl='git log --graph --all --pretty=format:"%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n"'
alias gm='git merge'
alias gn='git checkout -b'  # new branch
alias gp='git push'
alias gr='git reset'
alias gs='git status --short'
alias gu='git pull'
alias vim='nvim'
alias c='clear'
# alias cat='batcat'

# Shell integrations
_check_tool fzf "brew install fzf" && eval "$(fzf --zsh)"
_check_tool zoxide "brew install zoxide" && eval "$(zoxide init --cmd cd zsh)"
_check_tool direnv "brew install direnv" && eval "$(direnv hook zsh)"

if [[ -e /home/quara/.nix-profile/etc/profile.d/nix.sh ]]; then
    . /home/quara/.nix-profile/etc/profile.d/nix.sh
fi

if [[ -f /home/quara/.config/broot/launcher/bash/br ]]; then
    source /home/quara/.config/broot/launcher/bash/br
else
    __missing_tools+=("broot|brew install broot && broot --install")
fi
export ZED_ALLOW_EMULATED_GPU=1
alias zed="WAYLAND_DISPLAY= zed"

# opencode
export PATH=/home/quara/.opencode/bin:$PATH

GITSTATUS_LOG_LEVEL=DEBUG
autoload -U compinit; compinit
