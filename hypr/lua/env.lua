-- env.lua  –  common Wayland / toolkit / cursor environment variables
-- Generates: hypr/env_var/env.conf

hl.heading("WAYLAND / TOOLKITS")
hl.keyword("env", "XDG_SESSION_TYPE,wayland")
hl.keyword("env", "XDG_CURRENT_DESKTOP,Hyprland")
hl.keyword("env", "XDG_SESSION_DESKTOP,Hyprland")
hl.keyword("env", "QT_QPA_PLATFORM,wayland")
hl.keyword("env", "QT_WAYLAND_DISABLE_WINDOWDECORATION,1")
hl.keyword("env", "QT_QPA_PLATFORMTHEME,qt6ct")
hl.keyword("env", "QT_STYLE_OVERRIDE,kvantum")
hl.keyword("env", "MOZ_ENABLE_WAYLAND,1")
hl.keyword("env", "SDL_VIDEODRIVER,wayland")

hl.heading("CURSOR")
hl.keyword("env", "XCURSOR_THEME,Adwaita")
hl.keyword("env", "XCURSOR_SIZE,36")
hl.keyword("env", "HYPRCURSOR_SIZE,36")
