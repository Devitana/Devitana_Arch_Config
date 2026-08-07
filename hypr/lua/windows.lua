-- windows.lua
-- Source-of-truth for hypr/monitors/windows.conf
-- General layout, decorations, animations, dwindle/master, misc settings.

return {
  general = {
    gaps_in = 3,
    gaps_out = 6,
    border_size = 2,
    -- Active/inactive border gradient colors
    ["col.active_border"]   = "rgba(33ccffee) rgba(00ff99ee) 45deg",
    ["col.inactive_border"] = "rgba(595959aa)",
    resize_on_border = true,
    allow_tearing = true,
    layout = "dwindle",
  },

  decoration = {
    rounding = 6,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = false,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 10,
      passes = 4,
      new_optimizations = true,
      vibrancy = 0.1696,
    },
  },

  -- Named bezier curves: { name, x0, y0, x1, y1 }
  beziers = {
    { name = "easeOutQuint",   x0 = 0.23, y0 = 1,    x1 = 0.32, y1 = 1 },
    { name = "easeInOutCubic", x0 = 0.65, y0 = 0.05, x1 = 0.36, y1 = 1 },
    { name = "linear",         x0 = 0,    y0 = 0,    x1 = 1,    y1 = 1 },
    { name = "almostLinear",   x0 = 0.5,  y0 = 0.5,  x1 = 0.75, y1 = 1 },
    { name = "quick",          x0 = 0.15, y0 = 0,    x1 = 0.1,  y1 = 1 },
    { name = "launcherCurve",  x0 = 0.16, y0 = 1,    x1 = 0.3,  y1 = 1 },
  },

  -- Animations: { name, enabled, speed, curve, [style] }
  animations = {
    enabled = true,
    entries = {
      -- global
      { name = "global",        on = 1, speed = 10,  curve = "default" },
      -- Window
      { name = "windows",       on = 1, speed = 4.5, curve = "easeOutQuint" },
      { name = "windowsIn",     on = 1, speed = 10,  curve = "easeOutQuint", style = "gnomed" },
      { name = "windowsOut",    on = 1, speed = 2.5, curve = "easeOutQuint", style = "popin 87%" },
      -- Fade
      { name = "fadeIn",        on = 1, speed = 2.0, curve = "almostLinear" },
      { name = "fadeOut",       on = 1, speed = 1.8, curve = "almostLinear" },
      { name = "fade",          on = 1, speed = 3.0, curve = "quick" },
      -- Layers
      { name = "layers",        on = 1, speed = 4.5, curve = "easeOutQuint" },
      { name = "layersIn",      on = 1, speed = 4.5, curve = "launcherCurve", style = "popin 90%" },
      { name = "layersOut",     on = 1, speed = 2.8, curve = "launcherCurve", style = "popin 90%" },
      { name = "fadeLayersIn",  on = 1, speed = 2.5, curve = "easeOutQuint" },
      { name = "fadeLayersOut", on = 1, speed = 2.2, curve = "easeOutQuint" },
      -- Workspaces
      { name = "workspaces",    on = 1, speed = 2.0, curve = "almostLinear", style = "fade" },
      { name = "workspacesIn",  on = 1, speed = 1.5, curve = "almostLinear", style = "fade" },
      { name = "workspacesOut", on = 1, speed = 2.0, curve = "almostLinear", style = "fade" },
      -- Misc
      { name = "border",        on = 1, speed = 5.0, curve = "easeOutQuint" },
      { name = "zoomFactor",    on = 1, speed = 7.0, curve = "quick" },
    },
  },

  dwindle = {
    preserve_split = true,
  },

  master = {
    new_status = "master",
  },

  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = false,
  },
}
