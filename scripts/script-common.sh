# shellcheck disable=SC2148

# Purpose:  Useful functions for inclusion in bash scripts
# Usage:    . script-common.sh
# Notes:    progName & logFile vars should be set in calling script

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------

# Text colours
red='tput setaf 1'
green='tput setaf 2'
yellow='tput setaf 3'
magenta='tput setaf 5'
cyan='tput setaf 6'
reset='tput sgr0'

# Set sensible defaults if calling script didn't set vars
if [[ -z ${progName} ]]; then
  progName="script"
fi
if [[ -z ${logFile} ]]; then
  logFile="script.log"
fi

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

appendOnce() {
  # Purpose:  Appends a string to a file if it doesn't already exist
  # Usage:    appendOnce "string" "/path/to/file"
  string=$1
  file=$2
  if ! [ -f "${file}" ]; then
    echo "${string}" | sudo tee "${file}"
  elif [[ $(grep -c "${string}" < "${file}") -eq 0 ]]; then
    echo "${string}" | sudo tee -a "${file}"
  fi
}
begin() {
  # Purpose:  Prints progName and initialises log
  # Usage:    begin
  startTime=${SECONDS}
  echo
  ${magenta}; printf " ℹ︎  "; ${reset}; echo "${progName} started"
  echo "$(date "+%Y-%m-%d %H:%M:%S")  ${progName} started" > "${logFile}"
  echo
}
check() {
  # Purpose:  Checks the return code and displays an appropriate message
  # Usage:    check $? Task description
  if [[ $1 -eq 0 ]]; then
    shift
    okay "$* completed"
  else
    shift
    fail "$* failed"
  fi
}
end() {
  # Purpose:  Prints time taken for script to complete
  # Requires: begin function to be run at start of script
  # Usage:    end
  endTime=${SECONDS}
  elapsedTime=$(( endTime - startTime ))
  # Divide time into minutes & seconds
  if [[ ${elapsedTime} -lt 60 ]]; then
    mins=0
    secs=${elapsedTime}
  else
    mins=$(( elapsedTime / 60 ))
    secs=$(( elapsedTime % 60 ))
  fi
  # Check if minutes should be plural or single
  if [[ ${mins} -eq 1 ]]; then
    minSuffix="minute"
  else
    minSuffix="minutes"
  fi
  # Check if seconds should be plural or single
  if [[ ${secs} -eq 1 ]]; then
    secSuffix="second"
  else
    secSuffix="seconds"
  fi
  # Define output
  if [[ ${elapsedTime} -eq 0 ]]; then
    scriptTime="less than a second"
  elif [[ ${elapsedTime} -lt 60 ]]; then
    scriptTime="${secs} ${secSuffix}"
  else
    scriptTime="${mins} ${minSuffix}, ${secs} ${secSuffix}"
  fi
  echo
  ${magenta}; printf " ℹ︎  "; ${reset}; echo "${progName} completed in ${scriptTime}"
  echo
}
fail() {
  # Purpose:  Display & log a task failed message then exit
  # Usage:    fail Message to display
  echo
  ${red}; printf " ✗  "; ${reset}; echo "$*" >&2
  echo "$(date "+%Y-%m-%d %H:%M:%S")  $*" >> "${logFile}"
  echo
  ${red}; printf " ℹ︎  "; ${reset}; echo "Logs saved at ${logFile}"
  echo
  exit 1
}
info() {
  # Purpose:  Display & log an informational message
  # Usage:    info Message to display
  ${cyan}; printf " ℹ︎  "; ${reset}; echo "$*"
  echo "$(date "+%Y-%m-%d %H:%M:%S")  $*" >> "${logFile}"
}
# shellcheck disable=SC2206
ipValid() {
  # Purpose:  Check if argument is a valid IP address
  # Usage:    ipValid "x.x.x.x"
  local ip=${1:-1.2.3.4}
  local IFS=.; local -a a=(${ip})
  # Start with a regex format test
  if ! [[ ${ip} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    return 1
  fi
  # Test values of quads
  for quad in {0..3}; do
    if [[ "${a[$quad]}" -gt 255 ]]; then
      return 1
    fi
  done
  return 0
}
okay() {
  # Purpose:  Display & log a task successful message
  # Usage:    okay Message to display
  ${green}; printf " ✓  "; ${reset}; echo "$*"
  echo "$(date "+%Y-%m-%d %H:%M:%S")  $*" >> "${logFile}"
  echo
}
warn() {
  # Purpose:  Display & log a warning message
  # Usage:    warn Message to display
  ${yellow}; printf " !  "; ${reset}; echo "$*" >&2
  echo "$(date "+%Y-%m-%d %H:%M:%S")  $*" >> "${logFile}"
}