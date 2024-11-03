#!/bin/bash


HEADPHONE="bluez_sink.94_DB_56_C3_FE_29.a2dp_sink"
FIREFOX="firefox"

pactl subscribe | while read -r event; do 
if echo "$event" | grep -q "new" && echo "$event" | grep -q "sink-input"; then
# Check if the headphone is connected
	if pactl list sinks short | grep -q "$HEADPHONE"
	then
	    echo "Headphone is connected"
	    # Check if firefox is running
	    if pgrep -x "$FIREFOX" >/dev/null
	    then
		echo "Firefox is running"
	       stream_id=$(pactl list sink-inputs | grep -B 23 "application.process.binary = \"$FIREFOX\"" | grep "Sink Input" | awk '{print $3}' | cut -c2-)
		if [[ -n "$stream_id" ]]
		then
			echo "$stream_id"
			pactl set-sink-input-volume "$stream_id" 40% 100%	
		 echo "Volume has been adjusted"
	 else
		 echo "No Firefox audio stream found"
		fi
	    else
		echo "Firefox is not running"
	    fi
	else
	    echo "Headphone is not connected"
	fi
fi
done
