#!/bin/bash -eux

if (id -u ansbl > /dev/null 2>&1); then
  echo "User already exists"
else
  useradd -c "Ansible user" -m -r ansbl
fi
