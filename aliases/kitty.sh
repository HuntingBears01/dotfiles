# Aliases for Kitty terminal

# shellcheck disable=SC2148
# shellcheck disable=SC1091

if command -v kitty >/dev/null 2>&1; then
  if [[ $TERM = 'xterm-kitty' ]]; then
    alias icat="kitten icat"
    alias diff="kitten diff"
    alias ssh="kitten ssh"
    alias rg="rg --hyperlink-format=kitty"
  fi
fi
