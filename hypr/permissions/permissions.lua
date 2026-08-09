-- permissions/permissions.lua

--------------------
--- PERMISSIONS ----
--------------------

-- Ecosystem permissions (uncomment if needed)
-- hl.ecosystem = {
--     enforce_permissions = true,
-- }

-- hl.permission({
--     path = "/usr/(bin|local/bin)/grim",
--     type = "screencopy",
--     allow = true,
-- })

--------------------
--- AUTOSTART ------
--------------------

-- Polkit Authentication Agent
hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end)