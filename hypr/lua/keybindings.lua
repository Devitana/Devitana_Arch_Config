-- keybindings.lua  –  all key/mouse bindings
-- Generates: hypr/keyboard/keybindings.conf

hl.variable("mainMod", "SUPER")
hl.comment('Sets "Windows" key as main modifier')
hl.raw("")

-- ─── app launchers ───────────────────────────────────────────────────────────

hl.comment("Example binds, see https://wiki.hypr.land/Configuring/Binds/ for more")
hl.keyword("bind", "$mainMod, T, exec, $terminal")
hl.keyword("bind", "$mainMod, Q, killactive,")
hl.keyword("bind", "$mainMod, M, exit,")
hl.keyword("bind", "$mainMod, E, exec, $fileManager")
hl.keyword("bind", "$mainMod, V, togglefloating,")
hl.keyword("bind", "$mainMod, R, exec, $menu")
hl.keyword("bind", "$mainMod, P, pseudo,")
hl.comment("dwindle")
hl.keyword("bind", "$mainMod, L, exec, hyprlock")
hl.keyword("bind", "$mainMod, F, fullscreen, 0")
hl.raw("")

-- ─── focus ───────────────────────────────────────────────────────────────────

hl.comment("Move focus with mainMod + arrow keys")
hl.keyword("bind", "$mainMod, left,  movefocus, l")
hl.keyword("bind", "$mainMod, right, movefocus, r")
hl.keyword("bind", "$mainMod, up,    movefocus, u")
hl.keyword("bind", "$mainMod, down,  movefocus, d")
hl.raw("")

-- ─── workspace switch ────────────────────────────────────────────────────────

hl.comment("Switch workspaces with mainMod + [0-9]")
for i = 1, 9 do
    hl.keyword("bind", "$mainMod, " .. i .. ", workspace, " .. i)
end
hl.keyword("bind", "$mainMod, 0, workspace, 10")
hl.raw("")

-- ─── move window to workspace ────────────────────────────────────────────────

hl.comment("Move active window to a workspace with mainMod + SHIFT + [0-9]")
for i = 1, 9 do
    hl.keyword("bind", "$mainMod SHIFT, " .. i .. ", movetoworkspace, " .. i)
end
hl.keyword("bind", "$mainMod SHIFT, 0, movetoworkspace, 10")
hl.raw("")

-- ─── special workspace (scratchpad) ──────────────────────────────────────────

hl.comment("Example special workspace (scratchpad)")
hl.keyword("bind", "$mainMod, S, togglespecialworkspace, magic")
hl.keyword("bind", "$mainMod SHIFT, S, movetoworkspace, special:magic")
hl.raw("")

-- ─── mouse workspace scroll ──────────────────────────────────────────────────

hl.comment("Scroll through existing workspaces with mainMod + scroll")
hl.keyword("bind", "$mainMod, mouse_down, workspace, e+1")
hl.keyword("bind", "$mainMod, mouse_up,   workspace, e-1")
hl.raw("")

-- ─── mouse window move / resize ──────────────────────────────────────────────

hl.comment("Move/resize windows with mainMod + LMB/RMB and dragging")
hl.keyword("bindm", "$mainMod, mouse:272, movewindow")
hl.keyword("bindm", "$mainMod, mouse:273, resizewindow")
hl.raw("")

-- ─── multimedia / laptop keys ────────────────────────────────────────────────

hl.comment("Laptop multimedia keys for volume and LCD brightness")
hl.keyword("bindel", ",XF86AudioRaiseVolume,  exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")
hl.keyword("bindel", ",XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
hl.keyword("bindel", ",XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
hl.keyword("bindel", ",XF86AudioMicMute,      exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
hl.keyword("bindel", ",XF86MonBrightnessUp,   exec, brightnessctl -e4 -n2 set 5%+")
hl.keyword("bindel", ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-")
hl.raw("")

-- ─── media player ────────────────────────────────────────────────────────────

hl.comment("Requires playerctl")
hl.keyword("bindl", ", XF86AudioNext,  exec, playerctl next")
hl.keyword("bindl", ", XF86AudioPause, exec, playerctl play-pause")
hl.keyword("bindl", ", XF86AudioPlay,  exec, playerctl play-pause")
hl.keyword("bindl", ", XF86AudioPrev,  exec, playerctl previous")
