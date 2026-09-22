#!/usr/bin/env bash
# Waybar indicator for the infinite canvas: which cell you are on, the zoom
# level, and whether canvas mode is active.

name=$(hyprctl activeworkspace -j | jq -r '.name')

if [[ ! "$name" =~ ^canvas_(-?[0-9]+)_(-?[0-9]+)$ ]]; then
    echo '{"text": "", "tooltip": "Not on the infinite canvas", "class": "empty"}'
    exit 0
fi

x="${BASH_REMATCH[1]}"
y="${BASH_REMATCH[2]}"

# hyprctl getoption can't read a Lua-parsed config, so ask the config layer.
probe=$(mktemp -t canvas-status.XXXXXX)
trap 'rm -f "$probe"' EXIT
hyprctl eval "
    local f = io.open('$probe', 'w')
    f:write(tostring(hl.get_config('cursor.zoom_factor')) .. ' ' .. tostring(hl.get_current_submap()))
    f:close()" >/dev/null 2>&1 || true
read -r zoom submap <"$probe" 2>/dev/null || { zoom=1; submap=; }

zoom_label=""
if [[ -n "$zoom" ]] && awk "BEGIN{exit !($zoom > 1.001)}" 2>/dev/null; then
    zoom_label=$(printf '  %.2gx' "$zoom")
fi

if [[ "$submap" == "canvas" ]]; then
    class="canvas-mode"
    tooltip="Canvas mode at ${x}, ${y} - single keys drive the canvas, ? for the key list, Esc to leave"
else
    class="on-canvas"
    tooltip="On the infinite canvas at ${x}, ${y} - click to go home, Super+Alt+C for canvas mode"
fi

printf '{"text": "%s, %s%s", "tooltip": "%s", "class": "%s"}\n' \
    "$x" "$y" "$zoom_label" "$tooltip" "$class"
