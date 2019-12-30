#! /usr/bin/env bash
#
# Purpose:  Build a custom Vagrantfile using specified options
# Usage:    mkvagrantfile.sh release [options...] foldername [servername1, servername2 ...]

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Configuration
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Script variables
# shellcheck disable=SC2034
progDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
progName=$(basename "$0")
logDir="${HOME}/logs"
logName="${progName%.*}"
logFile="${logDir}/${logName}.log"

# Create log directory
if [[ ! -d ${logDir} ]]; then
  mkdir "${logDir}"
fi

# Import common functions
# shellcheck disable=SC1090
if [[ -f "${HOME}/scripts/script-common.sh" ]]; then
  . "${HOME}/scripts/script-common.sh"
else
  echo "Unable to open script-common.sh"
  exit 1
fi

# Update the version numbers below as required
# CentOS versions
centosCurrVersion="8"
centosPrevVersion="7"
centosPlatform="x86_64"
centosCurrRelease="centos-${centosCurrVersion}-${centosPlatform}"
centosPrevRelease="centos-${centosPrevVersion}-${centosPlatform}"
# Debian versions
debianCurrVersion="10"
debianPrevVersion="9"
debianPlatform="amd64"
debianCurrRelease="debian-${debianCurrVersion}-${debianPlatform}"
debianPrevRelease="debian-${debianPrevVersion}-${debianPlatform}"
# NOTE  All the *CurrVersion & *PrevVersion vars above must contain
# only numbers. No special characters allowed.

# Array to hold all boxes
declare -a selectedBoxes=()
# Array to hold all box names
declare -a selectedBoxNames=()
# Array to hold server names
declare -a selectedServerNames=()

# Default values
cpu="1"
mem="1024"
publicIP=""
destDir="."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

usage() {
  echo
  echo "Usage: ${progName} release [options...] foldername [servername1, servername2 ...]"
  echo
  echo "  Current releases:"
  echo
  echo "  --centos-current          Setup a CentOS ${centosCurrVersion} box"
  echo "  --debian-current          Setup a Debian ${debianCurrVersion} box"
  echo
  echo "  Previous releases:"
  echo
  echo "  --centos-previous         Setup a CentOS ${centosPrevVersion} box"
  echo "  --debian-previous         Setup a Debian ${debianPrevVersion} box"
  echo
  echo "  --all                     Setup all releases in one file"
  echo "  --centos-all              Setup all CentOS releases in one file"
  echo "  --debian-all              Setup all Debian releases in one file"
  echo
  echo "  Options:"
  echo
  echo "  --mem size                Set the amount of RAM in MB"
  echo "  --cpu number              Set the number of vCPUs"
  echo "  --ip ip_address           Set a public IP address"
  echo "  --dir /path/to/dir        Set destination directory (defaults to current dir)"
  echo
  echo "  --help                    Display this help"
  echo
}
incrementIP() {
  # Purpose:  Increment the last octet of an IP address
  # Usage:    incrementIP "x.x.x.x"
  # Returns:  nextIP
  base=$(echo "$1" | cut -d. -f1-3)
  lsv=$(echo "$1" | cut -d. -f4)
  export nextIP
  if [[ "${lsv}" -ge 254 ]]; then
    warn "IP address limit reached"
    nextIP=""
  else
    lsv=$(( lsv + 1 ))
    nextIP="${base}.${lsv}"
  fi
}
isDirectory() {
  # Purpose:  Check if argument is a directory
  # Usage:    isDirectory "/path/to/dir"
  if [[ -d $1 ]]; then
    return 0
  else
    return 1
  fi
}
isPosInt() {
  # Purpose:  Check if argument is a positive integer
  # Usage:    isPosInt number
  local number=$1
  if [[ "${number}" =~ ^[0-9]+$ ]]; then
    return 0
  else
    return 1
  fi
}
createDir() {
  # Purpose:  Create a directory if it doesn't exist
  # Usage:    creatDir "/path/to/dir"
  if [ -d "$1" ]; then
    return 1
  else
    mkdir "$1"
    return 0
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Vagrantfile creation functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

vagrantfileBegin() {
  # Usage:  vagrantfileBegin "/path/to/dir"
  cd "$1" || fail "Unable to open directory $1"
  cat << EOF > Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
EOF
}
vagrantfileDefineVM() {
  # Usage:  vagrantfileDefineVM "name" "box" "memory" "cpu"
  vmName="$1"
  vmBox="$2"
  vmMem="$3"
  vmCPU="$4"
  cat << EOF >> Vagrantfile
  config.vm.define "${vmName}" do |${vmName}|
    ${vmName}.vm.box = "${vmBox}"
    ${vmName}.vm.hostname = "${vmName}.test"
    ${vmName}.vm.provider "virtualbox" do |vb|
      vb.memory = ${vmMem}
      vb.cpus = ${vmCPU}
    end
EOF
}
vagrantfilePublicIP() {
  # Usage:  vagrantfilePublicIP "name" "IP"
  vmName="$1"
  vmIP="$2"
  cat << EOF >> Vagrantfile
    ${vmName}.vm.network "public_network", ip: "${vmIP}" , bridge: [
      "en0: Ethernet",
      "en1: Wi-Fi (AirPort)"
    ]
EOF
}
vagrantfileEndVM() {
  # Usage: vagrantfileEndVM
  cat << EOF >> Vagrantfile
  end
EOF
}
vagrantfileEnd() {
  # Usage: vagrantfileEnd
  cat << EOF >> Vagrantfile
end
EOF
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Main
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

begin

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

# Parse release & options
while [[ $# -gt 0 ]]; do
  case $1 in
    --help | -help | -h | '-?' )
      usage
      exit 0
      ;;
    --all | -all | -a )
      box="multi"
      selectedBoxes=(
        "${centosCurrRelease}" "${centosPrevRelease}"
        "${debianCurrRelease}" "${debianPrevRelease}"
        )
      selectedBoxNames=(
        "centos${centosCurrVersion}" "centos${centosPrevVersion}"
        "debian${debianCurrVersion}" "debian${debianPrevVersion}"
        )
      ;;
    --centos-current | -centos-current | -cc )
      box=${centosCurrRelease}
      ;;
    --centos-previous | -centos-previous | -cp )
      box=${centosPrevRelease}
      ;;
    --centos-all | -centos-all | -ca )
      box="multi"
      selectedBoxes=(
        "${centosCurrRelease}" "${centosPrevRelease}"
        )
      selectedBoxNames=(
        "centos${centosCurrVersion}" "centos${centosPrevVersion}"
        )
      ;;
    --debian-current | -debian-current | -dc )
      box=${debianCurrRelease}
      ;;
    --debian-previous | -debian-previous | -dp )
      box=${debianPrevRelease}
      ;;
    --debian-all | -debian-all | -da )
      box="multi"
      selectedBoxes=(
        "${debianCurrRelease}" "${debianPrevRelease}"
        )
      selectedBoxNames=(
        "debian${debianCurrVersion}" "debian${debianPrevVersion}"
        )
      ;;
    --cpu | -cpu )
      shift
      if isPosInt "$1"; then
        cpu=$1
      else
        fail "Invalid CPU value: $1"
      fi
      ;;
    --ip | -ip )
      shift
      if ipValid "$1"; then
        publicIP=$1
      else
        fail "Invalid public IP: $1"
      fi
      ;;
    --mem | -mem )
      shift
      if isPosInt "$1"; then
        mem="$1"
      else
        fail "Invalid memory value: $1"
      fi
      ;;
    --dir | -dir )
      shift
      if isDirectory "$1"; then
        destDir="$1"
      else
        fail "Invalid directory: $1"
      fi
      ;;
    -*)
      fail "Unrecognized option: $1"
      ;;
    *)
      break
      ;;
  esac
  shift
done

if [[ -z "${box}" ]];then
  fail "Release not specified"
fi

# Parse folder names & server names
if [[ $# -gt 1 ]]; then
  dirName=$1
  shift
  i=0
  while [[ $# -gt 0 ]]; do
    selectedServerNames[i]=$1
    shift
    ((i=i+1))
  done
else
  dirName=$1
  selectedServerNames[0]=$1
  shift
fi

info "Creating directory: ${destDir}/${dirName}"
if createDir "${destDir}/${dirName}"; then
  dirName="${destDir}/${dirName}"
else
  fail "Unable to create directory: ${destDir}/${dirName}"
fi

if [[ "${box}" = "multi" ]];then
  info "Setting up Vagrantfile for multiple boxes in directory ${dirName}"
  vagrantfileBegin "${destDir}/${dirName}"
  for (( i=0; i<${#selectedBoxes[@]}; i++ )); do
    box="${selectedBoxes[i]}"
    name="${selectedBoxNames[i]}"
    vagrantfileDefineVM "${name}" "${box}" "${mem}" "${cpu}"
    if [ -n "${publicIP}" ]; then
      vagrantfilePublicIP "${name}" "${publicIP}"
      incrementIP "${publicIP}"
      publicIP=${nextIP}
    fi
    vagrantfileEndVM
  done
  vagrantfileEnd
  okay "Vagrantfile setup complete"
  exit 0
else
  info "Setting up Vagrantfile for ${box} in directory ${dirName}"
  vagrantfileBegin "${destDir}/${dirName}"
  for (( i=0; i<${#selectedServerNames[@]}; i++ ))
  do
    name="${selectedServerNames[i]}"
    vagrantfileDefineVM "${name}" "${box}" "${mem}" "${cpu}"
    if [ -n "${publicIP}" ]; then
      vagrantfilePublicIP "${name}" "${publicIP}"
      incrementIP "${publicIP}"
      publicIP=${nextIP}
    fi
    vagrantfileEndVM
  done
  vagrantfileEnd
  okay "Vagrantfile setup complete"
  exit 0
fi

exit 0
