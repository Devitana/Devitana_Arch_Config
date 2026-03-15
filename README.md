# Devitana Arch Config

Personal Arch Linux Waybar configuration with custom scripts and styling.

## Features

- **Waybar Status Bar** - Customized for Wayland environments
- **Custom Scripts** - Weather, system updates, system monitoring
- **Modular Design** - Easy to customize and extend
- **Glass Morphism UI** - Modern visual design

## Quick Start

```bash
git clone https://github.com/Devitana/Devitana_Arch_Config.git
cd Devitana_Arch_Config
chmod +x install.sh
./install.sh
```

The script will:
- Install core Waybar dependencies
- Copy config to `~/.config/waybar`
- Make scripts executable

## Core Dependencies

- **waybar** - Status bar
- **ttf-font-awesome** - Icons
- **noto-fonts** - Font support
- **jq** - JSON processor (for scripts)
- **playerctl** - Media controls
- **grim**, **slurp** - Screenshot tools
- **wl-clipboard** - Clipboard management

## Optional Packages

```bash
sudo pacman -S btop yay pavucontrol figlet
```

- **btop** - System monitor
- **yay** - AUR helper (for updates)
- **pavucontrol** - Audio control
- **figlet** - ASCII text art

## File Manager / Browser

Waybar has built-in launchers for:
- **Firefox** (or Chromium/Vivaldi)
- **File Manager** (nautilus/krusader)
- **ChatGPT** quick link

You can customize these in `~/.config/waybar/config.jsonc`:

```jsonc
"custom/firefox": {
  "on-click": "firefox",           // Your preferred browser
  "tooltip": false
},
"custom/files": {
  "on-click": "nautilus",          // Your preferred file manager
  "tooltip": false
}
```

## Customization

### Weather Location

Edit `~/.config/waybar/scripts/weather.sh`:
```bash
LOCATION="Memmingen"  # Change to your city
```

Or use environment variable:
```bash
export WEATHER_LOCATION="Berlin"
```

### Colors & Styling

Edit `~/.config/waybar/style.css` for colors and layout.

Edit `~/.config/waybar/config.jsonc` for module configuration.

## Scripts

| Script | Purpose |
|--------|---------|
| `weather.sh` | Display current weather with forecast |
| `updates.sh` | Check for system updates |
| `installupdates.sh` | Install all updates (pacman/AUR/flatpak) |
| `system-monitor.sh` | Open system monitor in terminal |

## Troubleshooting

**Weather not working:**
- Check internet connection
- Verify `jq` is installed: `pacman -Q jq`

**Icons not displaying:**
- Install fonts: `sudo pacman -S ttf-font-awesome noto-fonts`
- Rebuild font cache: `fc-cache -fv`

**Scripts not running:**
- Make executable: `chmod +x ~/.config/waybar/scripts/*.sh`

## System Requirements

- Arch Linux or Arch-based distro
- Wayland environment (Sway, Hyprland, etc.)
- Bash shell

## License

No license specified. Free to use and modify.

## Author

**Devitana** - [GitHub](https://github.com/Devitana)