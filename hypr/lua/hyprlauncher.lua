-- hyprlauncher.lua  –  app launcher configuration
-- Generates: hypr/hyprlauncher.conf

hl.comment("General")
hl.config("general", {
    { "grab_focus", true },
})

hl.raw("")
hl.comment("Cache (tracks frequently used apps!)")
hl.config("cache", {
    { "enabled", true },
})

hl.raw("")
hl.comment("Finder behavior")
hl.config("finders", {
    { "default_finder", "desktop" },
    { "desktop_icons",  true      },
    { "math_prefix",    "="       },
})

hl.raw("")
hl.comment("UI")
hl.config("ui", {
    { "window_size", "800 400" },
    { "anchor",      "top"     },
    { "margin_top",  60        },
})
