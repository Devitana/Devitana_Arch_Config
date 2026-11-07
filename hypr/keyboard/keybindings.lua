
-- keyboard/keybindings.lua
-- Hyprland 0.57.0 - Native Lua configuration

local mainMod = "SUPER"
local programs = require("autostart.programs")

--------------------------
--- APPLICATION BINDS ---
--------------------------

-- Terminal
hl.bind(mainMod .. " + T",
    hl.dsp.exec_cmd(programs.terminal))

-- File Manager
hl.bind(mainMod .. " + E",
    hl.dsp.exec_cmd(programs.fileManager))

-- Application Launcher
hl.bind(mainMod .. " + R",
    hl.dsp.exec_cmd(programs.menu))

-- Browser
hl.bind(mainMod .. " + B",
    hl.dsp.exec_cmd("firefox"))

-- Lock Screen
hl.bind(mainMod .. " + L",
    hl.dsp.exec_cmd("hyprlock"))


--------------------------
--- WINDOW MANAGEMENT ---
--------------------------

hl.config({
    binds = {
        drag_threshold = 10,
    },
})

-- Close active window
hl.bind(mainMod .. " + Q",
    hl.dsp.window.close())

-- Toggle floating / tiled
hl.bind(mainMod .. " + V",
    hl.dsp.window.float({
        action = "toggle",
    }))

-- Toggle true fullscreen
hl.bind(mainMod .. " + F",
    hl.dsp.window.fullscreen({
        mode = "fullscreen",
        action = "toggle",
    }))

-- Toggle pseudotiling
hl.bind(mainMod .. " + P",
    hl.dsp.window.pseudo({
        action = "toggle",
    }))

-- SUPER + Left mouse: Move window
hl.bind(
    mainMod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)

-- SUPER + Right mouse: Resize window
hl.bind(
    mainMod .. " + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true }
)

-- Exit Hyprland session
hl.bind(mainMod .. " + M",
    hl.dsp.exit())

------------------------
--- FOCUS MOVEMENT ---
------------------------

hl.bind(mainMod .. " + left",
    hl.dsp.focus({ direction = "left" }))

hl.bind(mainMod .. " + right",
    hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + up",
    hl.dsp.focus({ direction = "up" }))

hl.bind(mainMod .. " + down",
    hl.dsp.focus({ direction = "down" }))

---------------------
--- WORKSPACES ---
---------------------

-- SUPER + 1-9: Switch workspace
-- SUPER + 0: Workspace 10
-- SUPER + SHIFT + number: Move window

for i = 1, 10 do
    local key = i % 10

    -- Switch workspace
    hl.bind(
        mainMod .. " + " .. key,
        hl.dsp.focus({
            workspace = i,
        })
    )

    -- Move window to workspace
    hl.bind(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({
            workspace = i,
        })
    )
end

-------------------------
--- SPECIAL WORKSPACE ---
-------------------------

-- Show / hide scratchpad
hl.bind(mainMod .. " + S",
    hl.dsp.workspace.toggle_special("magic"))

-- Move active window to scratchpad
hl.bind(mainMod .. " + SHIFT + S",
    hl.dsp.window.move({
        workspace = "special:magic",
    }))

-------------------------
--- MOUSE WORKSPACES ---
-------------------------

-- Next existing workspace
hl.bind(mainMod .. " + mouse_down",
    hl.dsp.focus({
        workspace = "e+1",
    }))

-- Previous existing workspace
hl.bind(mainMod .. " + mouse_up",
    hl.dsp.focus({
        workspace = "e-1",
    }))

----------------------------
--- MEDIA & HARDWARE KEYS ---
----------------------------

-- Volume up
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(
        "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
    ),
    { locked = true, repeating = true }
)

-- Volume down
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(
        "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ),
    { locked = true, repeating = true }
)

-- Mute audio
hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    ),
    { locked = true }
)

-- Mute microphone
hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ),
    { locked = true }
)

-- Increase brightness
hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd(
        "brightnessctl -e4 -n2 set 5%+"
    ),
    { locked = true, repeating = true }
)

-- Decrease brightness
hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd(
        "brightnessctl -e4 -n2 set 5%-"
    ),
    { locked = true, repeating = true }
)

-------------------
--- MEDIA PLAYER ---
-------------------

-- Next track
hl.bind(
    "XF86AudioNext",
    hl.dsp.exec_cmd("playerctl next"),
    { locked = true }
)

-- Play / pause
hl.bind(
    "XF86AudioPause",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true }
)

hl.bind(
    "XF86AudioPlay",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true }
)

-- Previous track
hl.bind(
    "XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl previous"),
    { locked = true }
)
