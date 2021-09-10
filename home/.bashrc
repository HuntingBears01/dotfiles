# shellcheck disable=SC2148
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "${PS1}" ] && return


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Bash Configuration
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# don't put duplicate lines or lines starting with space in the history.
export HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Add directories to path if they exist
for directory in "${HOME}/.local/bin" "/usr/local/opt/fzf/bin" "/usr/local/sbin"; do
  if [[ -d ${directory} ]]; then
    if [[ ! ${PATH} == *${directory}* ]]; then
      PATH=${PATH}:${directory}
    fi
  fi
done
unset directory

# Silence Bash warnings in MacOS
export BASH_SILENCE_DEPRECATION_WARNING=1


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Colours
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Base16 Shell
BASE16_SHELL="${HOME}/.config/base16-shell/"
if [[ -n "$PS1" ]]; then
  if [[ -s "${BASE16_SHELL}/profile_helper.sh" ]]; then
    eval "$("${BASE16_SHELL}/profile_helper.sh")"
  fi
fi
if [[ -d ${HOME}/.config/base16-shell/hooks ]]; then
  export BASE16_SHELL_HOOKS="${HOME}/.config/base16-shell/hooks"
fi

# Setup colours
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  tput sgr0 # reset colors

  reset=$(tput sgr0)
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  blue=$(tput setaf 4)
  white=$(tput setaf 7)
  grey=$(tput setaf 8)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "${TERM}" in
  xterm-color) color_prompt=yes;;
esac

# enable coloured prompt
force_color_prompt=yes

if [ -n "${force_color_prompt}" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support, assume it is compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "${color_prompt}" = yes ]; then
  # Highlight the user name when logged in as root
  if [[ "${UID}" -eq "0" ]]; then
    userStyle="${red}"
  else
    userStyle="${green}"
  fi
  # Only show the server name when connected via SSH
  if [[ ${SSH_TTY} ]]; then
    PS1='\[$userStyle\]\u\[$grey\]@\[$yellow\]\h\[$grey\]:\[$blue\]\w \[$white\]\$\[$reset\] '
  else
    PS1='\[$userStyle\]\u\[$grey\]:\[$blue\]\w \[$white\]\$\[$reset\] '
  fi
else
  # Fallback option
  PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title
case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;\W [\H]\a\]$PS1"
    ;;
  *)
    ;;
esac


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Useful Tweaks
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
if [ -e "${HOME}/.ssh/config" ]; then
  complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh
fi

# enable programmable completion features
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  source /etc/bash_completion
fi

# Source any files in ~/.private/
# Place files that shouldn't be commited to a public repo here
for file in ~/.private/*; do
  if [[ -f "${file}" ]]; then
    source "${file}"
  fi
done
unset file


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Other Applications
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set default editor
export VISUAL="/usr/bin/vim"
export EDITOR="/usr/bin/vim"
export SUDO_EDITOR="/usr/bin/vim"

# Configure less
export LESS_TERMCAP_mb=$'\e[31m'        # begin bold
export LESS_TERMCAP_md=$'\e[36m'        # begin blink
export LESS_TERMCAP_so=$'\e[01;44;37m'  # begin reverse video
export LESS_TERMCAP_us=$'\e[01;37m'     # begin underline
export LESS_TERMCAP_me=$'\e[0m'         # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'         # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'         # reset underline
export GROFF_NO_SGR=1                   # for konsole and gnome-terminal
export LESS="-giR"                      # see man less

# Configure colours
export LS_COLORS="di=00;34:ow=00;34:ln=00;35:ex=00;31:or=00;37;101:su=01;41;37:sg=01;41;37"

# Add Brew auto completion
if [ -f /usr/local/etc/bash_completion ]; then
  source /usr/local/etc/bash_completion
fi


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
#  Aliases
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Source any files in ~/.config/aliases/
for file in ~/.config/aliases/*; do
  if [[ -f "${file}" ]]; then
    source "${file}"
  fi
done
unset file


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

up() {
  # Moves up the directory tree a {number} of times
  # Usage: up {number}
  TIMES=$1

  if [ -z "${TIMES}" ]; then
    TIMES=1
  fi
  while [ ${TIMES} -gt 0 ]; do
    cd ..
    TIMES=$((TIMES - 1))
  done
}

rmrecursive() {
  # Deletes the specified file recursively
  # Usage: rmrecursive "*.bak"
  find . -type f -name "$1" -delete
}
