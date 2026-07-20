#!/usr/bin/env bash

echo "Switching to GAMING MODE..."

hyprctl keyword animations:enabled 0
hyprctl keyword decoration:blur:enabled 0
hyprctl keyword decoration:shadow:enabled 0
hyprctl keyword general:gaps_in 0
hyprctl keyword general:gaps_out 0
hyprctl keyword general:border_size 1

echo "GAMING MODE ENABLED"
