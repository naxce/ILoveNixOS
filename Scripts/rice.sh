#!/usr/bin/env bash

CHOICE=$(zenity --list \
    --title="Ricing Selector" \
    --column="Theme" \
    --text="Choose the style:" \
    "Blue" \
    "Red" \
    "Purple" \
    " " \
    "Change Wallpaper" \
    " " \
    "Kill Rice" \
    --width=300 --height=450)

case "$CHOICE" in
    Blue)
        ~/NixOS/scripts/blue.sh
        ;;
    Red)
        ~/NixOS/scripts/red.sh
        ;;
    Purple)
        ~/NixOS/scripts/purple.sh
        ;;
    "Change Wallpaper")
        ~/NixOS/scripts/wallpaper.sh
        ;;
    "Kill Rice")
        pkill -f kitty
        ;;
esac