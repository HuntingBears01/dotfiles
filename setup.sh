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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Common script functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

isInteractive(){
  # Purpose:  Check if running from an interactive shell
  # Usage:    isInteractive
  if [ -t 0 ]; then
    return 0
  else
    return 1
  fi
}

isRoot(){
  # Purpose:  Check if running as root
  # Usage:    isRoot
  if [ "$(id -u)" -eq 0 ]; then
    return 0
  else
    return 1
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appendOnce() {
  # Purpose:  Append string to a file if it doesn't already exist
  # Usage:    appendOnce "string" "/path/to/file"
  string=$1
  file=$2
  if ! [ -f "${file}" ]; then
    echo "${string}" | sudo tee "${file}"
  elif [ "$(grep -c "${string}" < "${file}")" -eq 0 ]; then
    echo "${string}" | sudo tee -a "${file}"
  fi
}
cloneGitRepo(){
  # Purpose:  Clone git repository from URL
  # Usage:    cloneGitRepo "repo URL" "/path/to/destination/dir"
  repoURL=$1
  destDir=$2
  repoName=$(basename -s .git "${repoURL}")
  info "Cloning ${repoName}"
  if [ -L "${destDir}/${repoName}" ]; then
    info "Deleting existing symlink ${destDir}"
    rm "${destDir}"
    git clone -q "${repoURL}" "${destDir}"
    check $? "${repoName} cloning"
  elif [ -d "${destDir}" ]; then
    warn "${repoName} directory already exists, skipping"
  else
    git clone -q "${repoURL}" "${destDir}"
    check $? "${repoName} cloning"
  fi
}

linkFiles(){
  # Purpose:  Link all files in source directory to destination directory
  # Usage:    linkFiles "/path/to/source/dir" "/path/to/destination/dir"
  sourceDir="$1"
  destDir="$2"
  fileList=$(ls -A "${sourceDir}")
  info "Linking files in ${sourceDir} to ${destDir}"
  if [ ! -d "${destDir}" ]; then
    mkdir -p "${destDir}"
  fi
  for item in ${fileList}; do
    if [ "${sourceDir}/${item}" -ef "${destDir}/${item}" ]; then
      # Skip if file is already linked
      info "Skipping, ${item} already linked to ${sourceDir}"
    elif [ -L "${destDir}/${item}" ]; then
      # Delete broken links & create new ones
      info "Deleting broken link for ${item}"
      rm "${destDir}/${item}"
      info "Linking ${item} to ${sourceDir}"
      ln -s "${sourceDir}/${item}" "${destDir}/${item}"
    elif [ -e "${destDir}/${item}" ]; then
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

check() {
  # Purpose:  Checks the return code and displays an appropriate message
  # Usage:    check $? "Task description"
  if [ "$1" -eq 0 ]; then
    shift
    okay "$* complete"
  else
    shift
    fail "$* failed"
  fi
}

fail() {
  # Purpose:  Display a task failed message then exit
  # Usage:    fail "Message to display"
  echo
  ${red}; printf " ✗  "; ${reset}; echo "$*" >&2
  echo
  exit 1
}

info() {
  # Purpose:  Display an informational message
  # Usage:    info "Message to display"
  ${cyan}; printf " ℹ︎  "; ${reset}; echo "$*"
}

notify() {
  # Purpose:  Display a notification
  # Usage:    notify "Message to display"
  ${green}; printf " ℹ︎  "; ${reset}; echo "$*"
  echo
}

okay() {
  # Purpose:  Display a task successful message
  # Usage:    okay "Message to display"
  ${green}; printf " ✓  "; ${reset}; echo "$*"
  echo
}

warn() {
  # Purpose:  Display a warning message
  # Usage:    warn "Message to display"
  ${yellow}; printf " !  "; ${reset}; echo "$*" >&2
}

# Set text colours
if isInteractive; then
  red='tput setaf 1'
  green='tput setaf 2'
  yellow='tput setaf 3'
  magenta='tput setaf 5'
  cyan='tput setaf 6'
  reset='tput sgr0'
else
  red=''
  green=''
  yellow=''
  magenta=''
  cyan=''
  reset=''
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
  echo "  --minimal           Install dotfiles only"
  echo "  --theme             Install dotfiles & theme (default)"
  echo "  --full              Install everything (interactive)"
  echo
  echo "  --help              Display this help"
  echo
}

linkDotfiles() {
  # Link dotfiles
  linkFiles "${progDir}/aliases" "${HOME}/.config/aliases"
  linkFiles "${progDir}/direnv" "${HOME}/.config/direnv"
  linkFiles "${progDir}/home" "${HOME}"
  linkFiles "${progDir}/kitty" "${HOME}/.config/kitty"
  linkFiles "${progDir}/ghostty" "${HOME}/.config/ghostty"
  linkFiles "${progDir}/scripts" "${HOME}/.local/bin"
  linkFiles "${progDir}/yamllint" "${HOME}/.config/yamllint"
  linkFiles "${progDir}/yt-dlp" "${HOME}/.yt-dlp"
}

gitCheck() {
  # Install git
  if (command -v git > /dev/null 2>&1); then
    notify "Git installed"
  else
    fail "Git not installed. Install git and try again"
  fi
}

powerlevel10k() {
  # Install powerlevel10k
  powerlevel10k_dir="${HOME}/.config/powerlevel10k"
  if [ -d "${powerlevel10k_dir}" ]; then
    info "Updating powerlevel10k"
    cd "${powerlevel10k_dir}" &&
    git pull -q
    check $? "powerlevel10k update"
    # shellcheck disable=SC2164
    cd "${progDir}"
  else
    info "Installing powerlevel10k"
    git clone --depth=1 -q https://github.com/romkatv/powerlevel10k.git "${powerlevel10k_dir}"
    check $? "powerlevel10k install"
  fi
}

installMinimal() {
  notify "Install dotfiles only"
  linkDotfiles
}

installTheme() {
  notify "Install dotfiles & theme"
  linkDotfiles
  gitCheck
  powerlevel10k
}

installFull() {
  notify "Install everything"
  if isInteractive; then
    linkDotfiles
    gitCheck
    powerlevel10k
  else
    fail "Full install can only be ran interactively"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Main
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Default option
if [ $# -eq 0 ]; then
  installTheme
fi

# Parse options
while [ $# -gt 0 ]; do
  case $1 in
    --help | -help | -h | '-?' )
      usage
      exit 0
      ;;
    --minimal | -minimal | -m )
      installMinimal
      ;;
    --theme | -theme | -t )
      installTheme
      ;;
    --full | -full | -f )
      installFull
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

exit 0
