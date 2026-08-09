-- hypridle.lua  –  idle management (screen lock + DPMS)
-- Generates: hypr/hypridle.conf
-- Note: hypridle uses the same block/keyword syntax as Hyprland core.

hl.config("general", {
    { "lock_cmd",          "pidof hyprlock || hyprlock" },
    { "before_sleep_cmd",  "" },
    { "after_sleep_cmd",   "" },
})

hl.raw("")
hl.config("listener", {
    { "timeout",    300 },
    { "on-timeout", "loginctl lock-session" },
})

hl.raw("")
hl.config("listener", {
    { "timeout",   600 },
    { "on-timeout", "hyprctl dispatch dpms off" },
    { "on-resume",  "hyprctl dispatch dpms on"  },
})
