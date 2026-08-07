-- monitors.lua
-- Source-of-truth for hypr/monitors/monitors.conf
-- Monitor layout configuration.

return {
  header = "#############################\n### MONITOR CONFIGURATION ###\n#############################\n",
  monitors = {
    -- { name, resolution, position, scale, comment (optional) }
    { name = "DP-3", res = "2560x1440@144", pos = "0x0",    scale = "1", comment = "Left monitor" },
    { name = "DP-2", res = "2560x1440@144", pos = "2560x0", scale = "1", comment = "Center (primary) monitor" },
    { name = "DP-1", res = "2560x1440@144", pos = "5120x0", scale = "1", comment = "Right monitor" },
  },
}
