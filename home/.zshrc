# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -e "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ~/.zshrc - ZSH configuration

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   PATH manipulation functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
pathAppend (){
  pathRemove "$1"
  export PATH="$PATH:$1"
}

pathPrepend (){
  pathRemove "$1"
  export PATH="$1:$PATH"
}

pathRemove (){
  PATH=$(echo -n $PATH | awk -v RS=: -v ORS=: '$0 != "'$1'"' | sed 's/:$//')
  export PATH
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Colours
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

unset LSCOLORS
export CLICOLOR=1

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   brew
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Check where brew is installed & set ${brewPrefix}
# Use ${brewPrefix} instead of $(brew --prefix) when needed
if [ -x /opt/homebrew/bin/brew ]; then
  # Apple Silicon
  brewPrefix=/opt/homebrew
elif [ -x /usr/local/bin/brew ]; then
  # Apple Intel
  brewPrefix=/usr/local
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  # Linux
  brewPrefix=/home/linuxbrew/.linuxbrew
fi

# Add brew bins to beginning of path if installed
if command -v "${brewPrefix}/bin/brew" >/dev/null 2>&1; then
  for directory in "${brewPrefix}/sbin" "${brewPrefix}/bin"; do
    if [[ -d "${directory}" ]]; then
      pathPrepend "${directory}"
    fi
  done
  unset directory
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Command completion
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Enable completions from brew installed apps
if command -v brew >/dev/null 2>&1; then
  FPATH="${brewPrefix}/share/zsh/site-functions:${FPATH}"
fi

autoload -Uz compinit
compinit
# Complete command line switches for aliases
setopt COMPLETE_ALIASES
# Case insensitive completions
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   History
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
# Immediately append to history file:
setopt INC_APPEND_HISTORY
# Record timestamp in history:
setopt EXTENDED_HISTORY
# Expire duplicate entries first when trimming history:
setopt HIST_EXPIRE_DUPS_FIRST
# Dont record an entry that was just recorded again:
setopt HIST_IGNORE_DUPS
# Delete old recorded entry if new entry is a duplicate:
setopt HIST_IGNORE_ALL_DUPS
# Do not display a line previously found:
setopt HIST_FIND_NO_DUPS
# Dont record an entry starting with a space:
setopt HIST_IGNORE_SPACE
# Dont write duplicate entries in the history file:
setopt HIST_SAVE_NO_DUPS
# Share history between all sessions:
setopt SHARE_HISTORY

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Options
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Keybindings: e = Emacs mode, v = Vim mode
bindkey -e
setopt AUTO_CD
setopt CORRECT

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Add directories to PATH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

for directory in "${HOME}/.local/bin" "/usr/local/sbin" "${HOME}/.local/bin/fzf/bin"; do
  if [[ -d "${directory}" ]]; then
    pathAppend "${directory}"
  fi
done
unset directory

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Plugins
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# plugins=(git brew history kubectl history-substring-search)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Prompt
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [[ -f "${HOME}/.config/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  # powerline10k prompt
  source "${HOME}/.config/powerlevel10k/powerlevel10k.zsh-theme"
  if [[ -f "${HOME}/.p10k.zsh" ]]; then
    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    source "${HOME}/.p10k.zsh"
  fi
else
  # Basic prompt
  if [[ "${UID}" -eq "0" ]]; then
    # Root prompt
    PS1='%F{red}%n%f@%F{yellow}%m%f %F{blue}%~%f %(?.%F{green}>.%F{red}>)%f '
  else
    if [[ ${SSH_TTY} ]]; then
      # User prompt over SSH
      PS1='%F{green}%n%f@%F{yellow}%m%f %F{blue}%~%f %(?.%F{green}>.%F{red}>)%f '
    else
      # Local user prompt
      PS1='%F{blue}%~%f %(?.%F{green}>.%F{red}>)%f '
    fi
  fi
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Window title
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

case $TERM in
  xterm*|rxvt*)
    precmd () { print -Pn "\e]0;%1~ [%m]\a" }
    ;;
esac

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Aliases
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Reload config
alias reload='source ~/.zshrc'

# Source alias files from ~/.config/aliases/
for file in ~/.config/aliases/*; do
  if [[ -f "${file}" ]]; then
    source "${file}"
  fi
done
unset file

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   direnv
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Editor
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [[ -f /usr/bin/vim ]]; then
  export VISUAL="/usr/bin/vim"
  export EDITOR="/usr/bin/vim"
  export SUDO_EDITOR="/usr/bin/vim"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

up() {
  # Moves up the directory tree a {number} of times
  # Usage: up {number}
  TIMES=$1

  if [[ -z "${TIMES}" ]]; then
    TIMES=1
  fi
  while [[ ${TIMES} -gt 0 ]]; do
    cd ..
    TIMES=$((TIMES - 1))
  done
}

rmrecursive() {
  # Deletes the specified file recursively
  # Usage: rmrecursive "*.bak"
  find . -type f -name "$1" -delete
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Fuzzy finder - fzf
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Determine fzf config path
if [[ -d "${HOME}/.local/bin/fzf/shell" ]]; then
  # Git
  fzf_config_path="${HOME}/.local/bin/fzf/shell"
elif [[ -d "/usr/share/doc/fzf/examples" ]]; then
  # Debian (apt)
  fzf_config_path="/usr/share/doc/fzf/examples"
elif command -v brew >/dev/null 2>&1; then
  # Mac (brew)
  fzf_config_path="${brewPrefix}/opt/fzf/shell"
fi

# Completion config
if [[ -f "$fzf_config_path/completion.zsh" ]]; then
  [[ $- == *i* ]] && source "$fzf_config_path/completion.zsh" 2> /dev/null
fi

# Key binding config
if [[ -f "$fzf_config_path/key-bindings.zsh" ]]; then
  source "$fzf_config_path/key-bindings.zsh"
fi

# fzf config
if command -v fzf >/dev/null 2>&1; then
  # Default options
  export FZF_DEFAULT_OPTS="
  --layout=reverse
  --height=80%
  --multi
  --preview-window=:hidden
  --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
  --color=16
  --bind '?:toggle-preview'
  --bind 'ctrl-a:select-all'
  --bind 'ctrl-s:execute(subl {+})'
  "

  # Completion trigger
  # export FZF_COMPLETION_TRIGGER='**'

  # fzf's command
  export FZF_DEFAULT_COMMAND="fd --hidden --exclude '.Trash' --exclude '.git'"
  # CTRL-T's command
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  # ALT-C's command
  export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Less
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

export LESS_TERMCAP_mb=$'\e[31m'        # begin bold
export LESS_TERMCAP_md=$'\e[36m'        # begin blink
export LESS_TERMCAP_so=$'\e[01;44;37m'  # begin reverse video
export LESS_TERMCAP_us=$'\e[01;37m'     # begin underline
export LESS_TERMCAP_me=$'\e[0m'         # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'         # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'         # reset underline
export GROFF_NO_SGR=1                   # for konsole and gnome-terminal
export LESS="-giR"                      # see man less
