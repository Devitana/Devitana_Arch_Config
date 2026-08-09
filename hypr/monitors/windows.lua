-- monitors/windows.lua

----------------------
--- GENERAL CONFIG ---
----------------------

hl.general = {
    gaps_in = 3,
    gaps_out = 6,
    border_size = 2,
    col = {
        active_border = "rgba(33ccffee) rgba(00ff99ee) 45deg",
        inactive_border = "rgba(595959aa)",
    },
    resize_on_border = true,
    allow_tearing = true,
    layout = "dwindle",
}

-------------------
--- DECORATION ---
-------------------

hl.decoration = {
    rounding = 6,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
        enabled = false,
        range = 4,
        render_power = 3,
        color = "rgba(1a1a1aee)",
    },
    blur = {
        enabled = true,
        size = 10,
        passes = 4,
        new_optimizations = true,
        vibrancy = 0.1696,
    },
}

------------------
--- ANIMATIONS ---
------------------

hl.animations = {
    enabled = true,

    -- Beziers (array of curves)
    bezier = {
        "easeOutQuint, 0.23, 1, 0.32, 1",
        "easeInOutCubic, 0.65, 0.05, 0.36, 1",
        "linear, 0, 0, 1, 1",
        "almostLinear, 0.5, 0.5, 0.75, 1",
        "quick, 0.15, 0, 0.1, 1",
        "launcherCurve, 0.16, 1, 0.3, 1",
    },

    -- Animations (array of rules)
    animation = {
        "global, 1, 10, default",

        -- Window Animations
        "windows, 1, 4.5, easeOutQuint",
        "windowsIn, 1, 10, easeOutQuint, gnomed",
        "windowsOut, 1, 2.5, easeOutQuint, popin 87%",

        -- Fade Animations
        "fadeIn, 1, 2.0, almostLinear",
        "fadeOut, 1, 1.8, almostLinear",
        "fade, 1, 3.0, quick",

        -- Layer Animations
        "layers, 1, 4.5, easeOutQuint",
        "layersIn, 1, 4.5, launcherCurve, popin 90%",
        "layersOut, 1, 2.8, launcherCurve, popin 90%",
        "fadeLayersIn, 1, 2.5, easeOutQuint",
        "fadeLayersOut, 1, 2.2, easeOutQuint",

        -- Workspace Animations
        "workspaces, 1, 2.0, almostLinear, fade",
        "workspacesIn, 1, 1.5, almostLinear, fade",
        "workspacesOut, 1, 2.0, almostLinear, fade",

        -- Misc
        "border, 1, 5.0, easeOutQuint",
        "zoomFactor, 1, 7.0, quick",
    },
}

---------------
--- LAYOUTS ---
---------------

hl.dwindle = {
    preserve_split = true,
}

hl.master = {
    new_status = "master",
}

------------
--- MISC ---
------------

hl.misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = false,
}