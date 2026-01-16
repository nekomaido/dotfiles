#!/bin/bash

# Check if wf-recorder is running
if pgrep -x "wf-recorder" > /dev/null; then
    # Stop recording
    pkill -SIGINT wf-recorder
    notify-send "Screen Recording" "Recording stopped"
else
    # Start recording
    mkdir -p ~/Videos/Recordings
    FILE=~/Videos/Recordings/recording-$(date +%Y-%m-%d-%H%M%S).mp4
    GEOMETRY=$(slurp)
    if [ -n "$GEOMETRY" ]; then
        wf-recorder -g "$GEOMETRY" --audio=alsa_output.pci-0000_0a_00.6.analog-stereo.monitor -f "$FILE" &
        notify-send "Screen Recording" "Recording started"
    fi
fi
