#!/bin/bash -eu

user_id="vagrant"
configDir="/home/${user_id}/.config"
dotfilesDir="${configDir}/dotfiles"

if [[ ! -d "${configDir}" ]]; then
  mkdir "${configDir}"
fi

if [[ ! -d "${dotfilesDir}" ]]; then
  echo "Install dotfiles"
  git clone https://github.com/huntingbears01/dotfiles.git "${dotfilesDir}"
else
  echo "Update dotfiles"
  cd "${dotfilesDir}"
  git pull
fi

echo "Setup dotfiles"
chown -R ${user_id}:${user_id} "${configDir}"
su -c "${dotfilesDir}/setup.sh" - ${user_id}
