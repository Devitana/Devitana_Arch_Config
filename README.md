# Devitana Arch Config

Personal Arch Linux Waybar + Hyprland configuration with custom scripts and styling.

This is my first project since moving to Linux about a year ago. I had no coding experience before this—only some basic knowledge.  
Please be kind. I did use AI to help me, and I worked on this project for about one hour each night. It took me more than three months to finish.  
Any feedback would be greatly appreciated. If you find this project interesting, I would be very happy if you tried it.

## Preview

![waybar](screenshots/2026-03-15_23-14.png)
![waybar](screenshots/2026-03-15_23-00.png)

## Features

- **Hyprland Wayland Desktop** - Lightweight tiling compositor
- **Waybar Status Bar** - Customized for Wayland environments
- **Custom Scripts** - Weather, system updates, system monitoring
- **Modular Design** - Easy to customize and extend
- **Glass Morphism UI** - Modern visual design
- **GPU Auto Setup** - Automatically installs AMD/NVIDIA/Intel drivers

## Quick Start

```bash
git clone https://github.com/Devitana/Devitana_Arch_Config.git
cd Devitana_Arch_Config
chmod +x install.sh
./install.sh
```

The script will:

- Installs core Hyprland + Waybar dependencies
- Installs PipeWire audio stack
- Installs greetd login manager
- Detects and installs GPU drivers automatically
- Copies config to ~/.config
- Backs up existing configs automatically
- Enables required system services

## Core Dependencies

- **hyprland** - Wayland compositor
- **waybar** - Status bar
- **kitty** - terminal
- **ttf-font-awesome** - Icons
- **noto-fonts** - Font support
- **jq** - JSON processor (for scripts)
- **playerctl** - Media controls
- **wl-clipboard** - Clipboard management
- **pipewire** - Audio system
- **polkit** - Permission handling

## Optional Packages

```bash
sudo pacman -S "is up to you"
```
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

script uses auto detection

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
