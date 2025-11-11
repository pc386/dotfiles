#!/bin/sh

power_now_microvolts=$(cat /sys/class/power_supply/BAT0/voltage_now)
power_now_volt=$(echo "scale=2; $power_now_microvolts / 1000000" | bc)

power_now_microwatts=$(cat /sys/class/power_supply/BAT0/power_now)
power_now_watts=$(echo "scale=1; $power_now_microwatts / 1000000" | bc)
echo "$power_now_watts W | $power_now_volt V" 
