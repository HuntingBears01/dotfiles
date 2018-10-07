#!/usr/bin/env bash

# Regular updates
regular=$(/usr/lib/update-notifier/apt-check 2>&1 | cut -d ';' -f 1)

# Security updates
# security=$(/usr/lib/update-notifier/apt-check 2>&1 | cut -d ';' -f 2)

echo "${regular}"