#!/usr/bin/env bash

name=$(hyprctl activeworkspace -j | jq -r '.name')

if [[ "$name" =~ ^canvas_(-?[0-9]+)_(-?[0-9]+)$ ]]; then
    x="${BASH_REMATCH[1]}"
    y="${BASH_REMATCH[2]}"
    echo "{\"text\": \"${x}, ${y}\", \"tooltip\": \"On the infinite canvas at ${x}, ${y} - click to go home\", \"class\": \"on-canvas\"}"
else
    echo '{"text": "", "tooltip": "Not on the infinite canvas", "class": "empty"}'
fi
