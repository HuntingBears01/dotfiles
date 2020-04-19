#!/bin/bash -eux

file=/etc/sudoers.d/050-ansible

if ! [ -f "${file}" ]; then
  # Ansible account
  echo "Defaults:ansbl  !requiretty" > "${file}"
  echo "ansbl  ALL=(ALL)  NOPASSWD: ALL" >> "${file}"
  chmod 440 "${file}"
fi
