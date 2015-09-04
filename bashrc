# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/base16-atelierdune.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# Setup colours
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    tput sgr0 # reset colors

    bold=$(tput bold)
    reset=$(tput sgr0)

    # base16 colours https://chriskempson.github.io/base16/
    black=$(tput setaf 0)
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    magenta=$(tput setaf 5)
    cyan=$(tput setaf 6)
    white=$(tput setaf 7)
    grey=$(tput setaf 8)
    orange=$(tput setaf 9)
    violet=$(tput setaf 14)
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
    # Highlight the user name when logged in as root.
    if [[ "${USER}" == "root" ]]; then
        userStyle="${red}";
    else
        userStyle="${green}";
    fi;

    PS1='\[$userStyle\]\u\[$grey\]@\[$yellow\]\h\[$blue\] \w \[$white\]\$\[$reset\] '
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
# Doesn't run under OS X
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# OS X specific section
if [ $(uname -s) = "Darwin" ]; then
    alias ls='ls -G'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
fi

# `up` is a convenient way to navigate back up a file tree, and is a general-use
# replacement for `cd ..`.
# if no arguments are passed, up is simply an alias for `cd ..`.
# with any integer argument n, `cd ..` will be performed n times
function up() {
# number of times to move up in the directory tree
TIMES=$1

if [ -z ${TIMES} ]; then
    TIMES=1
fi
while [ ${TIMES} -gt 0 ]; do
    cd ..
    TIMES=$((${TIMES} - 1))
done
}

# Alias definitions.
alias la='ls -a'
alias ll='ls -lh'
alias lla='ls -lha'
alias cl='clear'
alias reload='cd && . ./.bashrc' # Reload .bashrc
alias g='git'

if [ $(uname -s) = "Darwin" ]; then
    # OS X has no `md5sum`, so use `md5` as a fallback
    command -v md5sum > /dev/null || alias md5sum="md5"
    # OS X has no `sha1sum`, so use `shasum` as a fallback
    command -v sha1sum > /dev/null || alias sha1sum="shasum"
else
    # Linux only section
    alias updatey='sudo apt-get update && sudo apt-get -y upgrade'
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
