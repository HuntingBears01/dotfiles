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
fi
