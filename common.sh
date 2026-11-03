#!/bin/bash
# Shared by the activate and revert scripts.
logs="${XDG_RUNTIME_DIR:-/tmp}"
ghost="$HOME/.local/bin/ghost"

stop_shells() {
    # Its wrapper would otherwise restart it.
    pkill -f '/macshell-start' 2>/dev/null || true
    pkill -f 'qs -c MacShell' 2>/dev/null || true
    pkill -f 'qs -c nucleus-shell' 2>/dev/null || true
    pkill -f 'qs -c nandoroid' 2>/dev/null || true
    pkill -f 'qs -c sekaipop' 2>/dev/null || true
    pkill -f 'qs -c twinshell' 2>/dev/null || true
    pkill -f 'qs -c qsdots' 2>/dev/null || true
    pkill -f 'qs -c asaki' 2>/dev/null || true
    pkill -f 'qs -c materialui' 2>/dev/null || true
    pkill -f 'qs -c vantage' 2>/dev/null || true
    pkill -f 'qs -c ukishima' 2>/dev/null || true
    pkill -f 'qs -c lucid' 2>/dev/null || true
    pkill -f 'qs -c nothingshell' 2>/dev/null || true
    pkill -f 'qs -c nibras' 2>/dev/null || true
    pkill -f 'qs -c impasto' 2>/dev/null || true
pkill -f 'qs -c cuteshell' 2>/dev/null || true
pkill -f 'qs -c minflair' 2>/dev/null || true
pkill -f 'qs -c trip' 2>/dev/null || true
    dms kill 2>/dev/null || true
    pkill -f 'dms run' 2>/dev/null || true
    command -v serpantinum >/dev/null 2>&1 && serpantinum kill >/dev/null 2>&1
    pkill -f 'discord_voice_bridge.py' 2>/dev/null || true
    ps -eo pid,args | awk '/qs -c shell/ && !/awk/ {print $1}' | xargs -r kill 2>/dev/null || true
    [ -x "$ghost" ] && "$ghost" stop >/dev/null 2>&1
    sleep 0.5
}

restore_shell() {
    [ -x "$ghost" ] && "$ghost" start
}

# Exit 3: not installed, nothing touched. Exit 4: it did not stay up, ghOSt is back.
start_config() {
    [ -d "$HOME/.config/quickshell/$1" ] || exit 3
    stop_shells
    nohup qs -c "$1" </dev/null >"$logs/world-of-shells-$1.log" 2>&1 &
    disown
    sleep 1.5
    if ! qs list -c "$1" 2>&1 | grep -q '^Instance'; then
        restore_shell
        exit 4
    fi
}
