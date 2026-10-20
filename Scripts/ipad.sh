#!/usr/bin/env bash

set -euo pipefail

OUTPUT="ipad"
CONF="$HOME/.config/wayvnc"

if [[ ! -f "$CONF/config" ]]; then
    mkdir -p "$CONF"
    umask 077
    openssl genrsa -traditional -out "$CONF/rsa_key.pem" 2048 2>/dev/null
    cat > "$CONF/config" <<EOF
use_relative_paths=true
address=0.0.0.0
enable_auth=true
username=ipad
password=$(openssl rand -hex 8)
rsa_private_key_file=rsa_key.pem
xkb_layout=pl
EOF
fi

hyprctl output remove "$OUTPUT" >/dev/null 2>&1 || true
hyprctl output create headless "$OUTPUT" >/dev/null
trap 'hyprctl output remove "$OUTPUT" >/dev/null 2>&1' EXIT

ips=$(ip -4 -o addr show scope global | awk '{sub("/.*", "", $4); printf "%s:5900 ", $4}')
echo "iPad: VNC → ${ips}user: ipad  password: $(sed -n 's/^password=//p' "$CONF/config")"

wayvnc -o "$OUTPUT" -f 60
