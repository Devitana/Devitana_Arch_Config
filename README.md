# Devitana Arch Config

Arch Linux dotfiles for **Hyprland (Lua) + Waybar + Kitty**, with an installer using **official Arch repositories only**. The installer deploys the existing repository configs; it does not create a display manager or change bootloader settings.

## Features

- Installs official Arch Hyprland, Waybar, PipeWire, desktop utilities and font/icon dependencies.
- Detects **all** recognized AMD, Intel and NVIDIA display-class PCI devices, then installs matching driver packages (NVIDIA kernel driver requires explicit selection).
- Installs AMD/Intel **32-bit Vulkan libraries**, GameMode, MangoHud, Gamescope and Vulkan tools by default for Steam/Proton gaming.
- Creates a timestamped backup of any existing `~/.config/{hypr,waybar,kitty}` folders before copying.
- Provides a genuinely read-only dry run, package/config verification, and optional service enablement.
- Does not install AUR packages or silently change GPU/kernel/bootloader settings.

## Requirements

- Standard **Arch Linux x86_64** with `pacman`, `sudo`, internet access and a non-root user.
- `git` for cloning; `pciutils` is installed by the installer (GPU detection also works via `/sys`).
- **Enable `[multilib]`** in `/etc/pacman.conf` before the default gaming install. Then run `sudo pacman -Syu`. Multilib is required for Steam and 32-bit Proton libraries. The installer **does not edit pacman.conf**.
- Use the complete cloned repository, not isolated copies of the installer and GPU profiles.
- On Arch derivatives such as Manjaro, package availability and NVIDIA driver handling can differ. Those systems are not verified.

## Install

```bash
git clone https://github.com/Devitana/Devitana_Arch_Config.git
cd Devitana_Arch_Config
bash install.sh --dry-run
bash install.sh
bash install.sh --verify
```

`install.sh` runs a single `sudo pacman -Syu --needed ...` transaction, allowing `pacman` to resolve dependencies. It asks for confirmation unless you explicitly pass `--yes`. It does **not** install AUR helpers, apps, or packages from third-party repositories.

### Installer flags

| Flag | Purpose |
|---|---|
| `--dry-run`, `-n` | Preview packages/config backups/deployment without any writes or `sudo` |
| `--verify` | Check packages, deployed files and detected GPU profile (not a live GPU test) |
| `--no-gaming` | Skip gaming utilities and all 32-bit gaming packages; multilib not required |
| `--steam` | Add Steam from Arch multilib |
| `--nvidia-open-dkms` | Explicitly request the open NVIDIA DKMS module for **Turing or newer only**, plus headers for installed stock Arch kernels |
| `--enable-services` | Opt in to enabling NetworkManager and Bluetooth; may affect an existing network setup |
| `--yes`, `-y` | Unattended pacman transaction (`--noconfirm`) |
| `--help` | Show help |

For a desktop without gaming packages: `bash install.sh --no-gaming`. To include Steam: `bash install.sh --steam`.

## Packages

All packages in the installer are named by their **official Arch package names**; dependencies are automatically resolved by pacman.

| Area | Directly requested packages (summary) |
|---|---|
| Desktop | `hyprland`, `hyprland-guiutils`, `hyprpaper`, `hypridle`, `hyprlock`, `hyprlauncher`, Wayland portals, `kitty`, `firefox`, `nautilus` |
| PipeWire / controls | `pipewire`, `pipewire-pulse`, `pipewire-alsa`, `wireplumber`, `pavucontrol`, `playerctl`, `libnotify` |
| Config runtime | `waybar`, `polkit-gnome`, `qt6ct`, `kvantum`, `kvantum-qt5`, `jq`, `python-requests`, `pacman-contrib`, `brightnessctl`, `iputils`, `util-linux` |
| Icons / fonts | `otf-font-awesome`, Nerd Font symbols (regular and mono), JetBrains Mono Nerd, Noto + Emoji, Adwaita icons/cursors, Papirus icons |
| Gaming (default) | `gamemode`, `mangohud`, `gamescope`, `vulkan-tools`, `lib32-gamemode`, `lib32-mangohud`, `lib32-vulkan-icd-loader` |
| AMD GPU | `mesa`, `vulkan-radeon` and, in gaming mode, `lib32-mesa`, `lib32-vulkan-radeon` |
| Intel GPU | `mesa`, `vulkan-intel`, `intel-media-driver` and, in gaming mode, `lib32-mesa`, `lib32-vulkan-intel` |
| NVIDIA GPU | `nvidia-utils`, `nvidia-settings` and optional `lib32-nvidia-utils` **only if an NVIDIA driver is already present or `--nvidia-open-dkms` is selected** |

The installer installs neither `missioncenter` nor `flock` as package names: the correct package for the `missioncenter` command is `mission-center`, and the `flock` command comes from `util-linux`.

**Icons:** `otf-font-awesome` (the actual Font Awesome desktop font package) and Nerd Fonts provide glyphs in the Waybar labels; Papirus/Adwaita/hicolor provide app and GTK icons. `ttf-font-awesome` is now a virtual provide of the webfont package, so using `otf-font-awesome` matters for Waybar. Installing a theme does not automatically select it for every application. Run `fc-list | grep -Ei 'Awesome|Nerd'` to inspect fonts. After installing, log out/in or run `fc-cache -f` if needed.

## GPU detection and safe gaming defaults

Run detector directly from the repository:

```bash
bash hypr/scripts/detect_gpu.sh --report
bash hypr/scripts/detect_gpu.sh --vendors
bash hypr/scripts/detect_gpu.sh --primary
bash hypr/scripts/detect_gpu.sh --profile
```

The detector uses PCI sysfs vendor IDs and `boot_vga` where available, then falls back to `lspci -Dnn`. It reports all detected vendors for driver installation. **The selected Lua profile is only a label/config template**—it does not switch active rendering devices. On hybrid systems, configure per-game GPU selection explicitly.

The committed `hypr/env_var/current_gpu.lua` is a safe placeholder; the installer replaces the deployed copy with the chosen vendor profile. The profiles intentionally **do not force** `WLR_RENDERER=vulkan`, `WLR_NO_HARDWARE_CURSORS=1`, `RADV_PERFTEST=gpl`, global NVIDIA offload, `VK_ICD_FILENAMES`, or a Vulkan presentation mode. Many of these are obsolete or can break other hardware/games. Mesa, Hyprland and the Vulkan loader should use their current defaults.

### NVIDIA safety

On recent Arch kernels, NVIDIA cards need a compatible kernel driver. **Do not blindly install `nvidia`** on every machine. `--nvidia-open-dkms` installs `nvidia-open-dkms` and matching `linux[-zen|-lts|-hardened]-headers` for detected installed stock kernels, but only use it for a GPU supported by NVIDIA's open driver. Older NVIDIA GPUs, custom kernels and hybrid laptops need manual driver selection and testing. Review the [ArchWiki NVIDIA guide](https://wiki.archlinux.org/title/NVIDIA) and [Hyprland NVIDIA guide](https://wiki.hypr.land/Nvidia/) before rebooting. The script never edits bootloader or initramfs settings itself.

### Steam / Proton checks

```bash
pacman -Q mesa vulkan-radeon lib32-mesa lib32-vulkan-radeon  # AMD example
vulkaninfo --summary
gamemoded -t
```

Steam launch option for games that benefit from GameMode: `gamemoderun %command%`. Optional MangoHud overlay: `mangohud gamemoderun %command%`. Use them per game; avoid applying untested graphics tweaks to every app. Gamescope is installed but not forced globally.

For variable refresh rate (FreeSync/Adaptive Sync), set `misc.vrr` via `hl.config({ misc = { vrr = 2 } })` in your Hyprland Lua config **only if the monitor supports it**; this enables VRR for fullscreen applications. Test each display, and keep monitor refresh rates/configuration separate from GPU detection. For mixed Intel/AMD systems, make sure the game actually runs on the intended GPU.

## Installed files and backups

```text
~/.config/
├── hypr/
│   ├── hyprland.lua
│   ├── autostart/
│   ├── env_var/
│   │   ├── current_gpu.lua     # replaced by installer
│   │   └── gpu/
│   │       ├── amd.lua
│   │       ├── intel.lua
│   │       ├── nvidia.lua
│   │       └── generic_gpu.lua
│   ├── keyboard/
│   ├── monitors/
│   ├── permissions/
│   └── scripts/detect_gpu.sh
├── waybar/
│   ├── config.jsonc
│   ├── style.css
│   └── scripts/
└── kitty/
```

Before overwriting existing component files, the installer copies each existing component folder to `~/.config-backup-YYYYMMDD-HHMMSS-PID/{hypr,waybar,kitty}/`. Deployment merges files; it does not delete unrelated old config files. To restore, first save any new changes and then copy the relevant backed-up folder back to `~/.config/`.

## Manual setup after installing

1. `hypr/monitors/monitors.lua` uses a safe preferred-mode/automatic-position fallback. For a custom multi-monitor layout, edit connector names, resolution, refresh rates and positions (see `hyprctl monitors`).
2. Check `hypr/keyboard/layout.lua` for your keyboard layout.
3. Set `LAT` and `LON` for `waybar/scripts/weather.sh` (or edit that script) and confirm it can contact Open-Meteo.
4. This repo launches `/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1`, so the installer uses `polkit-gnome`, not the KDE agent.
5. Waybar's optional right/middle-click actions refer to additional applications (`chromium`, `vivaldi`, `krusader`, `thunderbird`). These are **not installed** by default; install/configure the ones you want or change the bindings. Vivaldi is in Arch Extra, but is deliberately not installed by default.
6. `--enable-services` is optional: avoid enabling NetworkManager automatically if another network manager is already controlling your network. Hyprland under systemd-logind does not require enabling `seatd.service`.
7. A greetd/tuigreet display manager is **not installed/configured** by this script. Start Hyprland through your existing login manager/session.
8. Hyprland permissions are disabled by default in `hypr/permissions/permissions.lua`. Set `ecosystem.enforce_permissions = true` and configure rules to opt in; `hyprland-guiutils` supports permission prompts.
9. `waybar/scripts/power_menu.xml` is required by the Waybar power-menu widget and is checked by the installer.
10. The existing `hypr/env_var/env.lua` uses `QT_QPA_PLATFORMTHEME=qt6ct` and `QT_STYLE_OVERRIDE=kvantum`; both related utilities are installed here. Review its global SDL and Qt environment assignments if legacy games or toolkit apps behave unexpectedly.

## Verify / troubleshoot

```bash
bash install.sh --verify
bash hypr/scripts/detect_gpu.sh --report
fc-list | grep -Ei 'Awesome|Nerd'
command -v missioncenter flock checkupdates
vulkaninfo --summary
journalctl --user -b | grep -Ei 'hyprland|waybar|portal'
```

`--verify` checks the selected options and required paths, not that Hyprland boots successfully or every glyph renders. Run `--no-gaming --verify` if gaming packages were deliberately skipped. The verifier checks the Waybar power-menu XML file and required scripts. If an icon is missing, check its actual Unicode glyph and selected Waybar CSS font—an icon theme cannot supply a missing font glyph.


## License

MIT. See [LICENSE](LICENSE).
