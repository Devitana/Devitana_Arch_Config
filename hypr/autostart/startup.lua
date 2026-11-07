
-- autostart/startup.lua
-- Hyprland 0.57.0

-------------------------
--- AUTOSTART ---
-------------------------

hl.on("hyprland.start", function()

    --------------------------
    --- DESKTOP COMPONENTS ---
    --------------------------

    -- Waybar (status bar)
    hl.exec_cmd("waybar")

    -- Hyprpaper (wallpapers)
    hl.exec_cmd("hyprpaper")

    -- Hypridle (idle management)
    hl.exec_cmd("hypridle")

    --------------------------
    --- SYSTEM SERVICES ---
    --------------------------

    -- Bluetooth tray applet
    hl.exec_cmd("blueman-applet")

    -- Polkit authentication agent
    hl.exec_cmd(
        "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
    )

    --------------------------
    --- WAYBAR UPDATES ---
    --------------------------

    -- Refresh signal 2 after startup
    hl.exec_cmd(
        "sleep 60 && pkill -RTMIN+2 -x waybar"
    )

    -- Refresh signal 1 after startup
    hl.exec_cmd(
        "sleep 60 && pkill -RTMIN+1 -x waybar"
    )

end)
