
-- monitors/waybar.lua
-- Hyprland 0.57.0

-------------------------------
--- WAYBAR LAYER RULES ---
-------------------------------

hl.layer_rule({
    name = "waybar-glass",

    match = {
        namespace = "waybar",
    },

    -- Enable background blur
    blur = true,

    -- Ignore fully transparent pixels
    ignore_alpha = 0.0,

    -- Normal background blur
    xray = false,

    -- Blur Waybar popups
    blur_popups = true,
})
