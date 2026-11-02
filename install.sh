#!/bin/bash
# World of Shells - Installer
# Usage: bash install.sh

set -e

APP_NAME="WorldOfShells"
APP_DIR="$HOME/.config/quickshell/$APP_NAME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== World of Shells - Installation ==="
echo ""

# Check dependencies
echo "Checking dependencies..."
for dep in qs quickshell; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "ERROR: $dep is not installed."
        echo "Install Quickshell: https://quickshell.org"
        exit 1
    fi
done
echo "Quickshell: OK"

# Check Hyprland
if ! command -v hyprctl >/dev/null 2>&1; then
    echo "WARNING: hyprctl not found. Hyprland is required."
fi

# Install app files
echo "Installing files..."
mkdir -p "$APP_DIR"
cp -r "$SCRIPT_DIR"/* "$APP_DIR/"
chmod +x "$APP_DIR"/*.sh

# Create .desktop entry
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/world-of-shells.desktop" <<EOF
[Desktop Entry]
Name=World of Shells
Comment=Showcase and try different Hyprland shells
Exec=qs -c WorldOfShells
Icon=$APP_DIR/assets/logo.png
Type=Application
Categories=Utility;
Terminal=false
StartupNotify=true
EOF

update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo ""
echo "=== Installation complete ==="
echo "Start the app with: qs -c WorldOfShells"
echo "Or from your app launcher: World of Shells"
echo ""
echo "Note: for shells that need installing (end-4, DMS),"
echo "follow the instructions shown in the app."