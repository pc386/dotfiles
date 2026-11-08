#!/usr/bin/env bash
set -euo pipefail

# Keep the menu's theme alongside the other dotfiles, including when symlinked.
theme="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../config/rofi.ptr/power-menu.rasi"

menu() {
    local lines="$1" prompt="$2"
    shift 2
    rofi -no-config -dmenu -no-custom -no-sort -no-show-icons -no-auto-select \
        -theme "$theme" -lines "$lines" -p "$prompt" -format s -i "$@"
}

confirm() {
    local answer
    # Escape closes the entire menu; Cancel returns to the options.
    answer=$(printf '%s\n' "Yes, $1" 'Cancel' | \
        menu 2 "$1?" -theme-str 'inputbar { enabled: true; }') || exit 0
    [[ "$answer" == "Yes, $1" ]]
}

actions=('Power off' 'Restart' 'Suspend')
hibernate=$(busctl --system --timeout=2s call org.freedesktop.login1 \
    /org/freedesktop/login1 org.freedesktop.login1.Manager CanHibernate \
    2>/dev/null) || hibernate=''
if [[ "$hibernate" == 's "yes"' || "$hibernate" == 's "challenge"' ]]; then
    actions+=('Hibernate')
fi
actions+=('Log out' 'Lock')

while true; do
    choice=$(printf '%s\n' "${actions[@]}" | menu "${#actions[@]}" '') || exit 0
    confirm "$choice" || continue

    case "$choice" in
        'Lock')
            exec loginctl lock-session
            ;;
        'Suspend')
            # Hypridle's before_sleep_cmd locks the session before sleeping.
            exec systemctl suspend
            ;;
        'Hibernate')
            exec systemctl hibernate
            ;;
        'Log out')
            exec hyprctl dispatch 'hl.dsp.exit()'
            ;;
        'Restart')
            exec systemctl reboot
            ;;
        'Power off')
            exec systemctl poweroff
            ;;
    esac
done
