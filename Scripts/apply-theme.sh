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

link "waybar/config-$THEME.jsonc" "waybar/config.jsonc"
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
link "niri/looknfeel-$THEME.kdl" "niri/looknfeel.kdl"

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

# hyprpaper has to be restarted to pick up a new conf: this build has no
# working "preload" IPC request, and "wallpaper" silently does nothing for an
# image that was never preloaded. Kill it, wait for the socket to be released,
# clear a socket left behind by any stray instance, then start exactly one.
if pgrep hyprpaper >/dev/null 2>&1; then
    wallpaper="$(sed -n 's/^ *path *= *//p' "$CFG/hypr/hyprpaper-$THEME.conf" | head -1)"
    wallpaper="${wallpaper/#\~/$HOME}"
    if [ -z "$wallpaper" ] || [ ! -e "$wallpaper" ]; then
        echo "apply-theme: ${wallpaper:-wallpaper} is missing, keeping the current one" >&2
    else
        pkill -x hyprpaper || true
        for _ in $(seq 20); do
            pgrep -x hyprpaper >/dev/null 2>&1 || break
            sleep 0.05
        done
        sock="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/${HYPRLAND_INSTANCE_SIGNATURE:-}/.hyprpaper.sock"
        [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && rm -f "$sock"
        setsid hyprpaper >/dev/null 2>&1 </dev/null &
    fi
fi

# niri reloads its own config on change, but the wallpaper is swaybg's job and
# has to be pointed at the new image.
if pgrep -x niri >/dev/null 2>&1; then
    setsid "$HOME/NixOS/Scripts/niri-wallpaper.sh" >/dev/null 2>&1 </dev/null &
fi

if pgrep hyprswitch >/dev/null 2>&1; then
    pkill hyprswitch || true
    setsid hyprswitch init --show-title --custom-css "$DST/hyprswitch/style.css" >/dev/null 2>&1 &
fi

echo "apply-theme: $THEME"
