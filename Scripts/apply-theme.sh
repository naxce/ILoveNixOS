#!/usr/bin/env bash
# Repoint every themed config at the chosen palette, then reload what's running.
#
# Configs live in ~/NixOS/Config as <name>-<theme>.<ext> pairs. Home-manager
# only links the theme-neutral files, so the themed paths below stay writable
# and this script owns them as symlinks back into the repo.
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

link() { # link <src under Config/> <dst under ~/.config/>
    local src="$CFG/$1" dst="$DST/$2"
    if [ ! -e "$src" ]; then
        echo "apply-theme: missing $src, leaving $dst alone" >&2
        return 0
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
}

link "waybar/style-$THEME.css" "waybar/style.css"
link "swaync/style-$THEME.css" "swaync/style.css"
link "wlogout/style-$THEME.css" "wlogout/style.css"
link "hyprswitch/style-$THEME.css" "hyprswitch/style.css"
link "control-center/control-center-$THEME.css" "control-center/style.css"
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

# wlogout's CSS points at its icons with paths relative to the stylesheet, and
# GTK resolves those against the path wlogout was handed, not the symlink target.
link "wlogout/icons" "wlogout/icons"
link "wlogout/icons-dachshund" "wlogout/icons-dachshund"

# --- reload whatever is running -------------------------------------------
# Everything else (rofi, yazi, cava, sptlrx, fastfetch, hyprlock, nvim) reads
# its config at launch, so it picks the new palette up on its own.

reload() { command -v "$1" >/dev/null 2>&1 || return 0; "$@" >/dev/null 2>&1 || true; }

# No -x here: nixpkgs wraps these, so the process name is ".waybar-wrapped".
pkill -USR2 waybar || true                         # waybar: reload config + css
pkill -USR1 kitty || true                          # kitty: reload kitty.conf
reload swaync-client --reload-css
reload hyprctl reload                              # hyprland: looknfeel

if pgrep hyprpaper >/dev/null 2>&1; then
    wallpaper="$(sed -n 's/^ *path *= *//p' "$CFG/hypr/hyprpaper-$THEME.conf" | head -1)"
    wallpaper="${wallpaper/#\~/$HOME}"
    if [ -n "$wallpaper" ] && [ ! -e "$wallpaper" ]; then
        echo "apply-theme: $wallpaper is missing, keeping the current wallpaper" >&2
    else
        pkill hyprpaper || true
        setsid hyprpaper >/dev/null 2>&1 &
    fi
fi

if pgrep hyprswitch >/dev/null 2>&1; then
    pkill hyprswitch || true
    setsid hyprswitch init --show-title --custom-css "$DST/hyprswitch/style.css" >/dev/null 2>&1 &
fi

echo "apply-theme: $THEME"
