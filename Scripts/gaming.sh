#!/usr/bin/env bash

echo "Switching to GAMING MODE..."

hyprctl eval '
hl.config({
    animations = { enabled = false },
    decoration = {
        blur   = { enabled = false },
        shadow = { enabled = false },
    },
    general = {
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 1,
    },
})'

echo "GAMING MODE ENABLED"
