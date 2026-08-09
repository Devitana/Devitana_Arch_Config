-- monitors/workspaces.lua

------------------------------
--- WINDOWS AND WORKSPACES ---
------------------------------

-- Suppress maximize requests from all apps
hl.window_rule({
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix dragging/focus issues with un-titled, un-classed floating XWayland windows
hl.window_rule({
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

--------------------------
--- GAMING WINDOW RULES ---
--------------------------

-- Allow immediate tearing and disable animations for fullscreen applications/games
hl.window_rule({
    name = "fullscreen-gaming-optimizations",
    match = { fullscreen = true },
    immediate = true,
    no_anim = true,
})