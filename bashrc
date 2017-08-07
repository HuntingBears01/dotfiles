# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

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

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && [ -s "$BASE16_SHELL/profile_helper.sh" ] && eval "$("$BASE16_SHELL/profile_helper.sh")"

# Setup colours
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  tput sgr0 # reset colors

  reset=$(tput sgr0)

  # base16 colours https://chriskempson.github.io/base16/
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  blue=$(tput setaf 4)
  white=$(tput setaf 7)
  grey=$(tput setaf 8)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  # Highlight the user name when logged in as root
  if [[ "${UID}" -eq "0" ]]; then
    userStyle="${red}";
  else
    userStyle="${green}";
  fi;

  # Highlight the server name when connected via SSH
  if [[ $SSH_TTY ]]; then
    srvStyle="${yellow}";
  else
    srvStyle="${green}";
  fi;

  PS1='\[$userStyle\]\u\[$grey\]@\[$srvStyle\]\h\[$blue\] \w \[$white\]\$\[$reset\] '
else
  PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host
case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;\u@\h\a\]$PS1"
    ;;
  *)
    ;;
esac

# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  if [[ -r ~/.dircolors ]];then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='ls --color=auto'
fi

# OS X specific section
if [ "$(uname -s)" = "Darwin" ]; then
  # Use GNU coreutils if installed
  if [ -x /usr/local/bin/gls ]; then
    alias ls='gls --color=auto'
    alias md5sum='gmd5sum'
    alias sha1sum='gsha1sum'
    alias sha224sum='gsha224sum'
    alias sha256sum='gsha256sum'
    alias sha384sum='gsha384sum'
    alias sha512sum='gsha512sum'
    if [[ -r ~/.dircolors ]];then
      eval "$(gdircolors -b ~/.dircolors)"
    else
      eval "$(gdircolors -b)"
    fi
  else
    alias ls='ls -G'
    export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
  fi
  # Add /usr/local/sbin to path for Brew
  export PATH="/usr/local/sbin:$PATH"
  # Add Brew auto completion
  [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
fi

info(){
  printf "\n[ "; tput setaf 6; printf "INFO"; tput sgr0; printf " ] "
  tput setaf 8; printf "%s\n" "${1}"; tput sgr0
}

# `up` is a convenient way to navigate back up a file tree, and is a general-use
# replacement for `cd ..`.
# if no arguments are passed, up is simply an alias for `cd ..`.
# with any integer argument n, `cd ..` will be performed n times
up() {
  # number of times to move up in the directory tree
  TIMES=$1

  if [ -z "${TIMES}" ]; then
    TIMES=1
  fi
  while [ ${TIMES} -gt 0 ]; do
    cd ..
    TIMES=$((TIMES - 1))
  done
}

updatey() {
  # Update O/S
  if ([ "$( uname -s )" = "Darwin" ]) > /dev/null 2>&1; then
    brew update && brew upgrade --cleanup
  elif ([ "$( cat /etc/*release | grep -ciwE "debian|ubuntu" )" -ge 1 ]) > /dev/null 2>&1; then
    if [ ${UID} -ne "0" ]; then
      sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get autoclean
    else
      apt-get update && apt-get -y upgrade && apt-get autoclean
    fi
  elif ([ "$( cat /etc/*release | grep -ciwE "red hat|centos|fedora" )" -ge 1 ]) > /dev/null 2>&1; then
    if [ ${UID} -ne "0" ]; then
      sudo yum -y update
    else
      yum -y update
    fi
  elif ([ "$( cat /etc/*release | grep -ciwE "opensuse" )" -ge 1 ]) > /dev/null 2>&1; then
    if [ ${UID} -ne "0" ]; then
      sudo zypper refresh && sudo zypper update -y
    else
      zypper refresh && zypper update -y
    fi
  fi
}

updated() {
  # Update dotfiles
  info "Updating dotfiles"
  cur_dir=$( pwd )
  cd ~/.dotfiles || exit
  git pull
  info "Updating base16-shell"
  cd ~/.config/base16-shell || exit
  git pull
  cd "${cur_dir}" || exit
  # Update Vim & Vim plugins
  info "Updating Vim"
  vim +PluginClean! +PluginUpdate +qall
}

# Alias definitions
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias la='ls -a'
alias ll='ls -lh'
alias lla='ls -lha'
alias reload='. ~/.bashrc' # Reload .bashrc
alias vi='vim'
alias cls='clear'
# Non root users only
if [ ${UID} -ne "0" ]; then
  alias svi='sudo vim'
  alias sudo='sudo -E'
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

# Source any files in ~/.private/
# Place files that shouldn't be commited to a public repo here
for file in ~/.private/*; do
  [ -r "$file" ] && [ -f "$file" ] && . "$file";
done;
unset file;

# Add ~/bin to path if it exists
if [[ -d ~/bin ]];then
  PATH=${PATH}:${HOME}/bin
fi

# Set default editor
export VISUAL="/usr/bin/vim"
export EDITOR="/usr/bin/vim"
export SUDO_EDITOR="/usr/bin/vim"

# Set default permissions
umask 0027
