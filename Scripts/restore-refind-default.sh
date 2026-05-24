#!/usr/bin/env bash

MANUAL_BOOT="/boot/EFI/refind/manual_boot.conf"

cat > "$MANUAL_BOOT" <<'EOF'
timeout 5
default_selection "NixOS"
EOF

echo "rEFInd: przywrócono domyślne ustawienia (NixOS, timeout 5)"
