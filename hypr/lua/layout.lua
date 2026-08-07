-- layout.lua
-- Source-of-truth for hypr/keyboard/layout.conf
-- Input settings: keyboard layout, mouse, touchpad, gestures, per-device overrides.

return {
  input = {
    kb_layout  = "de",
    kb_variant = "",
    kb_model   = "",
    kb_options = "",
    kb_rules   = "",

    follow_mouse  = 1,
    mouse_refocus = false,
    sensitivity   = 0,   -- -1.0 to 1.0; 0 = no modification

    touchpad = {
      natural_scroll = false,
    },
  },

  -- Gestures (https://wiki.hypr.land/Configuring/Gestures)
  gestures = {
    { fingers = 3, direction = "horizontal", action = "workspace" },
  },

  -- Per-device overrides
  devices = {
    {
      name = "epic-mouse-v1",
      sensitivity = -0.5,
    },
  },
}
