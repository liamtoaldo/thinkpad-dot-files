#!/bin/bash
# Only run xset if screensaver timeout is not 0
CURRENT_TIMEOUT=$(xset q | grep "timeout:" | awk '{print $2}')
if [ "$CURRENT_TIMEOUT" != "0" ]; then
    xset s 0 0
fi
