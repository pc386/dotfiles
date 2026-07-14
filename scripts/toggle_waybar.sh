#!/usr/bin/env bash
set -euo pipefail

stamp="/tmp/waybar-toggle.${UID}.stamp"
auto_hide="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/waybar_auto_hide"
now="$(date +%s%3N)"
last="0"

if [[ -f "$stamp" ]]; then
    last="$(cat "$stamp" 2>/dev/null || printf '0')"
fi

elapsed=$((now - last))
if (( elapsed >= 0 && elapsed < 50 )); then
    exit 0
fi

printf '%s\n' "$now" > "$stamp"

if pgrep -f -x -- "$auto_hide" >/dev/null; then
    # Permanent mode: stop automatic signals and force the bar to be visible.
    pkill -f -x -- "$auto_hide"
    pkill -x -SIGUSR2 waybar
else
    # Auto-hide mode: restart the helper and immediately sync Waybar's state.
    hyprctl dispatch exec "$auto_hide" >/dev/null

    if hyprctl -j activeworkspace | jq -e '.windows > 0' >/dev/null; then
        pkill -x -SIGUSR1 waybar
    else
        pkill -x -SIGUSR2 waybar
    fi
fi
