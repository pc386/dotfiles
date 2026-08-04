#!/usr/bin/env bash
set -euo pipefail

stamp="/tmp/waybar-toggle.${UID}.stamp"
runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
token_file="$runtime_dir/waybar-temporary-show.${UID}.token"
state_file="$runtime_dir/waybar-visibility.${UID}.state"
lock_file="$runtime_dir/waybar-visibility.${UID}.lock"
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
exec 9>"$lock_file"
flock 9
rm -f "$token_file"
state="$(cat "$state_file" 2>/dev/null || printf 'visible')"
pkill -x -SIGUSR1 waybar

if [[ "$state" == "hidden" ]]; then
    printf 'visible\n' > "$state_file"
else
    printf 'hidden\n' > "$state_file"
fi
