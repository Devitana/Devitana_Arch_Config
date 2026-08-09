-- permissions.lua  –  polkit agent and permission declarations
-- Generates: hypr/permissions/permissions.conf
--
-- The ecosystem{} block and permission= lines are intentionally commented
-- out; they are kept here so they can be un-commented when needed.

hl.raw("# ecosystem {")
hl.raw("#   enforce_permissions = 1")
hl.raw("# }")
hl.raw("")
hl.raw("# permission = /usr/(bin|local/bin)/grim, screencopy, allow")
hl.raw("# permission = /usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland, screencopy, allow")
hl.raw("# permission = /usr/(bin|local/bin)/hyprpm, plugin, allow")
hl.keyword("exec-once", "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
