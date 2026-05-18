#!/usr/bin/env bash

echo "🎮 Switching to GAMING MODE..."

kwriteconfig6 --file kwinrc --group Compositing --key AnimationSpeed 0
kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled false
kwriteconfig6 --file kwinrc --group Compositing --key LatencyPolicy Low
kwriteconfig6 --file kwinrc --group Compositing --key UnredirectFullscreen true

qdbus org.kde.KWin /KWin org.kde.KWin.reconfigure

kwin_wayland --replace & disown

sleep 3
pkill kitty

echo "✅ GAMING MODE ENABLED"