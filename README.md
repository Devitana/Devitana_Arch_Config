# Devitana Arch Config

Personal Arch Linux Hyprland + Waybar configuration with custom scripts and styling.

This is my first Linux project after moving from Windows. I built it over a few months with nightly progress and AI assistance. Feedback is always welcome.

## Preview

![waybar](screenshots/2026-03-15_23-14.png)
![waybar](screenshots/2026-03-15_23-00.png)

## Features

- **Hyprland desktop** with modular split config files authored in Lua and generated as `.conf`
- **Waybar setup** with custom weather, update, keyboard, and power modules
- **Installer script** with GPU detection, service setup, and auto-generated `current_gpu.conf`
- **Dry-run mode** to preview installer actions safely
- **Automatic backup** of replaced configs and dotfiles

## Hyprland Config: Lua Source Files

All Hyprland configuration is **authored in Lua** and **generated as `.conf` files**.  
Do **not** hand-edit the `.conf` files directly – edit the Lua sources and regenerate.

### Directory layout

```
hypr/
├── generate.sh          ← convenience wrapper (auto-selects lua or python3)
├── lua/
│   ├── generate.lua     ← Lua generator (preferred on Arch where lua is installed)
│   ├── generate.py      ← Python 3 fallback generator (portable / CI use)
│   ├── hyprland.lua     ← top-level include list
│   ├── programs.lua     ← $terminal, $fileManager, $menu
│   ├── startup.lua      ← exec-once autostart commands
│   ├── env.lua          ← core Wayland environment variables
│   ├── gpu_amd.lua      ← AMD GPU env vars
│   ├── gpu_intel.lua    ← Intel GPU env vars
│   ├── gpu_nvidia.lua   ← NVIDIA GPU env vars
│   ├── gpu_generic.lua  ← Generic GPU env vars
│   ├── monitors.lua     ← monitor layout
│   ├── waybar.lua       ← Waybar layer rules
│   ├── windows.lua      ← general / decoration / animations / dwindle / misc
│   ├── workspaces.lua   ← window rules and workspace rules
│   ├── layout.lua       ← keyboard / mouse / touchpad / gestures
│   ├── keybindings.lua  ← all keybinds
│   ├── permissions.lua  ← Hyprland permission rules
│   ├── hypridle.lua     ← screen-idle / DPMS config
│   ├── hyprlock.lua     ← lock-screen appearance
│   ├── hyprlauncher.lua ← launcher config
│   └── hyprtoolkit.lua  ← toolkit theme
└── **/*.conf            ← AUTO-GENERATED – do not hand-edit
```

### Regenerating configs

```bash
# From the repo root – prefers lua, falls back to python3:
bash hypr/generate.sh

# Or directly with Lua (Arch: pacman -S lua):
cd hypr/lua && lua generate.lua

# Or directly with Python 3 (any system):
cd hypr/lua && python3 generate.py
```

### Checking for drift

```bash
# Exits 0 if .conf files match sources, 1 if any are stale:
bash hypr/generate.sh --check
```

### Making changes

1. Edit the relevant `hypr/lua/*.lua` file.
2. Run `bash hypr/generate.sh` to rebuild the `.conf` files.
3. Reload Hyprland (`hyprctl reload`) or re-login to apply.

### Migration notes (existing users)

If you cloned this repo before the Lua migration:
- The `.conf` files still live in the same locations and are loaded by Hyprland unchanged.
- Hyprland never sees the Lua files; they are only used for code generation.
- To customise your config, edit `hypr/lua/*.lua` instead of the `.conf` files.
- Run `bash hypr/generate.sh` whenever you change a Lua source to update the `.conf` output.

## Quick Start

### Normal install

```bash
git clone https://github.com/Devitana/Devitana_Arch_Config.git
cd Devitana_Arch_Config
bash install.sh
```

> Scope: this project is **pacman-only** (Arch / Arch-based distros).

### Dry-run (preview only)

```bash
git clone https://github.com/Devitana/Devitana_Arch_Config.git
cd Devitana_Arch_Config
bash install.sh --dry-run
```

### Verify installed setup

```bash
bash install.sh --verify
```

This checks core commands, required config files, and whether `current_gpu.conf` is pointing to a GPU profile.

### What gets installed/copied

- Installs core packages (`hyprland`, `waybar`, `kitty`, `jq`, `playerctl`, `python`, `python-requests`, PipeWire stack, etc.)
- Detects GPU and installs matching drivers (AMD/NVIDIA/Intel)
- Writes `~/.config/hypr/env_var/current_gpu.conf` to source the detected GPU profile
- Copies configs to `~/.config/hypr`, `~/.config/kitty`, and `~/.config/waybar`
- Copies repo `.bashrc` to `~/.bashrc`
- Backs up replaced files to `~/.config-backup-<timestamp>/`
- Enables services: `NetworkManager`, `bluetooth`, `seatd`

## Personal Defaults vs Reusable Setup

This repo is my personal daily setup first, but it is structured so others can use it too.

Before first login on another machine, update these **Lua source files** (then run `bash hypr/generate.sh`):

- `hypr/lua/monitors.lua` (connector names, resolution, refresh rate, scale)
- `hypr/lua/layout.lua` (`kb_layout`, variants/options)
- `waybar/config.jsonc` launcher app choices (browser/file manager)
- Optional weather env vars: `LAT`, `LON`, `WEATHER_CACHE_TIME`

If your monitor outputs are unknown, start with a single safe line in `monitors.conf`:

```ini
monitor=,preferred,auto,1
```

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
- `pacman` repositories available

## License

MIT License. See `LICENSE`.

## Author

**Devitana** - [GitHub](https://github.com/Devitana)
