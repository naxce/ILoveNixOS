#!/usr/bin/env bash
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
