-- keyboard/layout.lua
-- Hyprland 0.57.0

-------------
--- INPUT ---
-------------

hl.config({
    input = {

        ---------------------
        --- KEYBOARD ---
        ---------------------

        kb_layout = "de",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",

        -- Enable Num Lock at startup
        numlock_by_default = true,

        ---------------------
        --- MOUSE ---
        ---------------------

        -- Focus follows the mouse
        follow_mouse = 1,

        -- Disable mouse boundary refocusing
        mouse_refocus = true,

        -- Default pointer sensitivity
        sensitivity = 0.0,

        ---------------------
        --- TOUCHPAD ---
        ---------------------

        touchpad = {
            natural_scroll = false,
        },
    },
})
