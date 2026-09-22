#!/usr/bin/env bash
# Overview of the infinite canvas: every occupied cell, what's on it, and a
# jump to whichever you pick.
#
# This exists because Hyprland's cursor zoom only magnifies -- a factor below
# 1.0 is accepted by the config but clamped away by the renderer -- so there
# is no "zoom out until you see everything". A picker covers that instead.
set -euo pipefail

jump() { # jump <workspace name>
    # hyprctl dispatch is intercepted by the Lua config layer and only accepts
    # hl.dsp.* objects, so go through eval.
    # "name:" matters: a bare name is read as an id, so an empty cell is
    # rejected instead of being created.
    hyprctl eval "hl.dispatch(hl.dsp.focus({ workspace = 'name:$1' }))" >/dev/null
}

current="$(hyprctl activeworkspace -j | jq -r '.name')"

# One row per occupied cell: coordinates, window count, and the app names, so
# you can recognise a cell without having to remember its number.
rows="$(hyprctl clients -j | jq -r --arg current "$current" '
    [ .[] | select(.workspace.name | test("^canvas_-?[0-9]+_-?[0-9]+$")) ]
    | group_by(.workspace.name)
    | map({
        name: .[0].workspace.name,
        x:    (.[0].workspace.name | capture("^canvas_(?<x>-?[0-9]+)_(?<y>-?[0-9]+)$") | .x | tonumber),
        y:    (.[0].workspace.name | capture("^canvas_(?<x>-?[0-9]+)_(?<y>-?[0-9]+)$") | .y | tonumber),
        count: length,
        apps: ([ .[] | .class | select(. != "") ] | unique | join(", "))
      })
    | sort_by(.y, .x)
    | .[]
    | "\(if .name == $current then "●" else "○" end)  \(.x), \(.y)\t\(.count) window\(if .count == 1 then "" else "s" end)  ·  \(.apps)\t\(.name)"
')"

# The home cell is always worth offering even when nothing is on it yet.
if ! grep -qP '\tcanvas_0_0$' <<<"${rows:-}"; then
    home_mark="$([ "$current" = "canvas_0_0" ] && printf '●' || printf '○')"
    rows="$(printf '%s  0, 0\tempty\tcanvas_0_0\n%s' "$home_mark" "${rows:+$rows}")"
fi

choice="$(printf '%s\n' "$rows" \
    | column -t -s $'\t' -o '   ' \
    | rofi -dmenu -i -p "Canvas" -mesg "Pick a cell to jump to" -format 's' \
    || true)"

[ -n "${choice:-}" ] || exit 0

# Recover the workspace name from the trailing column the picker displayed.
target="$(grep -oE 'canvas_-?[0-9]+_-?[0-9]+' <<<"$choice" | tail -1)"
[ -n "$target" ] || exit 0

jump "$target"
