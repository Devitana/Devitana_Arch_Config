-- startup.lua
-- Source-of-truth for hypr/autostart/startup.conf
-- Lists exec-once commands run at Hyprland startup.
-- Set `enabled = false` to comment out an entry.

return {
  header = "#################\n### AUTOSTART ###\n#################\n",
  comment = "# GPU profile is selected during install and written to env_var/current_gpu.conf\n",
  execs = {
    -- { cmd = "...", comment = "...", enabled = true/false }
    { cmd = "$terminal",                                      comment = "Terminal example (uncomment if you want a terminal at startup)", enabled = false },
    { cmd = "nm-applet &",                                    comment = "Network applet",                                                enabled = false },
    { cmd = "waybar &",                                       comment = "Waybar" },
    { cmd = "hyprpaper &",                                    comment = "Wallpapers" },
    { cmd = "hypridle &",                                     comment = "Idle manager (locks screen + DPMS off, no suspend)" },
    { cmd = "blueman-applet &",                               comment = "Bluetooth manager" },
    { cmd = "sleep 60 && pkill -RTMIN+2 waybar",              comment = "Waybar updates (weather, system updates)\nweather" },
    { cmd = "sleep 60 && pkill -RTMIN+1 waybar",              comment = "updates" },
  },
}
