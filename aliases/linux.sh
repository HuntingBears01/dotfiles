# Linux specific aliases

# shellcheck disable=SC2148
# shellcheck disable=SC1091

if [ -f /etc/os-release ]; then
  # Linux specific section
  # Enable color support for ls
  if [ -x /usr/bin/dircolors ]; then
    alias ls='ls -v --color=auto'
  fi

  # Alias fd-find to fd
  if (command -v fd-find > /dev/null 2>&1); then
    alias fd='fd-find'
  fi

  # Setup updy alias
  source /etc/os-release
  os="${ID}"
  os_family="${ID_LIKE}"
  case "${os}" in
    debian | ubuntu | raspbian | pop )
      alias updy='sudo apt update && sudo apt upgrade'
      ;;
  esac
  case "${os_family}" in
    *debian* | *ubuntu* )
      alias updy='sudo apt update && sudo apt upgrade'
      ;;
    *arch* )
      alias updy='sudo pacman -Syu'
      ;;
    *rhel* | *fedora* )
      if (command -v dnf > /dev/null 2>&1); then
        alias updy='sudo dnf update'
      else
        alias updy='sudo yum update'
      fi
      ;;
    *opensuse* | *suse* )
      alias updy='sudo zypper refresh && sudo zypper update'
      ;;
  esac
fi
