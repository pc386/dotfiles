#!/usr/bin/env bash
set -euo pipefail

stamp="/tmp/waybar-toggle.${UID}.stamp"
now="$(date +%s%3N)"
last="0"

if [[ -f "$stamp" ]]; then
    last="$(cat "$stamp" 2>/dev/null || printf '0')"
fi

if (( now - last < 50 )); then
    exit 0
fi

printf '%s\n' "$now" > "$stamp"
pkill -x -SIGUSR1 waybar
