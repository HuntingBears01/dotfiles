#!/usr/bin/env bash

laptop=eDP1
declare -a monitors
mapfile -t monitors < <(xrandr | grep '\Wconnected' | awk '{ print $1 }')

case ${#monitors[@]} in
  1)
    xrandr --dpi 144 --output "${monitors[0]}" --auto --primary
  ;;
  2)
    if [[ "${monitors[0]}" = "${laptop}" ]]; then
      xrandr --output "${monitors[0]}" --off --output "${monitors[1]}" --auto
    elif [[ "${monitors[1]}" = "${laptop}" ]]; then
      xrandr --output "${monitors[0]}" --auto --output "${monitors[1]}" --off
    else
      xrandr --output "${monitors[0]}" --auto --output "${monitors[1]}" --auto
    fi
  ;;
  3)
    if [[ "${monitors[0]}" = "${laptop}" ]]; then
      xrandr --output "${monitors[0]}" --off --output "${monitors[1]}" --auto --output "${monitors[2]}" --auto
    elif [[ "${monitors[1]}" = "${laptop}" ]]; then
      xrandr --output "${monitors[0]}" --auto --output "${monitors[1]}" --off --output "${monitors[2]}" --auto
    else
      xrandr --output "${monitors[0]}" --auto --output "${monitors[1]}" --auto --output "${monitors[2]}" --off
    fi
  ;;
esac

"$HOME/.config/i3/restart"
~/.fehbg
