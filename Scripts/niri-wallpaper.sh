#!/usr/bin/env bash
# Set the wallpaper for niri, following whichever palette is active.
#
# hyprpaper is driven over Hyprland's IPC and has nothing to talk to under
# niri, so swaybg does the job here. The path is read from the same
# hyprpaper-<theme>.conf the Hyprland side uses, so both compositors show the
# same picture and there is only one place to change it.
set -euo pipefail

THEME="$(cat "$HOME/.cache/control-center/theme" 2>/dev/null || echo noir)"
CONF="$HOME/NixOS/Config/hypr/hyprpaper-${THEME}.conf"

wallpaper="$(sed -n 's/^ *path *= *//p' "$CONF" 2>/dev/null | head -1)"
wallpaper="${wallpaper/#\~/$HOME}"

if [ -z "$wallpaper" ] || [ ! -e "$wallpaper" ]; then
    echo "niri-wallpaper: ${wallpaper:-wallpaper} is missing" >&2
    exit 0
fi

# Only one swaybg at a time, or they stack up invisible layers on every
# theme switch.
pkill -x swaybg 2>/dev/null || true
for _ in $(seq 20); do
    pgrep -x swaybg >/dev/null 2>&1 || break
    sleep 0.05
done

exec swaybg -i "$wallpaper" -m fill
