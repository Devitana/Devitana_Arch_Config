-- workspaces.lua
-- Source-of-truth for hypr/monitors/workspaces.conf
-- Window rules and workspace rules.

return {
  header = "##############################\n### WINDOWS AND WORKSPACES ###\n##############################\n",

  windowrules = {
    -- { rule, match, comment (optional) }
    { rule = "suppress_event maximize", match = "match:class .*",
      comment = "Ignore maximize requests from apps (most users keep this)" },
    { rule = "no_focus on",
      match = "match:class ^$, match:title ^$, match:xwayland 1, match:fullscreen 0, match:float 1, match:pin 0",
      comment = "Fix dragging/focus issues with certain XWayland floating windows" },
  },

  gaming_rules = {
    header = "\n#############################\n### WINDOWRULE (GAMING) ###\n#############################\n",
    comment = "# Low-latency fullscreen for games (immediate tearing + no animations)",
    rules = {
      { rule = "immediate on", match = "match:fullscreen 1" },
      { rule = "no_anim on",   match = "match:fullscreen 1" },
    },
  },
}
