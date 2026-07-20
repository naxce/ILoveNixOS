#!/usr/bin/env bash
set -euo pipefail

rm -rf "$HOME/NixOS/Config/Kvantum"        "$HOME/NixOS/Config/qt6ct"
rm -f  "$HOME/NixOS/Config/dolphinrc"        "$HOME/NixOS/Config/kdeglobals"

rm -rf "$HOME/.config/Kvantum"        "$HOME/.config/qt6ct"
rm -f  "$HOME/.config/dolphinrc"        "$HOME/.config/kdeglobals"

echo "Dolphin Noir leftovers removed. Yazi is the new operator."
