# shellcheck disable=SC2148
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "${PS1}" ] && return


#------------------------------------------------------------------------------
# >> Bash Configuration
#------------------------------------------------------------------------------

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

# Set default permissions
umask 0027

# Add ~/bin to path if it exists
if [[ -d ~/bin ]];then
  PATH=${PATH}:${HOME}/bin
fi


#------------------------------------------------------------------------------
# >> Colours
#------------------------------------------------------------------------------

# Setup colours
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  tput sgr0 # reset colors

  reset=$(tput sgr0)
  red=$(tput setaf 9)
  green=$(tput setaf 10)
  yellow=$(tput setaf 11)
  blue=$(tput setaf 12)
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
  fi;

  # Highlight the server name when connected via SSH
  if [[ ${SSH_TTY} ]]; then
    srvStyle="${yellow}"
  else
    srvStyle="${green}"
  fi;

  PS1='\[$userStyle\]\u\[$grey\]@\[$srvStyle\]\h\[$blue\] \w \[$white\]\$\[$reset\] '
else
  PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt


#------------------------------------------------------------------------------
# >> Useful Tweaks
#------------------------------------------------------------------------------

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
if [ -e "${HOME}/.ssh/config" ]; then
  complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh
fi

# enable programmable completion features
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  # shellcheck disable=SC1091
  . /etc/bash_completion
fi

# Source any files in ~/.private/
# Place files that shouldn't be commited to a public repo here
for file in ~/.private/*; do
  # shellcheck disable=SC1090
  [ -r "${file}" ] && [ -f "${file}" ] && . "${file}";
done;
unset file;


#------------------------------------------------------------------------------
# >> Other Applications
#------------------------------------------------------------------------------

# Set default editor
export VISUAL="/usr/bin/vim"
export EDITOR="/usr/bin/vim"
export SUDO_EDITOR="/usr/bin/vim"

# Set less colors
export LESS_TERMCAP_mb=$'\e[31m'        # begin bold
export LESS_TERMCAP_md=$'\e[36m'        # begin blink
export LESS_TERMCAP_so=$'\e[01;44;37m'  # begin reverse video
export LESS_TERMCAP_us=$'\e[01;37m'     # begin underline
export LESS_TERMCAP_me=$'\e[0m'         # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'         # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'         # reset underline
export GROFF_NO_SGR=1                   # for konsole and gnome-terminal


#------------------------------------------------------------------------------
# >> Aliases
#------------------------------------------------------------------------------

if [ -f /etc/os-release ]; then
  # Linux specific section
  # Enable color support for ls
  if [ -x /usr/bin/dircolors ]; then
    alias ls='ls -v --color=auto'
  fi
  # shellcheck disable=SC1091
  . /etc/os-release
  os="${ID}"
  case "${os}" in
    debian | ubuntu )
      alias updy='sudo apt update && sudo apt upgrade -y'
      ;;
    centos )
      alias updy='sudo yum update -y'
      ;;
    fedora )
      alias updy='sudo dnf update -y'
      ;;
    opensuse )
      alias updy='sudo zypper refresh && sudo zypper update -y'
      ;;
  esac
elif [[ "$( uname -s )" = "Darwin" ]] > /dev/null 2>&1; then
  # OS X specific section
  alias updy='brew update && brew upgrade'
  alias flushdns='sudo killall -HUP mDNSResponder'
  alias sudoedit='sudo vim'
  # Use GNU coreutils if installed
  if [ -x /usr/local/bin/gls ]; then
    alias ls='gls -v --color=auto'
    alias md5sum='gmd5sum'
    alias sha1sum='gsha1sum'
    alias sha224sum='gsha224sum'
    alias sha256sum='gsha256sum'
    alias sha384sum='gsha384sum'
    alias sha512sum='gsha512sum'
  else
    alias ls='ls -G'
    export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
  fi
  # Add /usr/local/sbin to path for Brew
  export PATH="/usr/local/sbin:${PATH}"
  # Add Brew auto completion
  # shellcheck disable=SC1091
  [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
fi



export LS_COLORS="di=00;94:ow=00;94:ln=00;95:ex=00;91:or=00;97;101:su=01;41;97:sg=01;41;97"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias la='ls -a'
alias ll='ls -lh'
alias lla='ls -lha'
alias reload='. ~/.bashrc'
alias vi='vim'
alias cls='clear'
alias sudo='sudo -E'

# Aliases for commonly edited files
# Format: "filename relative to $HOME":alias
for file in\
    ".vimrc":vimrc ".bashrc":bashrc\
    ".config/i3/config":i3c ".config/compton.conf":compc
  do
    if [ -f "$HOME/${file%:*}" ]; then
      alias ${file/*:}="vim $HOME/${file%:*}"
    fi
  done

# Aliases for commonly edited root owned files
# Format: "filename relative to $HOME":alias
for file in\
    "/etc/hosts":hosts "/etc/fstab":fstab "/etc/modules":modules
  do
    if [ -f "${file%:*}" ]; then
      alias ${file/*:}="sudoedit ${file%:*}"
    fi
  done

# Aliases for commonly used directories
# Format: "directory relative to $HOME":alias
for dir in\
    "Music":mus "Videos":vid "Desktop":dt "Pictures":pic\
    "Downloads":dl "Documents":doc "Archive":arc "Dropbox":dbx
  do
    if [ -d "$HOME/${dir%:*}" ]; then
      alias ${dir/*:}="cd $HOME/${dir%:*} && ls"
    fi
  done


#------------------------------------------------------------------------------
# >> Functions
#------------------------------------------------------------------------------

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
