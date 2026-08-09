-- Monitors setup for my triple monitor setup. This is a 3x 2560x1440@144hz setup with the left and right monitors rotated to portrait mode.

-- left monitor
hl.monitor({
    output = "DP-3",
    mode = "2560x1440@144",
    position = "0x0",
    scale = 1
})

-- center monitor
hl.monitor({
    output = "DP-2",
    mode = "2560x1440@144",
    position = "2560x0",
    scale = 1
})

-- right monitor
hl.monitor({
    output = "DP-1",
    mode = "2560x1440@144",
    position = "5120x0",
    scale = 1
})