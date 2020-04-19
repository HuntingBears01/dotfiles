#!/bin/bash -eux

if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  os="${ID}"
  case "${os}" in
    debian | ubuntu | raspbian )
      apt-get update
      apt-get install -y curl git htop jq mtr-tiny needrestart openssl python3 \
        python3-apt shellcheck tree unzip vim wget whois
      ;;
    centos )
      # Get EL major version
      major_version="$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}')";

      # Use dnf on EL 8+
      if [ "${major_version}" -ge 8 ]; then
        dnf -y install epel-release
        dnf -y install bzip2 dnf-utils git htop jq mtr python3 tar tree unzip \
          vim-enhanced whois wget
      else
        yum -y install epel-release
        yum -y install bzip2 git htop jq mtr openssl python libselinux-python \
          tree unzip vim-enhanced whois wget yum-utils
      fi
      ;;
  esac
fi
