# shellcheck disable=SC2148
if [ -n "$BASH_VERSION" ]; then
      # include .bashrc if it exists
      if [ -f "$HOME/.bashrc" ]; then
      # shellcheck disable=SC1090
      source "$HOME/.bashrc"
   fi
fi
