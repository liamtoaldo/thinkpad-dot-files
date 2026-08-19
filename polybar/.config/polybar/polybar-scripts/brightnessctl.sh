#!/bin/bash
BRIGHTNESS_VALUE=`brightnessctl | grep -o "(.*" | tr -d "()"`
BRIGHTNESS_NR=${BRIGHTNESS_VALUE//%}

BRIGHTNESS_ICON='%{F#F0C674}%{F-}'

echo "$BRIGHTNESS_ICON $BRIGHTNESS_VALUE"

