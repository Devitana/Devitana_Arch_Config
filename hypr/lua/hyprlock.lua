-- hyprlock.lua  –  lock screen layout
-- Generates: hypr/hyprlock.conf
-- Note: hyprlock uses the same block syntax as Hyprland core.

hl.config("background", {
    { "monitor",      ""                         },
    { "path",         "~/Pictures/wallpaper.jpg" },
    { "blur_passes",  3 },
    { "blur_size",    8 },
})

hl.raw("")
hl.config("label", {
    { "monitor",   ""                                        },
    { "text",      'cmd[update:1000] echo "$(date +"%H:%M")"' },
    { "font_size", 60 },
    { "position",  "0, 80" },
    { "halign",    "center" },
    { "valign",    "center" },
})

hl.raw("")
hl.config("input-field", {
    { "monitor",           ""            },
    { "size",              "250, 50"     },
    { "outline_thickness", 2             },
    { "dots_size",         0.3           },
    { "dots_spacing",      0.2           },
    { "fade_on_empty",     false         },
    { "placeholder_text",  "Password..." },
    { "halign",            "center"      },
    { "valign",            "center"      },
})
