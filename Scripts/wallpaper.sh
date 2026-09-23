#!/usr/bin/env bash
set -euo pipefail

[ -n "${WAYLAND_DISPLAY:-}" ] || exit 0

THEME="$(cat "$HOME/.cache/control-center/theme" 2>/dev/null || echo noir)"
CONF="$HOME/NixOS/Config/hypr/hyprpaper-${THEME}.conf"

wallpaper="$(sed -n 's/^ *path *= *//p' "$CONF" 2>/dev/null | head -1)"
wallpaper="${wallpaper/#\~/$HOME}"

if [ -z "$wallpaper" ] || [ ! -e "$wallpaper" ]; then
    echo "wallpaper: ${wallpaper:-wallpaper} is missing" >&2
    exit 0
fi

stop() {
    pkill "$1" 2>/dev/null || true
    for _ in $(seq 20); do
        pgrep "$1" >/dev/null 2>&1 || break
        sleep 0.05
    done
}

if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && hyprctl version >/dev/null 2>&1; then
    stop hyprpaper
    rm -f "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.hyprpaper.sock"
    exec hyprpaper
fi

stop swaybg
exec swaybg -i "$wallpaper" -m fill
