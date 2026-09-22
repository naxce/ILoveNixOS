#!/usr/bin/env bash
set -uo pipefail

trap 'exit 0' PIPE HUP TERM

emit() {
    niri-cli msg --json workspaces 2>/dev/null | jq -c '
        (map(select(.is_focused)) | first | .output) as $out
        | map(select(.output == $out))
        | sort_by(.idx)
        | (length) as $n
        | [ to_entries[]
            | select(.value.active_window_id != null or .value.is_active or .key < ($n - 1)) ]
        | map(.value)
        | { text: (map(if .is_active then "●" else "○" end) | join(" ")),
            tooltip: ($out + ": " + (map((.name // (.idx | tostring)))
                      | join(", "))),
            class: "niri-workspaces" }' 2>/dev/null \
        || echo '{"text": "", "class": "empty"}'
}

emit || exit 0

niri-cli msg --json event-stream 2>/dev/null | while IFS= read -r line; do
    case "$line" in
    *WorkspacesChanged* | *WorkspaceActivated* | *WorkspaceActiveWindowChanged* | *WindowsChanged* | *WindowClosed* | *WindowOpenedOrChanged*)
        emit || exit 0
        ;;
    esac
done
