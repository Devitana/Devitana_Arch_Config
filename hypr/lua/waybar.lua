-- waybar.lua  –  Waybar layer rules (blur, xray, popups)
-- Generates: hypr/monitors/waybar.conf

hl.comment("Waybar blur layer rules")
hl.keyword("layerrule", "match:namespace = waybar, blur on")
hl.keyword("layerrule", "match:namespace = waybar, ignore_alpha 0.0")
hl.keyword("layerrule", "match:namespace = waybar, xray off")
hl.keyword("layerrule", "match:namespace = waybar, blur_popups on")
