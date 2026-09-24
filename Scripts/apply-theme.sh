#!/usr/bin/env bash
set -euo pipefail

STATE="$HOME/.cache/control-center/theme"
CFG="$HOME/NixOS/Config"
DST="${XDG_CONFIG_HOME:-$HOME/.config}"

THEME="${1:-$(cat "$STATE" 2>/dev/null || echo noir)}"
case "$THEME" in
noir | dachshund) ;;
*)
    echo "apply-theme: unknown theme '$THEME'" >&2
    exit 1
    ;;
esac

mkdir -p "$(dirname "$STATE")"
printf '%s' "$THEME" >"$STATE"

link() {
    local src="$CFG/$1" dst="$DST/$2"
    if [ ! -e "$src" ]; then
        echo "apply-theme: missing $src, leaving $dst alone" >&2
        return 0
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
}

link "waybar/config-$THEME.jsonc" "waybar/config.jsonc"
link "waybar/style-$THEME.css" "waybar/style.css"
link "swaync/style-$THEME.css" "swaync/style.css"
link "wlogout/style-$THEME.css" "wlogout/style.css"
link "hyprswitch/style-$THEME.css" "hyprswitch/style.css"
link "rofi/$THEME.rasi" "rofi/theme.rasi"
link "kitty/themes/$THEME.conf" "kitty/theme.conf"
link "yazi/theme-$THEME.toml" "yazi/theme.toml"
link "cava/config-$THEME" "cava/config"
link "sptlrx/config-$THEME.yaml" "sptlrx/config.yaml"
link "fastfetch/config-$THEME.jsonc" "fastfetch/config.jsonc"
link "fastfetch/work-$THEME.jsonc" "fastfetch/work.jsonc"
link "hypr/hyprlock-$THEME.conf" "hypr/hyprlock.conf"
link "hypr/hyprpaper-$THEME.conf" "hypr/hyprpaper.conf"
link "hypr/looknfeel-$THEME.lua" "hypr/looknfeel.lua"
link "niri/looknfeel-$THEME.kdl" "niri/looknfeel.kdl"

link "wlogout/icons" "wlogout/icons"
link "wlogout/icons-dachshund" "wlogout/icons-dachshund"

reload() { command -v "$1" >/dev/null 2>&1 || return 0; "$@" >/dev/null 2>&1 || true; }

pkill -USR2 waybar || true
pkill -USR1 kitty || true
reload swaync-client --reload-css
reload hyprctl reload

if [ "$(sylvaris get paper.enabled 2>/dev/null)" != "true" ]; then
    setsid "$HOME/NixOS/Scripts/wallpaper.sh" >/dev/null 2>&1 </dev/null &
fi

if pgrep hyprswitch >/dev/null 2>&1; then
    pkill hyprswitch || true
    setsid hyprswitch init --show-title --custom-css "$DST/hyprswitch/style.css" >/dev/null 2>&1 &
fi

echo "apply-theme: $THEME"
