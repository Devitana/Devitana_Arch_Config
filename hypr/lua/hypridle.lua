-- hypridle.lua
-- Source-of-truth for hypr/hypridle.conf
-- Screen idle / DPMS configuration.

return {
  general = {
    lock_cmd          = "pidof hyprlock || hyprlock",
    before_sleep_cmd  = '""',
    after_sleep_cmd   = '""',
  },

  listeners = {
    -- { timeout (seconds), on_timeout, on_resume (optional) }
    {
      timeout    = 300,
      on_timeout = "loginctl lock-session",
    },
    {
      timeout    = 600,
      on_timeout = "hyprctl dispatch dpms off",
      on_resume  = "hyprctl dispatch dpms on",
    },
  },
}
