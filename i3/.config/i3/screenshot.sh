# The reason this screenshot exists is because if you just do flameshot gui -c -s the focus of the original window is lost and I have to refocus manually
set -euo pipefail
FOCUSED_WINDOW=$(xdotool getwindowfocus)

flameshot gui -c -s || true

test "$FOCUSED_WINDOW" = "$(xdotool getwindowfocus)" || {
	xdotool windowfocus $FOCUSED_WINDOW
}
