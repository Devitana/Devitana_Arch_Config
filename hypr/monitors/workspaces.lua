
-- monitors/workspaces.lua
-- Hyprland 0.57.0

------------------------------
--- WINDOWS AND WORKSPACES ---
------------------------------

-- Suppress automatic maximize requests from applications.
-- Manual fullscreen using SUPER + F remains available.
hl.window_rule({
    name = "suppress-maximize-requests",

    match = {
        class = ".*",
    },

    suppress_event = "maximize",
})

----------------------
--- XWAYLAND FIXES ---
----------------------

-- Prevent certain invisible / empty XWayland windows
-- from stealing keyboard focus.
hl.window_rule({
    name = "fix-xwayland-drags",

    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        fullscreen = false,
        float = true,
        pin = false,
    },

    no_focus = true,
})

----------------------------
--- FULLSCREEN ANIMATIONS ---
----------------------------

-- Disable animations for fullscreen windows.
-- Applies to games and other fullscreen applications.
hl.window_rule({
    name = "fullscreen-no-animations",

    match = {
        fullscreen = true,
    },

    no_anim = true,
})

--------------------------
--- GAMING OPTIMIZATIONS ---
--------------------------

-- Optional: enable tearing for a specific game.
-- Replace GAME_CLASS with the actual game window class.
-- Uncomment this rule after identifying the class.

-- hl.window_rule({
--     name = "game-immediate",
--
--     match = {
--         class = "^GAME_CLASS$",
--         fullscreen = true,
--     },
--
--     immediate = true,
-- })
