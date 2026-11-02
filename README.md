# World of Shells

![Preview](preview.png)


## Disclaimer

**This project is highly experimental.** I am not a developer — just someone in their room with a PC and internet access. This app is a showcase/vitrine for trying different Hyprland shells. Activating a shell may modify your system configuration. Always ensure you have backups of your Hyprland and Quickshell configs before trying a shell. I am not responsible for any damage to your system configuration.

Some shells (like end-4) perform full dotfiles installations that may overwrite your existing configuration. Use at your own risk.

A showcase app for trying different Hyprland shells. Built with Quickshell.

## Installation

```bash
bash install.sh
```

Or manually:
```bash
cp -r WorldOfShells-standalone ~/.config/quickshell/WorldOfShells
chmod +x ~/.config/quickshell/WorldOfShells/*.sh
```

## Usage

```bash
qs -c WorldOfShells
```

Or find "World of Shells" in your app launcher.

## Shells included (14)

| Shell | Stars | License | Activation |
|-------|-------|---------|------------|
| MacShell | 328 | MIT | Start qs -c MacShell |
| end-4 (illogical-impulse) | 16.5k | GPL-3.0 | Full dotfiles install (confirmation required) |
| DankMaterialShell (DMS) | 8.7k | MIT | Start dms run |
| Nucleus Shell | 721 | GPL-3.0 | Start qs -c nucleus-shell |
| Nandoroid | 179 | AGPL-3.0 | Start qs -c nandoroid |
| SekaiPop | 526 | GPL-3.0 | Start qs -c sekaipop |
| Twinshell | 5 | GPL-3.0 | Start qs -c twinshell |
| QSDots | 5 | MIT | Start qs -c qsdots |
| Asaki Shell | 0 | Unknown | Start qs -c asaki |
| MaterialUI | 0 | MIT | Start qs -c materialui |
| Vantage | 24 | MIT | Start qs -c vantage |
| Ukishima | 119 | MIT | Start qs -c ukishima |
| Lucid | 322 | MIT | Start qs -c lucid |
| Nothingshell | 26 | MIT | Start qs -c nothingshell |

## Features
- Browse 14 shells with screenshots
- Click "Activer" to try a shell (stops current, starts new one)
- Click "Revenir" to restore your previous shell
- Image lightbox with zoom/pan
- Matugen-friendly (reads colors from ~/.cache/ryoku/colors.json if available)
- Settings button (placeholder)

## Requirements
- Hyprland 0.55+
- Quickshell 0.3.0+
- Qt 6.5+
- qsb (qt6-shadertools)



## Contributing

Want to add a shell? See [CONTRIBUTING.md](CONTRIBUTING.md) for a step-by-step guide.

## License
MIT

## Disclaimer

**This project is highly experimental.** It is a showcase/vitrine application for trying different Hyprland shells. Activating a shell may modify your system configuration. Always ensure you have backups of your Hyprland and Quickshell configs before trying a shell. The authors are not responsible for any damage to your system configuration.

Some shells (like end-4) perform full dotfiles installations that may overwrite your existing configuration. Use at your own risk.
