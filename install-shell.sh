#!/bin/bash
# Usage: install-shell.sh <repo url> <branch> <command>
# Clones a shell's repo and runs its own installer in a terminal.
if [ "${1:-}" != --run ]; then
    for term in kitty alacritty foot ghostty konsole xterm; do
        if command -v "$term" >/dev/null 2>&1; then
            exec "$term" -e bash "$0" --run "$@"
        fi
    done
    if command -v gnome-terminal >/dev/null 2>&1; then
        exec gnome-terminal -- bash "$0" --run "$@"
    fi
    exit 5
fi
shift
repo=$1 branch=$2 command=$3
src="${XDG_DATA_HOME:-$HOME/.local/share}/WorldOfShells/src/$(basename "$repo")"
mkdir -p "$(dirname "$src")"
if [ -d "$src/.git" ]; then
    git -C "$src" pull --ff-only
else
    git clone --depth 1 --branch "$branch" "$repo" "$src"
fi || { echo "Could not download $repo"; read -r -p "Press Enter to close"; exit 1; }
cd "$src" || exit 1
echo "\$ $command"
eval "$command"
echo
echo "Installer exited with status $?"
read -r -p "Press Enter to close"
