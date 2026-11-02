#!/bin/bash
. "$(dirname "$0")/common.sh"
command -v dms >/dev/null 2>&1 || exit 3
stop_shells
nohup dms run </dev/null >"$logs/world-of-shells-dms.log" 2>&1 &
disown
echo "activated"
