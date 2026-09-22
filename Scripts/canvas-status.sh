#!/usr/bin/env bash

name=$(hyprctl activeworkspace -j | jq -r '.name')

if [[ "$name" != "canvas" ]]; then
    echo '{"text": "", "tooltip": "Not on the infinite canvas", "class": "empty"}'
    exit 0
fi

count=$(hyprctl clients -j | jq '[.[] | select(.workspace.name == "canvas")] | length')

probe=$(mktemp -t canvas-status.XXXXXX)
trap 'rm -f "$probe"' EXIT
hyprctl eval "local f = io.open('$probe', 'w') f:write(tostring(hl.get_current_submap())) f:close()" >/dev/null 2>&1 || true
submap=$(cat "$probe" 2>/dev/null || true)

if [[ "$submap" == "canvas" ]]; then
    class="canvas-mode"
    tooltip="Canvas mode - single keys drive the canvas, ? for the key list, Esc to leave"
else
    class="on-canvas"
    tooltip="Infinite canvas, ${count} window(s) - Super+Alt+C for canvas mode, Super+Alt+0 to fit"
fi

printf '{"text": "󰹑 %s", "tooltip": "%s", "class": "%s"}\n' "$count" "$tooltip" "$class"
