# Contributing a Shell to World of Shells

Thank you for your interest in adding a shell to World of Shells! This guide will walk you through the process.

## Prerequisites

- The shell must be a **Quickshell** configuration (runnable with `qs -c <name>`)
- The shell should be **standalone** (not a full dotfiles replacement, or clearly documented as such)
- You should have tested the shell on your own system

## Step 1: Add the shell to the app

Open `shell.qml` and find the `shells` array (around line 60). Add a new entry following this template:

```qml
{
    name: "Shell Name",
    author: "Author Name",
    license: "MIT",
    stars: "100",
    forks: "10",
    github: "https://github.com/author/shell-repo",
    video: "",  // YouTube/streamable URL if available, empty string otherwise
    tagline: "Short description of the shell.",
    bio: "Longer description of the shell and its features.",
    features: ["Feature 1", "Feature 2", "Feature 3"],
    prereqs: "Hyprland, Quickshell, Qt 6.",
    logo: "https://raw.githubusercontent.com/author/shell-repo/main/path/to/logo.png",
    featured: "https://raw.githubusercontent.com/author/shell-repo/main/path/to/screenshot.png",
    thumbs: ["https://raw.githubusercontent.com/author/shell-repo/main/path/to/thumb1.png", "https://raw.githubusercontent.com/author/shell-repo/main/path/to/thumb2.png", "https://raw.githubusercontent.com/author/shell-repo/main/path/to/thumb3.png"],
    activateScript: "/home/warren/.config/quickshell/WorldOfShells/yourshell-activate.sh",
    revertScript: "/home/warren/.config/quickshell/WorldOfShells/yourshell-revert.sh",
    activatable: true
},
```

### Field descriptions

| Field | Description | Example |
|-------|-------------|---------|
| `name` | Display name of the shell | `"MacShell"` |
| `author` | Author name(s) | `"0-ss (Rickky) & vSuol"` |
| `license` | License (SPDX identifier) | `"MIT"`, `"GPL-3.0"` |
| `stars` | GitHub stars count | `"328"` |
| `forks` | GitHub forks count | `"27"` |
| `github` | GitHub repository URL | `"https://github.com/0-ss/MacShell"` |
| `video` | Demo video URL (YouTube, Streamable, etc.) or empty string | `"https://www.youtube.com/watch?v=..."` |
| `tagline` | Short one-line description | `"Barre de menus + Dock façon macOS Tahoe."` |
| `bio` | Longer description | `"Une barre de menus..."` |
| `features` | Array of feature strings | `["Liquid Glass", "Spotlight"]` |
| `prereqs` | Prerequisites | `"Hyprland 0.55+, Quickshell, Qt 6."` |
| `logo` | URL to logo image | Stable raw GitHub URL |
| `featured` | URL to featured screenshot | Stable raw GitHub URL |
| `thumbs` | Array of 3 thumbnail image URLs | Stable raw GitHub URLs |
| `activateScript` | Path to activate script | `"/path/to/yourshell-activate.sh"` |
| `revertScript` | Path to revert script | `"/path/to/yourshell-revert.sh"` |
| `activatable` | Whether the shell can be activated (true/false) | `true` |

### Image URL guidelines
- Use **stable URLs** (raw.githubusercontent.com, github.com/user-attachments/assets/)
- Avoid signed URLs with JWT tokens (they expire)
- Prefer PNG/JPG over SVG (QML Image may not render SVG without QtSvg)
- Images should be screenshots of the shell in action

## Step 2: Create activate/revert scripts

Create two scripts in `~/.config/quickshell/WorldOfShells/` (or the app directory):

### `yourshell-activate.sh`
```bash
#!/bin/bash
# Kill all running shells
pkill -f 'qs -c MacShell' 2>/dev/null || true
pkill -f 'qs -c nucleus-shell' 2>/dev/null || true
# ... (add all other shells)
dms kill 2>/dev/null || true
pkill -f 'dms run' 2>/dev/null || true
systemctl --user stop ryoku-shell.service 2>/dev/null || true
ps -eo pid,args | awk '/qs -c shell/ && !/awk/ {print $1}' | xargs -r kill 2>/dev/null || true
sleep 0.5
# Start the new shell
nohup qs -c yourshell </dev/null >/tmp/opencode/yourshell.log 2>&1 &
disown
echo "activated"
```

### `yourshell-revert.sh`
```bash
#!/bin/bash
# Kill all running shells
pkill -f 'qs -c MacShell' 2>/dev/null || true
pkill -f 'qs -c nucleus-shell' 2>/dev/null || true
# ... (add all other shells)
dms kill 2>/dev/null || true
pkill -f 'dms run' 2>/dev/null || true
ps -eo pid,args | awk '/qs -c shell/ && !/awk/ {print $1}' | xargs -r kill 2>/dev/null || true
sleep 0.5
systemctl --user start ryoku-shell.service 2>/dev/null || true
echo "reverted"
```

Make them executable:
```bash
chmod +x yourshell-activate.sh yourshell-revert.sh
```

## Step 3: Install the shell

The shell must be installed on the user's system before it can be activated. For shells that use `qs -c`:
1. Clone the shell repo to `~/.config/quickshell/<shell-name>/`
2. Ensure `shell.qml` exists at `~/.config/quickshell/<shell-name>/shell.qml`
3. Test with `qs -c <shell-name>`

For shells with their own binary (like DMS with `dms run`), ensure the binary is in PATH.

## Step 4: Test

1. Launch World of Shells: `qs -c WorldOfShells`
2. Select your shell from the list
3. Click "Activer" to test activation
4. Click "Revenir" to test revert
5. Verify no elements from the previous shell persist

## Step 5: Submit

1. Fork the World of Shells repository
2. Make your changes
3. Test thoroughly
4. Submit a Pull Request with:
   - Description of the shell
   - Screenshots
   - Confirmation that activate/revert works

## Notes
- The app uses Quickshell FloatingWindow
- No animations (instant) - keep it fast
- Images use PreserveAspectFit (no crop)
- Lightbox: click image → fullscreen, mouse wheel zoom, drag pan, double-click reset, Escape close
- end4 requires confirmation before install (full dotfiles replacement)
- Matugen-friendly: reads colors from ~/.cache/ryoku/colors.json if available
- All shells: clic "Activer" = essai immédiat, clic "Revenir" = restauration propre