# Devitana Arch Config

Personal Arch Linux Hyprland + Waybar configuration with custom scripts and styling.

This is my first Linux project after moving from Windows. I built it over a few months with nightly progress and AI assistance. Feedback is always welcome.

## Preview

![waybar](screenshots/2026-03-15_23-14.png)
![waybar](screenshots/2026-03-15_23-00.png)

## Features

- **Hyprland desktop** with modular split config files
- **Waybar setup** with custom weather, update, keyboard, and power modules
- **Installer script** with GPU detection and service setup
- **Dry-run mode** to preview installer actions safely
- **Automatic backup** of replaced configs and dotfiles

## Quick Start

### Normal install

```bash
git clone https://github.com/Devitana/Devitana_Arch_Config.git
cd Devitana_Arch_Config
bash install.sh
```

### Dry-run (preview only)

```bash
git clone https://github.com/Devitana/Devitana_Arch_Config.git
cd Devitana_Arch_Config
bash install.sh --dry-run
```

### What gets installed/copied

- Installs core packages (`hyprland`, `waybar`, `kitty`, `jq`, `playerctl`, `python`, `python-requests`, PipeWire stack, etc.)
- Detects GPU and installs matching drivers (AMD/NVIDIA/Intel)
- Copies configs to `~/.config/hypr`, `~/.config/kitty`, and `~/.config/waybar`
- Copies repo `.bashrc` to `~/.bashrc`
- Backs up replaced files to `~/.config-backup-<timestamp>/`
- Enables services: `NetworkManager`, `bluetooth`, `seatd`

## Customization

### Browser / file manager launcher buttons

Edit `~/.config/waybar/config.jsonc`:

```jsonc
"custom/firefox": {
  "on-click": "firefox",
  "tooltip": false
},
"custom/files": {
  "on-click": "nautilus",
  "tooltip": false
}
```

### Colors and layout

- Edit `~/.config/waybar/style.css`
- Edit `~/.config/waybar/config.jsonc`

### Weather module

`waybar/scripts/weather.sh` uses Open-Meteo and supports:

- `LAT` and `LON` environment variables
- Cache settings via `WEATHER_CACHE_TIME`

## Waybar Scripts

| File | Purpose |
|------|---------|
| `weather.sh` | Current weather + forecast tooltip |
| `updates.sh` | Counts available pacman/AUR/flatpak updates |
| `installupdates.sh` | Interactive updater for pacman/AUR/flatpak |
| `kb.sh` | Keyboard layout + caps/num lock status |

## Troubleshooting

**Weather not working**

- Check internet connection
- Check Python requests: `python -c "import requests; print(requests.__version__)"`

**Keyboard module not showing layout**

- Verify `jq`: `pacman -Q jq`

**Media keys not working**

- Verify `playerctl`: `pacman -Q playerctl`

**Scripts not running**

```bash
chmod +x ~/.config/waybar/scripts/*.sh
```

## System Requirements

- Arch Linux or Arch-based distro
- Hyprland session
- Bash shell

## License

MIT License. See `LICENSE`.

## Author

**Devitana** - [GitHub](https://github.com/Devitana)
