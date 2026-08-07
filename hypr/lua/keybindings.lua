-- keybindings.lua
-- Source-of-truth for hypr/keyboard/keybindings.conf
-- All Hyprland keybindings.

local M = {}

-- Main modifier key
M.mainMod = "SUPER"

-- bind/bindm/bindel/bindl entries
-- type: "bind" (default) | "bindm" | "bindel" | "bindl"
M.binds = {
  -- App launchers
  { mods = "$mainMod",       key = "T",           action = "exec",               args = "$terminal" },
  { mods = "$mainMod",       key = "Q",           action = "killactive" },
  { mods = "$mainMod",       key = "M",           action = "exit" },
  { mods = "$mainMod",       key = "E",           action = "exec",               args = "$fileManager" },
  { mods = "$mainMod",       key = "V",           action = "togglefloating" },
  { mods = "$mainMod",       key = "R",           action = "exec",               args = "$menu" },
  { mods = "$mainMod",       key = "P",           action = "pseudo",             comment = "dwindle" },
  { mods = "$mainMod",       key = "L",           action = "exec",               args = "hyprlock" },
  { mods = "$mainMod",       key = "F",           action = "fullscreen",         args = "0" },

  -- Move focus
  { mods = "$mainMod",       key = "left",        action = "movefocus",          args = "l" },
  { mods = "$mainMod",       key = "right",       action = "movefocus",          args = "r" },
  { mods = "$mainMod",       key = "up",          action = "movefocus",          args = "u" },
  { mods = "$mainMod",       key = "down",        action = "movefocus",          args = "d" },

  -- Switch workspace
  { mods = "$mainMod",       key = "1",           action = "workspace",          args = "1" },
  { mods = "$mainMod",       key = "2",           action = "workspace",          args = "2" },
  { mods = "$mainMod",       key = "3",           action = "workspace",          args = "3" },
  { mods = "$mainMod",       key = "4",           action = "workspace",          args = "4" },
  { mods = "$mainMod",       key = "5",           action = "workspace",          args = "5" },
  { mods = "$mainMod",       key = "6",           action = "workspace",          args = "6" },
  { mods = "$mainMod",       key = "7",           action = "workspace",          args = "7" },
  { mods = "$mainMod",       key = "8",           action = "workspace",          args = "8" },
  { mods = "$mainMod",       key = "9",           action = "workspace",          args = "9" },
  { mods = "$mainMod",       key = "0",           action = "workspace",          args = "10" },

  -- Move window to workspace
  { mods = "$mainMod SHIFT", key = "1",           action = "movetoworkspace",    args = "1" },
  { mods = "$mainMod SHIFT", key = "2",           action = "movetoworkspace",    args = "2" },
  { mods = "$mainMod SHIFT", key = "3",           action = "movetoworkspace",    args = "3" },
  { mods = "$mainMod SHIFT", key = "4",           action = "movetoworkspace",    args = "4" },
  { mods = "$mainMod SHIFT", key = "5",           action = "movetoworkspace",    args = "5" },
  { mods = "$mainMod SHIFT", key = "6",           action = "movetoworkspace",    args = "6" },
  { mods = "$mainMod SHIFT", key = "7",           action = "movetoworkspace",    args = "7" },
  { mods = "$mainMod SHIFT", key = "8",           action = "movetoworkspace",    args = "8" },
  { mods = "$mainMod SHIFT", key = "9",           action = "movetoworkspace",    args = "9" },
  { mods = "$mainMod SHIFT", key = "0",           action = "movetoworkspace",    args = "10" },

  -- Special workspace (scratchpad)
  { mods = "$mainMod",       key = "S",           action = "togglespecialworkspace", args = "magic" },
  { mods = "$mainMod SHIFT", key = "S",           action = "movetoworkspace",    args = "special:magic" },

  -- Scroll workspaces
  { mods = "$mainMod",       key = "mouse_down",  action = "workspace",          args = "e+1" },
  { mods = "$mainMod",       key = "mouse_up",    action = "workspace",          args = "e-1" },

  -- Move/resize windows with mouse (bindm)
  { type = "bindm", mods = "$mainMod", key = "mouse:272", action = "movewindow" },
  { type = "bindm", mods = "$mainMod", key = "mouse:273", action = "resizewindow" },

  -- Media / brightness keys (bindel)
  { type = "bindel", mods = "", key = "XF86AudioRaiseVolume",  action = "exec", args = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+" },
  { type = "bindel", mods = "", key = "XF86AudioLowerVolume",  action = "exec", args = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" },
  { type = "bindel", mods = "", key = "XF86AudioMute",         action = "exec", args = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
  { type = "bindel", mods = "", key = "XF86AudioMicMute",      action = "exec", args = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
  { type = "bindel", mods = "", key = "XF86MonBrightnessUp",   action = "exec", args = "brightnessctl -e4 -n2 set 5%+" },
  { type = "bindel", mods = "", key = "XF86MonBrightnessDown", action = "exec", args = "brightnessctl -e4 -n2 set 5%-" },

  -- Playerctl media keys (bindl)
  { type = "bindl", mods = "", key = "XF86AudioNext",  action = "exec", args = "playerctl next",        comment = "Requires playerctl" },
  { type = "bindl", mods = "", key = "XF86AudioPause", action = "exec", args = "playerctl play-pause" },
  { type = "bindl", mods = "", key = "XF86AudioPlay",  action = "exec", args = "playerctl play-pause" },
  { type = "bindl", mods = "", key = "XF86AudioPrev",  action = "exec", args = "playerctl previous" },
}

return M
