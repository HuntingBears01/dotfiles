#!/bin/bash -eu

echo "Install updates"
if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  os="${ID}"
  case "${os}" in
    debian | ubuntu | raspbian )
      apt-get -q update
      apt-get -yq dist-upgrade
      apt-get -yq autoclean
      apt-get -yq autoremove
      # Reboot if new kernel has been installed
      if [[ $(needrestart -kb | grep 'NEEDRESTART-KSTA' | awk -F' ' '{print $2}') -gt 1 ]]; then
        shutdown -r 1
      fi
      ;;
    centos )
      # Get EL major version
      major_version="$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}')";

      # Use dnf on EL 8+
      if [ "${major_version}" -ge 8 ]; then
        dnf -y update
      else
        yum -y update
      fi
      if (needs-restarting -r | grep 'Reboot' | grep 'required'); then
        shutdown -r 1
      fi
      ;;
  esac
fi
