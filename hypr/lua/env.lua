-- env.lua
-- Source-of-truth for hypr/env_var/env.conf
-- Core Wayland/toolkit environment variables.

return {
  sections = {
    {
      header = "############################\n### WAYLAND / TOOLKITS\n############################\n",
      vars = {
        { key = "XDG_SESSION_TYPE",                value = "wayland" },
        { key = "XDG_CURRENT_DESKTOP",             value = "Hyprland" },
        { key = "XDG_SESSION_DESKTOP",             value = "Hyprland" },
        { key = "QT_QPA_PLATFORM",                 value = "wayland" },
        { key = "QT_WAYLAND_DISABLE_WINDOWDECORATION", value = "1" },
        { key = "QT_QPA_PLATFORMTHEME",            value = "qt6ct" },
        { key = "QT_STYLE_OVERRIDE",               value = "kvantum" },
        { key = "MOZ_ENABLE_WAYLAND",              value = "1" },
        { key = "SDL_VIDEODRIVER",                 value = "wayland" },
      },
    },
    {
      header = "\n##############\n### CURSOR ###\n##############\n",
      vars = {
        { key = "XCURSOR_THEME",   value = "Adwaita" },
        { key = "XCURSOR_SIZE",    value = "36" },
        { key = "HYPRCURSOR_SIZE", value = "36" },
      },
    },
  },
}
