-- Redirects to configurations

--autostart

require("autostart.programs")
require("autostart.startup")

--environment & variables 

require("env_var.current_gpu")
require("env_var.env")

--keyboard binds

require("keyboard.keybindings")
require("keyboard.layout")

--monitor configuration

require("monitors.monitors")
require("monitors.waybar")
require("monitors.windows")
require("monitors.workspaces")

--permissions

require("permissions.permissions")

--other scripts
