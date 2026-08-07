-- hyprlock.lua
-- Source-of-truth for hypr/hyprlock.conf
-- Hyprlock screen lock appearance.

return {
  background = {
    monitor     = "",
    path        = "~/Pictures/wallpaper.jpg",
    blur_passes = 3,
    blur_size   = 8,
  },

  labels = {
    {
      monitor   = "",
      text      = 'cmd[update:1000] echo "$(date +"%H:%M")"',
      font_size = 60,
      position  = "0, 80",
      halign    = "center",
      valign    = "center",
    },
  },

  input_fields = {
    {
      monitor           = "",
      size              = "250, 50",
      outline_thickness = 2,
      dots_size         = 0.3,
      dots_spacing      = 0.2,
      fade_on_empty     = false,
      placeholder_text  = "Password...",
      halign            = "center",
      valign            = "center",
    },
  },
}
