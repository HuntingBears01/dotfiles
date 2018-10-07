#! /usr/bin/env bash

# Purpose:  Creates an executable script using a heredoc template & opens it in
#           Sublime or else opens existing scripts in Sublime
# Author:   Conor Martin

usage() {
  echo
  echo "Usage: ${PROGRAM} scriptname [/path/to/script/folder]"
  echo
  echo "Default path: current directory"
  echo
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
elif [[ $# -gt 1 ]]; then
  scriptFolder="$2"
  scriptFile="${scriptFolder}/$1"
else
  scriptFolder="."
  scriptFile="${scriptFolder}/$1"
fi

if [[ -f "${scriptFile}" ]]; then
  subl "${scriptFile}"
elif [[ -d "${scriptFile}" ]]; then
  echo "ERROR: ${scriptFile} is a directory"
  exit 1
else
  # NB Use '' around EOF to prevent substitution & expansion inside heredoc
  cat << 'EOF' > "${scriptFile}"
#! /usr/bin/env bash

# Purpose:  
# Author:   Conor Martin


#------------------------------------------------------------------------------
#  Configuration
#------------------------------------------------------------------------------

# Script variables
# shellcheck disable=SC2034
progDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
progName=$(basename "$0")
logName="${progName%.*}"
logFile="${progDir}/${logName}.log"

# Import common functions
# shellcheck disable=SC1090
if [[ -f "${HOME}/.scripts/script-common.sh" ]]; then
  . "${HOME}/.scripts/script-common.sh"
else
  echo "Unable to open script-common.sh"
  exit 1
fi


#------------------------------------------------------------------------------
#  Functions
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
#  Main
#------------------------------------------------------------------------------

begin

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

exit 0
EOF

  chmod +x "${scriptFile}"
  subl "${scriptFile}"
fi