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
  echo "  --workstation       Install dotfiles, git & applications"
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
    git pull
    check $? "base16-shell update"
    # shellcheck disable=SC2164
    cd "${progDir}"
  else
    info "Installing base16-shell"
    git clone https://github.com/chriskempson/base16-shell.git "${base16_shell_dir}"
    check $? "base16-shell install"
  fi
}
linkDotfiles() {
  # Link dotfiles
  linkFiles "${progDir}/home" "${HOME}"
  linkFiles "${progDir}/scripts" "${HOME}/scripts"
  linkFiles "${progDir}/vagrant" "${HOME}/scripts/.vagrant"
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
workstation() {
  if isRoot; then
    fail "This program must not be run as root"
  else
    # Linux only section
    if [ -f /etc/os-release ]; then
      # shellcheck disable=SC1091
      source /etc/os-release
      os="${ID}"
      case "${os}" in
        debian | ubuntu | raspbian )
          notify "Debian based distribution detected"
          # Authenticate once
          sudo -v
          # Update apt cache
          info "Updating apt cache"
          sudo apt update
          check $? "Apt cache update"
          info "Installing applications"
          sudo apt install -y curl htop mtr-tiny python3 shellcheck tree unzip \
            vim wget whois
          check $? "Application install"
          ;;
        manjaro )
          notify "Arch based distribution detected"
          ;;
        centos )
          notify "CentOS detected"
          # Authenticate once
          sudo -v
          info "Installing EPEL"
          sudo yum install -y epel-release
          check $? "EPEL install"
          info "Installing applications"
          sudo yum install -y bzip2 curl htop mtr python3 tree unzip \
            vim-enhanced wget yum-utils
          check $? "Application install"
          ;;
        fedora )
          notify "Fedora detected"
          ;;
        opensuse )
          notify "OpenSUSE detected"
          ;;
      esac
    fi

    # MacOS only section
    if [[ "$( uname -s )" = "Darwin" ]] > /dev/null 2>&1; then
      notify "MacOS detected"
      # Authenticate once
      sudo -v

      # Set hostname
      info "Setting Hostname"
      read -rp "Enter Hostname: " name
      if [ -z "${name}" ]; then
        warn "Hostname unchanged"
      else
        sudo scutil --set ComputerName "${name}" &&
        sudo scutil --set HostName "${name}" &&
        sudo scutil --set LocalHostName "${name}" &&
        sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${name}"
        check $? "Hostname setup"
      fi

      # Install/update Homebrew
      if (command -v brew > /dev/null 2>&1); then
        info "Updating Homebrew"
        brew update && brew upgrade
        check $? "Homebrew updating"
      else
        info "Installing Homebrew"
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        check $? "Homebrew installation"
      fi

      # Install GNU Bash
      if [[ -f "/usr/local/bin/bash" ]]; then
        info "GNU Bash already installed"
      else
        info "Installing GNU Bash"
        brew install bash coreutils &&
        appendOnce /usr/local/bin/bash /etc/shells
        check $? "GNU Bash installation"
      fi
      if [[ "${SHELL}" == "/usr/local/bin/bash" ]]; then
        info "GNU Bash already set as default"
      else
        info "Set GNU Bash as default"
        appendOnce /usr/local/bin/bash /etc/shells &&
        sudo chsh -s /usr/local/bin/bash "$USER"
        check $? "Setting default shell"
      fi

      # Install software from Brewfile
      info "Installing Brew software"
      brew bundle
      check $? "Brew software installation"

      # Install Python applications
      info "Installing Python applications"
      pip3 install ansible-lint yamllint vim-vint
      check $? "Python application installation"

      # Install Vagrant plugins
      info "Installing Vagrant plugins"
      if (vagrant plugin list | grep -q vagrant-hostsupdater); then
        vagrant plugin update vagrant-hostupdater
      else
        vagrant plugin install vagrant-hostsupdater
      fi
      if ! [ -f /private/etc/sudoers.d/vagrant_hostsupdater ]; then
      cat << EOF | sudo tee /private/etc/sudoers.d/vagrant_hostsupdater
# Allow passwordless startup of Vagrant with vagrant-hostsupdater
Cmnd_Alias VAGRANT_HOSTS_ADD = /bin/sh -c echo "*" >> /etc/hosts
Cmnd_Alias VAGRANT_HOSTS_REMOVE = /usr/bin/sed -i -e /*/ d /etc/hosts
%admin ALL=(root) NOPASSWD: VAGRANT_HOSTS_ADD, VAGRANT_HOSTS_REMOVE
EOF
      fi
      check $? "Vagrant plugin installation"
    fi
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Main
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

begin

if [[ $# -eq 0 ]]; then
  notify "Minimal install"
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
      base16
      linkDotfiles
      ;;
    --git | -git | -g )
      notify "Git install"
      base16
      linkDotfiles
      gitConfig
      ;;
    --workstation | -workstation | -w )
      notify "Workstation install"
      base16
      linkDotfiles
      gitConfig
      workstation
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
