# ~/.bashrc - Bash configuration

# shellcheck disable=SC2148
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# ~/.bashrc: executed by bash(1) for non-login shells.


# If not running interactively, don't do anything
[[ -z "${PS1}" ]] && return

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Colours
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Setup colour variables
if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
  tput sgr0 # reset colors

  reset=$(tput sgr0)
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  blue=$(tput setaf 4)
  white=$(tput setaf 7)
  grey=$(tput setaf 8)
fi

export LS_COLORS="di=00;34:ow=00;34:ln=00;35:ex=00;31:or=00;37;101:su=01;41;37:sg=01;41;37"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Command completion
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Autocorrect typos in path names whne using cd
shopt -s cdspell

# Case insensitive globbing
shopt -s nocaseglob

if [[ -f /etc/bash_completion ]] && ! shopt -oq posix; then
  source /etc/bash_completion
fi

if [[ -e "${HOME}/.ssh/config" ]]; then
  complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   History
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Options
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Check windows size nafter each command and update values of LINES & COLUMNS
shopt -s checkwinsize

# Silence Bash warnings in MacOS
export BASH_SILENCE_DEPRECATION_WARNING=1

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
#   Prompt
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [[ "${UID}" -eq "0" ]]; then
  # Root prompt
  PS1='\[$red\]\u\[$grey\]@\[$yellow\]\h\[$grey\]:\[$blue\]\w \[$white\]\$\[$reset\] '
else
  if [[ ${SSH_TTY} ]]; then
    # User prompt over SSH
    PS1='\[$green\]\u\[$grey\]@\[$yellow\]\h\[$grey\]:\[$blue\]\w \[$white\]\$\[$reset\] '
  else
    # Local user prompt
    PS1='\[$green\]\u\[$grey\]:\[$blue\]\w \[$white\]\$\[$reset\] '
  fi
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Window title
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;\W [\h]\a\]$PS1"
    ;;
  *)
    ;;
esac

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Aliases
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Reload config
alias reload='. ~/.bashrc'

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
#  Brew auto completion
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [[ -f /usr/local/etc/bash_completion ]]; then
  source /usr/local/etc/bash_completion
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

if [[ -f "/usr/local/opt/fzf/shell/completion.bash" ]]; then
  # Auto-completion
  [[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.bash" 2> /dev/null

  # Key bindings
  source "/usr/local/opt/fzf/shell/key-bindings.bash"

  # Default options
  export FZF_DEFAULT_OPTS="
  --layout=reverse
  --height=80%
  --multi
  --preview-window=:hidden
  --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
  --color=16
  --bind '?:toggle-preview'
  --bind 'ctrl-s:execute(subl {+})'
  "

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
