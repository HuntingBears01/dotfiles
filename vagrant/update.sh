#!/bin/bash -eux

if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  os="${ID}"
  case "${os}" in
    debian | ubuntu | raspbian )
      apt update
      apt upgrade -y
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
      ;;
  esac
fi
