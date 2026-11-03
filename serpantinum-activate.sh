#!/bin/bash
. "$(dirname "$0")/common.sh"
command -v serpantinumd >/dev/null 2>&1 || exit 3
stop_shells
nohup serpantinumd start </dev/null >"$logs/world-of-shells-serpantinum.log" 2>&1 &
disown
sleep 1.5
if ! pgrep -f 'quickshell -p .*serpantinum.*/(Shell|Bar)\.qml' >/dev/null; then
    restore_shell
    exit 4
fi
echo "activated"
