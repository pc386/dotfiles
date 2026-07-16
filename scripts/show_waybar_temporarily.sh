#!/usr/bin/env bash
set -u

auto_hide="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/waybar_auto_hide"
token_file="${XDG_RUNTIME_DIR:-/tmp}/waybar-temporary-show.${UID}.token"
token="$(date +%s%N)-$$"
auto_hide_pids=()

mapfile -t auto_hide_pids < <(pgrep -f -x -- "$auto_hide" || true)

# F12's pinned mode has no auto-hide helper, so leave an already-visible bar
# pinned instead of scheduling an unexpected hide.
if (( ${#auto_hide_pids[@]} == 0 )); then
  pkill -x -SIGUSR2 waybar || true
  exit 0
fi

printf '%s\n' "$token" > "$token_file"

for pid in "${auto_hide_pids[@]}"; do
  kill -STOP "$pid" 2>/dev/null || true
done

pkill -x -SIGUSR2 waybar || true

cleanup() {
  if [[ "$(cat "$token_file" 2>/dev/null)" != "$token" ]]; then
    return
  fi

  for pid in "${auto_hide_pids[@]}"; do
    kill -CONT "$pid" 2>/dev/null || true
  done

  rm -f "$token_file"
}
trap cleanup EXIT HUP INT TERM

sleep 2

# A later swipe owns the timer now and will resume the helper itself.
if [[ "$(cat "$token_file" 2>/dev/null)" != "$token" ]]; then
  exit 0
fi

# If F12 killed the helper to pin Waybar, do not undo that choice.
helper_is_running=false
for pid in "${auto_hide_pids[@]}"; do
  if kill -0 "$pid" 2>/dev/null; then
    helper_is_running=true
    break
  fi
done

if [[ "$helper_is_running" = true ]]; then
  pkill -x -SIGUSR1 waybar || true
fi
