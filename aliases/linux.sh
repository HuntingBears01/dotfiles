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
  case "${os}" in
    debian | ubuntu | raspbian )
      alias updy='sudo apt update && sudo apt upgrade -Vy'
      ;;
    manjaro )
      alias updy='sudo pacman -Syu --noconfirm'
      ;;
    centos )
      alias updy='sudo yum update -y'
      ;;
    fedora )
      alias updy='sudo dnf update -y'
      ;;
    opensuse )
      alias updy='sudo zypper refresh && sudo zypper update -y'
      ;;
  esac
fi
