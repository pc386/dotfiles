#!/usr/bin/env bash

set -euo pipefail

scale_args=()

if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    active_scale="$(
        hyprctl -j monitors 2>/dev/null \
        | jq -r '.[] | select(.focused == true) | .scale' 2>/dev/null \
        | head -n 1
    )"

    if [[ -n "${active_scale:-}" && "$active_scale" == *.* && "$active_scale" != "1.0" && "$active_scale" != "2.0" ]]; then
        # Request an integer capture scale on fractional-scaled outputs.
        scale_args=(-s 2)
    fi
fi

tmp_file="$(mktemp --suffix=.png)"
trap 'rm -f "$tmp_file"' EXIT

grim "${scale_args[@]}" -t png -g "$(slurp)" "$tmp_file"
swappy -f "$tmp_file"
