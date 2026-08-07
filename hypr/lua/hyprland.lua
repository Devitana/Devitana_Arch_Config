-- hyprland.lua
-- Source-of-truth for hypr/hyprland.conf
-- This file defines the section includes in the correct order.
-- Edit this (and the other Lua source files) then run generate.lua to rebuild .conf files.

return {
  header = [[
################
### MONITORS ###
################

# See https://wiki.hypr.land/Configuring/Monitors/
]],

  sources = {
    -- Each entry: { comment (optional), path }
    { path = "~/.config/hypr/monitors/monitors.conf" },

    { header = "\n\n###################\n### MY PROGRAMS ###\n###################\n\n# See https://wiki.hypr.land/Configuring/Keywords/" },
    { path = "~/.config/hypr/autostart/programs.conf" },

    { header = "\n\n#################\n### AUTOSTART ###\n#################\n\n# Autostart necessary processes (like notifications daemons, status bars, etc.)" },
    { path = "~/.config/hypr/autostart/startup.conf" },

    { header = "\n\n#############################\n### ENVIRONMENT VARIABLES ###\n#############################\n\n# See https://wiki.hypr.land/Configuring/Environment-variables/" },
    { path = "~/.config/hypr/env_var/current_gpu.conf" },
    { path = "~/.config/hypr/env_var/env.conf" },
    -- AMD GPU profile is commented out by default; uncomment to activate:
    { commented_path = "~/.config/hypr/env_var/gpu/amd.conf" },

    { header = "\n\n###################\n### PERMISSIONS ###\n###################\n\n# See https://wiki.hypr.land/Configuring/Permissions/\n# Please note permission changes here require a Hyprland restart and are not applied on-the-fly\n# for security reasons" },
    { path = "~/.config/hypr/permissions/permissions.conf" },

    { header = "\n\n#####################\n### LOOK AND FEEL ###\n#####################\n\n# Refer to https://wiki.hypr.land/Configuring/Variables/\n# https://wiki.hypr.land/Configuring/Variables/#general\n# https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors\n# https://wiki.hypr.land/Configuring/Variables/#decoration\n# https://wiki.hypr.land/Configuring/Variables/#decoration" },
    { path = "~/.config/hypr/monitors/windows.conf" },
    { path = "~/.config/hypr/monitors/waybar.conf" },

    { header = "\n\n#############\n### INPUT ###\n#############\n\n# https://wiki.hypr.land/Configuring/Variables/#input" },
    { path = "~/.config/hypr/keyboard/layout.conf" },

    { header = "\n\n###################\n### KEYBINDINGS ###\n###################\n\n# See https://wiki.hypr.land/Configuring/Keywords/" },
    { path = "~/.config/hypr/keyboard/keybindings.conf" },

    { header = "\n\n##############################\n### WINDOWS AND WORKSPACES ###\n##############################\n\n# See https://wiki.hypr.land/Configuring/Window-Rules/ for more\n# See https://wiki.hypr.land/Configuring/Workspace-Rules/ for workspace rules" },
    { path = "~/.config/hypr/monitors/workspaces.conf" },
  },
}
