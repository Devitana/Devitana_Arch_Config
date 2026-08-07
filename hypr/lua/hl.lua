-- hl.lua
-- Shim of the Hyprland native Lua config API (hl.*).
-- Used by generate.lua to capture all hl.* calls and serialize them into
-- standard Hyprland .conf text.  Each config module calls hl.* exactly as
-- it would against the real Hyprland Lua API, so modules are forward-
-- compatible with any future Hyprland version that exposes this API
-- directly.
--
-- API summary
--   hl.keyword(key, value)       →  key = value
--   hl.monitor(spec)             →  monitor=spec           (no spaces, = no space)
--   hl.variable(name, value)     →  $name = value
--   hl.config(section, pairs)    →  section { key = val … } (nested blocks supported)
--   hl.comment(text)             →  # text
--   hl.heading(title)            →  ##########\n### title\n##########
--   hl.raw(text)                 →  literal text, no transformation
--
-- Ordered table convention for hl.config / nested blocks:
--   Pass an array of { "key", value } pairs to guarantee output order:
--     hl.config("general", {
--       { "gaps_in", 3 },
--       { "gaps_out", 6 },
--       { "shadow", { { "enabled", false }, { "range", 4 } } },
--     })
--   A plain dict table is also accepted; keys will be sorted alphabetically.

local M = {}

-- Internal line buffer.  generate.lua calls M.reset() before each file and
-- M.lines() to retrieve the captured output.
local _buf = {}

--- Reset the buffer (called before processing each output file).
function M.reset()
    _buf = {}
end

--- Return a copy of the current line buffer.
function M.lines()
    local copy = {}
    for i, v in ipairs(_buf) do copy[i] = v end
    return copy
end

-- ─── serialization helpers ───────────────────────────────────────────────────

local function val_str(v)
    if type(v) == "boolean" then return tostring(v) end
    return tostring(v)
end

-- Detect whether a table is an ordered list of { "key", value } pairs.
local function is_ordered(t)
    return type(t[1]) == "table" and type(t[1][1]) == "string"
end

-- Forward declaration so nested blocks can recurse.
local serialize_block

serialize_block = function(name, t, depth)
    depth = depth or 0
    local pad  = string.rep("    ", depth)
    local ipad = pad .. "    "
    local out  = {}

    table.insert(out, pad .. name .. " {")

    if #t > 0 and is_ordered(t) then
        -- Ordered list of { "key", value } pairs.
        for _, pair in ipairs(t) do
            local k, v = pair[1], pair[2]
            if type(v) == "table" then
                table.insert(out, serialize_block(k, v, depth + 1))
            else
                table.insert(out, ipad .. k .. " = " .. val_str(v))
            end
        end
    else
        -- Plain dict: sort keys for stable output.
        local keys = {}
        for k in pairs(t) do keys[#keys + 1] = k end
        table.sort(keys)
        for _, k in ipairs(keys) do
            local v = t[k]
            if type(v) == "table" then
                table.insert(out, serialize_block(k, v, depth + 1))
            else
                table.insert(out, ipad .. k .. " = " .. val_str(v))
            end
        end
    end

    table.insert(out, pad .. "}")
    return table.concat(out, "\n")
end

-- ─── public API ──────────────────────────────────────────────────────────────

--- keyword: generic key = value line (env, exec-once, bind, layerrule, …)
function M.keyword(key, value)
    table.insert(_buf, key .. " = " .. tostring(value))
end

--- monitor: uses `monitor=spec` (no spaces around =)
function M.monitor(spec)
    table.insert(_buf, "monitor=" .. tostring(spec))
end

--- variable: Hyprland $var = value
function M.variable(name, value)
    table.insert(_buf, "$" .. name .. " = " .. tostring(value))
end

--- config: block section  (uses ordered { {"key",val}, … } convention)
function M.config(section, t)
    table.insert(_buf, serialize_block(section, t, 0))
end

--- comment: # text
function M.comment(text)
    if text == "" then
        table.insert(_buf, "#")
    else
        table.insert(_buf, "# " .. text)
    end
end

--- heading: box-style section header
function M.heading(title)
    local bar = string.rep("#", #title + 6)
    table.insert(_buf, "")
    table.insert(_buf, bar)
    table.insert(_buf, "### " .. title .. " ###")
    table.insert(_buf, bar)
    table.insert(_buf, "")
end

--- raw: insert literal text unchanged
function M.raw(text)
    table.insert(_buf, text)
end

return M
