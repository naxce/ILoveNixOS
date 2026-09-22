#!/usr/bin/env bash
set -euo pipefail

THEME="$(cat "$HOME/.cache/control-center/theme" 2>/dev/null || echo noir)"
CONF="$HOME/NixOS/Config/hypr/hyprpaper-${THEME}.conf"

wallpaper="$(sed -n 's/^ *path *= *//p' "$CONF" 2>/dev/null | head -1)"
wallpaper="${wallpaper/#\~/$HOME}"

if [ -z "$wallpaper" ] || [ ! -e "$wallpaper" ]; then
    echo "niri-wallpaper: ${wallpaper:-wallpaper} is missing" >&2
    exit 0
fi

pkill swaybg 2>/dev/null || true
for _ in $(seq 20); do
    pgrep swaybg >/dev/null 2>&1 || break
    sleep 0.05
done

exec swaybg -i "$wallpaper" -m fill
