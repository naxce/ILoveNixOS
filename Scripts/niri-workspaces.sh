#!/usr/bin/env bash
# Waybar workspace indicator for niri.
#
# This build of Waybar has no niri/workspaces module, so the bar gets a custom
# module fed from niri's own IPC instead.
set -euo pipefail

json="$(niri-cli msg --json workspaces 2>/dev/null || echo '[]')"

printf '%s' "$json" | jq -c --arg out "${1:-}" '
    map(select($out == "" or .output == $out))
    | sort_by(.idx)
    | { text: (map(if .is_focused then "●" elif .active_window_id != null then "◍" else "○" end) | join("  ")),
        tooltip: ("Workspaces: " + (map((.name // (.idx|tostring))) | join(", "))),
        class: "niri-workspaces" }
'
