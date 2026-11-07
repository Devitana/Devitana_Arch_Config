
-- monitors/windows.lua

----------------------
--- GENERAL CONFIG ---
----------------------

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 6,
        border_size = 2,
        col = {
            active_border = {
                colors = {
                    "rgba(33ccffee)",
                    "rgba(00ff99ee)",
                },
                angle = 45,
            },
            inactive_border = "rgba(595959aa)",
                },
        resize_on_border = true,
        allow_tearing = true,
        layout = "dwindle",   
    },

    -------------------
    --- DECORATION ---
    -------------------

    decoration = {
        rounding = 6,
        rounding_power = 2,
        active_opacity = 0.9,
        inactive_opacity = 0.60,
        fullscreen_opacity = 1.0,

        shadow = {
            enabled = false,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
        border_part_of_window = true,
        motion_blur = {
            enabled = true,
            samples = 7,
        },
        blur = {
            enabled = true,
            size = 2,
            variant = "water",
            passes = 2,
            new_optimizations = true,
            vibrancy = 0.1696,
        },

        wobble = {
            enabled = true,
            mesh = 16,
            stiffness = 120.0,
            damping = 8.0,
            mass = 1.0,
            intensity = 1.0,
            value_epsilon = 0.25,
            velocity_epsilon = 2.0,
        },
    },

    ------------------
    --- ANIMATIONS ---
    ------------------

    animations = {
        enabled = true,
    },

    ---------------
    --- LAYOUTS ---
    ---------------

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    ------------
    --- MISC ---
    ------------

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,

        ----------------------------
        --- VRR / FREESYNC ---
        ----------------------------

        -- 0 = Disabled
        -- 1 = Always enabled
        -- 2 = Fullscreen applications only
        -- 3 = Fullscreen video/game content only

        vrr = 2,
    },

})

----------------------
--- BEZIER CURVES ---
----------------------

hl.curve("easeOutQuint", {
    type = "bezier",
    points = { {0.23, 1}, {0.32, 1} }
})

hl.curve("easeInOutCubic", {
    type = "bezier",
    points = { {0.65, 0.05}, {0.36, 1} }
})

hl.curve("linear", {
    type = "bezier",
    points = { {0, 0}, {1, 1} }
})

hl.curve("almostLinear", {
    type = "bezier",
    points = { {0.5, 0.5}, {0.75, 1} }
})

hl.curve("quick", {
    type = "bezier",
    points = { {0.15, 0}, {0.1, 1} }
})

hl.curve("launcherCurve", {
    type = "bezier",
    points = { {0.16, 1}, {0.3, 1} }
})

------------------------
--- ANIMATION RULES ---
------------------------

local function anim(leaf, speed, curve, style)
    hl.animation({
        leaf = leaf,
        enabled = true,
        speed = speed,
        bezier = curve,
        style = style,
    })
end

-- Global
anim("global", 10, "default")

-- Window animations
anim("windows", 4.5, "easeOutQuint")
anim("windowsIn", 10, "easeOutQuint", "gnomed")
anim("windowsOut", 2.5, "easeOutQuint", "popin 87%")

-- Fade animations
anim("fadeIn", 2.0, "almostLinear")
anim("fadeOut", 1.8, "almostLinear")
anim("fade", 3.0, "quick")

-- Layer animations
anim("layers", 4.5, "easeOutQuint")
anim("layersIn", 4.5, "launcherCurve", "popin 90%")
anim("layersOut", 2.8, "launcherCurve", "popin 90%")
anim("fadeLayersIn", 2.5, "easeOutQuint")
anim("fadeLayersOut", 2.2, "easeOutQuint")

-- Workspace animations
anim("workspaces", 2.0, "almostLinear", "fade")
anim("workspacesIn", 1.5, "almostLinear", "fade")
anim("workspacesOut", 2.0, "almostLinear", "fade")

-- Misc animations
anim("border", 5.0, "easeOutQuint")
anim("zoomFactor", 7.0, "quick")
