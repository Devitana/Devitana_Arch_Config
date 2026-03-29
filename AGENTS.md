# AGENTS.md

## Purpose and Scope
- This repo is a personal Arch Linux desktop config centered on Hyprland (`hypr/`) and Waybar (`Waybar/`).
- `install.sh` deploys Waybar into `~/.config/waybar`; Hyprland files are maintained separately.
- Treat hardware/user-specific settings as intentional unless asked to generalize (for example `hypr/monitors/monitors.conf`).

## Architecture Map
- Hyprland entrypoint: `hypr/hyprland.conf` is an include hub (`source = ~/.config/hypr/...`).
- Split modules by responsibility: `autostart/`, `env_var/`, `keyboard/`, `monitors/`, `permissions/`.
- Waybar entrypoint: `Waybar/config.jsonc` defines module placement, script exec hooks, and click actions.
- Styling is in `Waybar/style.css`; module keys map directly to CSS IDs (for example `custom/firefox` -> `#custom-firefox`).
- Cross-component signals: `hypr/autostart/startup.conf` runs `pkill -RTMIN+2 waybar` (weather) and `pkill -RTMIN+1 waybar` (updates).

## Runtime Contracts
- Scripts for modules with `"return-type": "json"` must always emit valid JSON (`Waybar/scripts/weather.sh`, `Waybar/scripts/updates.sh`).
- `Waybar/scripts/weather.sh` relies on cache + absolute tool paths and wttr.in JSON shape.
- `Waybar/scripts/updates.sh` and `Waybar/scripts/installupdates.sh` use `/tmp` lock files to avoid concurrent runs.
- `custom/updates` launches `kitty ~/.config/waybar/scripts/installupdates.sh`; preserve this path contract.
- `hypr/autostart/programs.conf` defines `$terminal`, `$fileManager`, `$menu` reused by keybindings.

## Developer Workflows
- Bootstrap Waybar config on Arch:
```bash
chmod +x install.sh
./install.sh
```
- Reload Waybar after config/script changes:
```bash
killall waybar; waybar &
```
- Refresh modules without full restart:
```bash
pkill -RTMIN+1 waybar   # updates
pkill -RTMIN+2 waybar   # weather
```
- Prefer editing the specific include file instead of monolithic edits to `hypr/hyprland.conf`.

## Project Conventions
- Keep shell script section banners (`# ============================================================================`).
- Preserve defensive script style: dependency checks, lock handling, fallback output.
- Do not remove Arch assumptions (`pacman`, optional `yay/paru`, optional `flatpak`) unless requested.
- Keep interactive prompts in installer/update scripts unless asked to make them non-interactive.
- Prefer minimal, targeted edits in modular files (`hypr/keyboard/keybindings.conf`, `hypr/monitors/workspaces.conf`, etc.).

## High-Risk Areas (Confirm First)
- `install.sh` backup/deploy behavior for existing `~/.config/waybar`.
- `hypr/monitors/monitors.conf` monitor names, resolutions, and coordinates.
- `Waybar/config.jsonc` + `Waybar/style.css` key renames that can break selectors and actions.
- `Waybar/scripts/installupdates.sh` update flow (`sudo pacman -Syu`, AUR helper, flatpak).
