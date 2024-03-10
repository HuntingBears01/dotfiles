# MacOS specific aliases

# shellcheck disable=SC2148
# shellcheck disable=SC1091

if  [[ "$( uname -s )" = "Darwin" ]] > /dev/null 2>&1; then
  alias flushdns='sudo killall -HUP mDNSResponder'
  alias sudoedit='sudo vim'

  # Use GNU coreutils if installed
  if [ -x /usr/local/bin/gls ]; then
    alias date='gdate'
    alias ls='gls -v --color=auto'
    alias md5sum='gmd5sum'
    alias sha1sum='gsha1sum'
    alias sha224sum='gsha224sum'
    alias sha256sum='gsha256sum'
    alias sha384sum='gsha384sum'
    alias sha512sum='gsha512sum'
  else
    alias ls='ls -G'
    export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
  fi
fi
