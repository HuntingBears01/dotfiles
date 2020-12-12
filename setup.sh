#! /usr/bin/env bash

# Dotfiles setup script
# Author: Conor Martin

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Configuration
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Script variables
# shellcheck disable=SC2034
progDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
progName=$(basename "$0")
logDir="${HOME}/logs"
logName="${progName%.*}"
logFile="${logDir}/${logName}.log"

# Create log directory
if [[ ! -d ${logDir} ]]; then
  mkdir "${logDir}"
fi

# Import common functions
# shellcheck disable=SC1090
if [[ -f "${progDir}/scripts/script-common.sh" ]]; then
  . "${progDir}/scripts/script-common.sh"
else
  echo "Unable to open script-common.sh"
  exit 1
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

usage() {
  echo
  echo "Usage: ${progName} [option]"
  echo
  echo "  Options:"
  echo
  echo "  --minimal           Install dotfiles only (default)"
  echo "  --git               Install dotfiles & configure git"
  echo
  echo "  --help              Display this help"
  echo
}
base16() {
  # Install base16-shell
  base16_shell_dir="${HOME}/.config/base16-shell"
  if [[ -d "${base16_shell_dir}" ]]; then
    info "Updating base16-shell"
    cd "${base16_shell_dir}" &&
    git pull -q
    check $? "base16-shell update"
    # shellcheck disable=SC2164
    cd "${progDir}"
  else
    info "Installing base16-shell"
    git clone -q https://github.com/chriskempson/base16-shell.git "${base16_shell_dir}"
    check $? "base16-shell install"
  fi
}
linkDotfiles() {
  # Link dotfiles
  linkFiles "${progDir}/aliases" "${HOME}/.config/aliases"
  linkFiles "${progDir}/home" "${HOME}"
  linkFiles "${progDir}/scripts" "${HOME}/.local/bin"
  linkFiles "${progDir}/yamllint" "${HOME}/.config/yamllint"
}
gitConfig() {
  # Configure Git
  if isRoot; then
    fail "This program must not be run as root"
  else
    info "Git configuration"
    if isInteractive; then
      read -rp "Enter Git name: " gitName
      if [[ -n "${gitName}" ]]; then
        git config --global user.name "${gitName}"
        read -rp "Enter Git email: " gitEmail
        if [[ -n "${gitEmail}" ]]; then
          git config --global user.email "${gitEmail}"
          if [[ ! -f ~/.ssh/id_rsa ]]; then
            ssh-keygen -t rsa -C "${gitEmail}" -f ~/.ssh/id_rsa
          fi
        fi
      fi
    fi &&
    git config --global color.ui auto &&
    git config --global core.editor "$(command -v vim)" &&
    git config --global core.autocrlf input &&
    git config --global core.excludesfile "${HOME}/.gitignore" &&
    git config --global push.default current &&
    git config --global alias.unstage 'reset HEAD --' &&
    git config --global alias.last 'log -1 HEAD' &&
    git config --global alias.co checkout &&
    git config --global alias.br branch &&
    git config --global alias.ci commit &&
    git config --global alias.s status &&
    git config --global alias.logp 'log --pretty=oneline --graph'
    check $? "Git configuration"
  fi
}
gitInstall() {
  # Install git
  if (command -v git > /dev/null 2>&1); then
    notify "Git installed"
  else
    if [ -f /etc/os-release ]; then
      # shellcheck disable=SC1091
      source /etc/os-release
      os="${ID}"
      case "${os}" in
        debian | ubuntu | raspbian )
          info "Installing git for Debian"
          export DEBIAN_FRONTEND=noninteractive
          apt-get -q update
          apt-get -qy install git
          check "Git install for Debian"
          ;;
        centos )
          info "Installing git for CentOS"
          # Get EL major version
          major_version="$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}')";

          # Use dnf on EL 8+
          if [ "${major_version}" -ge 8 ]; then
            dnf -y install git
          else
            yum -y install git
          fi
          check "Git install for CentOS"
          ;;
        * )
          fail "Git not installed. Install git and try again"
          ;;
      esac
    else
      fail "Git not installed. Install git and try again"
    fi
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Main
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

begin

if [[ $# -eq 0 ]]; then
  notify "Minimal install"
  gitInstall
  base16
  linkDotfiles
fi

# Parse options
while [[ $# -gt 0 ]]; do
  case $1 in
    --help | -help | -h | '-?' )
      usage
      exit 0
      ;;
    --minimal | -minimal | -m )
      notify "Minimal install"
      gitInstall
      base16
      linkDotfiles
      ;;
    --git | -git | -g )
      notify "Git install"
      gitInstall
      base16
      linkDotfiles
      gitConfig
      ;;
    -*)
      fail "Unrecognized option: $1"
      ;;
    *)
      break
      ;;
  esac
  shift
done

end

exit 0
