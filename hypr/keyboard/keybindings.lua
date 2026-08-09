-- keyboard/keybindings.lua

local mainMod = "SUPER"

--------------------------
--- APPLICATION BINDS ---
--------------------------

-- Terminal, File Manager, Launcher, Lock Screen
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("hyprlauncher"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

--------------------------
--- WINDOW MANAGEMENT ----
--------------------------

-- Close active window (uses singular hl.dsp.window.close())
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

-- Toggle Floating / Fullscreen / Pseudo
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("hyprctl dispatch togglefloating"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("hyprctl dispatch fullscreen 0"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprctl dispatch pseudo"))

-- Exit Hyprland session
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprctl dispatch exit"))

------------------------
--- FOCUS MOVEMENT ---
------------------------

hl.bind(mainMod .. " + left",  hl.dsp.exec_cmd("hyprctl dispatch movefocus l"))
hl.bind(mainMod .. " + right", hl.dsp.exec_cmd("hyprctl dispatch movefocus r"))
hl.bind(mainMod .. " + up",    hl.dsp.exec_cmd("hyprctl dispatch movefocus u"))
hl.bind(mainMod .. " + down",  hl.dsp.exec_cmd("hyprctl dispatch movefocus d"))

---------------------
--- WORKSPACES ---
---------------------

-- Switch & Move active window to workspaces 1 - 9
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.exec_cmd("hyprctl dispatch workspace " .. i))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.exec_cmd("hyprctl dispatch movetoworkspace " .. i))
end

-- Workspace 10
hl.bind(mainMod .. " + 0", hl.dsp.exec_cmd("hyprctl dispatch workspace 10"))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspace 10"))

-- Special Workspace (Scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("hyprctl dispatch togglespecialworkspace magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspace special:magic"))

-- Scroll through existing workspaces with mouse wheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.exec_cmd("hyprctl dispatch workspace e+1"))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.exec_cmd("hyprctl dispatch workspace e-1"))

----------------------------
--- MEDIA & HARDWARE KEYS ---
----------------------------

-- Volume & Brightness Controls
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"))

-- Media Player Controls
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"))