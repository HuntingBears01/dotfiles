#! /usr/bin/env bash

# Reload xresources
xrdb -merge "${HOME}/.Xresources"

# Reload i3wm
i3-msg restart

# Restart compton
pkill compton  && compton
