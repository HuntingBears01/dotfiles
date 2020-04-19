#!/bin/bash -eux

user_id="vagrant"
configDir="/home/${user_id}/.config"
dotfilesDir="${configDir}/dotfiles"

if [[ ! -d "${configDir}" ]]; then
  mkdir "${configDir}"
fi

if [[ ! -d "${dotfilesDir}" ]]; then
  # Clone dotfiles
  git clone https://github.com/huntingbears01/dotfiles.git "${dotfilesDir}"
else
  # Update dotfiles
  cd "${dotfilesDir}"
  git pull
fi

# Fix permissions
chown -R ${user_id}:${user_id} "${configDir}"

su -c "${dotfilesDir}/setup.sh" - ${user_id}
