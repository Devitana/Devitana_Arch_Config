
-- permissions/permissions.lua
-- Hyprland 0.57.0

--------------------
--- PERMISSIONS ---
--------------------

-- Hyprland's built-in permission system
--
-- Requires hyprland-guiutils for permission prompts.
-- Disabled until explicitly enabled.

hl.config({
    ecosystem = {
        enforce_permissions = true,
    },
})

------------------------
--- PERMISSION RULES ---
------------------------

-- Optional: allow screenshots with grim
--
-- Requires enforce_permissions = true.
--
-- hl.permission({
--     binary = "/usr/bin/grim",
--     type = "screencopy",
--     mode = "ask",
-- })

-- Other supported modes:
--
-- "allow" = Always permit
-- "ask"   = Ask for authorization
-- "deny"  = Always deny
