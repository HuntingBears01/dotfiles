#!/usr/bin/env bash

# Display load averages for last 1, 5 & 15 minutes
uptime | awk '{print $(NF-2) " " $(NF-1) " " $NF}'