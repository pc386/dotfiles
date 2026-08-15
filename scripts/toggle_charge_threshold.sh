#!/usr/bin/env bash
set -euo pipefail

readonly CONSERVATION_START=75
readonly CONSERVATION_END=80
readonly FULL_CHARGE_START=0
readonly FULL_CHARGE_END=100

die() {
    printf 'toggle_charge_threshold: %s\n' "$*" >&2
    exit 1
}

find_battery() {
    local battery

    for battery in /sys/class/power_supply/BAT*; do
        [[ -d "$battery" ]] || continue

        if [[ -e "$battery/charge_control_start_threshold" &&
              -e "$battery/charge_control_end_threshold" ]]; then
            battery_dir="$battery"
            start_file="$battery/charge_control_start_threshold"
            end_file="$battery/charge_control_end_threshold"
            return
        fi

        if [[ -e "$battery/charge_start_threshold" &&
              -e "$battery/charge_stop_threshold" ]]; then
            battery_dir="$battery"
            start_file="$battery/charge_start_threshold"
            end_file="$battery/charge_stop_threshold"
            return
        fi
    done

    die 'no battery with charge-threshold controls was found'
}

read_thresholds() {
    start_threshold="$(<"$start_file")"
    end_threshold="$(<"$end_file")"
}

mode_from_thresholds() {
    if [[ "$start_threshold" == "$CONSERVATION_START" &&
          "$end_threshold" == "$CONSERVATION_END" ]]; then
        printf 'conservation\n'
    elif [[ "$start_threshold" == "$FULL_CHARGE_START" &&
            "$end_threshold" == "$FULL_CHARGE_END" ]]; then
        printf 'full\n'
    else
        printf 'custom\n'
    fi
}

describe_mode() {
    case "$1" in
        conservation)
            printf 'Conservation mode: charging starts at %s%% and stops at %s%%.\n' \
                "$CONSERVATION_START" "$CONSERVATION_END"
            ;;
        full)
            printf 'Full-charge mode: charging is allowed up to %s%%.\n' \
                "$FULL_CHARGE_END"
            ;;
        custom)
            printf 'Custom thresholds: charging starts at %s%% and stops at %s%%.\n' \
                "$start_threshold" "$end_threshold"
            ;;
    esac
}

waybar_status() {
    local mode state text tooltip

    mode="$(mode_from_thresholds)"
    tooltip="$(describe_mode "$mode") Click to toggle the charging threshold."

    if [[ "$mode" == 'conservation' ]]; then
        state='on'
        text=''
    else
        state='off'
        text=''
    fi

    printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
        "$text" "$tooltip" "$state"
}

set_mode() {
    local mode="$1"
    local desired_start desired_end

    case "$mode" in
        conservation)
            desired_start="$CONSERVATION_START"
            desired_end="$CONSERVATION_END"
            ;;
        full)
            desired_start="$FULL_CHARGE_START"
            desired_end="$FULL_CHARGE_END"
            ;;
        *)
            die "invalid internal mode: $mode"
            ;;
    esac

    # Lower the start point first so changing the end point is valid even when
    # replacing arbitrary custom thresholds.
    printf '%s\n' "$FULL_CHARGE_START" > "$start_file"
    printf '%s\n' "$desired_end" > "$end_file"
    printf '%s\n' "$desired_start" > "$start_file"

    read_thresholds
    [[ "$start_threshold" == "$desired_start" &&
       "$end_threshold" == "$desired_end" ]] ||
        die "the driver did not retain the requested thresholds (now ${start_threshold}-${end_threshold})"
}

notify_result() {
    local message="$1"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send 'Battery charge threshold' "$message"
    fi
}

usage() {
    cat <<'EOF'
Usage: toggle_charge_threshold.sh [toggle|on|off|status|waybar]

  toggle  Switch between 75-80% conservation mode and charging to 100%
  on      Enable 75-80% conservation mode
  off     Allow charging to 100%
  status  Show the current thresholds
  waybar  Print the current threshold as Waybar JSON
EOF
}

find_battery
read_thresholds

action="${1:-toggle}"
case "$action" in
    toggle)
        if [[ "$(mode_from_thresholds)" == 'conservation' ]]; then
            requested_mode='full'
        else
            requested_mode='conservation'
        fi
        ;;
    on)
        requested_mode='conservation'
        ;;
    off)
        requested_mode='full'
        ;;
    status)
        describe_mode "$(mode_from_thresholds)"
        exit 0
        ;;
    waybar)
        waybar_status
        exit 0
        ;;
    --set)
        [[ $EUID -eq 0 ]] || die '--set is an internal privileged operation'
        [[ $# -eq 2 ]] || die '--set requires exactly one mode'
        set_mode "$2"
        exit 0
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac

if [[ $EUID -eq 0 ]]; then
    set_mode "$requested_mode"
else
    script_path="$(readlink -f "$0")"
    pkexec "$script_path" --set "$requested_mode"
    read_thresholds
fi

message="$(describe_mode "$(mode_from_thresholds)")"
printf '%s\n' "$message"
notify_result "$message"
