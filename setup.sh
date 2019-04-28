#! /usr/bin/env bash

# Dotfiles setup script
# Author: Conor Martin

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------

# Script variables
# shellcheck disable=SC2034
progDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
progName=$(basename "$0")
logName="${progName%.*}"
logFile="${progDir}/${logName}.log"

# Import common functions
# shellcheck disable=SC1090
if [[ -f "${progDir}/scripts/script-common.sh" ]]; then
  . "${progDir}/scripts/script-common.sh"
else
  echo "Unable to open script-common.sh"
  exit 1
fi

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

isInteractive(){
  # Check if running from an interactive shell
  if [[ -t 0 ]]; then
    return 0
  else
    return 1
  fi
}
isMac(){
  # Check if running on MacOS
  if [[ "$( uname -s )" = "Darwin" ]] > /dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}
isRoot(){
  # Check if running as root
  if [[ ${EUID} -eq 0 ]]; then
    return 0
  else
    return 1
  fi
}
cloneGitRepo(){
  # Clones repository from GitHub
  # Usage cloneGitRepo "repo URL" "/path/to/destination/dir"
  repoURL=$1
  destDir=$2
  repoName=$(basename -s .git "${repoURL}")
  info "Cloning ${repoName}"
  if [[ -L "${destDir}/${repoName}" ]]; then
    info "Deleting existing symlink ${destDir}"
    rm "${destDir}"
    git clone -q "${repoURL}" "${destDir}"
    check $? "${repoName} cloning"
  elif [[ -d "${destDir}" ]]; then
    warn "${repoName} directory already exists, skipping"
  else
    git clone -q "${repoURL}" "${destDir}"
    check $? "${repoName} cloning"
  fi
}
linkFiles(){
  # Links all files in source directory to destination directory
  # Usage: linkFiles "/path/to/source/dir" "/path/to/destination/dir"
  sourceDir="$1"
  destDir="$2"
  fileList=$(ls -A "${sourceDir}")
  info "Linking files in ${sourceDir} to ${destDir}"
  if [[ ! -d "${destDir}" ]]; then
    mkdir "${destDir}"
  fi
  for item in ${fileList}; do
    if [[ "${sourceDir}/${item}" -ef "${destDir}/${item}" ]]; then
      # Skip if file is already linked
      info "Skipping, ${item} already linked to ${sourceDir}"
    elif [[ -L "${destDir}/${item}" ]]; then
      # Delete broken links & create new ones
      info "Deleting broken link for ${item}"
      rm "${destDir}/${item}"
      info "Linking ${item} to ${sourceDir}"
      ln -s "${sourceDir}/${item}" "${destDir}/${item}"
    elif [[ -e "${destDir}/${item}" ]]; then
      # Backup existing files and create new links
      info "Backing up ${destDir}/${item} to ${destDir}/${item}.bak"
      mv "${destDir}/${item}" "${destDir}/${item}.bak"
      info "Linking ${item} to ${sourceDir}"
      ln -s "${sourceDir}/${item}" "${destDir}/${item}"
    else
      # Create links
      info "Linking ${item} to ${sourceDir}"
      ln -s "${sourceDir}/${item}" "${destDir}/${item}"
    fi
  done
  check $? "Linking"
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

begin

# Setup MacOS
if isMac; then
  if isRoot; then
    fail "This program must not be run as root"
  else
    sudo -v
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
    
    info "Installing Homebrew"
    if (command -v brew > /dev/null 2>&1); then
      warn "Homebrew already installed"
    else
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      check $? "Homebrew installation"
    fi
  fi
fi

# Link dotfiles
linkFiles "${progDir}/home" "${HOME}"
linkFiles "${progDir}/scripts" "${HOME}/.scripts"
if (command -v i3 > /dev/null 2>&1); then
  linkFiles "${progDir}/i3/home" "${HOME}"
  linkFiles "${progDir}/i3/config" "${HOME}/.config"
  linkFiles "${progDir}/i3/scripts" "${HOME}/.scripts"
fi

# Update Xresources
if (command -v xrdb > /dev/null 2>&1); then
  info "Updating Xresources"
  xrdb ~/.Xresources
  check $? "Xresources update"
fi

# Configure Git
if isRoot; then
  fail "This program must not be run as root"
else
  info "Git configuration"
  if isInteractive; then
    read -rp "Enter Git name: " gitName
    if [[ ! -z "${gitName}" ]]; then
      git config --global user.name "${gitName}"
      read -rp "Enter Git email: " gitEmail
      if [[ ! -z "${gitEmail}" ]]; then
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

end

exit 0