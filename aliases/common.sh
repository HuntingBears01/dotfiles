# Common aliases

# shellcheck disable=SC2148
# shellcheck disable=SC1091

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias la='ls -a'
alias ll='ls -lh'
alias lla='ls -lha'
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
for dir in "Desktop":dt "Downloads":dl "Documents":doc \
  "Nextcloud":nc "Projects":prj \
  ".config":cnf ".config":cfg \
  "Library/Application Support/Firefox":fox ".mozilla/firefox":fox
do
  if [ -d "$HOME/${dir%:*}" ]; then
    # shellcheck disable=SC2139
    # shellcheck disable=SC2086
    alias ${dir/*:}="cd '$HOME/${dir%:*}' && ls"
  fi
done

# Aliases for Ansible
if command -v ansible >/dev/null 2>&1; then
  alias ap='ansible-playbook'
  alias ag='ansible-galaxy'
  alias avc='ansible-vault create'
  alias ave='ansible-vault edit'
fi
