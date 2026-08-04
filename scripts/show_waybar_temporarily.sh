#!/usr/bin/env bash
set -u

runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
token_file="$runtime_dir/waybar-temporary-show.${UID}.token"
state_file="$runtime_dir/waybar-visibility.${UID}.state"
lock_file="$runtime_dir/waybar-visibility.${UID}.lock"
token="$(date +%s%N)-$$"
exec 9>"$lock_file"

flock 9
state="$(cat "$state_file" 2>/dev/null || printf 'visible')"

if [[ "$state" == "visible" ]]; then
  rm -f "$token_file"
  flock -u 9
  exit 0
fi

printf '%s\n' "$token" > "$token_file"
printf 'temporary\n' > "$state_file"
pkill -x -SIGUSR2 waybar || true
flock -u 9

sleep 3

flock 9
if [[ "$(cat "$token_file" 2>/dev/null)" != "$token" ]] ||
   [[ "$(cat "$state_file" 2>/dev/null)" != "temporary" ]]; then
  flock -u 9
  exit 0
fi

pkill -x -SIGUSR1 waybar || true
printf 'hidden\n' > "$state_file"
rm -f "$token_file"
flock -u 9
