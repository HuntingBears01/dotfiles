#!/bin/bash -eu

file=/etc/sudoers.d/050-ansible

if ! [ -f "${file}" ]; then
  echo "Configure sudoers for Ansible user"
  # Ansible account
  echo "Defaults:ansbl  !requiretty" > "${file}"
  echo "ansbl  ALL=(ALL)  NOPASSWD: ALL" >> "${file}"
  chmod 440 "${file}"
fi
