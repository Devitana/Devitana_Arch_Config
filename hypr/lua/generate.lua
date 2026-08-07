#!/usr/bin/env lua
--
-- generate.lua  –  Hyprland Lua → .conf generator
--
-- Usage:
--   cd <repo-root>/hypr/lua
--   lua generate.lua [--check]
--
-- Options:
--   (no flag)  Write generated .conf files to their canonical paths under hypr/
--   --check    Dry-run: print a diff-like report and exit non-zero if any file
--              would change (useful in CI to detect drift).
--
-- All source-of-truth Lua files live alongside this script in hypr/lua/.
-- Generated .conf files are written to their original paths under hypr/.
-- Do NOT hand-edit the generated .conf files; edit the .lua sources instead.
--

-- ────────────────────────────────────────────────────────────────────────────
-- Helper utilities
-- ────────────────────────────────────────────────────────────────────────────

local check_mode = false
local drift_found = false

for _, arg in ipairs(arg or {}) do
  if arg == "--check" then check_mode = true end
end

-- Resolve paths relative to this script's directory (hypr/lua/)
local script_dir = debug.getinfo(1, "S").source:match("^@(.+/)[^/]+$") or "./"
-- Output root is one level up (hypr/)
local hypr_dir   = script_dir .. "../"

local function out_path(rel)
  return hypr_dir .. rel
end

--- Read a file; returns nil if it does not exist.
local function read_file(path)
  local fh = io.open(path, "r")
  if not fh then return nil end
  local s = fh:read("*a")
  fh:close()
  return s
end

--- Write content to path (or just compare in check mode).
local function write_file(path, content)
  if check_mode then
    local existing = read_file(path)
    if existing ~= content then
      drift_found = true
      io.stderr:write(("[DRIFT] %s would change\n"):format(path))
    else
      io.stdout:write(("[OK]    %s\n"):format(path))
    end
  else
    local fh = assert(io.open(path, "w"), "Cannot write: " .. path)
    fh:write(content)
    fh:close()
    io.stdout:write(("Written: %s\n"):format(path))
  end
end

--- Convert a Lua boolean/number/string to Hyprland value string.
local function to_val(v)
  if type(v) == "boolean" then
    return v and "true" or "false"
  end
  return tostring(v)
end

--- Emit a simple key = value line (no section nesting).
local function kv(key, value)
  return key .. " = " .. to_val(value) .. "\n"
end

--- Emit a block:
---   name {
---     k = v
---     ...
---   }
local function block(name, tbl, keys)
  local lines = { name .. " {\n" }
  for _, k in ipairs(keys) do
    local v = tbl[k]
    if v ~= nil then
      lines[#lines+1] = "    " .. k .. " = " .. to_val(v) .. "\n"
    end
  end
  lines[#lines+1] = "}\n"
  return table.concat(lines)
end

--- Emit an env line.
local function env_line(key, value)
  return "env = " .. key .. "," .. value .. "\n"
end

-- ────────────────────────────────────────────────────────────────────────────
-- Load Lua source modules
-- ────────────────────────────────────────────────────────────────────────────

package.path = script_dir .. "?.lua;" .. package.path

local programs     = require("programs")
local startup      = require("startup")
local env          = require("env")
local gpu_amd      = require("gpu_amd")
local gpu_intel    = require("gpu_intel")
local gpu_nvidia   = require("gpu_nvidia")
local gpu_generic  = require("gpu_generic")
local monitors_src = require("monitors")
local waybar_src   = require("waybar")
local windows_src  = require("windows")
local workspaces_src = require("workspaces")
local layout_src   = require("layout")
local keybindings_src = require("keybindings")
local permissions_src = require("permissions")
local hypridle_src = require("hypridle")
local hyprlock_src = require("hyprlock")
local hyprlauncher_src = require("hyprlauncher")
local hyprtoolkit_src  = require("hyprtoolkit")
local hyprland_src     = require("hyprland")

-- ────────────────────────────────────────────────────────────────────────────
-- Generator functions (one per .conf file)
-- ────────────────────────────────────────────────────────────────────────────

-- AUTO-GENERATED header appended to every file
local GENERATED_HEADER =
"# ============================================================\n" ..
"# AUTO-GENERATED – do not edit by hand.\n" ..
"# Source: hypr/lua/  |  Regenerate: cd hypr/lua && lua generate.lua\n" ..
"# ============================================================\n\n"

--- hypr/autostart/programs.conf
local function gen_programs()
  local out = { GENERATED_HEADER, programs.header, "\n" }
  local first = true
  for _, v in ipairs(programs.vars) do
    if v.comment and first then
      out[#out+1] = "# " .. v.comment .. "\n"
      first = false
    end
    out[#out+1] = "$" .. v.name .. " = " .. v.value .. "\n"
  end
  return table.concat(out)
end

--- hypr/autostart/startup.conf
local function gen_startup()
  local out = { GENERATED_HEADER, startup.header, "\n" }
  if startup.comment then out[#out+1] = startup.comment .. "\n" end
  for _, e in ipairs(startup.execs) do
    if e.comment then
      -- Handle multi-line comments by prefixing each line
      for line in (e.comment .. "\n"):gmatch("([^\n]*)\n") do
        out[#out+1] = "# " .. line .. "\n"
      end
    end
    if e.enabled == false then
      out[#out+1] = "# exec-once = " .. e.cmd .. "\n"
    else
      out[#out+1] = "exec-once = " .. e.cmd .. "\n"
    end
  end
  return table.concat(out)
end

--- hypr/env_var/env.conf
local function gen_env()
  local out = { GENERATED_HEADER }
  for _, section in ipairs(env.sections) do
    out[#out+1] = section.header .. "\n"
    for _, v in ipairs(section.vars) do
      out[#out+1] = env_line(v.key, v.value)
    end
  end
  return table.concat(out)
end

--- Generic simple env conf (AMD / generic)
local function gen_simple_env(src)
  local out = { GENERATED_HEADER, src.header, "\n" }
  for _, v in ipairs(src.vars) do
    out[#out+1] = env_line(v.key, v.value)
  end
  return table.concat(out)
end

--- Generic sectioned env conf (Intel / NVIDIA / generic with sections)
local function gen_sectioned_env(src)
  local out = { GENERATED_HEADER, src.header, "\n" }
  if src.comment then out[#out+1] = src.comment .. "\n" end
  for _, section in ipairs(src.sections or {}) do
    if section.comment then out[#out+1] = section.comment .. "\n" end
    for _, v in ipairs(section.vars or {}) do
      out[#out+1] = env_line(v.key, v.value)
    end
    -- Commented-out variant vars
    for _, cv in ipairs(section.commented_vars or {}) do
      if cv.comment then out[#out+1] = "# " .. cv.comment .. "\n" end
      out[#out+1] = "# " .. env_line(cv.key, cv.value)
    end
  end
  return table.concat(out)
end

--- hypr/monitors/monitors.conf
local function gen_monitors()
  local out = { GENERATED_HEADER, monitors_src.header, "\n" }
  for _, m in ipairs(monitors_src.monitors) do
    if m.comment then out[#out+1] = "# " .. m.comment .. "\n" end
    out[#out+1] = ("monitor=%s,%s,%s,%s\n"):format(m.name, m.res, m.pos, m.scale)
    out[#out+1] = "\n"
  end
  return table.concat(out)
end

--- hypr/monitors/waybar.conf
local function gen_waybar()
  local out = { GENERATED_HEADER, "# Waybar blur layer rules\n" }
  for _, r in ipairs(waybar_src.rules) do
    out[#out+1] = ("layerrule = match:%s, %s\n"):format(r.match, r.rule)
  end
  return table.concat(out)
end

--- hypr/monitors/windows.conf  (general, decoration, animations, dwindle, master, misc)
local function gen_windows()
  local out = { GENERATED_HEADER }
  local g = windows_src.general

  -- general block
  out[#out+1] = "general {\n"
  out[#out+1] = ("    gaps_in = %s\n"):format(g.gaps_in)
  out[#out+1] = ("    gaps_out = %s\n"):format(g.gaps_out)
  out[#out+1] = ("    border_size = %s\n"):format(g.border_size)
  out[#out+1] = "\n# Colors\n"
  out[#out+1] = ("    col.active_border = %s\n"):format(g["col.active_border"])
  out[#out+1] = ("    col.inactive_border = %s\n"):format(g["col.inactive_border"])
  out[#out+1] = "\n# Set to true enable resizing windows by clicking and dragging on borders and gaps\n"
  out[#out+1] = ("    resize_on_border = %s\n"):format(to_val(g.resize_on_border))
  out[#out+1] = "\n# Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on\n"
  out[#out+1] = ("    allow_tearing = %s\n"):format(to_val(g.allow_tearing))
  out[#out+1] = "\n"
  out[#out+1] = ("    layout = %s\n"):format(g.layout)
  out[#out+1] = "}\n\n"

  -- decoration block
  local d = windows_src.decoration
  out[#out+1] = "# Decorations\n\n"
  out[#out+1] = "decoration {\n"
  out[#out+1] = ("    rounding = %s\n"):format(d.rounding)
  out[#out+1] = ("    rounding_power = %s\n"):format(d.rounding_power)
  out[#out+1] = "\n    # Change transparency of focused and unfocused windows\n"
  out[#out+1] = ("    active_opacity = %s\n"):format(d.active_opacity)
  out[#out+1] = ("    inactive_opacity = %s\n"):format(d.inactive_opacity)
  out[#out+1] = "\n"
  local sh = d.shadow
  out[#out+1] = "    shadow {\n"
  out[#out+1] = ("        enabled = %s\n"):format(to_val(sh.enabled))
  out[#out+1] = ("        range = %s\n"):format(sh.range)
  out[#out+1] = ("        render_power = %s\n"):format(sh.render_power)
  out[#out+1] = ("        color = %s\n"):format(sh.color)
  out[#out+1] = "    }\n\n"
  out[#out+1] = "    # https://wiki.hypr.land/Configuring/Variables/#blur\n"
  local bl = d.blur
  out[#out+1] = "    blur {\n"
  out[#out+1] = ("        enabled = %s\n"):format(to_val(bl.enabled))
  out[#out+1] = ("        size = %s\n"):format(bl.size)
  out[#out+1] = ("        passes = %s\n"):format(bl.passes)
  out[#out+1] = ("        new_optimizations = %s\n"):format(to_val(bl.new_optimizations))
  out[#out+1] = ("        vibrancy = %s\n"):format(bl.vibrancy)
  out[#out+1] = "    }\n"
  out[#out+1] = "}\n\n"

  -- animations block
  local a = windows_src.animations
  out[#out+1] = "# Animations\n\n"
  out[#out+1] = "animations {\n"
  out[#out+1] = ("    enabled = %s\n"):format(a.enabled and "yes" or "no")
  out[#out+1] = "\n    # Default curves, see https://wiki.hypr.land/Configuring/Animations/#curves\n"
  out[#out+1] = "    #        NAME,           X0,   Y0,   X1,   Y1\n"
  for _, bz in ipairs(windows_src.beziers) do
    out[#out+1] = ("    bezier = %-16s %s, %s, %s, %s\n"):format(
      bz.name .. ",", bz.x0, bz.y0, bz.x1, bz.y1)
  end
  out[#out+1] = "\n    # Default animations, see https://wiki.hypr.land/Configuring/Animations/\n"
  out[#out+1] = "    #           NAME,          ONOFF, SPEED, CURVE,        [STYLE]\n"

  -- Group labels
  local labels = {
    windows      = "# =========================\n    # Window Animations\n    # =========================",
    fadeIn       = "# =========================\n    # Fade Animations\n    # =========================",
    layers       = "# =========================\n    # Layer Animations (IMPORTANT for launcher)\n    # =========================",
    workspaces   = "# =========================\n    # Workspace Animations\n    # =========================",
    border       = "# =========================\n    # Misc\n    # =========================",
  }
  for _, en in ipairs(a.entries) do
    if labels[en.name] then
      out[#out+1] = "\n    " .. labels[en.name] .. "\n"
    end
    local line
    if en.style then
      line = ("    animation = %-16s %s, %s, %s, %s\n"):format(
        en.name .. ",", en.on, en.speed, en.curve, en.style)
    else
      line = ("    animation = %-16s %s, %s, %s\n"):format(
        en.name .. ",", en.on, en.speed, en.curve)
    end
    out[#out+1] = line
  end
  out[#out+1] = "}\n\n"

  -- Smart gaps (commented out)
  out[#out+1] = "# Ref https://wiki.hypr.land/Configuring/Workspace-Rules/\n"
  out[#out+1] = '# "Smart gaps" / "No gaps when only"\n'
  out[#out+1] = "# uncomment all if you wish to use that.\n"
  out[#out+1] = "# workspace = w[tv1], gapsout:0, gapsin:0\n"
  out[#out+1] = "# workspace = f[1], gapsout:0, gapsin:0\n"
  out[#out+1] = "# windowrule = bordersize 0, floating:0, onworkspace:w[tv1]\n"
  out[#out+1] = "# windowrule = rounding 0, floating:0, onworkspace:w[tv1]\n"
  out[#out+1] = "# windowrule = bordersize 0, floating:0, onworkspace:f[1]\n"
  out[#out+1] = "# windowrule = rounding 0, floating:0, onworkspace:f[1]\n\n"

  -- dwindle block
  local dw = windows_src.dwindle
  out[#out+1] = "# See https://wiki.hypr.land/Configuring/Dwindle-Layout/ for more\n"
  out[#out+1] = "dwindle {\n"
  out[#out+1] = ("    preserve_split = %s # You probably want this\n"):format(to_val(dw.preserve_split))
  out[#out+1] = "}\n\n"

  -- master block
  local ms = windows_src.master
  out[#out+1] = "# See https://wiki.hypr.land/Configuring/Master-Layout/ for more\n"
  out[#out+1] = "master {\n"
  out[#out+1] = ("    new_status = %s\n"):format(ms.new_status)
  out[#out+1] = "}\n\n"

  -- misc block
  local mi = windows_src.misc
  out[#out+1] = "# https://wiki.hypr.land/Configuring/Variables/#misc\n"
  out[#out+1] = "misc {\n"
  out[#out+1] = ("    force_default_wallpaper = %s # Set to 0 or 1 to disable the anime mascot wallpapers\n"):format(mi.force_default_wallpaper)
  out[#out+1] = ("    disable_hyprland_logo = %s # If true disables the random hyprland logo / anime girl background. :(\n"):format(to_val(mi.disable_hyprland_logo))
  out[#out+1] = "}\n"

  return table.concat(out)
end

--- hypr/monitors/workspaces.conf
local function gen_workspaces()
  local out = { GENERATED_HEADER, workspaces_src.header, "\n" }
  for _, r in ipairs(workspaces_src.windowrules) do
    if r.comment then out[#out+1] = "# " .. r.comment .. "\n" end
    out[#out+1] = ("windowrule = %s, %s\n\n"):format(r.rule, r.match)
  end
  local gr = workspaces_src.gaming_rules
  out[#out+1] = gr.header .. "\n"
  out[#out+1] = gr.comment .. "\n"
  for _, r in ipairs(gr.rules) do
    out[#out+1] = ("windowrule = %s, %s\n"):format(r.rule, r.match)
  end
  return table.concat(out)
end

--- hypr/keyboard/layout.conf
local function gen_layout()
  local out = { GENERATED_HEADER }
  local inp = layout_src.input
  out[#out+1] = "input {\n"
  for _, k in ipairs({"kb_layout","kb_variant","kb_model","kb_options","kb_rules"}) do
    out[#out+1] = ("    %s = %s\n"):format(k, inp[k])
  end
  out[#out+1] = "\n"
  out[#out+1] = ("    follow_mouse = %s\n"):format(inp.follow_mouse)
  out[#out+1] = ("    mouse_refocus = %s\n"):format(to_val(inp.mouse_refocus))
  out[#out+1] = ("    sensitivity = %s # -1.0 - 1.0, 0 means no modification.\n"):format(inp.sensitivity)
  out[#out+1] = "\n"
  out[#out+1] = "    touchpad {\n"
  out[#out+1] = ("        natural_scroll = %s\n"):format(to_val(inp.touchpad.natural_scroll))
  out[#out+1] = "    }\n"
  out[#out+1] = "}\n\n"
  out[#out+1] = "# See https://wiki.hypr.land/Configuring/Gestures\n"
  for _, g in ipairs(layout_src.gestures) do
    out[#out+1] = ("gesture = %s, %s, %s\n"):format(g.fingers, g.direction, g.action)
  end
  out[#out+1] = "\n# Example per-device config\n"
  out[#out+1] = "# See https://wiki.hypr.land/Configuring/Keywords/#per-device-input-configs for more\n"
  for _, dev in ipairs(layout_src.devices) do
    out[#out+1] = "device {\n"
    out[#out+1] = ("    name = %s\n"):format(dev.name)
    out[#out+1] = ("    sensitivity = %s\n"):format(dev.sensitivity)
    out[#out+1] = "}\n"
  end
  return table.concat(out)
end

--- hypr/keyboard/keybindings.conf
local function gen_keybindings()
  local out = { GENERATED_HEADER }
  local kb = keybindings_src
  out[#out+1] = "$mainMod = " .. kb.mainMod .. " # Sets \"Windows\" key as main modifier\n\n"
  out[#out+1] = "# Example binds, see https://wiki.hypr.land/Configuring/Binds/ for more\n"

  local sections = {
    { name = nil, until_name = "left" },
    { comment = "# Move focus with mainMod + arrow keys",         start = "left",      stop_before = "1" },
    { comment = "# Switch workspaces with mainMod + [0-9]",       start = "1",         stop_before = "S" },
    { comment = "# Move active window to a workspace with mainMod + SHIFT + [0-9]", shift_start = true },
    { comment = "# Example special workspace (scratchpad)",       start = "S",         stop_before = "mouse_down", shift_only = false },
    { comment = "# Scroll through existing workspaces with mainMod + scroll", start = "mouse_down", stop_before = "bindm_start" },
    { comment = "# Move/resize windows with mainMod + LMB/RMB and dragging", bindm = true },
    { comment = "# Laptop multimedia keys for volume and LCD brightness",     bindel = true },
    { comment = "# Requires playerctl",                            bindl = true },
  }

  -- Simple sequential emit: group by comment hints
  local prev_type = "bind"
  local emitted_media_comment = false
  local emitted_playerctl_comment = false
  local emitted_move_comment = false
  local emitted_switch_comment = false
  local emitted_movews_comment = false
  local emitted_scratch_comment = false
  local emitted_scroll_comment = false
  local emitted_bindm_comment = false
  local emitted_apps_comment = false

  for _, b in ipairs(kb.binds) do
    local btype = b.type or "bind"

    -- Section headers
    if not emitted_apps_comment and btype == "bind" and b.action == "exec" and b.args == "$terminal" then
      emitted_apps_comment = true
    end
    if not emitted_move_comment and btype == "bind" and b.key == "left" then
      out[#out+1] = "\n# Move focus with mainMod + arrow keys\n"
      emitted_move_comment = true
    end
    if not emitted_switch_comment and btype == "bind" and b.key == "1" and not b.mods:find("SHIFT") then
      out[#out+1] = "\n# Switch workspaces with mainMod + [0-9]\n"
      emitted_switch_comment = true
    end
    if not emitted_movews_comment and btype == "bind" and b.key == "1" and b.mods:find("SHIFT") then
      out[#out+1] = "\n# Move active window to a workspace with mainMod + SHIFT + [0-9]\n"
      emitted_movews_comment = true
    end
    if not emitted_scratch_comment and btype == "bind" and b.key == "S" and not b.mods:find("SHIFT") then
      out[#out+1] = "\n# Example special workspace (scratchpad)\n"
      emitted_scratch_comment = true
    end
    if not emitted_scroll_comment and btype == "bind" and b.key == "mouse_down" then
      out[#out+1] = "\n# Scroll through existing workspaces with mainMod + scroll\n"
      emitted_scroll_comment = true
    end
    if not emitted_bindm_comment and btype == "bindm" then
      out[#out+1] = "\n# Move/resize windows with mainMod + LMB/RMB and dragging\n"
      emitted_bindm_comment = true
    end
    if not emitted_media_comment and btype == "bindel" then
      out[#out+1] = "\n# Laptop multimedia keys for volume and LCD brightness\n"
      emitted_media_comment = true
    end
    if not emitted_playerctl_comment and btype == "bindl" and b.comment and b.comment:find("playerctl") then
      out[#out+1] = "\n# Requires playerctl\n"
      emitted_playerctl_comment = true
    end

    -- Build line
    local line
    local action_part = b.action
    if b.args and b.args ~= "" then
      action_part = action_part .. ", " .. b.args
    else
      action_part = action_part .. ","
    end

    -- Inline comment
    local inline = b.comment and (" # " .. b.comment) or ""

    if btype == "bind" or btype == "bindel" or btype == "bindl" then
      line = ("%s = %s, %s, %s%s\n"):format(btype, b.mods, b.key, action_part, inline)
    elseif btype == "bindm" then
      line = ("bindm = %s, %s, %s\n"):format(b.mods, b.key, b.action)
    end
    if line then out[#out+1] = line end
  end

  return table.concat(out)
end

--- hypr/permissions/permissions.conf
local function gen_permissions()
  local out = { GENERATED_HEADER }
  -- Commented-out blocks
  out[#out+1] = "# ecosystem {\n#   enforce_permissions = 1\n# }\n\n"
  out[#out+1] = "# permission = /usr/(bin|local/bin)/grim, screencopy, allow\n"
  out[#out+1] = "# permission = /usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland, screencopy, allow\n"
  out[#out+1] = "# permission = /usr/(bin|local/bin)/hyprpm, plugin, allow\n"
  for _, e in ipairs(permissions_src.execs) do
    out[#out+1] = "exec-once = " .. e.cmd .. "\n"
  end
  return table.concat(out)
end

--- hypr/hypridle.conf
local function gen_hypridle()
  local out = { GENERATED_HEADER }
  local g = hypridle_src.general
  out[#out+1] = "general {\n"
  out[#out+1] = ("    lock_cmd = %s\n"):format(g.lock_cmd)
  out[#out+1] = ("    before_sleep_cmd = %s                   \n"):format(g.before_sleep_cmd)
  out[#out+1] = ("    after_sleep_cmd = %s                    \n"):format(g.after_sleep_cmd)
  out[#out+1] = "}\n\n"
  for _, l in ipairs(hypridle_src.listeners) do
    out[#out+1] = "listener {\n"
    out[#out+1] = ("    timeout = %s           \n"):format(l.timeout)
    out[#out+1] = ("    on-timeout = %s\n"):format(l.on_timeout)
    if l.on_resume then
      out[#out+1] = ("    on-resume = %s\n"):format(l.on_resume)
    end
    out[#out+1] = "}\n\n"
  end
  return table.concat(out)
end

--- hypr/hyprlock.conf
local function gen_hyprlock()
  local out = { GENERATED_HEADER }
  local bg = hyprlock_src.background
  out[#out+1] = "background {\n"
  out[#out+1] = ("    monitor = %s\n"):format(bg.monitor)
  out[#out+1] = ("    path = %s\n"):format(bg.path)
  out[#out+1] = ("    blur_passes = %s\n"):format(bg.blur_passes)
  out[#out+1] = ("    blur_size = %s\n"):format(bg.blur_size)
  out[#out+1] = "}\n\n"
  for _, lbl in ipairs(hyprlock_src.labels) do
    out[#out+1] = "label {\n"
    out[#out+1] = ("    monitor = %s\n"):format(lbl.monitor)
    out[#out+1] = ("    text = %s\n"):format(lbl.text)
    out[#out+1] = ("    font_size = %s\n"):format(lbl.font_size)
    out[#out+1] = ("    position = %s\n"):format(lbl.position)
    out[#out+1] = ("    halign = %s\n"):format(lbl.halign)
    out[#out+1] = ("    valign = %s\n"):format(lbl.valign)
    out[#out+1] = "}\n\n"
  end
  for _, inp in ipairs(hyprlock_src.input_fields) do
    out[#out+1] = "input-field {\n"
    out[#out+1] = ("    monitor = %s\n"):format(inp.monitor)
    out[#out+1] = ("    size = %s\n"):format(inp.size)
    out[#out+1] = ("    outline_thickness = %s\n"):format(inp.outline_thickness)
    out[#out+1] = ("    dots_size = %s\n"):format(inp.dots_size)
    out[#out+1] = ("    dots_spacing = %s\n"):format(inp.dots_spacing)
    out[#out+1] = ("    fade_on_empty = %s\n"):format(to_val(inp.fade_on_empty))
    out[#out+1] = ("    placeholder_text = %s\n"):format(inp.placeholder_text)
    out[#out+1] = ("    halign = %s\n"):format(inp.halign)
    out[#out+1] = ("    valign = %s\n"):format(inp.valign)
    out[#out+1] = "}\n"
  end
  return table.concat(out)
end

--- hypr/hyprlauncher.conf
local function gen_hyprlauncher()
  local out = { GENERATED_HEADER }
  local src = hyprlauncher_src
  out[#out+1] = "# General\ngeneral {\n"
  out[#out+1] = ("    grab_focus = %s\n"):format(to_val(src.general.grab_focus))
  out[#out+1] = "}\n\n"
  out[#out+1] = "# Cache (tracks frequently used apps!)\ncache {\n"
  out[#out+1] = ("    enabled = %s\n"):format(to_val(src.cache.enabled))
  out[#out+1] = "}\n\n"
  out[#out+1] = "# Finder behavior\nfinders {\n"
  out[#out+1] = ("    default_finder = %s\n"):format(src.finders.default_finder)
  out[#out+1] = ("    desktop_icons = %s\n"):format(to_val(src.finders.desktop_icons))
  out[#out+1] = ("    math_prefix = %s\n"):format(src.finders.math_prefix)
  out[#out+1] = "}\n\n"
  out[#out+1] = "# UI\nui {\n"
  out[#out+1] = ("    window_size = %s\n"):format(src.ui.window_size)
  out[#out+1] = ("    anchor = %s\n"):format(src.ui.anchor)
  out[#out+1] = ("    margin_top = %s\n"):format(src.ui.margin_top)
  out[#out+1] = "}\n"
  return table.concat(out)
end

--- hypr/hyprtoolkit.conf
local function gen_hyprtoolkit()
  local out = { GENERATED_HEADER }
  local s = hyprtoolkit_src
  out[#out+1] = "# Colors (Waybar style)\n"
  out[#out+1] = kv("background",           s.background)
  out[#out+1] = kv("background_secondary", s.background_secondary)
  out[#out+1] = "\n"
  out[#out+1] = kv("text",           s.text)
  out[#out+1] = kv("text_secondary", s.text_secondary)
  out[#out+1] = "\n"
  out[#out+1] = kv("accent", s.accent)
  out[#out+1] = "\n# Borders & rounding\n"
  out[#out+1] = kv("border_size",  s.border_size)
  out[#out+1] = kv("border_color", s.border_color)
  out[#out+1] = "\n"
  out[#out+1] = kv("rounding",       s.rounding)
  out[#out+1] = kv("rounding_large", s.rounding_large)
  out[#out+1] = "\n# Shadows (soft like Waybar)\n"
  out[#out+1] = kv("shadow_size",  s.shadow_size)
  out[#out+1] = kv("shadow_color", s.shadow_color)
  out[#out+1] = "\n# Blur (IMPORTANT)\n"
  out[#out+1] = kv("blur",        s.blur)
  out[#out+1] = kv("blur_size",   s.blur_size)
  out[#out+1] = kv("blur_passes", s.blur_passes)
  out[#out+1] = "\n# Padding\n"
  out[#out+1] = kv("padding", s.padding)
  return table.concat(out)
end

--- hypr/hyprland.conf  (the top-level include file)
local function gen_hyprland()
  local out = { GENERATED_HEADER }
  for _, entry in ipairs(hyprland_src.sources) do
    if entry.header then
      out[#out+1] = entry.header .. "\n"
    elseif entry.commented_path then
      out[#out+1] = "# source = " .. entry.commented_path .. "\n"
    elseif entry.path then
      out[#out+1] = "source = " .. entry.path .. "\n"
    end
  end
  return table.concat(out)
end

-- ────────────────────────────────────────────────────────────────────────────
-- Write all files
-- ────────────────────────────────────────────────────────────────────────────

write_file(out_path("hyprland.conf"),                   gen_hyprland())
write_file(out_path("autostart/programs.conf"),         gen_programs())
write_file(out_path("autostart/startup.conf"),          gen_startup())
write_file(out_path("env_var/env.conf"),                gen_env())
write_file(out_path("env_var/gpu/amd.conf"),            gen_simple_env(gpu_amd))
write_file(out_path("env_var/gpu/generic_gpu.conf"),    gen_sectioned_env(gpu_generic))
write_file(out_path("env_var/gpu/intel.conf"),          gen_sectioned_env(gpu_intel))
write_file(out_path("env_var/gpu/nvidia.conf"),         gen_sectioned_env(gpu_nvidia))
write_file(out_path("monitors/monitors.conf"),          gen_monitors())
write_file(out_path("monitors/waybar.conf"),            gen_waybar())
write_file(out_path("monitors/windows.conf"),           gen_windows())
write_file(out_path("monitors/workspaces.conf"),        gen_workspaces())
write_file(out_path("keyboard/layout.conf"),            gen_layout())
write_file(out_path("keyboard/keybindings.conf"),       gen_keybindings())
write_file(out_path("permissions/permissions.conf"),    gen_permissions())
write_file(out_path("hypridle.conf"),                   gen_hypridle())
write_file(out_path("hyprlock.conf"),                   gen_hyprlock())
write_file(out_path("hyprlauncher.conf"),               gen_hyprlauncher())
write_file(out_path("hyprtoolkit.conf"),                gen_hyprtoolkit())

if check_mode and drift_found then
  io.stderr:write("\nDrift detected – run `cd hypr/lua && lua generate.lua` to regenerate.\n")
  os.exit(1)
elseif check_mode then
  io.stdout:write("\nAll generated files are up-to-date.\n")
end
