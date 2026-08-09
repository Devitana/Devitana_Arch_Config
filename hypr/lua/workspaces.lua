-- workspaces.lua  –  window rules and workspace rules
-- Generates: hypr/monitors/workspaces.conf

hl.heading("WINDOWS AND WORKSPACES")
hl.raw("")
hl.comment("Ignore maximize requests from apps (most users keep this)")
hl.keyword("windowrule", "suppress_event maximize, match:class .*")
hl.raw("")
hl.comment("Fix dragging/focus issues with certain XWayland floating windows")
hl.keyword("windowrule", "no_focus on, match:class ^$, match:title ^$, match:xwayland 1, match:fullscreen 0, match:float 1, match:pin 0")
hl.raw("")
hl.heading("WINDOWRULE (GAMING)")
hl.raw("")
hl.comment("Low-latency fullscreen for games (immediate tearing + no animations)")
hl.keyword("windowrule", "immediate on, match:fullscreen 1")
hl.keyword("windowrule", "no_anim on, match:fullscreen 1")
