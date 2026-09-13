#!/usr/bin/env bash

count=$(hyprctl clients -j | jq '[.[] | select(.workspace.name == "special:minimized")] | length')

if [ "$count" -eq 0 ]; then
    echo '{"text": "", "tooltip": "No minimized windows", "class": "empty"}'
else
    echo "{\"text\": \" ${count}\", \"tooltip\": \"${count} minimized window(s) - click to restore\", \"class\": \"has-minimized\"}"
fi
