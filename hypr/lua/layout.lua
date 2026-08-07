-- layout.lua  –  keyboard / mouse / touchpad / gesture / device config
-- Generates: hypr/keyboard/layout.conf

hl.config("input", {
    { "kb_layout",  "de" },
    { "kb_variant", ""   },
    { "kb_model",   ""   },
    { "kb_options", ""   },
    { "kb_rules",   ""   },
    { "follow_mouse",   1     },
    { "mouse_refocus",  false },
    { "sensitivity",    0     },
    { "touchpad", {
        { "natural_scroll", false },
    }},
})

hl.raw("")
hl.comment("See https://wiki.hypr.land/Configuring/Gestures")
hl.keyword("gesture", "3, horizontal, workspace")

hl.raw("")
hl.comment("Example per-device config")
hl.comment("See https://wiki.hypr.land/Configuring/Keywords/#per-device-input-configs for more")
hl.config("device", {
    { "name",        "epic-mouse-v1" },
    { "sensitivity", -0.5            },
})
