#!/bin/bash -eu

echo "Install apps"
if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  os="${ID}"
  case "${os}" in
    debian | raspbian )
      export DEBIAN_FRONTEND=noninteractive
      apt-get -q update
      # Install prerequisites for guest additions
      apt-get -qy install build-essential dkms linux-headers-amd64
      # Install useful apps
      apt-get -qy install curl dnsutils git htop jq mtr-tiny needrestart openssl \
        shellcheck tree unzip vim wget
      ;;
    ubuntu )
      export DEBIAN_FRONTEND=noninteractive
      apt-get -q update
      # Install prerequisites for guest additions
      apt-get -qy install build-essential dkms linux-headers-generic
      # Install useful apps
      apt-get -qy install curl dnsutils git htop jq mtr-tiny needrestart openssl \
        shellcheck tree unzip vim wget
      ;;
    centos )
      # Get EL major version
      major_version="$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}')";

      # Use dnf on EL 8+
      if [ "${major_version}" -ge 8 ]; then
        # Install EPEL
        dnf -y install epel-release
        # Install prerequisites for guest additions
        dnf -y install dkms gcc kernel-devel kernel-headers make perl
        # Install useful apps
        dnf -y install bind-utils bzip2 dnf-utils git htop jq mtr tar tree unzip \
          vim-enhanced wget
      else
        # Install EPEL
        yum -y install epel-release
        # Install prerequisites for guest additions
        yum -y install dkms gcc kernel-devel kernel-headers make perl
        # Install useful apps
        yum -y install bind-utils bzip2 git htop jq mtr openssl tree unzip vim-enhanced \
          wget yum-utils
      fi
      ;;
  esac
fi
