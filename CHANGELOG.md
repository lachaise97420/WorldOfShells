# Changelog

All notable changes to World of Shells will be documented in this file.

## [1.4.0] - 2026-11-03

### Added
- **Adaptive colors**: app reads colors from multiple sources (ryoku, wal, matugen, nucleus, etc.) and applies them automatically
- **Custom colors file path** in Settings for universal matugen compatibility
- **applyColors** now supports 3 formats: matugen/ryoku, MaterialUI, Pywal
- **5 color presets** in Settings: Ryoku, Ocean, Forest, Sunset, Monochrome
- **Emergency revert button**: red button always visible when a shell is active, bypasses busy state
- **Crash detection**: monitors active shell process every 5s, auto-reverts if crashed
- **Usage timer**: shows elapsed time (M:SS) next to ACTIVE badge
- **Transition animation on Revert**: transition now plays on revert too
- **Transition style selector**: Sobre, Dynamic, or None (disable)
- **Preview buttons** in Settings to preview transition styles

### Changed
- Renamed "Gemini" transition to "Dynamic"
- Color sources expanded to 8 paths for universal compatibility

## [1.3.0] - 2026-11-03

### Changed
- Transition animation now also plays on Revert (status: "Reverting to Ryoku...")
- Added transitionStyle property and previewTransition function

### Added
- Transition style selector in Settings: choose between Sobre (minimalist), Dynamic (rich effects), or None (disabled)
- Preview buttons for Sobre and Dynamic styles
- No transition animation option for users who prefer instant switching
- **Transition style selector** in Settings: choose between "Sobre" (minimalist monochrome) and "Gemini" (rich Matugen effects)
- **Preview buttons** in Settings to preview each transition style without activating a shell
- Both transition overlays coexist; only the selected one is shown
-  property (0 = Sobre, 1 = Gemini) controls which overlay is active

## [1.3.0] - 2026-11-03

### Added
- Transition style selector in Settings: choose between Sobre (minimalist monochrome) and Gemini (rich Matugen effects)
- Preview buttons in Settings to preview each transition style without activating a shell
- Both transition overlays coexist; only the selected one is shown

## [1.2.0] - 2026-11-03

### Changed
- **Transition overlay completely rewritten** with Gemini improvements:
  - Canvas-based animated orbit (3.2s sweep, comet trail, Matugen primary glow)
  - Progressive center-out reveal of the logo
  - 9 floating particles with drift, scatter on exit (disintegration effect)
  - 4-point star pulse animation (wosStarPulse)
  - Inner star pulse in the O disc cutout
  - Shockwave ring on entry/exit
  - Multi-layered pulsing glow (white + Matugen primary)
  - Progress bar (2.5s sweep) + 3 pulsing dots
  - Flanking lines that grow with reveal progress
  - All animations driven by Canvas requestPaint for 60fps

## [1.1.0] - 2026-11-03

### Added
- **Fullscreen transition overlay** with animated World of Shells logo when activating a shell
- Logo breathe animation (scale 0.996 ↔ 1.004), subtle rotation, glow pulse
- Loading indicator dots and activating status text
- Main content fades to 30% opacity during transition
- Transition duration: 2.5 seconds

### Changed
- 20 shells total (added CuteShell, Minflair, Tripathi Quickshell)

## [1.0.0] - 2026-11-02

### Added
- **20 shells** supported: MacShell, end-4 (illogical-impulse), DankMaterialShell (DMS), Nucleus Shell, Nandoroid, SekaiPop, Twinshell, QSDots, Asaki Shell, MaterialUI, Vantage, Ukishima, Lucid, Nothingshell
- **Shell selector** with pagination (4 shells per page, Prev/Next navigation)
- **Activate/Revert** system: try any shell with one click, revert to your previous shell anytime
- **Image gallery** with lightbox (zoom via mouse wheel, pan via drag, reset via double-click, close via Escape)
- **Lightbox navigation** with Prev/Next buttons and image counter
- **Settings panel** with:
  - Theme toggle (Dark/Light)
  - Auto-revert timer (Off/5min/10min/30min)
  - Remember last shell (restore selection on startup)
  - Download all preview images for offline use
  - Check for updates (GitHub stars + last push date)
  - Window size/position persistence
  - About section (version, author, license, GitHub link)
- **Keyboard shortcuts**: ↑/↓ navigate shells, Enter activate, Esc revert/close, ←/→ navigate lightbox images
- **Active shell indicator**: green "ACTIVE" badge on the running shell's card
- **Matugen-friendly**: reads colors from `~/.cache/ryoku/colors.json` for dynamic theming
- **Image optimization**: sourceSize limits, async loading, cache, fade-in, loading placeholders
- **End-4 confirmation dialog**: warning before full dotfiles installation with automatic backup
- **Demo video links** for shells that have them (end-4)
- **CONTRIBUTING.md**: guide for adding new shells to the app
- **Preview image** in README

### Changed
- All UI text in English
- Instant interactions (no animations, 0ms transitions)
- Clean two-pane layout (left panel 300px, right panel fills remaining space)
- No scrollbars in the main layout

### Fixed
- Text overflow in all panels
- Layout breaking when switching shells
- Process exit detection (using `disown` and `</dev/null` for proper detachment)
- All shells killed before activating/reverting (no persistent elements)

### Security
- All activate/revert scripts kill all shells before running
- End-4 creates automatic backup before installation
- Disclaimer in README and GitHub description

## [0.1.0] - Initial Release

### Added
- MacShell and end-4 shells
- Basic two-pane layout
- Activate/revert functionality
- Image gallery with lightbox
- GitHub integration