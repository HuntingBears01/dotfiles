# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ~/.zshrc - ZSH configuration

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Colours
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

unset LSCOLORS
export CLICOLOR=1

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Command completion
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

autoload -Uz compinit
compinit
# Complete command line switches for aliases
setopt COMPLETE_ALIASES
# Case insensitive completions
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   History
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE
setopt HIST_VERIFY

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Options
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Keybindings: e = Emacs mode, v = Vim mode
bindkey -e
setopt AUTO_CD
setopt CORRECT

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Path
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

for directory in "${HOME}/.local/bin" "/usr/local/opt/fzf/bin" "/usr/local/sbin"; do
  if [[ -d ${directory} ]]; then
    if [[ ! ${PATH} == *${directory}* ]]; then
      PATH=${PATH}:${directory}
    fi
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
    PS1='%F{red}%n%f@%F{yellow}%m%f %F{blue}%~%f %# '
  else
    if [[ ${SSH_TTY} ]]; then
      # User prompt over SSH
      PS1='%F{green}%n%f@%F{yellow}%m%f %F{blue}%~%f %# '
    else
      # Local user prompt
      PS1='%F{green}%n%f %F{blue}%~%f %# '
    fi
  fi

  # Right hand side prompt
  RPROMPT='%* %(?.%F{green}✓.%F{red}✗)%f'
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
alias reload='. ~/.zshrc'

# Source alias files from ~/.config/aliases/
for file in ~/.config/aliases/*; do
  if [[ -f "${file}" ]]; then
    source "${file}"
  fi
done
unset file

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Base16 Shell
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

BASE16_SHELL="${HOME}/.config/base16-shell/"
if [[ -n "$PS1" ]]; then
  if [[ -s "${BASE16_SHELL}/profile_helper.sh" ]]; then
    eval "$("${BASE16_SHELL}/profile_helper.sh")"
  fi
fi
if [[ -d ${HOME}/.config/base16-shell/hooks ]]; then
  export BASE16_SHELL_HOOKS="${HOME}/.config/base16-shell/hooks"
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

if [[ -f "/usr/local/opt/fzf/shell/completion.zsh" ]]; then
  # Auto-completion
  [[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

  # Key bindings
  source "/usr/local/opt/fzf/shell/key-bindings.zsh"
  bindkey "ç" fzf-cd-widget # Make ALT-C work on MacOS

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