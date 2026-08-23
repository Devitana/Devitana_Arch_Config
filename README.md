# Devitana Arch Config

Personal Arch Linux **Hyprland + Waybar** configuration with custom scripts and styling.

This is my daily driver setup on Arch Linux, built after moving from Windows. It includes a fully scripted installer that handles packages, GPU drivers, services, and config deployment in one shot. Feedback is always welcome.

## Preview

![waybar](screenshots/2026-03-15_23-14.png)
![waybar](screenshots/2026-03-15_23-00.png)

## Features

- **Hyprland desktop** with modular split config files authored in Lua
- **Waybar setup** with custom weather, update, keyboard, and power modules
- **Full dependency installer** – packages, GPU drivers, fonts, AUR packages, and services in one script
- **Dry-run mode** to preview installer actions safely
- **Automatic backup** of replaced configs and dotfiles

## Current status

| Area | Status |
|------|--------|
| Hyprland config | ✅ Working |
| Waybar config + scripts | ✅ Working |
| Kitty terminal config | ✅ Working |
| `install.sh` – package install | ✅ Working |
| `install.sh` – GPU detection | ✅ Working |
| `install.sh` – config deploy | ✅ Working |
| Hyprland Lua → `.conf` generation | ✅ Working |

### Known limitations / TODO

- Intel GPU driver list is a best-effort selection; verify against your specific hardware
- `waybar-hyprland-git` (AUR) is not installed; the official `waybar` package from pacman is used instead
- Weather module defaults to a placeholder location (`LAT`/`LON`) – set your coordinates before use
- Flatpak is installed but no Flatpak apps are configured by default

## Prerequisites

- **Arch Linux** or an Arch-based distro (Manjaro, EndeavourOS, etc.)
- `pacman` available
- An **AUR helper** (paru or yay) – or the installer will attempt to build `paru` from AUR automatically
- A user account with `sudo` access
- Internet connection during install

## Quick Start

### Normal install (installs everything and deploys configs)

```bash
git clone https://github.com/Devitana/Devitana_Arch_Config.git
cd Devitana_Arch_Config
bash install.sh
```

> **Note:** The installer requires Arch / pacman. Do not run as root.

### Dry-run (preview only, no changes made)

```bash
bash install.sh --dry-run
```

### Verify installed setup

```bash
bash install.sh --verify
```

Checks core commands, required config files, and whether `current_gpu.lua` contains valid GPU env settings.

## What `install.sh` installs and configures

### Packages installed via `pacman`

| Group | Packages |
|-------|----------|
| Hyprland ecosystem | `hyprland`, `hyprpaper`, `hypridle`, `hyprlock`, `hyprcursor`, `xdg-desktop-portal-hyprland`, `qt5-wayland`, `qt6-wayland`, `polkit-kde-agent`, `seatd` |
| Waybar + audio | `waybar`, `pipewire`, `pipewire-pulse`, `pipewire-alsa`, `wireplumber`, `pavucontrol`, `playerctl`, `libpulse`, `libnotify` |
| Utilities | `kitty`, `firefox`, `nautilus`, `blueman`, `networkmanager`, `hyprlauncher`, `flatpak`, `pacman-contrib`, `figlet`, `missioncenter` |
| Screenshot / clipboard | `grim`, `slurp`, `wl-clipboard`, `cliphist`, `swappy` |
| Fonts | `ttf-font-awesome`, `ttf-nerd-fonts-symbols`, `ttf-jetbrains-mono`, `ttf-jetbrains-mono-nerd`, `noto-fonts`, `noto-fonts-emoji` |
| Scripting | `jq`, `curl`, `python`, `python-requests` |

### GPU drivers

The installer detects your GPU via `lspci` and installs:

- **NVIDIA** → `nvidia`, `nvidia-utils`, `nvidia-settings`
- **AMD** → `mesa`, `vulkan-radeon`, `libva-mesa-driver`
- **Intel** → `mesa`, `vulkan-intel`, `intel-media-driver`

### System services enabled

- `NetworkManager` – networking
- `bluetooth` – Bluetooth
- `seatd` – seat management required by Hyprland

### Configs deployed

- `~/.config/hypr/` – Hyprland Lua config files
- `~/.config/waybar/` – Waybar config + scripts (scripts are made executable)
- `~/.config/kitty/` – Kitty terminal config
- `~/.config/hypr/env_var/current_gpu.lua` – GPU profile auto-detected and written

Existing configs are backed up to `~/.config-backup-<timestamp>/` before being replaced.

## Post-install notes

1. **Log out and back in** (or reboot) to start a fresh Hyprland session
2. If Bluetooth is not working, run `sudo systemctl start bluetooth`
3. Set your **weather coordinates** – export `LAT` and `LON` environment variables or edit `~/.config/waybar/scripts/weather.sh` directly
4. If you have an NVIDIA GPU you may need to add kernel parameters (`nvidia_drm.modeset=1`) to your bootloader – see the [Hyprland NVIDIA wiki](https://wiki.hyprland.org/Nvidia/)

## Hyprland Config: Lua Source Files

All Hyprland configuration is **authored in Lua**.

```
hypr/
├── hyprland.lua             ← top-level include list
├── autostart/
│   ├── programs.lua         ← $terminal, $fileManager, $menu
│   └── startup.lua          ← exec-once autostart commands
├── env_var/
│   ├── current_gpu.lua      ← AUTO-WRITTEN by installer (GPU-specific env vars)
│   ├── env.lua              ← core Wayland environment variables
│   └── gpu/
│       ├── amd.lua          ← AMD GPU env vars
│       ├── nvidia.lua       ← NVIDIA GPU env vars
│       └── generic_gpu.lua  ← fallback GPU env vars
├── keyboard/
│   ├── keybindings.lua      ← all keybinds
│   └── layout.lua           ← keyboard / mouse / touchpad / gestures
├── monitors/
│   └── monitors.lua         ← monitor layout
├── permissions/
│   └── permissions.lua      ← Hyprland permission rules
└── scripts/
    └── detect_gpu.sh        ← GPU detection helper (called by installer)
```

Before first login on a new machine, update:

- `hypr/monitors/monitors.lua` (connector names, resolution, refresh rate, scale)
- `hypr/keyboard/layout.lua` (`kb_layout`, variants/options)
- `waybar/config.jsonc` launcher app choices (browser/file manager)

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
