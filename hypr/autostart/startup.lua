-- autostart/startup.lua

hl.on("hyprland.start", function()
    -- Waybar
    hl.exec_cmd("waybar")

    -- Wallpapers
    hl.exec_cmd("hyprpaper")

    -- Idle manager
    hl.exec_cmd("hypridle")

    -- Bluetooth manager
    hl.exec_cmd("blueman-applet")

    -- Waybar updates (weather, system updates)
    hl.exec_cmd("sleep 60 && pkill -RTMIN+2 waybar")
    hl.exec_cmd("sleep 60 && pkill -RTMIN+1 waybar")
end)