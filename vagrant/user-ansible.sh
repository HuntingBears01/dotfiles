#!/bin/bash -eu

if (id -u ansbl > /dev/null 2>&1); then
  echo "Ansible user already exists"
else
  echo "Create Ansible user"
  useradd -c "Ansible user" -m -r ansbl
fi
