# Changelog

All notable changes to World of Shells will be documented in this file.

## [1.0.0] - 2026-11-02

### Added
- **14 shells** supported: MacShell, end-4 (illogical-impulse), DankMaterialShell (DMS), Nucleus Shell, Nandoroid, SekaiPop, Twinshell, QSDots, Asaki Shell, MaterialUI, Vantage, Ukishima, Lucid, Nothingshell
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