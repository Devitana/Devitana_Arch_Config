-- hyprlauncher.lua
-- Source-of-truth for hypr/hyprlauncher.conf
-- Hyprlauncher appearance and behavior.

return {
  general = {
    grab_focus = true,
  },

  cache = {
    enabled = true,
  },

  finders = {
    default_finder = "desktop",
    desktop_icons  = true,
    math_prefix    = "=",
  },

  ui = {
    window_size = "800 400",
    anchor      = "top",
    margin_top  = 60,
  },
}
