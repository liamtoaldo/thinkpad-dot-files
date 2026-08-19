#!/bin/sh
# One icon next to the battery telling you which CPU power state is active.
#   lock  (red)    = TLP not running / disabled -> nothing rewrites the sysfs knobs
#   bolt  (yellow) = performance (governor=performance or EPP=performance)
#   scale (blue)   = balanced (EPP=balance_performance)
#   leaf  (green)  = power saving (EPP=balance_power / power)

CPUFREQ=/sys/devices/system/cpu/cpu0/cpufreq

gov=$(cat "$CPUFREQ/scaling_governor" 2>/dev/null)
epp=$(cat "$CPUFREQ/energy_performance_preference" 2>/dev/null)

# The runit service holds a placeholder process whose cmdline is exactly "tlp".
# No root needed, unlike `sv status tlp`.
tlp_off=0
pgrep -x -f tlp >/dev/null 2>&1 || tlp_off=1
grep -qs '^[[:space:]]*TLP_ENABLE=0' /etc/tlp.conf /etc/tlp.d/*.conf && tlp_off=1

if [ "$tlp_off" = 1 ]; then
    printf '%%{F#bf616a}\357\200\243%%{F-}\n'   # lock
elif [ "$gov" = performance ] || [ "$epp" = performance ]; then
    printf '%%{F#F0C674}\357\203\247%%{F-}\n'   # bolt
elif [ "$epp" = balance_performance ]; then
    printf '%%{F#88c0d0}\357\211\216%%{F-}\n'   # scale
else
    printf '%%{F#a3be8c}\357\201\254%%{F-}\n'   # leaf
fi
