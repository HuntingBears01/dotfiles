#!/bin/bash -eu

appendOnce() {
  # Purpose:  Append string to a file if it doesn't already exist
  # Usage:    appendOnce "string" "/path/to/file"
  string=$1
  file=$2
  if ! [ -f "${file}" ]; then
    echo "${string}" | sudo tee "${file}"
  elif [[ $(grep -c "${string}" < "${file}") -eq 0 ]]; then
    echo "${string}" | sudo tee -a "${file}"
  fi
}

echo "Install SSH keys"
for user_id in ansbl vagrant; do
  if [[ ! -d "/home/${user_id}/.ssh" ]]; then
    mkdir -p "/home/${user_id}/.ssh"
  fi
   appendOnce "$(cat "/tmp/id_rsa.pub")" "/home/${user_id}/.ssh/authorized_keys" > /dev/null 2>&1

  chown -R ${user_id}:${user_id} "/home/${user_id}/.ssh"
  chmod 700 "/home/${user_id}/.ssh"
  chmod 600 "/home/${user_id}/.ssh/authorized_keys"
done

rm -f /tmp/id_rsa.pub
