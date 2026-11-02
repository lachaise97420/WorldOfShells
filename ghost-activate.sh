#!/bin/bash
. "$(dirname "$0")/common.sh"
[ -x "$ghost" ] || exit 3
stop_shells
restore_shell
echo "activated"
