import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    component ActionButton: Rectangle {
        id: button
        property string text: ""
        property bool primary: false
        signal clicked
        implicitWidth: Math.max(96, buttonLabel.implicitWidth + tok.sp4 * 2)
        implicitHeight: 44
        radius: tok.r3
        color: primary ? (buttonMouse.containsMouse ? "#a6dcfa" : tok.primary) : (buttonMouse.containsMouse ? tok.surfaceHigh : "transparent")
        border.width: primary ? 0 : 1
        border.color: tok.outlineVariant
        opacity: enabled ? 1 : 0.45
        Behavior on color { ColorAnimation { duration: tok.animFast } }
        Text {
            id: buttonLabel
            anchors.centerIn: parent
            text: button.text
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: button.primary ? tok.fgOnPrimary : tok.fg
        }
        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            enabled: button.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    Component.onCompleted: {
        Quickshell.watchFiles = false
        // Load last selected shell
        var proc = Qt.createQmlObject('import Quickshell.Io; Process {}', win)
        proc.command = ["bash", "-c", "cat ~/.config/WorldOfShells/last_shell 2>/dev/null || echo 0"]
    }

    FileView {
        id: lastShellFile
        path: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/WorldOfShells/last_shell"
        blockLoading: true
        printErrors: false
        onLoaded: {
            try {
                var idx = parseInt(lastShellFile.text().trim())
                if (idx >= 0 && idx < shells.length) win.selectedShell = idx
            } catch (e) {}
        }
        Component.onCompleted: {
            try { reload() } catch (e) {}
        }
    }

    FileView {
        id: windowSizeFile
        path: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/WorldOfShells/window_size"
        blockLoading: true
        printErrors: false
        onLoaded: {
            try {
                var parts = windowSizeFile.text().trim().split("x")
                if (parts.length === 4) {
                    var w = parseInt(parts[0])
                    var h = parseInt(parts[1])
                    var px = parseInt(parts[2])
                    var py = parseInt(parts[3])
                    if (w >= 700 && h >= 500) {
                        win.width = w
                        win.height = h
                        if (px >= 0 && py >= 0) {
                            win.x = px
                            win.y = py
                        }
                    }
                } else if (parts.length === 2) {
                    var w = parseInt(parts[0])
                    var h = parseInt(parts[1])
                    if (w >= 700 && h >= 500) {
                        win.width = w
                        win.height = h
                    }
                }
            } catch (e) {}
        }
        Component.onCompleted: {
            try { reload() } catch (e) {}
        }
    }

    QtObject {
        id: tok
        property color bg: "#0f1417"
        property color surface: "#171c1f"
        property color surfaceHigh: "#262b2e"
        property color fg: "#dfe3e7"
        property color fgVariant: "#c0c7cd"
        property color fgMuted: "#8a9297"
        property color fgOnPrimary: "#003549"
        property color primary: "#8ecff2"
        property color tertiary: "#c9c1ea"
        property color outline: "#8a9297"
        property color outlineVariant: "#40484d"
        property int sp1: 4
        property int sp2: 8
        property int sp3: 12
        property int sp4: 16
        property int sp5: 24
        property int sp6: 32
        property int r2: 8
        property int r3: 12
        property int r4: 16

        property int animFast: 130
        property int animMed: 200
        property int animSlow: 280

        property string colorsPath: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/ryoku/colors.json"

        function applyTheme(dark) {
            if (dark) {
                bg = "#0f1417"; surface = "#171c1f"; surfaceHigh = "#262b2e"
                fg = "#dfe3e7"; fgVariant = "#c0c7cd"; fgMuted = "#8a9297"
                fgOnPrimary = "#003549"; primary = "#8ecff2"; tertiary = "#c9c1ea"
                outline = "#8a9297"; outlineVariant = "#40484d"
            } else {
                bg = "#f5f5f5"; surface = "#ffffff"; surfaceHigh = "#e8e8e8"
                fg = "#1a1a1a"; fgVariant = "#4a4a4a"; fgMuted = "#8a8a8a"
                fgOnPrimary = "#ffffff"; primary = "#0066cc"; tertiary = "#6633cc"
                outline = "#8a8a8a"; outlineVariant = "#cccccc"
            }
        }

        function applyColors(c) {
            if (!c || typeof c !== "object") return
            function usable(v) { return typeof v === "string" && v.length > 0 }
            if (usable(c.background)) bg = c.background
            if (usable(c.surface)) surface = c.surface
            if (usable(c.surfaceContainerHigh)) surfaceHigh = c.surfaceContainerHigh
            if (usable(c.onSurface)) fg = c.onSurface
            if (usable(c.onSurfaceVariant)) fgVariant = c.onSurfaceVariant
            if (usable(c.outline)) fgMuted = c.outline
            if (usable(c.onPrimary)) fgOnPrimary = c.onPrimary
            if (usable(c.primary)) primary = c.primary
            if (usable(c.tertiary)) tertiary = c.tertiary
            if (usable(c.outline)) outline = c.outline
            if (usable(c.outlineVariant)) outlineVariant = c.outlineVariant
        }
    }

    // Apply theme when darkTheme changes
    Connections {
        target: win
        function onDarkThemeChanged() {
            tok.applyTheme(win.darkTheme)
        }
    }

    FileView {
        id: colorsFile
        path: tok.colorsPath
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            try {
                const t = colorsFile.text()
                const c = t && t.length ? JSON.parse(t) : null
                if (c) tok.applyColors(c)
            } catch (e) {}
            tok.applyTheme(win.darkTheme)
        }
        Component.onCompleted: {
            try { reload() } catch (e) {}
        }
    }

    property var shells: [
        {
            name: "MacShell",
            author: "0-ss (Rickky) & vSuol",
            license: "MIT",
            stars: "328",
            forks: "27",
            github: "https://github.com/0-ss/MacShell",
            video: "",
            tagline: "macOS Tahoe style menu bar and Dock for Hyprland.",
            bio: "macOS Tahoe style menu bar and Dock. Liquid Glass, Spotlight, widgets, MacLock.",
            features: ["Liquid Glass", "Spotlight", "Widgets", "Screenshots", "MacLock", "Alt+Tab"],
            prereqs: "Hyprland 0.55+ (Lua config), Quickshell 0.3.0+, Qt 6.5+, qsb.",
            logo: "https://github.com/user-attachments/assets/bc67b3fa-33a6-4326-9752-f0d271d0ed22",
            featured: "https://github.com/user-attachments/assets/600f75bc-b4d1-442d-bec5-41ee7dfa5023",
            thumbs: ["https://github.com/user-attachments/assets/edf45f8f-b71a-4bc5-9880-46dafbebf47c", "https://github.com/user-attachments/assets/cb6c5708-5786-4328-89bd-24737d39e482", "https://github.com/user-attachments/assets/6ef28e50-612f-4e7b-9822-c0aa0168a6ae"],
            activateScript: Quickshell.shellPath("activate.sh"),
            revertScript: Quickshell.shellPath("revert.sh"),
            activatable: true
        },
        {
            name: "end-4 (illogical-impulse)",
            author: "end-4",
            license: "GPL-3.0",
            stars: "16.5k",
            forks: "1.4k",
            github: "https://github.com/end-4/dots-hyprland",
            video: "https://www.youtube.com/watch?v=RPwovTInagE",
            tagline: "Usability-first dotfiles for Hyprland. Material Design 3, built-in AI, rich widgets.",
            bio: "Usability-first dotfiles for Hyprland. Material Design 3, built-in AI, rich widgets, sidebar, launcher. Very popular (16.5k stars).",
            features: ["Material Design 3", "Built-in AI", "Rich widgets", "Sidebar", "Lock screen", "Dynamic themes"],
            prereqs: "Hyprland 0.55+, Quickshell, Qt 6, Arch Linux recommended.",
            logo: "https://github.com/user-attachments/assets/9d7af13f-89ef-470d-ba78-d2288b79cf60",
            featured: "https://github.com/user-attachments/assets/5d4e7d07-d0b4-4406-a4c9-ed7ba90e3fe4",
            thumbs: ["https://github.com/user-attachments/assets/6a32395f-9437-4192-8faf-2951a9e84cbe", "https://github.com/user-attachments/assets/c51bed8b-3670-4d4c-9074-873be224fb8e", "https://github.com/user-attachments/assets/98703a66-0743-439f-a721-cef7afa6ab95"],
            activateScript: Quickshell.shellPath("end4-activate.sh"),
            revertScript: Quickshell.shellPath("end4-revert.sh"),
            activatable: true
        },
        {
            name: "ghOSt",
            author: "dsksnkz",
            license: "None",
            stars: "5",
            forks: "0",
            github: "https://github.com/dsksnkz/ghOSt",
            video: "",
            tagline: "Monochrome desktop shell for Arch Linux and Hyprland.",
            bio: "Monochrome desktop shell with a slim top bar, Super+Tab desktop switcher, Magic Workspaces, calendar, sidebar, music player, launcher, Settings and lock screen.",
            features: ["Top bar", "Desktop switcher", "Calendar", "Music player", "Launcher", "Lock screen"],
            prereqs: "Arch Linux, Hyprland, Quickshell.",
            logo: "https://raw.githubusercontent.com/dsksnkz/ghOSt/main/site/assets/icons/white/ghost.svg",
            featured: "https://raw.githubusercontent.com/dsksnkz/ghOSt/main/site/assets/product/desktop.webp",
            thumbs: ["switcher", "calendar", "settings", "launcher", "media", "sidebar", "login"].map(name => "https://raw.githubusercontent.com/dsksnkz/ghOSt/main/site/assets/product/" + name + ".webp"),
            activateScript: Quickshell.shellPath("ghost-activate.sh"),
            revertScript: Quickshell.shellPath("ghost-revert.sh"),
            activatable: true
        },
        {
            name: "DankMaterialShell (DMS)",
            author: "AvengeMedia / duxlabs-dev",
            license: "MIT",
            stars: "8.7k",
            forks: "575",
            github: "https://github.com/duxlabs-dev/dux-shell",
            video: "",
            tagline: "Material Design 3 shell for Hyprland, Niri, Sway and more.",
            bio: "Complete shell for Wayland. Material Design 3, panels, widgets, dynamic themes, notifications, launcher, lock screen. Multi-compositor.",
            features: ["Material Design 3", "Panels & widgets", "Dynamic themes", "Notifications", "Launcher", "Multi-compositor"],
            prereqs: "Hyprland/Niri/Sway, Quickshell, Go.",
            logo: "https://github.com/user-attachments/assets/203a9678-c3b7-4720-bb97-853a511ac5c8",
            featured: "https://github.com/user-attachments/assets/732c30de-5f4a-4a2b-a995-c8ab656cecd5",
            thumbs: ["https://github.com/user-attachments/assets/a937cf35-a43b-4558-8c39-5694ff5fcac4", "https://github.com/user-attachments/assets/2da00ea1-8921-4473-a2a9-44a44535a822", "https://github.com/user-attachments/assets/732c30de-5f4a-4a2b-a995-c8ab656cecd5"],
            activateScript: Quickshell.shellPath("dms-activate.sh"),
            revertScript: Quickshell.shellPath("dms-revert.sh"),
            activatable: true
        },
        {
            name: "Nucleus Shell",
            author: "nucleus-hq",
            license: "GPL-3.0",
            stars: "721",
            forks: "0",
            github: "https://github.com/nucleus-hq/nucleus-shell",
            video: "",
            tagline: "Flexible, extensible shell in QML, C++ and JS.",
            bio: "Flexible, extensible desktop shell built with QML, C++ and JavaScript. Quickshell-based. Modular and customizable.",
            features: ["Extensible", "Modular", "Multi-compositor", "Customizable"],
            prereqs: "Hyprland/Niri, Quickshell, Qt 6.",
            logo: "https://raw.githubusercontent.com/nucleus-hq/nucleus-shell/main/previews/Forests.png",
            featured: "https://raw.githubusercontent.com/nucleus-hq/nucleus-shell/main/previews/Passion.png",
            thumbs: ["https://raw.githubusercontent.com/nucleus-hq/nucleus-shell/main/previews/Forests.png", "https://raw.githubusercontent.com/nucleus-hq/nucleus-shell/main/previews/Love.png", "https://raw.githubusercontent.com/nucleus-hq/nucleus-shell/main/previews/Metallic.png"],
            activateScript: Quickshell.shellPath("nucleus-activate.sh"),
            revertScript: Quickshell.shellPath("nucleus-revert.sh"),
            activatable: true
        },
        {
            name: "Nandoroid",
            author: "na-ive",
            license: "AGPL-3.0",
            stars: "179",
            forks: "0",
            github: "https://github.com/na-ive/nandoroid-shell",
            video: "",
            tagline: "Hyprland shell inspired by custom Android ROMs.",
            bio: "Opinionated Hyprland shell inspired by custom Android ROMs. Quickshell-based, with a dynamic island, widgets and notifications.",
            features: ["Dynamic Island", "Widgets", "Notifications", "Themes", "Android-inspired"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://raw.githubusercontent.com/na-ive/nandoroid-docs/refs/heads/main/public/showcase1.png",
            featured: "https://raw.githubusercontent.com/na-ive/nandoroid-docs/refs/heads/main/public/showcase1.png",
            thumbs: ["https://raw.githubusercontent.com/na-ive/nandoroid-docs/refs/heads/main/public/showcase2.png", "https://raw.githubusercontent.com/na-ive/nandoroid-docs/refs/heads/main/public/showcase3.png", "https://raw.githubusercontent.com/na-ive/nandoroid-docs/refs/heads/main/public/showcase4.png"],
            activateScript: Quickshell.shellPath("nandoroid-activate.sh"),
            revertScript: Quickshell.shellPath("nandoroid-revert.sh"),
            activatable: true
        },
        {
            name: "SekaiPop",
            author: "Blapples",
            license: "GPL-3.0",
            stars: "526",
            forks: "0",
            github: "https://github.com/Blapples/SekaiPop",
            video: "",
            tagline: "Shell inspired by Project Sekai. Vibe-coded passion project.",
            bio: "Shell inspired by Project Sekai, with a control center, equalizer, desktop editing, shader transitions and two lock screens. Vibe-coded passion project.",
            features: ["Control center", "Equalizer", "Edit desktop", "Shader transitions", "Lock screens", "Phone integration"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://raw.githubusercontent.com/Blapples/SekaiPop/main/assets/shot-desktop-widgets.png",
            featured: "https://raw.githubusercontent.com/Blapples/SekaiPop/main/assets/shot-desktop-widgets.png",
            thumbs: ["https://raw.githubusercontent.com/Blapples/SekaiPop/main/assets/shot-edit-desktop.png", "https://raw.githubusercontent.com/Blapples/SekaiPop/main/assets/shot-quick-panel-phone.png", "https://raw.githubusercontent.com/Blapples/SekaiPop/main/assets/shot-sekai-pad-eq.png"],
            activateScript: Quickshell.shellPath("sekaipop-activate.sh"),
            revertScript: Quickshell.shellPath("sekaipop-revert.sh"),
            activatable: true
        },
        {
            name: "Twinshell",
            author: "etherealboi",
            license: "GPL-3.0",
            stars: "5",
            forks: "0",
            github: "https://github.com/etherealboi/twinshell",
            video: "",
            tagline: "Keyboard-centric shell for Hyprland.",
            bio: "Keyboard-centric shell for Hyprland, with a bar, screenshot tool and screen recording. Minimal and functional.",
            features: ["Bar", "Workspaces", "Screenshot", "Screen recording", "Audio", "Network"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://opengraph.githubassets.com/1/etherealboi/twinshell",
            featured: "https://opengraph.githubassets.com/1/etherealboi/twinshell",
            thumbs: ["https://opengraph.githubassets.com/1/etherealboi/twinshell", "https://opengraph.githubassets.com/1/etherealboi/twinshell", "https://opengraph.githubassets.com/1/etherealboi/twinshell"],
            activateScript: Quickshell.shellPath("twinshell-activate.sh"),
            revertScript: Quickshell.shellPath("twinshell-revert.sh"),
            activatable: true
        },
        {
            name: "QSDots",
            author: "BelimFaux",
            license: "MIT",
            stars: "5",
            forks: "0",
            github: "https://github.com/BelimFaux/qsdots",
            video: "",
            tagline: "Quickshell dotfiles for Hyprland.",
            bio: "Quickshell dotfiles for Hyprland. Bar, notifications, OSD, lock screen, media player, services.",
            features: ["Bar", "Notifications", "OSD", "Lockscreen", "Mediaplayer", "Services"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://raw.githubusercontent.com/BelimFaux/qsdots/main/examples/desktop.png",
            featured: "https://raw.githubusercontent.com/BelimFaux/qsdots/main/examples/desktop.png",
            thumbs: ["https://raw.githubusercontent.com/BelimFaux/qsdots/main/examples/desktop.png", "https://raw.githubusercontent.com/BelimFaux/qsdots/main/examples/desktop.png", "https://raw.githubusercontent.com/BelimFaux/qsdots/main/examples/desktop.png"],
            activateScript: Quickshell.shellPath("qsdots-activate.sh"),
            revertScript: Quickshell.shellPath("qsdots-revert.sh"),
            activatable: true
        },
        {
            name: "Asaki Shell",
            author: "AsakiYuki",
            license: "Unknown",
            stars: "0",
            forks: "0",
            github: "https://github.com/AsakiYuki/quickshell",
            video: "",
            tagline: "Simple shell for Hyprland.",
            bio: "Simple shell for Hyprland, with a bar, modules and configuration. Minimal and functional.",
            features: ["Bar", "Modules", "Configuration", "Wallpaper"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://opengraph.githubassets.com/1/AsakiYuki/quickshell",
            featured: "https://opengraph.githubassets.com/1/AsakiYuki/quickshell",
            thumbs: ["https://opengraph.githubassets.com/1/AsakiYuki/quickshell", "https://opengraph.githubassets.com/1/AsakiYuki/quickshell", "https://opengraph.githubassets.com/1/AsakiYuki/quickshell"],
            activateScript: Quickshell.shellPath("asaki-activate.sh"),
            revertScript: Quickshell.shellPath("asaki-revert.sh"),
            activatable: true
        },
        {
            name: "MaterialUI",
            author: "ps2string",
            license: "MIT",
            stars: "0",
            forks: "0",
            github: "https://github.com/ps2string/quickshell-materialui",
            video: "",
            tagline: "Material Design 3 shell for Hyprland.",
            bio: "Material Design 3 shell for Hyprland, with a bar, launcher, quick settings and dock. Android 16 M3 UI.",
            features: ["Material Design 3", "Bar", "Launcher", "Quick settings", "Dock", "Android M3"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://opengraph.githubassets.com/1/ps2string/quickshell-materialui",
            featured: "https://opengraph.githubassets.com/1/ps2string/quickshell-materialui",
            thumbs: ["https://opengraph.githubassets.com/1/ps2string/quickshell-materialui", "https://opengraph.githubassets.com/1/ps2string/quickshell-materialui", "https://opengraph.githubassets.com/1/ps2string/quickshell-materialui"],
            activateScript: Quickshell.shellPath("materialui-activate.sh"),
            revertScript: Quickshell.shellPath("materialui-revert.sh"),
            activatable: true
        },
        {
            name: "Vantage",
            author: "simeulinuxkaliaiwr",
            license: "MIT",
            stars: "24",
            forks: "0",
            github: "https://github.com/simeulinuxkaliaiwr/vantage",
            video: "",
            tagline: "Simple, minimal shell for Hyprland.",
            bio: "Simple, minimal shell for Hyprland, with a bar, widgets, wallpaper picker, game mode and keep-awake. Installer included.",
            features: ["Bar", "Widgets", "Wallpaper picker", "Game mode", "Keep-awake", "Night light"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://opengraph.githubassets.com/1/simeulinuxkaliaiwr/vantage",
            featured: "https://opengraph.githubassets.com/1/simeulinuxkaliaiwr/vantage",
            thumbs: ["https://opengraph.githubassets.com/1/simeulinuxkaliaiwr/vantage", "https://opengraph.githubassets.com/1/simeulinuxkaliaiwr/vantage", "https://opengraph.githubassets.com/1/simeulinuxkaliaiwr/vantage"],
            activateScript: Quickshell.shellPath("vantage-activate.sh"),
            revertScript: Quickshell.shellPath("vantage-revert.sh"),
            activatable: true
        },
        {
            name: "Ukishima",
            author: "amanhex",
            license: "MIT",
            stars: "119",
            forks: "0",
            github: "https://github.com/amanhex/ukishima",
            video: "",
            tagline: "Pill bar shell for Hyprland. Compositor-aware.",
            bio: "Pill bar shell for Hyprland with compositor-aware workspaces, window state, keyboard layout and lock backends. Extras: night light, game mode, keep-awake, in-app updater.",
            features: ["Pill bar", "Compositor-aware", "Night light", "Game mode", "Keep-awake", "In-app updater"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://raw.githubusercontent.com/amanhex/Ukishima/master/assets/ukishima-readme-banner.png",
            featured: "https://raw.githubusercontent.com/amanhex/Ukishima/master/assets/ukishima-readme-banner.png",
            thumbs: ["https://raw.githubusercontent.com/amanhex/Ukishima/master/assets/ukishima-readme-banner.png", "https://raw.githubusercontent.com/amanhex/Ukishima/master/assets/ukishima-readme-banner.png", "https://raw.githubusercontent.com/amanhex/Ukishima/master/assets/ukishima-readme-banner.png"],
            activateScript: Quickshell.shellPath("ukishima-activate.sh"),
            revertScript: Quickshell.shellPath("ukishima-revert.sh"),
            activatable: true
        },
        {
            name: "Lucid",
            author: "sn3akyy1",
            license: "MIT",
            stars: "322",
            forks: "12",
            github: "https://github.com/sn3akyy1/lucid",
            video: "",
            tagline: "Dynamic shell for Hyprland.",
            bio: "Dynamic shell for Hyprland with a bar, dock, widgets, lock screen and themes. Inspired by Caelestia.",
            features: ["Bar", "Dock", "Widgets", "Lock screen", "Themes", "Dynamic colors"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://raw.githubusercontent.com/Sn3akyy1/lucid/main/assets/fallback.jpg",
            featured: "https://raw.githubusercontent.com/Sn3akyy1/lucid/main/assets/fallback.jpg",
            thumbs: ["https://raw.githubusercontent.com/Sn3akyy1/lucid/main/assets/fallback.jpg", "https://raw.githubusercontent.com/Sn3akyy1/lucid/main/assets/fallback.jpg", "https://raw.githubusercontent.com/Sn3akyy1/lucid/main/assets/fallback.jpg"],
            activateScript: Quickshell.shellPath("lucid-activate.sh"),
            revertScript: Quickshell.shellPath("lucid-revert.sh"),
            activatable: true
        },
        {
            name: "Nothingshell",
            author: "Tsunami43",
            license: "MIT",
            stars: "26",
            forks: "0",
            github: "https://github.com/Tsunami43/nothingshell",
            video: "",
            tagline: "Complete shell for Hyprland in one process.",
            bio: "Complete shell for Hyprland in a single Quickshell process: bar, dashboard, launcher, settings, lock and login screens.",
            features: ["Bar", "Dashboard", "Launcher", "Settings", "Lock screen", "Login screen"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://raw.githubusercontent.com/Tsunami43/nothingshell/master/.github/assets/screenshots.jpg",
            featured: "https://raw.githubusercontent.com/Tsunami43/nothingshell/master/.github/assets/screenshots.jpg",
            thumbs: ["https://raw.githubusercontent.com/Tsunami43/nothingshell/master/.github/assets/demo.gif", "https://raw.githubusercontent.com/Tsunami43/nothingshell/master/.github/assets/screenshots.jpg", "https://raw.githubusercontent.com/Tsunami43/nothingshell/master/.github/assets/screenshots.jpg"],
            activateScript: Quickshell.shellPath("nothingshell-activate.sh"),
            revertScript: Quickshell.shellPath("nothingshell-revert.sh"),
            activatable: true
        },
        {
            name: "NibrasShell",
            author: "AhmedSaadi0",
            license: "MIT",
            stars: "778",
            forks: "0",
            github: "https://github.com/AhmedSaadi0/NibrasShell",
            video: "",
            tagline: "Shell with built-in AI for Hyprland. Material Design 3.",
            bio: "Shell with built-in AI for Hyprland. Material Design 3, Claude AI, live wallpaper theming, widgets, animations. English and Russian.",
            features: ["Built-in AI", "Material Design 3", "Live theming", "Widgets", "Animations", "Multilingual"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://raw.githubusercontent.com/AhmedSaadi0/my-hyprland-config/main/screenshots/dark_1.png",
            featured: "https://raw.githubusercontent.com/AhmedSaadi0/my-hyprland-config/main/screenshots/dark_1.png",
            thumbs: ["https://raw.githubusercontent.com/AhmedSaadi0/my-hyprland-config/main/screenshots/dark_2.png", "https://raw.githubusercontent.com/AhmedSaadi0/my-hyprland-config/main/screenshots/dark_3.png", "https://raw.githubusercontent.com/AhmedSaadi0/my-hyprland-config/main/screenshots/dark_4.png"],
            activateScript: Quickshell.shellPath("nibras-activate.sh"),
            revertScript: Quickshell.shellPath("nibras-revert.sh"),
            activatable: true
        },
        {
            name: "Impasto",
            author: "andreumassanet",
            license: "GPL-3.0",
            stars: "417",
            forks: "0",
            github: "https://github.com/andreumassanet/impasto",
            video: "",
            tagline: "Dynamic shell with an island, widgets, notes and tasks.",
            bio: "Dynamic shell for Hyprland with a dynamic island, desktop widgets, notes and tasks, and a one-script installer. Inspired by Caelestia.",
            features: ["Dynamic island", "Widgets", "Notes", "Tasks", "Themes", "Installer"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://opengraph.githubassets.com/1/andreumassanet/impasto",
            featured: "https://opengraph.githubassets.com/1/andreumassanet/impasto",
            thumbs: ["https://opengraph.githubassets.com/1/andreumassanet/impasto", "https://opengraph.githubassets.com/1/andreumassanet/impasto", "https://opengraph.githubassets.com/1/andreumassanet/impasto"],
            activateScript: Quickshell.shellPath("impasto-activate.sh"),
            revertScript: Quickshell.shellPath("impasto-revert.sh"),
            activatable: true
        },
        {
            name: "CuteShell",
            author: "retinotopic",
            license: "GPL-3.0",
            stars: "17",
            forks: "0",
            github: "https://github.com/retinotopic/CuteShell",
            video: "",
            tagline: "Shell bloatless et personnalisable pour Niri et Hyprland.",
            bio: "Shell bloatless pour Niri et Hyprland, entièrement personnalisable, hot swappable, facilement configurable. Écrit en QML/Quickshell.",
            features: ["Bloatless", "Personnalisable", "Hot swappable", "Configurable", "Niri & Hyprland"],
            prereqs: "Hyprland/Niri, Quickshell, Qt 6.",
            logo: "https://opengraph.githubassets.com/1/retinotopic/CuteShell",
            featured: "https://opengraph.githubassets.com/1/retinotopic/CuteShell",
            thumbs: ["https://opengraph.githubassets.com/1/retinotopic/CuteShell", "https://opengraph.githubassets.com/1/retinotopic/CuteShell", "https://opengraph.githubassets.com/1/retinotopic/CuteShell"],
            activateScript: Quickshell.shellPath("cuteshell-activate.sh"),
            revertScript: Quickshell.shellPath("cuteshell-revert.sh"),
            activatable: true
        },
        {
            name: "Minflair",
            author: "t4lentles5",
            license: "GPL-3.0",
            stars: "212",
            forks: "0",
            github: "https://github.com/t4lentles5/minflair",
            video: "",
            tagline: "Shell modulaire et esthétique pour Hyprland.",
            bio: "Shell modulaire et esthétique pour Hyprland, avec thèmes dynamiques, widgets, animations. Powered by Quickshell.",
            features: ["Modulaire", "Esthétique", "Thèmes dynamiques", "Widgets", "Animations", "Matugen"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://raw.githubusercontent.com/t4lentles5/minflair/main/assets/preview.webp",
            featured: "https://raw.githubusercontent.com/t4lentles5/minflair/main/assets/preview.webp",
            thumbs: ["https://raw.githubusercontent.com/t4lentles5/minflair/main/assets/island.webp", "https://raw.githubusercontent.com/t4lentles5/minflair/main/assets/convex.webp", "https://raw.githubusercontent.com/t4lentles5/minflair/main/assets/gaming.webp"],
            activateScript: Quickshell.shellPath("minflair-activate.sh"),
            revertScript: Quickshell.shellPath("minflair-revert.sh"),
            activatable: true
        },
        {
            name: "Tripathi Quickshell",
            author: "tripathiji1312",
            license: "MIT",
            stars: "196",
            forks: "0",
            github: "https://github.com/tripathiji1312/quickshell",
            video: "",
            tagline: "Shell hautement personnalisable et modulaire pour Hyprland.",
            bio: "Shell hautement personnalisable, modulaire et performant pour Hyprland. Composants, services, settings. Built with Quickshell.",
            features: ["Personnalisable", "Modulaire", "Performant", "Composants", "Services", "Settings"],
            prereqs: "Hyprland, Quickshell, Qt 6.",
            logo: "https://raw.githubusercontent.com/tripathiji1312/quickshell/main/image_quick/main_config.png",
            featured: "https://raw.githubusercontent.com/tripathiji1312/quickshell/main/image_quick/main_config.png",
            thumbs: ["https://raw.githubusercontent.com/tripathiji1312/quickshell/main/image_quick/notification.png", "https://raw.githubusercontent.com/tripathiji1312/quickshell/main/image_quick/bluetooth.png", "https://raw.githubusercontent.com/tripathiji1312/quickshell/main/image_quick/main_config.png"],
            activateScript: Quickshell.shellPath("trip-activate.sh"),
            revertScript: Quickshell.shellPath("trip-revert.sh"),
            activatable: true
        }
    ]

    property var tutorialSteps: [
        {
            icon: "\u2726",
            badge: "STEP 1 OF 7  •  INTRODUCTION",
            title: "Welcome to World of Shells",
            desc: "Browse 17 Quickshell environments for Hyprland and try one in a click, without touching your current configuration.",
            hint: "Use the Next and Previous buttons or the arrow keys to move through this guide."
        },
        {
            icon: "\u2630",
            badge: "STEP 2 OF 7  •  NAVIGATION",
            title: "Shell selector",
            desc: "The left panel lists every available shell. Scroll through the list and click a card to see its details.",
            hint: "Each card shows the project's logo, author and GitHub stars."
        },
        {
            icon: "\uD83D\uDD0D",
            badge: "STEP 3 OF 7  •  PREVIEWS",
            title: "Image gallery",
            desc: "The right panel shows a large main screenshot and a strip of thumbnails. Click any image to open it full screen in the lightbox.",
            hint: "In the lightbox, scroll to zoom, drag to move and double-click to reset."
        },
        {
            icon: "\u25B6",
            badge: "STEP 4 OF 7  •  LIVE TEST",
            title: "Activate a shell",
            desc: "Click Activate at the bottom right to try the selected shell straight away. Your current shell is stopped cleanly while the new one starts.",
            hint: "For end-4 (full dotfiles), a confirmation window appears before anything is installed."
        },
        {
            icon: "\u21BA",
            badge: "STEP 5 OF 7  •  RESTORE",
            title: "Return to your shell",
            desc: "At any time, click ↺ Revert at the bottom of the left panel to stop the shell you are trying and restore your environment.",
            hint: "The status line just above the button confirms each action."
        },
        {
            icon: "\u2699",
            badge: "STEP 6 OF 7  •  SETTINGS",
            title: "Settings",
            desc: "The ⚙ Settings button in the left panel's header opens the World of Shells preferences (currently a preview).",
            hint: "You can also replay this tutorial from there at any time."
        },
        {
            icon: "\u2713",
            badge: "STEP 7 OF 7  •  READY",
            title: "You're all set",
            desc: "You now know everything World of Shells can do. Click Finish to start exploring and trying Hyprland environments.",
            hint: "This tutorial won't open by itself next time."
        }
    ]

    // Each shell's own installer. Shells missing here have no install script in their repo.
    property var installers: ({
        "MacShell": {branch: "main", file: "install.sh", run: "bash install.sh --no-autostart --no-services --no-start"},
        "end-4 (illogical-impulse)": {branch: "main", file: "setup", run: "./setup install"},
        "ghOSt": {branch: "main", file: "install.sh", run: "./install.sh --activate"},
        "DankMaterialShell (DMS)": {branch: "master", file: "Makefile", run: "make build && sudo make install"},
        "Nandoroid": {branch: "main", file: "install.sh", run: "bash install.sh"},
        "SekaiPop": {branch: "main", file: "install.sh", run: "bash install.sh"},
        "Vantage": {branch: "main", file: "install.sh", run: "bash install.sh"},
        "Ukishima": {branch: "master", file: "remote-install.sh", run: "bash remote-install.sh"},
        "Lucid": {branch: "main", file: "install.sh", run: "bash install.sh"},
        "Nothingshell": {branch: "master", file: "install.sh", run: "bash install.sh"},
        "NibrasShell": {branch: "quickshell", file: "install.py", run: "python3 install.py"},
        "Impasto": {branch: "main", file: "setup", run: "bash setup"}
    })

    FloatingWindow {
        id: win
        title: "World of Shells"
        minimumSize: Qt.size(700, 500)
        implicitWidth: 1120
        implicitHeight: 740
        onClosed: {
            var proc = Qt.createQmlObject('import Quickshell.Io; Process {}', win)
            proc.command = ["bash", "-c", "mkdir -p ~/.config/WorldOfShells && echo " + width + "x" + height + "x" + x + "x" + y + " > ~/.config/WorldOfShells/window_size"]
            proc.running = true
            Qt.quit()
        }


        color: tok.bg
        Behavior on color { ColorAnimation { duration: tok.animMed } }

        property int selectedShell: 0
        property int shellPage: 0
        property int activeShellIndex: -1
        property bool transitionActive: false
        property bool busy: false
        property bool confirmEnd4: false
        property bool darkTheme: true
        property int autoRevertMinutes: 0
        property bool rememberLastShell: false
        property string lastSelectedShell: "0"
        property bool confirmInstall: false
        property bool scriptOpen: false
        property string scriptText: ""
        property string scriptStatus: ""
        readonly property var installer: installers[shell.name] || null
        readonly property string repoLabel: shell.github.replace("https://", "")
        readonly property string scriptUrl: installer
            ? shell.github.replace("https://github.com/", "https://raw.githubusercontent.com/") + "/" + installer.branch + "/" + installer.file
            : ""
        property bool settingsOpen: false
        property bool tutorialOpen: false
        property int tutorialStep: 0
        property int tutorialDirection: 1
        property string statusText: "Ready. Select a shell to explore or activate."
        property var shell: shells[selectedShell]

        // Save last selected shell
        property bool lightboxOpen: false
        property string lightboxSource: ""
        property real lightboxZoom: 1.0
        property real lightboxPanX: 0
        property real lightboxPanY: 0
        property int lightboxIndex: 0
        property var lightboxImages: []

        Behavior on lightboxZoom {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }
        Behavior on lightboxPanX {
            enabled: !lbMouse.pressed
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }
        Behavior on lightboxPanY {
            enabled: !lbMouse.pressed
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }

        property string tutorialFlagPath: Quickshell.env("HOME") + "/.config/WorldOfShells/tutorial_done"

        onSelectedShellChanged: {
            shellSwitchAnim.restart()
            if (rememberLastShell) {
                var proc = Qt.createQmlObject('import Quickshell.Io; Process {}', win)
                proc.command = ["bash", "-c", "mkdir -p ~/.config/WorldOfShells && echo " + selectedShell + " > ~/.config/WorldOfShells/last_shell"]
                proc.running = true
            }
        }

        function goToTutorialStep(newStep) {
            if (newStep < 0 || newStep >= tutorialSteps.length || newStep === win.tutorialStep) return
            win.tutorialDirection = newStep > win.tutorialStep ? 1 : -1
            win.tutorialStep = newStep
            tutStepAnim.restart()
        }

        Process {
            id: checkTutorialProc
            command: ["bash", "-c", "test -f \"" + win.tutorialFlagPath + "\""]
            onExited: (code) => {
                if (code !== 0) {
                    win.tutorialStep = 0
                    win.tutorialOpen = true
                }
            }
            Component.onCompleted: running = true
        }

        function completeTutorial() {
            win.tutorialOpen = false
            Quickshell.execDetached([
                "bash", "-c",
                "mkdir -p \"$(dirname \"" + win.tutorialFlagPath + "\")\" && touch \"" + win.tutorialFlagPath + "\""
            ])
        }

        function openLightbox(src) {
            lightboxImages = [shell.featured].concat(shell.thumbs)
            var idx = 0
            for (var i = 0; i < lightboxImages.length; i++) {
                if (lightboxImages[i] === src) { idx = i; break }
            }
            lightboxIndex = idx
            lightboxSource = lightboxImages[idx]
            lightboxZoom = 1.0
            lightboxPanX = 0
            lightboxPanY = 0
            lightboxOpen = true
        }
        function lightboxPrev() {
            if (lightboxIndex > 0) {
                lightboxIndex--
                lightboxSource = lightboxImages[lightboxIndex]
                lightboxZoom = 1.0
                lightboxPanX = 0
                lightboxPanY = 0
            }
        }
        function lightboxNext() {
            if (lightboxIndex < lightboxImages.length - 1) {
                lightboxIndex++
                lightboxSource = lightboxImages[lightboxIndex]
                lightboxZoom = 1.0
                lightboxPanX = 0
                lightboxPanY = 0
            }
        }
        function closeLightbox() { lightboxOpen = false }

        Process {
            id: actProcess
            property string target: ""
            onExited: code => {
                win.busy = false
                if (code === 3)
                    win.statusText = target + " is not installed. Nothing was changed."
                else if (code === 0)
                    win.statusText = target + " active."
                else
                    win.statusText = target + " did not start. Your shell was restored."
            }
        }

        Timer {
            id: revTimer
            interval: 800
            onTriggered: {
                win.busy = false
                win.statusText = "Previous shell restored."
            }
        }

        Timer {
            id: autoRevertTimer
            interval: win.autoRevertMinutes * 60000
            running: win.busy && win.autoRevertMinutes > 0
            repeat: false
            onTriggered: {
                win.revert()
            }
        }

        Timer {
            id: transitionTimer
            interval: 2500
            onTriggered: win.transitionActive = false
        }

        function viewScript() {
            if (!installer) return
            scriptText = ""
            scriptStatus = "Fetching " + scriptUrl
            scriptOpen = true
            scriptFetch.running = false
            scriptFetch.command = ["curl", "-fsSL", "--max-time", "20", scriptUrl]
            scriptFetch.running = true
        }
        function startInstall() {
            confirmInstall = false
            scriptOpen = false
            installProcess.target = shell.name
            installProcess.command = ["bash", Quickshell.shellPath("install-shell.sh"), shell.github, installer.branch, installer.run]
            installProcess.running = true
            statusText = "Installing " + shell.name + " in a terminal..."
        }
        Process {
            id: scriptFetch
            stdout: StdioCollector {
                onStreamFinished: win.scriptText = text
            }
            onExited: code => {
                win.scriptStatus = code === 0 ? win.scriptUrl : "Could not fetch " + win.scriptUrl
            }
        }
        Process {
            id: installProcess
            property string target: ""
            onExited: code => {
                if (code === 5)
                    win.statusText = "No terminal found to run the installer."
                else
                    win.statusText = target + " installer closed."
            }
        }

        function activate() {
            if (win.busy) return
            if (win.shell.name.startsWith("end-4")) { win.confirmEnd4 = true; return }
            win.busy = true
            win.statusText = "Activating " + win.shell.name + "..."
            win.transitionActive = true
            transitionTimer.restart()
            actProcess.target = win.shell.name
            actProcess.command = ["bash", win.shell.activateScript]
            actProcess.running = true
            autoRevertTimer.restart()
            win.activeShellIndex = win.selectedShell
        }
        function confirmEnd4Activate() {
            win.confirmEnd4 = false
            win.busy = true
            win.statusText = "Backing up and starting the end-4 installer..."
            win.transitionActive = true
            transitionTimer.restart()
            actProcess.target = win.shell.name
            actProcess.command = ["bash", win.shell.activateScript]
            actProcess.running = true
            autoRevertTimer.restart()
            win.activeShellIndex = win.selectedShell
        }
        function cancelEnd4Activate() {
            win.confirmEnd4 = false
            win.statusText = "Cancelled."
        }
        function revert() {
            if (win.busy || !win.shell.revertScript) return
            win.busy = true
            win.statusText = "Restoring..."
            Quickshell.execDetached(["bash", win.shell.revertScript])
            revTimer.restart()
            autoRevertTimer.stop()
            win.activeShellIndex = -1
        }

        // Transition animation when switching selectedShell
        ParallelAnimation {
            id: shellSwitchAnim
            NumberAnimation {
                target: rightPanelContainer
                property: "opacity"
                from: 0.45
                to: 1.0
                duration: 180
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: rightPanelTrans
                property: "y"
                from: 8
                to: 0
                duration: 200
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: leftMetaCol
                property: "opacity"
                from: 0.45
                to: 1.0
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        // Hidden focus item for keyboard shortcuts
        Item {
            id: keyHandler
            anchors.fill: parent
            focus: true
            Keys.onPressed: (event) => {
                if (win.lightboxOpen) {
                    if (event.key === Qt.Key_Left) { win.lightboxPrev(); event.accepted = true }
                    else if (event.key === Qt.Key_Right) { win.lightboxNext(); event.accepted = true }
                    else if (event.key === Qt.Key_Escape) { win.closeLightbox(); event.accepted = true }
                } else {
                    if (event.key === Qt.Key_Up) {
                        if (win.selectedShell > 0) win.selectedShell--
                        event.accepted = true
                    } else if (event.key === Qt.Key_Down) {
                        if (win.selectedShell < shells.length - 1) win.selectedShell++
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        win.activate()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        if (win.settingsOpen) win.settingsOpen = false
                        else win.revert()
                        event.accepted = true
                    }
                }
            }
        }

// ===== FULLSCREEN TRANSITION OVERLAY =====
        Rectangle {
            id: transitionOverlay
            anchors.fill: parent
            color: "#09090b"
            opacity: win.transitionActive ? 1.0 : 0.0
            visible: opacity > 0.01
            z: 10000

            // Animation properties driving the 60fps orbit, reveal & disintegration
            property real orbitProgress: 0.0
            property real revealProgress: win.transitionActive ? 1.0 : 0.0
            property real burstProgress: win.transitionActive ? 0.0 : 1.0

            // Pre-configured 9 floating particles (x, y offsets from center, size, speed, drift, colorRole)
            readonly property var particleSpecs: [
                { dx: -210, dy: -68, sz: 3.5, dur: 2200, delay: 0,   driftX: -18, driftY: -22, accent: 0 },
                { dx: -145, dy:  74, sz: 2.5, dur: 2600, delay: 180, driftX: -14, driftY:  18, accent: 1 },
                { dx:  -65, dy: -92, sz: 3.0, dur: 2400, delay: 320, driftX:  -8, driftY: -25, accent: 2 },
                { dx:   45, dy: -88, sz: 2.5, dur: 2100, delay: 120, driftX:  10, driftY: -20, accent: 0 },
                { dx:  168, dy: -52, sz: 4.0, dur: 2700, delay: 400, driftX:  22, driftY: -16, accent: 1 },
                { dx:  220, dy:  18, sz: 3.0, dur: 2300, delay: 250, driftX:  26, driftY:   8, accent: 0 },
                { dx:  135, dy:  82, sz: 2.5, dur: 2500, delay: 90,  driftX:  16, driftY:  22, accent: 2 },
                { dx:  -15, dy:  96, sz: 3.5, dur: 2800, delay: 300, driftX:   4, driftY:  24, accent: 1 },
                { dx: -235, dy:  12, sz: 2.8, dur: 2350, delay: 210, driftX: -24, driftY:   6, accent: 0 }
            ]

            Behavior on opacity {
                NumberAnimation {
                    duration: win.transitionActive ? 300 : 450
                    easing.type: win.transitionActive ? Easing.OutCubic : Easing.InCubic
                }
            }
            Behavior on revealProgress {
                NumberAnimation {
                    duration: win.transitionActive ? 650 : 380
                    easing.type: win.transitionActive ? Easing.OutCubic : Easing.InCubic
                }
            }
            Behavior on burstProgress {
                NumberAnimation {
                    duration: win.transitionActive ? 450 : 420
                    easing.type: Easing.OutCubic
                }
            }

            // Continuous 3.2s linear orbit sweep (matches wosOrbitSweep 3.2s linear infinite)
            NumberAnimation on orbitProgress {
                running: transitionOverlay.visible
                from: 0.0
                to: 1.0
                duration: 3200
                loops: Animation.Infinite
            }

            onOrbitProgressChanged: {
                if (transitionOverlay.visible) {
                    orbitBackCanvas.requestPaint()
                    orbitFrontCanvas.requestPaint()
                }
            }

            // 1. Matugen-tinted outer ambient halo
            Rectangle {
                anchors.centerIn: parent
                width: 680; height: 680
                radius: 340
                color: "transparent"
                border.color: tok.primary
                border.width: 1
                opacity: win.transitionActive ? 0.12 : 0.0
                scale: win.transitionActive ? 1.0 : 1.35
                Behavior on opacity { NumberAnimation { duration: 450 } }
                Behavior on scale { NumberAnimation { duration: 550; easing.type: Easing.OutCubic } }
            }

            // 2. Center reveal / shockwave ring on entry & disintegration wave on exit
            Rectangle {
                id: shockwaveRing
                anchors.centerIn: parent
                width: 460; height: 230
                radius: 115
                color: "transparent"
                border.color: tok.primary
                border.width: 2
                scale: win.transitionActive ? 1.18 : 0.35
                opacity: win.transitionActive ? 0.0 : 0.55
                Behavior on scale { NumberAnimation { duration: 650; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 650; easing.type: Easing.OutQuad } }
            }

            // 3. Multi-layered pulsing glow behind logo
            Rectangle {
                anchors.centerIn: parent
                width: 520; height: 520
                radius: 260
                color: "transparent"
                border.color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 2
                opacity: win.transitionActive ? 0.55 : 0.0
                scale: win.transitionActive ? 1.0 : 0.75

                Behavior on opacity { NumberAnimation { duration: 500 } }
                Behavior on scale { NumberAnimation { duration: 650; easing.type: Easing.OutCubic } }

                SequentialAnimation on scale {
                    running: transitionOverlay.visible
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.96; to: 1.14; duration: 2000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.14; to: 0.96; duration: 2000; easing.type: Easing.InOutSine }
                }
                SequentialAnimation on opacity {
                    running: transitionOverlay.visible
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.25; to: 0.65; duration: 2000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.65; to: 0.25; duration: 2000; easing.type: Easing.InOutSine }
                }
            }

            // Soft inner core glow (Matugen primary + white blend)
            Rectangle {
                anchors.centerIn: parent
                width: 340; height: 150
                radius: 75
                color: tok.primary
                opacity: win.transitionActive ? 0.07 : 0.0
                scale: win.transitionActive ? 1.0 : 0.5
                Behavior on opacity { NumberAnimation { duration: 500 } }
                Behavior on scale { NumberAnimation { duration: 550; easing.type: Easing.OutBack } }

                SequentialAnimation on opacity {
                    running: transitionOverlay.visible
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.05; to: 0.12; duration: 2300; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.12; to: 0.05; duration: 2300; easing.type: Easing.InOutSine }
                }
            }

            // 4. Floating & scattering star particles (9 particles for 60fps)
            Item {
                id: particleField
                anchors.centerIn: parent
                width: 450
                height: 220

                Repeater {
                    model: transitionOverlay.particleSpecs.length
                    Item {
                        id: pWrap
                        readonly property var spec: transitionOverlay.particleSpecs[index]
                        // Scatter outward when transition closes (disintegration effect)
                        x: parent.width / 2 + spec.dx * (1.0 + transitionOverlay.burstProgress * 0.45)
                        y: parent.height / 2 + spec.dy * (1.0 + transitionOverlay.burstProgress * 0.45)

                        property real floatOffset: 0.0
                        SequentialAnimation on floatOffset {
                            running: transitionOverlay.visible
                            loops: Animation.Infinite
                            PauseAnimation { duration: pWrap.spec.delay }
                            NumberAnimation { from: 0.0; to: 1.0; duration: pWrap.spec.dur; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 1.0; to: 0.0; duration: pWrap.spec.dur; easing.type: Easing.InOutSine }
                        }

                        Rectangle {
                            width: pWrap.spec.sz
                            height: pWrap.spec.sz
                            radius: width / 2
                            x: pWrap.spec.driftX * pWrap.floatOffset
                            y: pWrap.spec.driftY * pWrap.floatOffset
                            color: pWrap.spec.accent === 1 ? tok.primary : (pWrap.spec.accent === 2 ? tok.tertiary : "#FFFFFF")
                            opacity: (0.25 + 0.65 * pWrap.floatOffset) * transitionOverlay.revealProgress

                            // Subtle halo around each particle
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width * 2.6
                                height: parent.height * 2.6
                                radius: width / 2
                                color: parent.color
                                opacity: 0.22
                            }
                        }
                    }
                }
            }

            // 5. Main Logo Container (handles Entry spring & Exit disintegration without fighting Breathe)
            Item {
                id: logoContainer
                anchors.centerIn: parent
                width: 450
                height: 220

                // Progressive construction scale on entry (OutBack) & disintegration scale on exit
                scale: win.transitionActive ? 1.0 : 0.74
                opacity: win.transitionActive ? 1.0 : 0.0

                Behavior on scale {
                    NumberAnimation {
                        duration: win.transitionActive ? 580 : 380
                        easing.type: win.transitionActive ? Easing.OutBack : Easing.InBack
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: win.transitionActive ? 380 : 350
                        easing.type: Easing.OutCubic
                    }
                }

                // Inner wrapper dedicated to continuous Breathe & Rotation (wosLogoBreathe 4.6s)
                Item {
                    id: logoBreatheWrapper
                    anchors.fill: parent
                    transformOrigin: Item.Center

                    SequentialAnimation on scale {
                        running: transitionOverlay.visible
                        loops: Animation.Infinite
                        NumberAnimation { from: 0.996; to: 1.004; duration: 2300; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 1.004; to: 0.996; duration: 2300; easing.type: Easing.InOutSine }
                    }

                    SequentialAnimation on rotation {
                        running: transitionOverlay.visible
                        loops: Animation.Infinite
                        NumberAnimation { from: -1.6; to: 1.6; duration: 2300; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 1.6; to: -1.6; duration: 2300; easing.type: Easing.InOutSine }
                    }

                    // LAYER 1 (BACK): Upper half of the tilted orbit passing BEHIND the WOS letters
                    Canvas {
                        id: orbitBackCanvas
                        anchors.fill: parent
                        z: 1
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var s = width / 640.0
                            var cx = 306.0 * s
                            var cy = 142.0 * s + 1.0
                            var rx = 214.0 * s * transitionOverlay.revealProgress
                            var ry = 73.0 * s * transitionOverlay.revealProgress
                            var rot = -23.5 * Math.PI / 180.0

                            ctx.save()
                            ctx.translate(cx, cy)
                            ctx.rotate(rot)

                            // Clip to back/upper half of orbit (y < 0 in rotated ellipse space)
                            ctx.beginPath()
                            ctx.rect(-260 * s, -120 * s, 520 * s, 120 * s)
                            ctx.clip()

                            // Base subtle static orbit track
                            ctx.beginPath()
                            for (var a = Math.PI; a <= Math.PI * 2.02; a += 0.06) {
                                var px = rx * Math.cos(a)
                                var py = ry * Math.sin(a)
                                if (a === Math.PI) ctx.moveTo(px, py)
                                else ctx.lineTo(px, py)
                            }
                            ctx.strokeStyle = "rgba(212, 212, 220, 0.28)"
                            ctx.lineWidth = 1.4
                            ctx.stroke()

                            // Right-apex static highlight from animated-logo.html
                            ctx.beginPath()
                            for (var h = -0.62; h <= 0.0; h += 0.04) {
                                var hx = rx * Math.cos(h)
                                var hy = ry * Math.sin(h)
                                if (h === -0.62) ctx.moveTo(hx, hy)
                                else ctx.lineTo(hx, hy)
                            }
                            ctx.strokeStyle = "rgba(255, 255, 255, 0.75)"
                            ctx.lineWidth = 2.2
                            ctx.lineCap = "round"
                            ctx.stroke()

                            // Animated orbit sweep trail (comet with graduated alpha & width)
                            var headAngle = transitionOverlay.orbitProgress * Math.PI * 2.0
                            var sweepLen = Math.PI * 0.42
                            var steps = 28
                            for (var i = 0; i < steps; i++) {
                                var t0 = i / steps
                                var t1 = (i + 1) / steps
                                var a0 = headAngle - sweepLen * (1.0 - t0)
                                var a1 = headAngle - sweepLen * (1.0 - t1)

                                // Outer Matugen primary glow along trail
                                ctx.beginPath()
                                ctx.moveTo(rx * Math.cos(a0), ry * Math.sin(a0))
                                ctx.lineTo(rx * Math.cos(a1), ry * Math.sin(a1))
                                ctx.strokeStyle = Qt.rgba(tok.primary.r, tok.primary.g, tok.primary.b, t1 * t1 * 0.45)
                                ctx.lineWidth = 5.5 * t1
                                ctx.lineCap = "round"
                                ctx.stroke()

                                // Bright white core sweep
                                ctx.beginPath()
                                ctx.moveTo(rx * Math.cos(a0), ry * Math.sin(a0))
                                ctx.lineTo(rx * Math.cos(a1), ry * Math.sin(a1))
                                ctx.strokeStyle = "rgba(255, 255, 255, " + (t1 * t1 * 0.95) + ")"
                                ctx.lineWidth = 0.8 + 2.2 * t1
                                ctx.lineCap = "round"
                                ctx.stroke()
                            }

                            ctx.restore()
                        }
                    }

                    // LAYER 2 (MIDDLE): The WOS metallic SVG logo with center-out progressive reveal
                    Item {
                        id: logoRevealClip
                        anchors.centerIn: parent
                        width: parent.width * (0.35 + 0.65 * transitionOverlay.revealProgress)
                        height: parent.height
                        clip: true
                        z: 2

                        Image {
                            id: transitionLogo
                            anchors.centerIn: parent
                            source: Quickshell.shellPath("logo.svg")
                            width: 450
                            height: 220
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }
                    }

                    // LAYER 3 (FRONT): Lower half of the tilted orbit passing IN FRONT OF the WOS letters
                    Canvas {
                        id: orbitFrontCanvas
                        anchors.fill: parent
                        z: 3
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var s = width / 640.0
                            var cx = 306.0 * s
                            var cy = 142.0 * s + 1.0
                            var rx = 214.0 * s * transitionOverlay.revealProgress
                            var ry = 73.0 * s * transitionOverlay.revealProgress
                            var rot = -23.5 * Math.PI / 180.0

                            ctx.save()
                            ctx.translate(cx, cy)
                            ctx.rotate(rot)

                            // Clip to front/lower half of orbit (y >= -1 in rotated ellipse space)
                            ctx.beginPath()
                            ctx.rect(-260 * s, -1 * s, 520 * s, 130 * s)
                            ctx.clip()

                            // Base subtle static orbit track (front)
                            ctx.beginPath()
                            for (var a = 0.0; a <= Math.PI * 1.02; a += 0.06) {
                                var px = rx * Math.cos(a)
                                var py = ry * Math.sin(a)
                                if (a === 0.0) ctx.moveTo(px, py)
                                else ctx.lineTo(px, py)
                            }
                            ctx.strokeStyle = "rgba(212, 212, 220, 0.34)"
                            ctx.lineWidth = 1.4
                            ctx.stroke()

                            // Left-apex static highlight from animated-logo.html
                            ctx.beginPath()
                            for (var h = Math.PI - 0.55; h <= Math.PI + 0.05; h += 0.04) {
                                var hx = rx * Math.cos(h)
                                var hy = ry * Math.sin(h)
                                if (h === Math.PI - 0.55) ctx.moveTo(hx, hy)
                                else ctx.lineTo(hx, hy)
                            }
                            ctx.strokeStyle = "rgba(255, 255, 255, 0.78)"
                            ctx.lineWidth = 2.2
                            ctx.lineCap = "round"
                            ctx.stroke()

                            // Animated orbit sweep trail (front pass)
                            var headAngle = transitionOverlay.orbitProgress * Math.PI * 2.0
                            var sweepLen = Math.PI * 0.42
                            var steps = 28
                            for (var i = 0; i < steps; i++) {
                                var t0 = i / steps
                                var t1 = (i + 1) / steps
                                var a0 = headAngle - sweepLen * (1.0 - t0)
                                var a1 = headAngle - sweepLen * (1.0 - t1)

                                // Outer Matugen primary glow along trail
                                ctx.beginPath()
                                ctx.moveTo(rx * Math.cos(a0), ry * Math.sin(a0))
                                ctx.lineTo(rx * Math.cos(a1), ry * Math.sin(a1))
                                ctx.strokeStyle = Qt.rgba(tok.primary.r, tok.primary.g, tok.primary.b, t1 * t1 * 0.5)
                                ctx.lineWidth = 6.0 * t1
                                ctx.lineCap = "round"
                                ctx.stroke()

                                // Bright white core sweep
                                ctx.beginPath()
                                ctx.moveTo(rx * Math.cos(a0), ry * Math.sin(a0))
                                ctx.lineTo(rx * Math.cos(a1), ry * Math.sin(a1))
                                ctx.strokeStyle = "rgba(255, 255, 255, " + (t1 * t1 * 0.96) + ")"
                                ctx.lineWidth = 0.9 + 2.3 * t1
                                ctx.lineCap = "round"
                                ctx.stroke()
                            }

                            // Glowing comet head dot
                            var headX = rx * Math.cos(headAngle)
                            var headY = ry * Math.sin(headAngle)
                            ctx.beginPath()
                            ctx.arc(headX, headY, 2.4, 0, Math.PI * 2.0)
                            ctx.fillStyle = "#FFFFFF"
                            ctx.fill()

                            ctx.restore()
                        }
                    }

                    // LAYER 4: Animated 4-point Star Pulse at (476, 61) in 640x310 space (wosStarPulse)
                    Item {
                        id: starPulseItem
                        readonly property real svgScale: parent.width / 640.0
                        x: 476.0 * svgScale - width / 2
                        y: 61.0 * svgScale + 1.0 - height / 2
                        width: 40
                        height: 40
                        z: 4
                        scale: 0.94
                        opacity: 0.72

                        SequentialAnimation on scale {
                            running: transitionOverlay.visible
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.94; to: 1.08; duration: 1600; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 1.08; to: 0.94; duration: 1600; easing.type: Easing.InOutSine }
                        }
                        SequentialAnimation on opacity {
                            running: transitionOverlay.visible
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.72; to: 1.0; duration: 1600; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 1.0; to: 0.72; duration: 1600; easing.type: Easing.InOutSine }
                        }

                        // Soft glow behind the 4-point star
                        Rectangle {
                            anchors.centerIn: parent
                            width: 16; height: 16; radius: 8
                            color: "#FFFFFF"
                            opacity: 0.28
                        }

                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                ctx.translate(width / 2, height / 2)
                                var s = starPulseItem.svgScale
                                ctx.scale(s, s)
                                // Exact SVG path from animated-logo.html: M 0 -19 C 1.1 -4.2, 4.2 -1.1, 19 0 ...
                                ctx.beginPath()
                                ctx.moveTo(0, -19)
                                ctx.bezierCurveTo(1.1, -4.2, 4.2, -1.1, 19, 0)
                                ctx.bezierCurveTo(4.2, 1.1, 1.1, 4.2, 0, 19)
                                ctx.bezierCurveTo(-1.1, 4.2, -4.2, 1.1, -19, 0)
                                ctx.bezierCurveTo(-4.2, -1.1, -1.1, -4.2, 0, -19)
                                ctx.closePath()
                                ctx.fillStyle = "#FFFFFF"
                                ctx.fill()
                            }
                        }
                    }

                    // LAYER 5: Subtle inner star pulse inside the "O" disc cutout at (332, 140)
                    Rectangle {
                        readonly property real svgScale: parent.width / 640.0
                        x: 332.0 * svgScale - width / 2
                        y: 140.0 * svgScale + 1.0 - height / 2
                        width: 14; height: 14; radius: 7
                        color: tok.primary
                        z: 4
                        opacity: 0.0

                        SequentialAnimation on opacity {
                            running: transitionOverlay.visible
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.08; to: 0.35; duration: 1600; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 0.35; to: 0.08; duration: 1600; easing.type: Easing.InOutSine }
                        }
                    }
                }
            }

            // 6. "WORLD OF SHELLS" title with flanking lines (matching animated-logo.html)
            Row {
                id: titleRow
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: logoContainer.bottom
                anchors.topMargin: 16
                spacing: 14
                opacity: win.transitionActive ? 0.88 : 0.0
                scale: win.transitionActive ? 1.0 : 0.94
                Behavior on opacity { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36 * transitionOverlay.revealProgress
                    height: 1
                    color: "#8E8E98"
                    opacity: 0.45
                }

                Text {
                    text: "WORLD OF SHELLS"
                    color: "#9A9AA6"
                    font.pixelSize: 11
                    font.letterSpacing: 6
                    font.weight: Font.Light
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36 * transitionOverlay.revealProgress
                    height: 1
                    color: "#8E8E98"
                    opacity: 0.45
                }
            }

            // 7. Activating shell status text
            Text {
                id: statusTransitionText
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: titleRow.bottom
                anchors.topMargin: 16
                text: win.statusText
                color: tok.primary
                font.pixelSize: 13
                font.weight: Font.Medium
                opacity: win.transitionActive ? 0.92 : 0.0
                Behavior on opacity { NumberAnimation { duration: 400 } }
            }

            // 8. Sleek 2.5s progress sweep bar + 3 pulsing dots at bottom
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 52
                spacing: 14
                opacity: win.transitionActive ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 300 } }

                // Thin 2.5s progress bar
                Rectangle {
                    width: 140
                    height: 2
                    radius: 1
                    color: Qt.rgba(1, 1, 1, 0.12)
                    clip: true

                    Rectangle {
                        id: progressFill
                        height: parent.height
                        radius: 1
                        color: tok.primary
                        width: 0

                        NumberAnimation on width {
                            running: win.transitionActive
                            from: 0
                            to: 140
                            duration: 2450
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                // Loading indicator dots
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    Repeater {
                        model: 3
                        Rectangle {
                            width: 6; height: 6; radius: 3
                            color: index === 1 ? tok.primary : "#FFFFFF"
                            opacity: 0.35

                            SequentialAnimation on opacity {
                                running: transitionOverlay.visible
                                loops: Animation.Infinite
                                PauseAnimation { duration: index * 180 }
                                NumberAnimation { from: 0.35; to: 1.0; duration: 380; easing.type: Easing.InOutSine }
                                NumberAnimation { from: 1.0; to: 0.35; duration: 380; easing.type: Easing.InOutSine }
                                PauseAnimation { duration: (2 - index) * 180 }
                            }
                            SequentialAnimation on scale {
                                running: transitionOverlay.visible
                                loops: Animation.Infinite
                                PauseAnimation { duration: index * 180 }
                                NumberAnimation { from: 0.85; to: 1.25; duration: 380; easing.type: Easing.InOutSine }
                                NumberAnimation { from: 1.25; to: 0.85; duration: 380; easing.type: Easing.InOutSine }
                                PauseAnimation { duration: (2 - index) * 180 }
                            }
                        }
                    }
                }
            }
        }

                // Main two-pane layout
        RowLayout {
            anchors.fill: parent
            anchors.margins: tok.sp5
            spacing: tok.sp5
            opacity: win.transitionActive ? 0.3 : 1.0
            Behavior on opacity { NumberAnimation { duration: 300 } }

            // ================= LEFT PANEL (300px) =================
            ColumnLayout {
                Layout.preferredWidth: 300
                Layout.maximumWidth: 300
                Layout.fillHeight: true
                spacing: tok.sp4

                // App Header + Settings Button
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: tok.sp2
                        Rectangle {
                            width: 8
                            height: 20
                            radius: 4
                            color: tok.primary
                            Behavior on color { ColorAnimation { duration: tok.animMed } }
                        }
                        Text {
                            text: "World of Shells"
                            font.pixelSize: 20
                            font.weight: Font.Bold
                            color: tok.fg
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            Layout.preferredWidth: settingsBtnRow.implicitWidth + tok.sp2 * 2
                            Layout.preferredHeight: 26
                            radius: tok.r2
                            color: settingsBtnMouse.containsMouse ? tok.surfaceHigh : tok.surface
                            border.width: 1
                            border.color: settingsBtnMouse.containsMouse ? tok.primary : tok.outlineVariant
                            scale: settingsBtnMouse.pressed ? 0.95 : (settingsBtnMouse.containsMouse ? 1.03 : 1.0)
                            Behavior on color { ColorAnimation { duration: tok.animFast } }
                            Behavior on border.color { ColorAnimation { duration: tok.animFast } }
                            Behavior on scale { NumberAnimation { duration: tok.animFast; easing.type: Easing.OutQuad } }

                            RowLayout {
                                id: settingsBtnRow
                                anchors.centerIn: parent
                                spacing: 4
                                Text {
                                    text: "\u2699"
                                    font.pixelSize: 12
                                    color: tok.primary
                                    rotation: settingsBtnMouse.containsMouse ? 45 : 0
                                    Behavior on rotation { NumberAnimation { duration: tok.animMed; easing.type: Easing.OutBack } }
                                }
                                Text {
                                    text: "Settings"
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    color: tok.fgVariant
                                }
                            }
                            MouseArea {
                                id: settingsBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: win.settingsOpen = true
                            }
                        }
                    }
                    Text {
                        text: "Quickshell environment selector"
                        font.pixelSize: 11
                        color: tok.fgMuted
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // Shell Selector Cards
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: tok.sp2
                    Repeater {
                        model: Math.min(4, shells.length - win.shellPage * 4)
                        Rectangle {
                            id: cardRect
                            property int shellIndex: win.shellPage * 4 + index
                            property bool isSelected: win.selectedShell === shellIndex
                            property bool hovered: cardMouse.containsMouse
                            Layout.fillWidth: true
                            height: 68
                            radius: tok.r3
                            color: isSelected ? tok.surfaceHigh : (hovered ? "#1e2428" : tok.bg)
                            border.width: isSelected ? 2 : 1
                            border.color: isSelected ? tok.primary : (hovered ? tok.outline : tok.outlineVariant)

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: tok.sp3
                                spacing: tok.sp3

                                Rectangle {
                                    Layout.preferredWidth: 44
                                    Layout.preferredHeight: 44
                                    radius: tok.r2
                                    color: cardRect.isSelected ? tok.bg : tok.surface
                                    border.width: 1
                                    border.color: tok.outlineVariant
                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        source: shells[cardRect.shellIndex].logo
                                        fillMode: Image.PreserveAspectFit
                                        sourceSize: Qt.size(44, 44)
                                        asynchronous: true
                                        cache: false
                                        opacity: status === Image.Ready ? 1.0 : 0.3
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: shells[cardRect.shellIndex].name
                                        font.pixelSize: 14
                                        font.weight: cardRect.isSelected ? Font.Bold : Font.Medium
                                        color: cardRect.isSelected ? tok.primary : tok.fg
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: "by " + shells[cardRect.shellIndex].author
                                        font.pixelSize: 11
                                        color: tok.fgVariant
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: starBadgeText.implicitWidth + tok.sp2 * 2
                                    Layout.preferredHeight: 22
                                    radius: 11
                                    color: cardRect.isSelected ? tok.primary : tok.surfaceHigh
                                    Text {
                                        id: starBadgeText
                                        anchors.centerIn: parent
                                        text: "\u2605 " + shells[cardRect.shellIndex].stars
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                        color: cardRect.isSelected ? tok.fgOnPrimary : tok.fgVariant
                                    }
                                }

                                // Active shell badge
                                Rectangle {
                                    Layout.preferredWidth: activeBadgeText.implicitWidth + tok.sp2 * 2
                                    Layout.preferredHeight: 22
                                    radius: 11
                                    color: "#22c55e"
                                    visible: win.activeShellIndex === cardRect.shellIndex
                                    Text {
                                        id: activeBadgeText
                                        anchors.centerIn: parent
                                        text: "ACTIVE"
                                        font.pixelSize: 9
                                        font.weight: Font.Bold
                                        color: "#ffffff"
                                    }
                                }
                            }

                            MouseArea {
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: win.selectedShell = cardRect.shellIndex
                            }
                        }
                    }

                    // Navigation buttons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: tok.sp2
                        Rectangle {
                            property bool canPrev: win.shellPage > 0
                            Layout.fillWidth: true
                            height: 28
                            radius: tok.r2
                            color: canPrev ? (prevPageMouse.containsMouse ? tok.primary : tok.surfaceHigh) : tok.surface
                            opacity: canPrev ? 1.0 : 0.4
                            Text {
                                anchors.centerIn: parent
                                text: "\u25B2  Prev"
                                font.pixelSize: 10
                                font.weight: Font.Medium
                                color: prevPageMouse.containsMouse && parent.canPrev ? tok.fgOnPrimary : tok.fgVariant
                            }
                            MouseArea {
                                id: prevPageMouse
                                anchors.fill: parent
                                enabled: win.shellPage > 0
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (win.shellPage > 0) win.shellPage--
                            }
                        }
                        Rectangle {
                            property bool canNext: (win.shellPage + 1) * 4 < shells.length
                            Layout.fillWidth: true
                            height: 28
                            radius: tok.r2
                            color: canNext ? (nextPageMouse.containsMouse ? tok.primary : tok.surfaceHigh) : tok.surface
                            opacity: canNext ? 1.0 : 0.4
                            Text {
                                anchors.centerIn: parent
                                text: "Next  \u25BC"
                                font.pixelSize: 10
                                font.weight: Font.Medium
                                color: nextPageMouse.containsMouse && parent.canNext ? tok.fgOnPrimary : tok.fgVariant
                            }
                            MouseArea {
                                id: nextPageMouse
                                anchors.fill: parent
                                enabled: (win.shellPage + 1) * 4 < shells.length
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if ((win.shellPage + 1) * 4 < shells.length) win.shellPage++
                            }
                        }
                    }

                    // Page indicator
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: (win.shellPage + 1) + " / " + Math.ceil(shells.length / 4)
                        font.pixelSize: 9
                        color: tok.fgMuted
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: tok.outlineVariant
                        opacity: 0.6
                    }

                    // Left metadata container (animated on shell switch)
                    ColumnLayout {
                        id: leftMetaCol
                        Layout.fillWidth: true
                        spacing: tok.sp2

                        // Tagline
                        Text {
                            text: win.shell.tagline
                            font.pixelSize: 13
                            color: tok.fgVariant
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            lineHeight: 1.4
                        }

                        // Stats grid
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: tok.sp2

                            Rectangle {
                                Layout.fillWidth: true
                                height: 54
                                radius: tok.r2
                                color: tok.bg
                                border.width: 1
                                border.color: tok.outlineVariant
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 0
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: win.shell.stars
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        color: tok.primary
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "Stars"
                                        font.pixelSize: 10
                                        color: tok.fgMuted
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 54
                                radius: tok.r2
                                color: tok.bg
                                border.width: 1
                                border.color: tok.outlineVariant
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 0
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: win.shell.forks
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        color: tok.tertiary
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "Forks"
                                        font.pixelSize: 10
                                        color: tok.fgMuted
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 54
                                radius: tok.r2
                                color: tok.bg
                                border.width: 1
                                border.color: tok.outlineVariant
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: win.shell.license
                                        font.pixelSize: 13
                                        font.weight: Font.Bold
                                        color: tok.fg
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "License"
                                        font.pixelSize: 10
                                        color: tok.fgMuted
                                    }
                                }
                            }
                        }

                        // Key features summary
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: tok.sp1
                            Text {
                                text: "KEY FEATURES"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: tok.fgMuted
                            }
                            Flow {
                                Layout.fillWidth: true
                                spacing: 6
                                Repeater {
                                    model: win.shell.features
                                    Rectangle {
                                        width: leftFeatText.implicitWidth + tok.sp2 * 2
                                        height: 22
                                        radius: 6
                                        color: tok.bg
                                        border.width: 1
                                        border.color: tok.outlineVariant
                                        Text {
                                            id: leftFeatText
                                            anchors.centerIn: parent
                                            text: modelData
                                            font.pixelSize: 10
                                            color: tok.fgVariant
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Status Box
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: statusRow.implicitHeight + tok.sp2 * 2
                        radius: tok.r2
                        color: tok.bg
                        border.width: 1
                        border.color: win.busy ? tok.primary : tok.outlineVariant
                        Behavior on border.color { ColorAnimation { duration: tok.animMed } }

                        RowLayout {
                            id: statusRow
                            anchors.fill: parent
                            anchors.margins: tok.sp2
                            spacing: tok.sp2
                            Rectangle {
                                id: statusDot
                                width: 6
                                height: 6
                                radius: 3
                                color: win.busy ? tok.primary : tok.tertiary
                                Layout.alignment: Qt.AlignTop
                                Layout.topMargin: 4
                                Behavior on color { ColorAnimation { duration: tok.animFast } }

                                SequentialAnimation on opacity {
                                    running: win.busy
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.25; duration: 400; easing.type: Easing.InOutQuad }
                                    NumberAnimation { to: 1.0; duration: 400; easing.type: Easing.InOutQuad }
                                    onRunningChanged: if (!running) statusDot.opacity = 1.0
                                }
                            }
                            Text {
                                id: statusLabel
                                text: win.statusText
                                font.pixelSize: 11
                                color: tok.fgVariant
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Revert Button
                    Rectangle {
                        id: revBtn
                        Layout.fillWidth: true
                        height: 38
                        radius: tok.r3
                        color: revMouse.containsMouse && !win.busy ? tok.surfaceHigh : tok.bg
                        border.width: 1
                        border.color: revMouse.containsMouse && !win.busy ? tok.primary : tok.outlineVariant
                        scale: revMouse.pressed && !win.busy ? 0.97 : (revMouse.containsMouse && !win.busy ? 1.01 : 1.0)
                        visible: win.shell.activatable

                        Behavior on color { ColorAnimation { duration: tok.animFast } }
                        Behavior on border.color { ColorAnimation { duration: tok.animFast } }
                        Behavior on scale { NumberAnimation { duration: tok.animFast; easing.type: Easing.OutQuad } }

                        Text {
                            anchors.centerIn: parent
                            text: win.busy ? "Working..." : "\u21BA  Revert"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: win.busy ? tok.fgMuted : tok.fg
                            Behavior on color { ColorAnimation { duration: tok.animFast } }
                        }
                        MouseArea {
                            id: revMouse
                            anchors.fill: parent
                            enabled: !win.busy
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: win.revert()
                        }
                    }

                    // GitHub link
                    Rectangle {
                        Layout.fillWidth: true
                        height: 28
                        radius: tok.r2
                        color: ghLeftMouse.containsMouse ? tok.surfaceHigh : "transparent"
                        clip: true
                        Behavior on color { ColorAnimation { duration: tok.animFast } }

                        RowLayout {
                            anchors.centerIn: parent
                            width: parent.width - tok.sp2 * 2
                            spacing: tok.sp1
                            Text {
                                text: "\u2197"
                                font.pixelSize: 12
                                color: tok.primary
                            }
                            Text {
                                text: win.shell.github
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: tok.primary
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }
                        }
                        MouseArea {
                            id: ghLeftMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.openUrlExternally(win.shell.github)
                        }
                    }

                    // Video link (if available)
                    Rectangle {
                        Layout.fillWidth: true
                        height: 28
                        radius: tok.r2
                        visible: win.shell.video !== ""
                        color: vidLeftMouse.containsMouse ? tok.surfaceHigh : "transparent"
                        Behavior on color { ColorAnimation { duration: tok.animFast } }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: tok.sp1
                            Text {
                                text: "\u25B6"
                                font.pixelSize: 12
                                color: tok.tertiary
                            }

                            Text {
                                text: "Demo video"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: tok.tertiary
                            }
                        }
                        MouseArea {
                            id: vidLeftMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.openUrlExternally(win.shell.video)
                        }
                    }

                    // Disclaimer
                    Text {
                        text: "Experimental. Activating a shell may change your configuration. Keep backups."
                        font.pixelSize: 10
                        color: tok.fgMuted
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        font.italic: true
                    }
                }
            }

            // ================= RIGHT PANEL (FILL) =================
            ColumnLayout {
                id: rightPanelContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: tok.sp3
                transform: Translate { id: rightPanelTrans; y: 0 }

                // Featured Image Container (Large)
                Rectangle {
                    id: featuredCard
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: tok.r4
                    color: tok.surface
                    border.width: 1
                    border.color: featMouse.containsMouse ? tok.primary : tok.outlineVariant
                    clip: true
                    Behavior on border.color { ColorAnimation { duration: tok.animFast } }

                    Image {
                        anchors.fill: parent
                        anchors.margins: tok.sp3
                        source: win.shell.featured
                        fillMode: Image.PreserveAspectFit
                        sourceSize: Qt.size(800, 600)
                        asynchronous: true
                        cache: true
                        opacity: status === Image.Ready ? 1.0 : 0.0
                        scale: featMouse.containsMouse ? 1.015 : 1.0
                        Behavior on opacity { NumberAnimation { duration: tok.animSlow; easing.type: Easing.OutCubic } }
                        Behavior on scale { NumberAnimation { duration: tok.animSlow; easing.type: Easing.OutCubic } }
                    }

                    // Top-left shell badge overlay
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: tok.sp3
                        width: badgeRow.implicitWidth + tok.sp3 * 2
                        height: 30
                        radius: 15
                        color: Qt.rgba(15/255, 20/255, 23/255, 0.85)
                        border.width: 1
                        border.color: tok.outlineVariant
                        RowLayout {
                            id: badgeRow
                            anchors.centerIn: parent
                            spacing: tok.sp2
                            Text {
                                text: win.shell.name
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: tok.fg
                            }
                            Text {
                                text: "\u2022  Main preview"
                                font.pixelSize: 11
                                color: tok.fgMuted
                            }
                        }
                    }

                    // Bottom-right zoom hint pill
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.margins: tok.sp3
                        width: zoomHintText.implicitWidth + tok.sp3 * 2
                        height: 28
                        radius: 14
                        color: featMouse.containsMouse ? tok.primary : Qt.rgba(15/255, 20/255, 23/255, 0.85)
                        border.width: 1
                        border.color: featMouse.containsMouse ? tok.primary : tok.outlineVariant
                        scale: featMouse.containsMouse ? 1.04 : 1.0
                        Behavior on color { ColorAnimation { duration: tok.animFast } }
                        Behavior on border.color { ColorAnimation { duration: tok.animFast } }
                        Behavior on scale { NumberAnimation { duration: tok.animFast; easing.type: Easing.OutQuad } }

                        Text {
                            id: zoomHintText
                            anchors.centerIn: parent
                            text: "\uD83D\uDD0D Click to enlarge"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: featMouse.containsMouse ? tok.fgOnPrimary : tok.fgVariant
                            Behavior on color { ColorAnimation { duration: tok.animFast } }
                        }
                    }

                    MouseArea {
                        id: featMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: win.openLightbox(win.shell.featured)
                    }
                }

                // Thumbnails Strip
                RowLayout {
                    Layout.fillWidth: true
                    spacing: tok.sp3
                    Repeater {
                        model: win.shell.thumbs
                        Rectangle {
                            Layout.fillWidth: true
                            height: 136
                            radius: tok.r3
                            color: tok.surface
                            border.width: 1
                            border.color: thumbMouse.containsMouse ? tok.primary : tok.outlineVariant
                            scale: thumbMouse.pressed ? 0.97 : (thumbMouse.containsMouse ? 1.015 : 1.0)
                            clip: true

                            Behavior on border.color { ColorAnimation { duration: tok.animFast } }
                            Behavior on scale { NumberAnimation { duration: tok.animFast; easing.type: Easing.OutQuad } }

                            Image {
                                anchors.fill: parent
                                anchors.margins: tok.sp2
                                source: modelData
                                fillMode: Image.PreserveAspectFit
                                sourceSize: Qt.size(320, 160)
                                asynchronous: true
                                cache: true
                                opacity: status === Image.Ready ? 1.0 : 0.0
                                scale: thumbMouse.containsMouse ? 1.03 : 1.0
                                Behavior on opacity { NumberAnimation { duration: tok.animSlow; easing.type: Easing.OutCubic } }
                                Behavior on scale { NumberAnimation { duration: tok.animSlow; easing.type: Easing.OutCubic } }
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                anchors.margins: tok.sp2
                                width: 24
                                height: 24
                                radius: 12
                                opacity: thumbMouse.containsMouse ? 1.0 : 0.0
                                scale: thumbMouse.containsMouse ? 1.0 : 0.6
                                color: tok.primary
                                Behavior on opacity { NumberAnimation { duration: tok.animFast } }
                                Behavior on scale { NumberAnimation { duration: tok.animFast; easing.type: Easing.OutBack } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "+"
                                    font.pixelSize: 15
                                    font.weight: Font.Bold
                                    color: tok.fgOnPrimary
                                }
                            }

                            MouseArea {
                                id: thumbMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: win.openLightbox(modelData)
                            }
                        }
                    }
                }

                // Details & Action Card
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: detailsCol.implicitHeight + tok.sp4 * 2
                    radius: tok.r4
                    color: tok.surface
                    border.width: 1
                    border.color: tok.outlineVariant

                    ColumnLayout {
                        id: detailsCol
                        anchors.fill: parent
                        anchors.margins: tok.sp4
                        spacing: tok.sp3

                        // Top action row: Title + Activate CTA button
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: tok.sp4

                            ColumnLayout {
                                Layout.fillWidth: true
                                // The long description must wrap, not widen the whole window layout.
                                Layout.preferredWidth: 0
                                spacing: 2
                                Text {
                                    text: win.shell.name
                                    font.pixelSize: 18
                                    font.weight: Font.Bold
                                    color: tok.fg
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: win.shell.bio + "  <a href=\"" + win.shell.github + "\">" + win.repoLabel + "</a>"
                                    textFormat: Text.StyledText
                                    linkColor: tok.primary
                                    font.pixelSize: 12
                                    color: tok.fgVariant
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    lineHeight: 1.35
                                    onLinkActivated: link => Qt.openUrlExternally(link)
                                    HoverHandler {
                                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    }
                                }
                            }

                            ActionButton {
                                text: win.installer ? "View script" : "No script"
                                enabled: win.installer !== null
                                onClicked: win.viewScript()
                            }
                            ActionButton {
                                text: "Install"
                                enabled: win.installer !== null
                                onClicked: win.confirmInstall = true
                            }
                            Rectangle {
                                Layout.preferredWidth: 190
                                Layout.preferredHeight: 44
                                radius: tok.r3
                                color: win.busy ? tok.surfaceHigh : (actMouse.containsMouse ? "#a6dcfa" : tok.primary)
                                border.width: win.busy ? 1 : 0
                                border.color: tok.outlineVariant
                                scale: actMouse.pressed && !win.busy ? 0.96 : (actMouse.containsMouse && !win.busy ? 1.02 : 1.0)
                                clip: true

                                Behavior on color { ColorAnimation { duration: tok.animFast } }
                                Behavior on scale { NumberAnimation { duration: tok.animFast; easing.type: Easing.OutQuad } }

                                Text {
                                    anchors.centerIn: parent
                                    width: parent.width - tok.sp3 * 2
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    text: win.busy ? "Running..." : "Activate " + win.shell.name
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    color: win.busy ? tok.fgVariant : tok.fgOnPrimary
                                    Behavior on color { ColorAnimation { duration: tok.animFast } }
                                }
                                MouseArea {
                                    id: actMouse
                                    anchors.fill: parent
                                    enabled: !win.busy
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: win.activate()
                                }
                            }
                        }

                        // Features pills row
                        Flow {
                            Layout.fillWidth: true
                            spacing: tok.sp2
                            Repeater {
                                model: win.shell.features
                                Rectangle {
                                    width: ft.implicitWidth + tok.sp3 * 2
                                    height: 26
                                    radius: 13
                                    color: tok.surfaceHigh
                                    border.width: 1
                                    border.color: tok.outlineVariant
                                    Text {
                                        id: ft
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: tok.primary
                                    }
                                }
                            }
                        }

                        // Prerequisites bar
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: prereqRow.implicitHeight + tok.sp2 * 2
                            radius: tok.r2
                            color: tok.bg
                            border.width: 1
                            border.color: tok.outlineVariant
                            RowLayout {
                                id: prereqRow
                                anchors.fill: parent
                                anchors.margins: tok.sp2
                                spacing: tok.sp2
                                Rectangle {
                                    Layout.preferredWidth: prereqLabel.implicitWidth + tok.sp2 * 2
                                    Layout.preferredHeight: 20
                                    radius: 4
                                    color: tok.surfaceHigh
                                    Text {
                                        id: prereqLabel
                                        anchors.centerIn: parent
                                        text: "REQUIREMENTS"
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                        color: tok.tertiary
                                    }
                                }
                                Text {
                                    text: win.shell.prereqs
                                    font.pixelSize: 11
                                    color: tok.fgMuted
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }

        // ================= SETTINGS OVERLAY (ANIMATED) =================
        Rectangle {
            id: settingsOverlay
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.85)
            opacity: win.settingsOpen ? 1.0 : 0.0
            visible: opacity > 0.01
            z: 998
            focus: win.settingsOpen
            onVisibleChanged: if (win.settingsOpen) forceActiveFocus()
            Keys.onEscapePressed: win.settingsOpen = false
            Behavior on opacity { NumberAnimation { duration: tok.animMed; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                enabled: win.settingsOpen
                onClicked: win.settingsOpen = false
            }

            Rectangle {
                anchors.centerIn: parent
                width: 420
                height: settingsCol.implicitHeight + tok.sp5 * 2
                radius: tok.r4
                color: tok.surface
                border.width: 1
                border.color: tok.outlineVariant
                scale: win.settingsOpen ? 1.0 : 0.92
                clip: true
                Behavior on scale { NumberAnimation { duration: tok.animMed; easing.type: Easing.OutBack } }

                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    id: settingsCol
                    anchors.fill: parent
                    anchors.margins: tok.sp5
                    spacing: tok.sp4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: tok.sp2
                        Rectangle {
                            width: 8
                            height: 20
                            radius: 4
                            color: tok.primary
                        }
                        Text {
                            text: "\u2699  Settings"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            color: tok.fg
                            Layout.fillWidth: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: settingsMsgCol.implicitHeight + tok.sp4 * 2
                        radius: tok.r3
                        color: tok.bg
                        border.width: 1
                        border.color: tok.outlineVariant

                        ColumnLayout {
                            id: settingsMsgCol
                            anchors.fill: parent
                            anchors.margins: tok.sp4
                            spacing: tok.sp3

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: tok.sp2
                                Text {
                                    text: "Theme"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: tok.fg
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: tok.sp2
                                    Repeater {
                                        model: ["Dark", "Light"]
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 32
                                            radius: tok.r2
                                            color: (modelData === "Dark" && win.darkTheme) || (modelData === "Light" && !win.darkTheme) ? tok.primary : tok.surfaceHigh
                                            border.width: 1
                                            border.color: (modelData === "Dark" && win.darkTheme) || (modelData === "Light" && !win.darkTheme) ? tok.primary : tok.outlineVariant
                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: (modelData === "Dark" && win.darkTheme) || (modelData === "Light" && !win.darkTheme) ? tok.fgOnPrimary : tok.fgVariant
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    win.darkTheme = (modelData === "Dark")
                                                    tok.applyTheme(win.darkTheme)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: tok.sp2
                                Text {
                                    text: "Remember last shell"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: tok.fg
                                }
                                Text {
                                    text: "Restore the last selected shell on startup."
                                    font.pixelSize: 11
                                    color: tok.fgMuted
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 32
                                    radius: tok.r2
                                    color: win.rememberLastShell ? tok.primary : tok.surfaceHigh
                                    border.width: 1
                                    border.color: win.rememberLastShell ? tok.primary : tok.outlineVariant
                                    Text {
                                        anchors.centerIn: parent
                                        text: win.rememberLastShell ? "On" : "Off"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: win.rememberLastShell ? tok.fgOnPrimary : tok.fgVariant
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: win.rememberLastShell = !win.rememberLastShell
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: tok.sp2
                                Text {
                                    text: "Auto-revert timer"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: tok.fg
                                }
                                Text {
                                    text: "Automatically revert to your shell after activating."
                                    font.pixelSize: 11
                                    color: tok.fgMuted
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: tok.sp2
                                    Repeater {
                                        model: [0, 5, 10, 30]
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 32
                                            radius: tok.r2
                                            color: win.autoRevertMinutes === modelData ? tok.primary : tok.surfaceHigh
                                            border.width: 1
                                            border.color: win.autoRevertMinutes === modelData ? tok.primary : tok.outlineVariant
                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData === 0 ? "Off" : modelData + " min"
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: win.autoRevertMinutes === modelData ? tok.fgOnPrimary : tok.fgVariant
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: win.autoRevertMinutes = modelData
                                            }
                                        }
                                    }
                                }
                            }

                            // Check for updates
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: tok.sp2
                                Text {
                                    text: "Check for updates"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: tok.fg
                                }
                                Text {
                                    text: "Check if a newer version is available on GitHub."
                                    font.pixelSize: 11
                                    color: tok.fgMuted
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 32
                                    radius: tok.r2
                                    color: checkUpdateMouse.containsMouse ? tok.surfaceHigh : tok.bg
                                    border.width: 1
                                    border.color: checkUpdateMouse.containsMouse ? tok.primary : tok.outlineVariant
                                    Text {
                                        anchors.centerIn: parent
                                        text: win.busy ? "Checking..." : "Check updates"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: tok.fg
                                    }
                                    MouseArea {
                                        id: checkUpdateMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var repo = win.shell.github.replace("https://github.com/", "")
                                            var proc = Qt.createQmlObject('import Quickshell.Io; Process { stdout: StdioCollector { onStreamFinished: { win.statusText = text.trim() } } }', win)
                                            proc.command = ["bash", "-c", "curl -s https://api.github.com/repos/" + repo + " 2>/dev/null | python3 -c \"import json,sys; d=json.load(sys.stdin); print('Stars:', d.get('stargazers_count','?')); print('Last push:', str(d.get('pushed_at','?'))[:10])\""]
                                            proc.onExited = function(code) {
                                                win.busy = false
                                                if (code !== 0) win.statusText = "Update check failed."
                                            }
                                            win.busy = true
                                            win.statusText = "Checking updates for " + win.shell.name + "..."
                                            proc.running = true
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: tok.sp2
                                Text {
                                    text: "Image cache"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: tok.fg
                                }
                                Text {
                                    text: "Download all preview images for offline use."
                                    font.pixelSize: 11
                                    color: tok.fgMuted
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 32
                                    radius: tok.r2
                                    color: dlMouse.containsMouse ? tok.surfaceHigh : tok.bg
                                    border.width: 1
                                    border.color: dlMouse.containsMouse ? tok.primary : tok.outlineVariant
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Download images"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: tok.fg
                                    }
                                    MouseArea {
                                        id: dlMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var proc = Qt.createQmlObject('import Quickshell.Io; Process {}', win)
                                            proc.command = ["bash", "/home/warren/.config/quickshell/WorldOfShells/download-images.sh"]
                                            proc.running = true
                                            win.statusText = "Downloading images..."
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: aboutCol.implicitHeight + tok.sp3 * 2
                                radius: tok.r3
                                color: tok.bg
                                border.width: 1
                                border.color: tok.outlineVariant
                                ColumnLayout {
                                    id: aboutCol
                                    anchors.fill: parent
                                    anchors.margins: tok.sp3
                                    spacing: tok.sp1
                                    Text {
                                        text: "About"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: tok.fg
                                    }
                                    Text {
                                        text: "World of Shells v1.0"
                                        font.pixelSize: 11
                                        color: tok.fgVariant
                                    }
                                    Text {
                                        text: "A showcase app for trying Hyprland shells."
                                        font.pixelSize: 11
                                        color: tok.fgMuted
                                        wrapMode: Text.Wrap
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: "By lachaise97420 - MIT License"
                                        font.pixelSize: 10
                                        color: tok.fgMuted
                                    }
                                    Text {
                                        text: "github.com/lachaise97420/WorldOfShells"
                                        font.pixelSize: 10
                                        color: tok.primary
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Qt.openUrlExternally("https://github.com/lachaise97420/WorldOfShells")
                                        }
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: tok.sp3

                        Rectangle {
                            Layout.fillWidth: true
                            height: 38
                            radius: tok.r2
                            color: replayTutMouse.containsMouse ? tok.bg : tok.surfaceHigh
                            border.width: 1
                            border.color: replayTutMouse.containsMouse ? tok.primary : tok.outlineVariant
                            scale: replayTutMouse.pressed ? 0.96 : 1.0
                            Behavior on color { ColorAnimation { duration: tok.animFast } }
                            Behavior on border.color { ColorAnimation { duration: tok.animFast } }
                            Behavior on scale { NumberAnimation { duration: tok.animFast } }

                            Text {
                                anchors.centerIn: parent
                                text: "Replay the tutorial"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: tok.fgVariant
                            }
                            MouseArea {
                                id: replayTutMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    win.settingsOpen = false
                                    win.tutorialStep = 0
                                    win.tutorialOpen = true
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 38
                            radius: tok.r2
                            color: closeSetMouse.containsMouse ? "#a6dcfa" : tok.primary
                            scale: closeSetMouse.pressed ? 0.96 : 1.0
                            Behavior on color { ColorAnimation { duration: tok.animFast } }
                            Behavior on scale { NumberAnimation { duration: tok.animFast } }

                            Text {
                                anchors.centerIn: parent
                                text: "Close"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: tok.fgOnPrimary
                            }
                            MouseArea {
                                id: closeSetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: win.settingsOpen = false
                            }
                        }
                    }
                }
            }
        }

        // ================= INSTALL CONFIRMATION =================
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.85)
            opacity: win.confirmInstall ? 1.0 : 0.0
            visible: opacity > 0.01
            z: 1001
            focus: win.confirmInstall
            onVisibleChanged: if (win.confirmInstall) forceActiveFocus()
            Keys.onEscapePressed: win.confirmInstall = false
            Behavior on opacity { NumberAnimation { duration: tok.animMed; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                enabled: win.confirmInstall
                onClicked: win.confirmInstall = false
            }
            Rectangle {
                anchors.centerIn: parent
                width: 480
                height: installCol.implicitHeight + tok.sp5 * 2
                radius: tok.r4
                color: tok.surface
                border.width: 1
                border.color: tok.outlineVariant

                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    id: installCol
                    anchors.fill: parent
                    anchors.margins: tok.sp5
                    spacing: tok.sp3

                    Text {
                        text: "Install " + win.shell.name + "?"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: tok.fg
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    Text {
                        text: "Downloads " + win.repoLabel + " and runs its own installer in a terminal. It may install packages or change your Hyprland configuration."
                        font.pixelSize: 12
                        color: tok.fgVariant
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        lineHeight: 1.35
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: runText.implicitHeight + tok.sp2 * 2
                        radius: tok.r2
                        color: tok.bg
                        border.width: 1
                        border.color: tok.outlineVariant
                        Text {
                            id: runText
                            anchors.fill: parent
                            anchors.margins: tok.sp2
                            text: win.installer ? win.installer.run : ""
                            font.family: "monospace"
                            font.pixelSize: 11
                            color: tok.fg
                            wrapMode: Text.WrapAnywhere
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: tok.sp2
                        Item { Layout.fillWidth: true }
                        ActionButton {
                            text: "Cancel"
                            onClicked: win.confirmInstall = false
                        }
                        ActionButton {
                            text: "View script"
                            onClicked: { win.confirmInstall = false; win.viewScript() }
                        }
                        ActionButton {
                            text: "Install"
                            primary: true
                            onClicked: win.startInstall()
                        }
                    }
                }
            }
        }

        // ================= INSTALL SCRIPT VIEWER =================
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.85)
            opacity: win.scriptOpen ? 1.0 : 0.0
            visible: opacity > 0.01
            z: 1000
            focus: win.scriptOpen
            onVisibleChanged: if (win.scriptOpen) forceActiveFocus()
            Keys.onEscapePressed: win.scriptOpen = false
            Behavior on opacity { NumberAnimation { duration: tok.animMed; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                enabled: win.scriptOpen
                onClicked: win.scriptOpen = false
            }
            Rectangle {
                anchors.fill: parent
                anchors.margins: tok.sp6
                radius: tok.r4
                color: tok.surface
                border.width: 1
                border.color: tok.outlineVariant

                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: tok.sp4
                    spacing: tok.sp3

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: tok.sp2
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: win.shell.name + " install script"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: tok.fg
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            Text {
                                text: win.scriptStatus
                                font.pixelSize: 11
                                color: tok.fgMuted
                                Layout.fillWidth: true
                                elide: Text.ElideMiddle
                            }
                        }
                        ActionButton {
                            text: "Close"
                            onClicked: win.scriptOpen = false
                        }
                        ActionButton {
                            text: "Install"
                            primary: true
                            onClicked: { win.scriptOpen = false; win.confirmInstall = true }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: tok.r2
                        color: tok.bg
                        border.width: 1
                        border.color: tok.outlineVariant
                        clip: true
                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: tok.sp2
                            TextArea {
                                objectName: "script-text"
                                readOnly: true
                                selectByMouse: true
                                text: win.scriptText
                                textFormat: TextEdit.PlainText
                                font.family: "monospace"
                                font.pixelSize: 12
                                color: tok.fg
                                background: null
                            }
                        }
                    }
                }
            }
        }

        // ================= END-4 CONFIRMATION OVERLAY (ANIMATED) =================
        Rectangle {
            id: end4Overlay
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.85)
            opacity: win.confirmEnd4 ? 1.0 : 0.0
            visible: opacity > 0.01
            z: 999
            Behavior on opacity { NumberAnimation { duration: tok.animMed; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                enabled: win.confirmEnd4
                onClicked: win.cancelEnd4Activate()
            }
            Rectangle {
                anchors.centerIn: parent
                width: 440
                height: confirmCol.implicitHeight + tok.sp5 * 2
                radius: tok.r4
                color: tok.surface
                border.width: 1
                border.color: tok.outlineVariant
                scale: win.confirmEnd4 ? 1.0 : 0.92
                Behavior on scale { NumberAnimation { duration: tok.animMed; easing.type: Easing.OutBack } }

                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    id: confirmCol
                    anchors.fill: parent
                    anchors.margins: tok.sp5
                    spacing: tok.sp4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: tok.sp2
                        Rectangle {
                            width: 10
                            height: 22
                            radius: 5
                            color: tok.primary
                        }
                        Text {
                            text: "Install end-4 (illogical-impulse)?"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            color: tok.fg
                            Layout.fillWidth: true
                        }
                    }

                    Text {
                        text: "end-4 (illogical-impulse) is a complete set of dotfiles that will replace your Hyprland and Quickshell configuration. A backup of your current configuration is created automatically before installing."
                        font.pixelSize: 13
                        color: tok.fgVariant
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        lineHeight: 1.4
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: termNote.implicitHeight + tok.sp3 * 2
                        radius: tok.r2
                        color: tok.bg
                        border.width: 1
                        border.color: tok.outlineVariant
                        Text {
                            id: termNote
                            anchors.fill: parent
                            anchors.margins: tok.sp3
                            text: "The interactive installer opens in a separate terminal. Follow the instructions on screen."
                            font.pixelSize: 12
                            color: tok.fgMuted
                            wrapMode: Text.Wrap
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: tok.sp3
                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            radius: tok.r2
                            color: cancelBtnMouse.containsMouse ? tok.bg : tok.surfaceHigh
                            border.width: 1
                            border.color: tok.outlineVariant
                            scale: cancelBtnMouse.pressed ? 0.96 : 1.0
                            Behavior on color { ColorAnimation { duration: tok.animFast } }
                            Behavior on scale { NumberAnimation { duration: tok.animFast } }

                            Text {
                                anchors.centerIn: parent
                                text: "Cancel"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: tok.fg
                            }
                            MouseArea {
                                id: cancelBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: win.cancelEnd4Activate()
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            radius: tok.r2
                            color: confirmBtnMouse.containsMouse ? "#a6dcfa" : tok.primary
                            scale: confirmBtnMouse.pressed ? 0.96 : 1.0
                            Behavior on color { ColorAnimation { duration: tok.animFast } }
                            Behavior on scale { NumberAnimation { duration: tok.animFast } }

                            Text {
                                anchors.centerIn: parent
                                text: "Back up & Install"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: tok.fgOnPrimary
                            }
                            MouseArea {
                                id: confirmBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: win.confirmEnd4Activate()
                            }
                        }
                    }
                }
            }
        }

        // ================= LIGHTBOX OVERLAY (ANIMATED) =================
        Rectangle {
            id: lightboxOverlay
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.92)
            opacity: win.lightboxOpen ? 1.0 : 0.0
            visible: opacity > 0.01
            z: 1000
            focus: win.lightboxOpen
            onVisibleChanged: if (win.lightboxOpen) forceActiveFocus()
            Keys.onEscapePressed: win.closeLightbox()
            Keys.onLeftPressed: win.lightboxPrev()
            Keys.onRightPressed: win.lightboxNext()
            Behavior on opacity { NumberAnimation { duration: tok.animMed; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                enabled: win.lightboxOpen
                onClicked: win.closeLightbox()
            }

            Item {
                id: lbContainer
                anchors.centerIn: parent
                width: parent.width * 0.92
                height: parent.height * 0.88
                scale: win.lightboxOpen ? 1.0 : 0.95
                Behavior on scale { NumberAnimation { duration: tok.animMed; easing.type: Easing.OutCubic } }

                Image {
                    id: lbImage
                    x: (lbContainer.width - width) / 2 + win.lightboxPanX
                    y: (lbContainer.height - height) / 2 + win.lightboxPanY
                    width: lbContainer.width
                    height: lbContainer.height
                    source: win.lightboxSource
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(1920, 1080)
                    asynchronous: true
                    cache: true
                    opacity: status === Image.Ready ? 1.0 : 0.0
                    scale: win.lightboxZoom
                    transformOrigin: Item.Center
                    Behavior on opacity { NumberAnimation { duration: tok.animMed } }
                }

                MouseArea {
                    id: lbMouse
                    anchors.fill: parent
                    enabled: win.lightboxOpen
                    acceptedButtons: Qt.LeftButton
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    property real lastX: 0
                    property real lastY: 0
                    onWheel: (wheel) => {
                        var factor = wheel.angleDelta.y > 0 ? 1.15 : 1 / 1.15
                        var newZoom = Math.max(0.5, Math.min(6.0, win.lightboxZoom * factor))
                        if (Math.abs(newZoom - 1.0) < 0.05) {
                            newZoom = 1.0
                            win.lightboxPanX = 0
                            win.lightboxPanY = 0
                        }
                        win.lightboxZoom = newZoom
                    }
                    onPressed: (mouse) => { lastX = mouse.x; lastY = mouse.y }
                    onPositionChanged: (mouse) => {
                        win.lightboxPanX += mouse.x - lastX
                        win.lightboxPanY += mouse.y - lastY
                        lastX = mouse.x
                        lastY = mouse.y
                    }
                    onDoubleClicked: {
                        win.lightboxZoom = 1.0
                        win.lightboxPanX = 0
                        win.lightboxPanY = 0
                    }
                }
            }

            // Prev button (left)
            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: tok.sp4
                width: 44
                height: 44
                radius: 22
                color: prevLbMouse.containsMouse ? tok.primary : Qt.rgba(0, 0, 0, 0.6)
                border.width: 1
                border.color: tok.outlineVariant
                visible: win.lightboxIndex > 0
                Text {
                    anchors.centerIn: parent
                    text: "\u25C0"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: prevLbMouse.containsMouse ? tok.fgOnPrimary : tok.fg
                }
                MouseArea {
                    id: prevLbMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: win.lightboxPrev()
                }
            }

            // Next button (right)
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: tok.sp4
                width: 44
                height: 44
                radius: 22
                color: nextLbMouse.containsMouse ? tok.primary : Qt.rgba(0, 0, 0, 0.6)
                border.width: 1
                border.color: tok.outlineVariant
                visible: win.lightboxIndex < win.lightboxImages.length - 1
                Text {
                    anchors.centerIn: parent
                    text: "\u25B6"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: nextLbMouse.containsMouse ? tok.fgOnPrimary : tok.fg
                }
                MouseArea {
                    id: nextLbMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: win.lightboxNext()
                }
            }

            // Close button (top-right)
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: tok.sp4
                width: 42
                height: 42
                radius: 21
                color: closeLbMouse.containsMouse ? tok.primary : tok.surfaceHigh
                border.width: 1
                border.color: tok.outlineVariant
                scale: closeLbMouse.pressed ? 0.92 : (closeLbMouse.containsMouse ? 1.06 : 1.0)
                Behavior on color { ColorAnimation { duration: tok.animFast } }
                Behavior on scale { NumberAnimation { duration: tok.animFast; easing.type: Easing.OutQuad } }

                Text {
                    anchors.centerIn: parent
                    text: "\u00D7"
                    font.pixelSize: 22
                    font.weight: Font.Bold
                    color: closeLbMouse.containsMouse ? tok.fgOnPrimary : tok.fg
                }
                MouseArea {
                    id: closeLbMouse
                    anchors.fill: parent
                    enabled: win.lightboxOpen
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: win.closeLightbox()
                }
            }

            // Bottom floating HUD bar
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: tok.sp4
                width: lbHelpRow.implicitWidth + tok.sp4 * 2
                height: 34
                radius: 17
                color: tok.surface
                border.width: 1
                border.color: tok.outlineVariant

                RowLayout {
                    id: lbHelpRow
                    anchors.centerIn: parent
                    spacing: tok.sp3
                    Text {
                        text: "Image " + (win.lightboxIndex + 1) + " / " + win.lightboxImages.length
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: tok.primary
                    }
                    Text {
                        text: "|"
                        font.pixelSize: 11
                        color: tok.fgMuted
                    }
                    Text {
                        text: "Zoom: " + Math.round(win.lightboxZoom * 100) + "%"
                        font.pixelSize: 11
                        color: tok.fgVariant
                    }
                    Text {
                        text: "|   Scroll: zoom   |   Drag: move   |   Double-click: reset   |   Esc: close"
                        font.pixelSize: 11
                        color: tok.fgVariant
                    }
                }
            }
        }

        // ================= INTERACTIVE TUTORIAL OVERLAY (7 STEPS, ANIMATED) =================
        Rectangle {
            id: tutorialOverlay
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.88)
            opacity: win.tutorialOpen ? 1.0 : 0.0
            visible: opacity > 0.01
            z: 1001
            focus: win.tutorialOpen
            onVisibleChanged: if (win.tutorialOpen) forceActiveFocus()
            Keys.onEscapePressed: win.completeTutorial()
            Keys.onRightPressed: win.goToTutorialStep(win.tutorialStep + 1)
            Keys.onLeftPressed: win.goToTutorialStep(win.tutorialStep - 1)
            Behavior on opacity { NumberAnimation { duration: tok.animSlow; easing.type: Easing.OutCubic } }

            // Directional step transition animation
            ParallelAnimation {
                id: tutStepAnim
                NumberAnimation {
                    target: tutStepBody
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 210
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: tutStepTrans
                    property: "x"
                    from: win.tutorialDirection * 24
                    to: 0
                    duration: 230
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: tutIconBadge
                    property: "scale"
                    from: 0.75
                    to: 1.0
                    duration: 260
                    easing.type: Easing.OutBack
                }
            }

            // Block background clicks from leaking through
            MouseArea {
                anchors.fill: parent
                enabled: win.tutorialOpen
            }

            Rectangle {
                id: tutCard
                anchors.centerIn: parent
                width: Math.min(560, parent.width - tok.sp6 * 2)
                height: tutCardCol.implicitHeight + tok.sp5 * 2
                radius: tok.r4
                color: tok.surface
                border.width: 1
                border.color: tok.primary
                scale: win.tutorialOpen ? 1.0 : 0.92
                clip: true

                Behavior on scale { NumberAnimation { duration: tok.animSlow; easing.type: Easing.OutBack } }
                Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                // Top animated progress bar
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    height: 3
                    width: parent.width * ((win.tutorialStep + 1) / tutorialSteps.length)
                    color: win.tutorialStep === tutorialSteps.length - 1 ? tok.tertiary : tok.primary
                    Behavior on width { NumberAnimation { duration: tok.animMed; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: tok.animMed } }
                }

                ColumnLayout {
                    id: tutCardCol
                    anchors.fill: parent
                    anchors.margins: tok.sp5
                    spacing: tok.sp4

                    // Top bar: Step icon + badge + Skip button
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: tok.sp2

                        Rectangle {
                            id: tutIconBadge
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 10
                            color: tok.surfaceHigh
                            border.width: 1
                            border.color: tok.primary
                            Text {
                                anchors.centerIn: parent
                                text: tutorialSteps[win.tutorialStep].icon
                                font.pixelSize: 15
                                font.weight: Font.Bold
                                color: tok.primary
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: stepBadgeText.implicitWidth + tok.sp3 * 2
                            Layout.preferredHeight: 24
                            radius: 12
                            color: tok.surfaceHigh
                            border.width: 1
                            border.color: tok.outlineVariant
                            Behavior on Layout.preferredWidth { NumberAnimation { duration: tok.animFast; easing.type: Easing.OutCubic } }

                            Text {
                                id: stepBadgeText
                                anchors.centerIn: parent
                                text: tutorialSteps[win.tutorialStep].badge
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: tok.primary
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            Layout.preferredWidth: skipBtnText.implicitWidth + tok.sp3 * 2
                            Layout.preferredHeight: 26
                            radius: tok.r2
                            color: skipMouse.containsMouse ? tok.surfaceHigh : "transparent"
                            border.width: 1
                            border.color: skipMouse.containsMouse ? tok.outline : tok.outlineVariant
                            scale: skipMouse.pressed ? 0.95 : 1.0
                            Behavior on color { ColorAnimation { duration: tok.animFast } }
                            Behavior on border.color { ColorAnimation { duration: tok.animFast } }
                            Behavior on scale { NumberAnimation { duration: tok.animFast } }

                            Text {
                                id: skipBtnText
                                anchors.centerIn: parent
                                text: "Skip the tutorial"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: skipMouse.containsMouse ? tok.fg : tok.fgMuted
                                Behavior on color { ColorAnimation { duration: tok.animFast } }
                            }
                            MouseArea {
                                id: skipMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: win.completeTutorial()
                            }
                        }
                    }

                    // Animated Step Content Body
                    ColumnLayout {
                        id: tutStepBody
                        Layout.fillWidth: true
                        spacing: tok.sp3
                        transform: Translate { id: tutStepTrans; x: 0 }

                        // Step Title
                        Text {
                            text: tutorialSteps[win.tutorialStep].title
                            font.pixelSize: 22
                            font.weight: Font.Bold
                            color: tok.fg
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

                        // Step Description
                        Text {
                            text: tutorialSteps[win.tutorialStep].desc
                            font.pixelSize: 14
                            color: tok.fgVariant
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            lineHeight: 1.45
                        }

                        // Step Hint Box
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: tutHintRow.implicitHeight + tok.sp3 * 2
                            radius: tok.r3
                            color: tok.bg
                            border.width: 1
                            border.color: tok.outlineVariant

                            RowLayout {
                                id: tutHintRow
                                anchors.fill: parent
                                anchors.margins: tok.sp3
                                spacing: tok.sp3

                                Rectangle {
                                    width: 6
                                    height: 28
                                    radius: 3
                                    color: tok.tertiary
                                }

                                Text {
                                    text: tutorialSteps[win.tutorialStep].hint
                                    font.pixelSize: 12
                                    color: tok.fgMuted
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    lineHeight: 1.35
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: tok.outlineVariant
                        opacity: 0.5
                    }

                    // Bottom bar: Animated Progress dots + Previous / Next / Finish buttons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: tok.sp3

                        // Progress dots
                        RowLayout {
                            spacing: 6
                            Repeater {
                                model: tutorialSteps.length
                                Rectangle {
                                    property bool active: index === win.tutorialStep
                                    property bool passed: index < win.tutorialStep
                                    width: active ? 24 : 8
                                    height: 8
                                    radius: 4
                                    color: active ? tok.primary : (passed ? tok.tertiary : tok.surfaceHigh)
                                    border.width: active ? 0 : 1
                                    border.color: tok.outlineVariant
                                    scale: dotMouse.containsMouse && !active ? 1.25 : 1.0

                                    Behavior on width { NumberAnimation { duration: tok.animMed; easing.type: Easing.OutBack } }
                                    Behavior on color { ColorAnimation { duration: tok.animFast } }
                                    Behavior on scale { NumberAnimation { duration: tok.animFast } }

                                    MouseArea {
                                        id: dotMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: win.goToTutorialStep(index)
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Previous button
                        Rectangle {
                            property bool canPrev: win.tutorialStep > 0
                            Layout.preferredWidth: 110
                            Layout.preferredHeight: 38
                            radius: tok.r2
                            color: prevTutMouse.containsMouse && canPrev ? tok.bg : tok.surfaceHigh
                            border.width: 1
                            border.color: prevTutMouse.containsMouse && canPrev ? tok.outline : tok.outlineVariant
                            opacity: canPrev ? 1.0 : 0.4
                            scale: prevTutMouse.pressed && canPrev ? 0.96 : 1.0

                            Behavior on color { ColorAnimation { duration: tok.animFast } }
                            Behavior on border.color { ColorAnimation { duration: tok.animFast } }
                            Behavior on opacity { NumberAnimation { duration: tok.animFast } }
                            Behavior on scale { NumberAnimation { duration: tok.animFast } }

                            Text {
                                anchors.centerIn: parent
                                text: "Previous"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: tok.fg
                            }
                            MouseArea {
                                id: prevTutMouse
                                anchors.fill: parent
                                enabled: win.tutorialStep > 0
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: win.goToTutorialStep(win.tutorialStep - 1)
                            }
                        }

                        // Suivant / Terminer button
                        Rectangle {
                            readonly property bool isLastStep: win.tutorialStep === tutorialSteps.length - 1
                            Layout.preferredWidth: 130
                            Layout.preferredHeight: 38
                            radius: tok.r2
                            color: nextTutMouse.containsMouse ? "#a6dcfa" : (isLastStep ? tok.tertiary : tok.primary)
                            scale: nextTutMouse.pressed ? 0.96 : (nextTutMouse.containsMouse ? 1.02 : 1.0)

                            Behavior on color { ColorAnimation { duration: tok.animFast } }
                            Behavior on scale { NumberAnimation { duration: tok.animFast; easing.type: Easing.OutQuad } }

                            Text {
                                anchors.centerIn: parent
                                text: parent.isLastStep ? "Finish" : "Next"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: tok.fgOnPrimary
                            }
                            MouseArea {
                                id: nextTutMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (win.tutorialStep < tutorialSteps.length - 1) {
                                        win.goToTutorialStep(win.tutorialStep + 1)
                                    } else {
                                        win.completeTutorial()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
