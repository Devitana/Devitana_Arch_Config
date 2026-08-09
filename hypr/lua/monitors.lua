-- monitors.lua  –  physical monitor declarations
-- Generates: hypr/monitors/monitors.conf

hl.heading("MONITOR CONFIGURATION")
hl.raw("")
hl.comment("Left monitor")
hl.monitor("DP-3,2560x1440@144,0x0,1")
hl.raw("")
hl.comment("Center (primary) monitor")
hl.monitor("DP-2,2560x1440@144,2560x0,1")
hl.raw("")
hl.comment("Right monitor")
hl.monitor("DP-1,2560x1440@144,5120x0,1")
