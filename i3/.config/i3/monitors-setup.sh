#!/bin/bash

# Audio card ID (find with `pactl list cards`)
CARD_NAME="alsa_card.pci-0000_00_1f.3"

# Monitor setup
if xrandr | grep "^HDMI-2 connected"; then
    xrandr --output HDMI-2 --auto --left-of eDP-1 --output eDP-1 --auto

    # Set HDMI profile
    pactl set-card-profile "$CARD_NAME" output:hdmi-stereo+input:analog-stereo

    # Set HDMI sink as default
    HDMI_SINK=$(pactl list short sinks | grep hdmi | awk '{print $2}' | head -n1)
    if [ -n "$HDMI_SINK" ]; then
        pactl set-default-sink "$HDMI_SINK"
        for INPUT in $(pactl list short sink-inputs | awk '{print $1}'); do
            pactl move-sink-input "$INPUT" "$HDMI_SINK"
        done
    fi
else
    xrandr --output HDMI-2 --off --output eDP-1 --auto

    # Set analog duplex profile
    pactl set-card-profile "$CARD_NAME" output:analog-stereo+input:analog-stereo

    # Set analog sink as default
    ANALOG_SINK=$(pactl list short sinks | grep analog | awk '{print $2}' | head -n1)
    if [ -n "$ANALOG_SINK" ]; then
        pactl set-default-sink "$ANALOG_SINK"
        for INPUT in $(pactl list short sink-inputs | awk '{print $1}'); do
            pactl move-sink-input "$INPUT" "$ANALOG_SINK"
        done
    fi
fi
