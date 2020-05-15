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
      # Install prerequisites for other scripts
      apt-get -qy install git needrestart
      ;;
    ubuntu )
      export DEBIAN_FRONTEND=noninteractive
      apt-get -q update
      # Install prerequisites for guest additions
      apt-get -qy install build-essential dkms linux-headers-generic
      # Install prerequisites for other scripts
      apt-get -qy install git needrestart
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
        # Install prerequisites for other scripts
        dnf -y install dnf-utils git
      else
        # Install EPEL
        yum -y install epel-release
        # Install prerequisites for guest additions
        yum -y install dkms gcc kernel-devel kernel-headers make perl
        # Install prerequisites for other scripts
        yum -y install git yum-utils
      fi
      ;;
  esac
fi
