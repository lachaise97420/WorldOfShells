#!/bin/bash
. "$(dirname "$0")/common.sh"
start=$HOME/.local/bin/macshell-start
[ -d "$HOME/.config/quickshell/MacShell" ] && [ -x "$start" ] || exit 3
stop_shells
# The wrapper reads MacShell's environment file and restores its wallpaper choice.
nohup sh "$start" </dev/null >"$logs/world-of-shells-MacShell.log" 2>&1 &
disown
sleep 2
if ! qs list -c MacShell 2>&1 | grep -q '^Instance'; then
    pkill -f '/macshell-start' 2>/dev/null || true
    restore_shell
    exit 4
fi
echo "activated"
