# Common aliases

# shellcheck disable=SC2148
# shellcheck disable=SC1091

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias la='ls -a'
alias ll='ls -lh'
alias lla='ls -lha'
alias reload='. ~/.bashrc'
alias vi='vim'
alias cls='clear'

# Aliases for commonly edited files
# Format: "filename relative to $HOME":alias
for file in ".vimrc":vimrc ".bashrc":bashrc ".ssh/config":sshc ".ssh/known_hosts":knownh
do
  if [ -f "$HOME/${file%:*}" ]; then
    # shellcheck disable=SC2139
    alias ${file/*:}="vim $HOME/${file%:*}"
  fi
done

# Aliases for commonly edited root owned files
# Format: "/path/to/file":alias
for file in "/etc/hosts":hosts "/etc/fstab":fstab
do
  if [ -f "${file%:*}" ]; then
    # shellcheck disable=SC2139
    alias ${file/*:}="sudoedit ${file%:*}"
  fi
done

# Aliases for commonly used directories
# Format: "directory relative to $HOME":alias
for dir in "Music":mus "Videos":vid "Desktop":dt "Pictures":pic \
  "Downloads":dl "Documents":doc "Archive":arc \
  ".config":cnf ".config":cfg "Projects":prj "Library/Application Support/Firefox":fox \
  ".mozilla/firefox":fox
do
  if [ -d "$HOME/${dir%:*}" ]; then
    # shellcheck disable=SC2139
    # shellcheck disable=SC2086
    alias ${dir/*:}="cd '$HOME/${dir%:*}' && ls"
  fi
done
