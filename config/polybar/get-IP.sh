#!/usr/bin/env bash

# Get all IPv4 interfaces, then exclude loopback and virtual adapters
# and extract the IP address
ip -4 -o addr | grep -Ev "\\Wlo|vmnet" | awk '{print $4}' | cut -d/ -f1