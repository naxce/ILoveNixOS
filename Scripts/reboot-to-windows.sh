#!/usr/bin/env bash

set -euo pipefail

MANUAL_BOOT="/boot/EFI/refind/manual_boot.conf"
RED='\033[0;31m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

die() { echo -e "${RED}BŁĄD: $*${RESET}" >&2; exit 1; }

[[ $EUID -ne 0 ]] && exec sudo "$0" "$@"

[[ -f "$MANUAL_BOOT" ]] || die "Nie znaleziono $MANUAL_BOOT"

echo -e "${BOLD}${CYAN}» Windows 11${RESET}"

cat > "$MANUAL_BOOT" <<'EOF'
timeout -1
default_selection "Windows 11"
EOF

reboot
