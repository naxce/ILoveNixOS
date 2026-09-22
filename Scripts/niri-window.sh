#!/usr/bin/env bash
# Waybar focused-window indicator for niri, standing in for the missing
# niri/window module.
set -euo pipefail

niri-cli msg --json focused-window 2>/dev/null \
    | jq -c 'if . == null then
                 { text: "Desktop", tooltip: "No focused window", class: "empty" }
             else
                 { text: ((.title // .app_id // "Window")[0:40]),
                   tooltip: ((.app_id // "?") + " — " + (.title // "")),
                   class: "focused" }
             end' 2>/dev/null || echo '{"text": "Desktop", "class": "empty"}'
