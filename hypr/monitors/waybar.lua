-- monitors/waybar.lua

-------------------------------
--- WAYBAR LAYER RULES --------
-------------------------------

hl.layer_rule({
    match = { namespace = "waybar" },
    blur = true,
    ignore_alpha = 0.0,
    xray = false,
    blur_popups = true,
})