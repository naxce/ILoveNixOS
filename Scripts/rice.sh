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
        ~/NixOS/Scripts/blue.sh
        ;;
    Red)
        ~/NixOS/Scripts/red.sh
        ;;
    Purple)
        ~/NixOS/Scripts/purple.sh
        ;;
    "Change Wallpaper")
        ~/NixOS/Scripts/wallpaper.sh
        ;;
    "Kill Rice")
        pkill -f kitty
        ;;
esac