#!/usr/bin/env python3
"""
generate.py  –  Hyprland Lua-source → .conf generator (Python implementation)

Usage:
    cd <repo-root>/hypr/lua
    python3 generate.py [--check]

Options:
    (no flag)  Write generated .conf files to their canonical paths under hypr/
    --check    Dry-run: report drift and exit 1 if any file would change.

This script produces the same output as `lua generate.lua`.
Prefer running the Lua generator on Arch (lua is available there); this Python
version exists as a portable fallback (e.g., CI, macOS, non-Arch setups).

Source-of-truth:  hypr/lua/*.lua
Generated output: hypr/**/*.conf
"""

import os
import sys
import pathlib

CHECK = "--check" in sys.argv
DRIFT = False

SCRIPT_DIR = pathlib.Path(__file__).parent.resolve()
HYPR_DIR   = SCRIPT_DIR.parent  # one level up: hypr/

HEADER = """\
# ============================================================
# AUTO-GENERATED – do not edit by hand.
# Source: hypr/lua/  |  Regenerate: cd hypr/lua && lua generate.lua
# ============================================================

"""

# ─── helpers ────────────────────────────────────────────────────────────────

def bval(v):
    """Convert Python bool/number/str to Hyprland string representation."""
    if isinstance(v, bool):
        return "true" if v else "false"
    return str(v)

def env_line(k, v):
    return f"env = {k},{v}\n"

def write(rel_path: str, content: str):
    global DRIFT
    path = HYPR_DIR / rel_path
    if CHECK:
        try:
            existing = path.read_text()
        except FileNotFoundError:
            existing = None
        if existing != content:
            DRIFT = True
            print(f"[DRIFT] {path} would change", file=sys.stderr)
        else:
            print(f"[OK]    {path}")
    else:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        print(f"Written: {path}")

# ─── generators ─────────────────────────────────────────────────────────────

def gen_hyprland():
    return HEADER + """\
################
### MONITORS ###
################

# See https://wiki.hypr.land/Configuring/Monitors/
source = ~/.config/hypr/monitors/monitors.conf


###################
### MY PROGRAMS ###
###################

# See https://wiki.hypr.land/Configuring/Keywords/
source = ~/.config/hypr/autostart/programs.conf


#################
### AUTOSTART ###
#################

# Autostart necessary processes (like notifications daemons, status bars, etc.)
source = ~/.config/hypr/autostart/startup.conf


#############################
### ENVIRONMENT VARIABLES ###
#############################

# See https://wiki.hypr.land/Configuring/Environment-variables/
source = ~/.config/hypr/env_var/current_gpu.conf
source = ~/.config/hypr/env_var/env.conf
# source = ~/.config/hypr/env_var/gpu/amd.conf


###################
### PERMISSIONS ###
###################

# See https://wiki.hypr.land/Configuring/Permissions/
# Please note permission changes here require a Hyprland restart and are not applied on-the-fly
# for security reasons
source = ~/.config/hypr/permissions/permissions.conf


#####################
### LOOK AND FEEL ###
#####################

# Refer to https://wiki.hypr.land/Configuring/Variables/
# https://wiki.hypr.land/Configuring/Variables/#general
# https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors
# https://wiki.hypr.land/Configuring/Variables/#decoration
# https://wiki.hypr.land/Configuring/Variables/#decoration
source = ~/.config/hypr/monitors/windows.conf
source = ~/.config/hypr/monitors/waybar.conf


#############
### INPUT ###
#############

# https://wiki.hypr.land/Configuring/Variables/#input
source = ~/.config/hypr/keyboard/layout.conf


###################
### KEYBINDINGS ###
###################

# See https://wiki.hypr.land/Configuring/Keywords/
source = ~/.config/hypr/keyboard/keybindings.conf


##############################
### WINDOWS AND WORKSPACES ###
##############################

# See https://wiki.hypr.land/Configuring/Window-Rules/ for more
# See https://wiki.hypr.land/Configuring/Workspace-Rules/ for workspace rules
source = ~/.config/hypr/monitors/workspaces.conf
"""

def gen_programs():
    return HEADER + """\
###################
### MY PROGRAMS ###
###################

# Set programs that you use
$terminal = kitty
$fileManager = nautilus
$menu = hyprlauncher
"""

def gen_startup():
    return HEADER + """\
#################
### AUTOSTART ###
#################

# GPU profile is selected during install and written to env_var/current_gpu.conf

# Terminal example (uncomment if you want a terminal at startup)
# exec-once = $terminal

# Network applet
# exec-once = nm-applet &

# Waybar
exec-once = waybar &

# Wallpapers
exec-once = hyprpaper &

# Idle manager (locks screen + DPMS off, no suspend)
exec-once = hypridle &

# Bluetooth manager
exec-once = blueman-applet &

# Waybar updates (weather, system updates)
# weather
exec-once = sleep 60 && pkill -RTMIN+2 waybar
# updates
exec-once = sleep 60 && pkill -RTMIN+1 waybar
"""

def gen_env():
    return HEADER + """\
############################
### WAYLAND / TOOLKITS
############################

env = XDG_SESSION_TYPE,wayland
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_DESKTOP,Hyprland
env = QT_QPA_PLATFORM,wayland
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = QT_QPA_PLATFORMTHEME,qt6ct
env = QT_STYLE_OVERRIDE,kvantum
env = MOZ_ENABLE_WAYLAND,1
env = SDL_VIDEODRIVER,wayland

##############
### CURSOR ###
##############

env = XCURSOR_THEME,Adwaita
env = XCURSOR_SIZE,36
env = HYPRCURSOR_SIZE,36
"""

def gen_gpu_amd():
    return HEADER + """\
###############################
### AMD / MESA OPTIMIZATION ###
###############################

env = WLR_RENDERER,vulkan
env = WLR_NO_HARDWARE_CURSORS,1
env = RADV_PERFTEST,gpl
env = AMD_VULKAN_ICD,radv
env = MESA_VK_WSI_PRESENT_MODE,mailbox
env = __GL_GSYNC_ALLOWED,1
env = __GL_VRR_ALLOWED,1
"""

def gen_gpu_generic():
    return HEADER + """\
#################################
### GENERIC WAYLAND SETTINGS   ###
#################################

# Generic Vulkan configuration
env = WLR_RENDERER,vulkan
env = WLR_NO_HARDWARE_CURSORS,1

# Generic VRR settings
env = __GL_GSYNC_ALLOWED,1
env = __GL_VRR_ALLOWED,1

# Default present mode
env = MESA_VK_WSI_PRESENT_MODE,mailbox
"""

def gen_gpu_intel():
    return HEADER + """\
#################################
### INTEL GPU OPTIMIZATION     ###
#################################

# Intel iGPU and Arc GPU support
# Intel Vulkan driver (choose one based on your GPU)
# For older Intel iGPU (UHD/Iris):
env = WLR_RENDERER,vulkan
env = WLR_NO_HARDWARE_CURSORS,1
env = VK_ICD_FILENAMES,/usr/share/vulkan/icd.d/intel_icd.x86_64.json
# For newer Intel Arc GPU:
# env = VK_ICD_FILENAMES,/usr/share/vulkan/icd.d/intel_hasvk_icd.x86_64.json

# Intel-specific settings
env = INTEL_PRECISE_TRIG,1
env = MESA_LOADER_DRIVER_OVERRIDE,iris
env = INTEL_DEBUG,

# VRR/Adaptive Sync (may work on newer Arc)
env = __GL_GSYNC_ALLOWED,1
env = __GL_VRR_ALLOWED,1

# Present mode
env = MESA_VK_WSI_PRESENT_MODE,mailbox
"""

def gen_gpu_nvidia():
    return HEADER + """\
#################################
### NVIDIA OPTIMIZATION        ###
#################################

# Wayland + NVIDIA
env = __NV_PRIME_RENDER_OFFLOAD,1
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __VK_LAYER_NV_optimus,NVIDIA_only

# Vulkan ICD for NVIDIA
env = VK_ICD_FILENAMES,/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json

# NVIDIA-specific settings
env = NVIDIA_MIG_CONFIG,disabled
env = NVIDIA_PRESERVE_VIDEOCORE,1

# VRR/Adaptive Sync (NVIDIA G-Sync)
env = __GL_GSYNC_ALLOWED,1
env = __GL_VRR_ALLOWED,1

# Wayland rendering
env = WLR_RENDERER,vulkan
env = WLR_NO_HARDWARE_CURSORS,1
env = MESA_VK_WSI_PRESENT_MODE,fifo
"""

def gen_monitors():
    return HEADER + """\
#############################
### MONITOR CONFIGURATION ###
#############################

# Left monitor
monitor=DP-3,2560x1440@144,0x0,1

# Center (primary) monitor
monitor=DP-2,2560x1440@144,2560x0,1

# Right monitor
monitor=DP-1,2560x1440@144,5120x0,1
"""

def gen_waybar():
    return HEADER + """\
# Waybar blur layer rules
layerrule = match:namespace = waybar, blur on
layerrule = match:namespace = waybar, ignore_alpha 0.0
layerrule = match:namespace = waybar, xray off
layerrule = match:namespace = waybar, blur_popups on
"""

def gen_windows():
    return HEADER + """\
general {
    gaps_in = 3
    gaps_out = 6
    border_size = 2

# Colors
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)

# Set to true enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = true

# Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
    allow_tearing = true

    layout = dwindle
}

# Decorations

decoration {
    rounding = 6
    rounding_power = 2

    # Change transparency of focused and unfocused windows
    active_opacity = 1.0
    inactive_opacity = 1.0

    shadow {
        enabled = false
        range = 4
        render_power = 3
        color = rgba(1a1a1aee)
    }

    # https://wiki.hypr.land/Configuring/Variables/#blur
    blur {
        enabled = true
        size = 10
        passes = 4
        new_optimizations = true
        vibrancy = 0.1696
    }
}

# Animations

animations {
    enabled = yes

    # Default curves, see https://wiki.hypr.land/Configuring/Animations/#curves
    #        NAME,           X0,   Y0,   X1,   Y1
    bezier = easeOutQuint,   0.23, 1,    0.32, 1
    bezier = easeInOutCubic, 0.65, 0.05, 0.36, 1
    bezier = linear,         0,    0,    1,    1
    bezier = almostLinear,   0.5,  0.5,  0.75, 1
    bezier = quick,          0.15, 0,    0.1,  1
    bezier = launcherCurve,  0.16, 1,    0.3,  1

    # Default animations, see https://wiki.hypr.land/Configuring/Animations/
    #           NAME,          ONOFF, SPEED, CURVE,        [STYLE]
    animation = global,        1,     10,    default

    # =========================
    # Window Animations
    # =========================
    animation = windows,       1, 4.5, easeOutQuint
    animation = windowsIn,     1, 10, easeOutQuint, gnomed
    animation = windowsOut,    1, 2.5, easeOutQuint, popin 87%

    # =========================
    # Fade Animations
    # =========================
    animation = fadeIn,        1, 2.0, almostLinear
    animation = fadeOut,       1, 1.8, almostLinear
    animation = fade,          1, 3.0, quick

    # =========================
    # Layer Animations (IMPORTANT for launcher)
    # =========================
    animation = layers,        1, 4.5, easeOutQuint

    # Hyprlauncher entry/exit (smooth + premium feel)
    animation = layersIn,      1, 4.5, launcherCurve, popin 90%
    animation = layersOut,     1, 2.8, launcherCurve, popin 90%

    # Fade for layers (soft glass feel)
    animation = fadeLayersIn,  1, 2.5, easeOutQuint
    animation = fadeLayersOut, 1, 2.2, easeOutQuint

    # =========================
    # Workspace Animations
    # =========================
    animation = workspaces,    1, 2.0, almostLinear, fade
    animation = workspacesIn,  1, 1.5, almostLinear, fade
    animation = workspacesOut, 1, 2.0, almostLinear, fade

    # =========================
    # Misc
    # =========================
    animation = border,        1, 5.0, easeOutQuint
    animation = zoomFactor,    1, 7.0, quick
}

# Ref https://wiki.hypr.land/Configuring/Workspace-Rules/
# "Smart gaps" / "No gaps when only"
# uncomment all if you wish to use that.
# workspace = w[tv1], gapsout:0, gapsin:0
# workspace = f[1], gapsout:0, gapsin:0
# windowrule = bordersize 0, floating:0, onworkspace:w[tv1]
# windowrule = rounding 0, floating:0, onworkspace:w[tv1]
# windowrule = bordersize 0, floating:0, onworkspace:f[1]
# windowrule = rounding 0, floating:0, onworkspace:f[1]

# See https://wiki.hypr.land/Configuring/Dwindle-Layout/ for more
dwindle {
    preserve_split = true # You probably want this
}

# See https://wiki.hypr.land/Configuring/Master-Layout/ for more
master {
    new_status = master
}

# https://wiki.hypr.land/Configuring/Variables/#misc
misc {
    force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
}
"""

def gen_workspaces():
    return HEADER + """\
##############################
### WINDOWS AND WORKSPACES ###
##############################

# Ignore maximize requests from apps (most users keep this)
windowrule = suppress_event maximize, match:class .*

# Fix dragging/focus issues with certain XWayland floating windows
windowrule = no_focus on, match:class ^$, match:title ^$, match:xwayland 1, match:fullscreen 0, match:float 1, match:pin 0

#############################
### WINDOWRULE (GAMING) ###
#############################

# Low-latency fullscreen for games (immediate tearing + no animations)
windowrule = immediate on, match:fullscreen 1
windowrule = no_anim on, match:fullscreen 1
"""

def gen_layout():
    return HEADER + """\
input {
    kb_layout = de
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1
    mouse_refocus = false
    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

    touchpad {
        natural_scroll = false
    }
}

# See https://wiki.hypr.land/Configuring/Gestures
gesture = 3, horizontal, workspace

# Example per-device config
# See https://wiki.hypr.land/Configuring/Keywords/#per-device-input-configs for more
device {
    name = epic-mouse-v1
    sensitivity = -0.5
}
"""

def gen_keybindings():
    return HEADER + """\
$mainMod = SUPER # Sets "Windows" key as main modifier

# Example binds, see https://wiki.hypr.land/Configuring/Binds/ for more
bind = $mainMod, T, exec, $terminal
bind = $mainMod, Q, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, $fileManager
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, $menu
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, L, exec, hyprlock
bind = $mainMod, F, fullscreen, 0

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Example special workspace (scratchpad)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Laptop multimedia keys for volume and LCD brightness
bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
bindel = ,XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+
bindel = ,XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-

# Requires playerctl
bindl = , XF86AudioNext, exec, playerctl next
bindl = , XF86AudioPause, exec, playerctl play-pause
bindl = , XF86AudioPlay, exec, playerctl play-pause
bindl = , XF86AudioPrev, exec, playerctl previous
"""

def gen_permissions():
    return HEADER + """\
# ecosystem {
#   enforce_permissions = 1
# }

# permission = /usr/(bin|local/bin)/grim, screencopy, allow
# permission = /usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland, screencopy, allow
# permission = /usr/(bin|local/bin)/hyprpm, plugin, allow
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
"""

def gen_hypridle():
    return HEADER + """\
general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = ""                   
    after_sleep_cmd = ""                    
}

listener {
    timeout = 300           
    on-timeout = loginctl lock-session
}

listener {
    timeout = 600           
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}
"""

def gen_hyprlock():
    return HEADER + """\
background {
    monitor =
    path = ~/Pictures/wallpaper.jpg
    blur_passes = 3
    blur_size = 8
}

label {
    monitor =
    text = cmd[update:1000] echo "$(date +"%H:%M")"
    font_size = 60
    position = 0, 80
    halign = center
    valign = center
}

input-field {
    monitor =
    size = 250, 50
    outline_thickness = 2
    dots_size = 0.3
    dots_spacing = 0.2
    fade_on_empty = false
    placeholder_text = Password...
    halign = center
    valign = center
}
"""

def gen_hyprlauncher():
    return HEADER + """\
# General
general {
    grab_focus = true
}

# Cache (tracks frequently used apps!)
cache {
    enabled = true
}

# Finder behavior
finders {
    default_finder = desktop
    desktop_icons = true
    math_prefix = =
}

# UI
ui {
    window_size = 800 400
    anchor = top
    margin_top = 60
}
"""

def gen_hyprtoolkit():
    return HEADER + """\
# Colors (Waybar style)
background = 0xCC1E1E2E
background_secondary = 0xCC1E1E2E

text = 0xE6FFFFFF
text_secondary = 0xB3FFFFFF

accent = 0x59FFFFFF

# Borders & rounding
border_size = 1
border_color = 0x40FFFFFF

rounding = 12
rounding_large = 16

# Shadows (soft like Waybar)
shadow_size = 20
shadow_color = 0x80000000

# Blur (IMPORTANT)
blur = true
blur_size = 8
blur_passes = 2

# Padding
padding = 10
"""

# ─── main ────────────────────────────────────────────────────────────────────

write("hyprland.conf",                   gen_hyprland())
write("autostart/programs.conf",         gen_programs())
write("autostart/startup.conf",          gen_startup())
write("env_var/env.conf",                gen_env())
write("env_var/gpu/amd.conf",            gen_gpu_amd())
write("env_var/gpu/generic_gpu.conf",    gen_gpu_generic())
write("env_var/gpu/intel.conf",          gen_gpu_intel())
write("env_var/gpu/nvidia.conf",         gen_gpu_nvidia())
write("monitors/monitors.conf",          gen_monitors())
write("monitors/waybar.conf",            gen_waybar())
write("monitors/windows.conf",           gen_windows())
write("monitors/workspaces.conf",        gen_workspaces())
write("keyboard/layout.conf",            gen_layout())
write("keyboard/keybindings.conf",       gen_keybindings())
write("permissions/permissions.conf",    gen_permissions())
write("hypridle.conf",                   gen_hypridle())
write("hyprlock.conf",                   gen_hyprlock())
write("hyprlauncher.conf",               gen_hyprlauncher())
write("hyprtoolkit.conf",                gen_hyprtoolkit())

if CHECK:
    if DRIFT:
        print("\nDrift detected – run `cd hypr/lua && python3 generate.py` to regenerate.",
              file=sys.stderr)
        sys.exit(1)
    else:
        print("\nAll generated files are up-to-date.")
