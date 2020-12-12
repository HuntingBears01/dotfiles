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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Configuration
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Catch all errors in a pipeline
set -o pipefail

# Exit trap
trap cleanup EXIT

# Script variables
# shellcheck disable=SC2034
progDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
progName=$(basename "$0")
logDir="${HOME}/.local/logs"
logName="${progName%.*}"
logFile="${logDir}/${logName}.log"

# Create log directory
if [[ ! -d ${logDir} ]]; then
  mkdir -p "${logDir}"
fi

# Import common functions
# shellcheck disable=SC1090
if [[ -f "${HOME}/scripts/script-common.sh" ]]; then
  . "${HOME}/scripts/script-common.sh"
else
  echo "Unable to open script-common.sh"
  exit 1
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

cleanup() {
  # Purpose:  Cleanup before exiting
  # Usage:    Always runs even if script fails
}
usage() {
  # Purpose:  Display usage instructions
  # Usage:    usage
  echo
  echo "Usage: ${progName}"
  echo
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Main
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

begin

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

exit 0
EOF

  chmod +x "${scriptFile}"
  subl -n "${scriptFile}"
fi
