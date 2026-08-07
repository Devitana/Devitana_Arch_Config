-- permissions.lua
-- Source-of-truth for hypr/permissions/permissions.conf
-- Hyprland permission rules and polkit autostart.

return {
  -- Commented-out ecosystem enforcement block (uncomment to enable):
  -- ecosystem = { enforce_permissions = 1 },

  -- Commented-out permission rules (uncomment to activate specific tools):
  -- permissions = {
  --   { path = "/usr/(bin|local/bin)/grim",                              capability = "screencopy", action = "allow" },
  --   { path = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland",   capability = "screencopy", action = "allow" },
  --   { path = "/usr/(bin|local/bin)/hyprpm",                            capability = "plugin",     action = "allow" },
  -- },

  -- exec-once entries that go directly in this conf:
  execs = {
    { cmd = "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1" },
  },
}
