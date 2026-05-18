#!/usr/bin/env bash

echo "✨ Switching to RICING MODE..."

kwriteconfig6 --file kwinrc --group Compositing --key AnimationSpeed 3
kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
kwriteconfig6 --file kwinrc --group Compositing --key LatencyPolicy Balanced
kwriteconfig6 --file kwinrc --group Compositing --key UnredirectFullscreen false

qdbus org.kde.KWin /KWin org.kde.KWin.reconfigure

sleep 0.5
kwin_wayland --replace & disown

sleep 3
sh -c "~/NixOS/scripts/rice.sh"

echo "✅ RICING MODE ENABLED"