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
if command -v "${brewPrefix}"/bin/brew >/dev/null 2>&1; then
  for directory in "${brewPrefix}/sbin" "${brewPrefix}/bin"; do
    if [[ -d ${directory} ]]; then
      if [[ ! ${PATH} == *${directory}* ]]; then
        PATH=${directory}:${PATH}
      fi
    fi
  done
  unset directory
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Command completion
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Autocorrect typos in path names whne using cd
shopt -s cdspell

# Case insensitive globbing
shopt -s nocaseglob

# Enable completions from brew installed apps
if command -v brew >/dev/null 2>&1; then
  if [[ -r "${brewPrefix}/etc/profile.d/bash_completion.sh" ]]
  then
    source "${brewPrefix}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${brewPrefix}/etc/bash_completion.d/"*
    do
      [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
    done
  fi
fi

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
    PS1='\[$blue\]\w \[$white\]\$\[$reset\] '
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
if [[ -f "$fzf_config_path/completion.bash" ]]; then
  [[ $- == *i* ]] && source "$fzf_config_path/completion.bash" 2> /dev/null
fi

# Key binding config
if [[ -f "$fzf_config_path/key-bindings.bash" ]]; then
  source "$fzf_config_path/key-bindings.bash"
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   direnv
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
eval "$(direnv hook bash)"
