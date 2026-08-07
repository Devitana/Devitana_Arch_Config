-- waybar.lua
-- Source-of-truth for hypr/monitors/waybar.conf
-- Layer rules that apply blur and xray settings to Waybar.

return {
  rules = {
    -- { match, rule }
    { match = "namespace = waybar", rule = "blur on" },
    { match = "namespace = waybar", rule = "ignore_alpha 0.0" },
    { match = "namespace = waybar", rule = "xray off" },
    { match = "namespace = waybar", rule = "blur_popups on" },
  },
}
