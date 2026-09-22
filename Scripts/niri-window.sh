#!/usr/bin/env bash
set -uo pipefail

trap 'exit 0' PIPE HUP TERM

emit() {
    niri-cli msg --json focused-window 2>/dev/null | jq -c '
        if . == null then
            { text: "Desktop", tooltip: "No focused window", class: "empty" }
        else
            { text: ((.title // .app_id // "Window") | if length > 40 then .[0:39] + "…" else . end),
              tooltip: ((.app_id // "?") + " — " + (.title // "")),
              class: "focused" }
        end' 2>/dev/null || echo '{"text": "Desktop", "class": "empty"}'
}

emit || exit 0

niri-cli msg --json event-stream 2>/dev/null | while IFS= read -r line; do
    case "$line" in
    *WindowFocusChanged* | *WindowOpenedOrChanged* | *WindowClosed* | *WindowsChanged* | *WorkspaceActivated*)
        emit || exit 0
        ;;
    esac
done
