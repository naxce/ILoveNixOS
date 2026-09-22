#!/usr/bin/env bash
# Pick a window on the infinite canvas and bring the view to it.
#
# On a canvas that is zoomed out, or panned a long way from where you left
# something, hunting for a window by eye stops working. This lists what is on
# the canvas and centres the view on whichever you pick.
set -euo pipefail

CANVAS_WS="canvas"

rows="$(hyprctl clients -j | jq -r --arg ws "$CANVAS_WS" '
    [ .[] | select(.workspace.name == $ws) ]
    | sort_by(.at[1], .at[0])
    | .[]
    | "\(.class)\t\(.title[0:60])\t\(.address)"
')"

if [ -z "${rows//[[:space:]]/}" ]; then
    hyprctl notify 1 2500 0 "Canvas is empty" >/dev/null 2>&1 || true
    exit 0
fi

choice="$(printf '%s\n' "$rows" \
    | column -t -s $'\t' -o '   ' \
    | rofi -dmenu -i -p "Canvas" -mesg "Jump to a window" \
    || true)"

[ -n "${choice:-}" ] || exit 0

address="$(grep -oE '0x[0-9a-f]+' <<<"$choice" | tail -1)"
[ -n "$address" ] || exit 0

# Focus it, then slide the whole canvas so it lands in the middle of the
# monitor. Panning moves every window together, which is what keeps their
# relative positions on the plane intact.
# hyprctl dispatch is intercepted by the Lua config layer and only accepts
# hl.dsp.* objects, so go through eval.
hyprctl eval "
    hl.dispatch(hl.dsp.focus({ workspace = 'name:${CANVAS_WS}' }))
    local win = hl.get_window('address:${address}')
    local mon = hl.get_active_monitor()
    if win and mon and win.floating then
        local dx = (mon.x + (mon.width  - win.size.x) / 2) - win.at.x
        local dy = (mon.y + (mon.height - win.size.y) / 2) - win.at.y
        for _, w in ipairs(hl.get_windows({ workspace = '${CANVAS_WS}' })) do
            if w.floating then
                hl.dispatch(hl.dsp.window.move({
                    x = math.floor(w.at.x + dx),
                    y = math.floor(w.at.y + dy),
                    exact = true,
                    window = 'address:' .. tostring(w.address),
                }))
            end
        end
    end
    hl.dispatch(hl.dsp.focus({ window = 'address:${address}' }))
" >/dev/null
