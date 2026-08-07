-- generate.lua
-- Main entry point for the Hyprland .conf generator.
-- Usage (from repository root):  ./hypr/generate.sh
-- Usage (direct):                cd hypr/lua && lua generate.lua [--check]
--
-- --check mode: regenerates into a temp buffer and exits 1 if any output
--               would differ from the file on disk (CI drift detection).
--
-- The global `hl` is set here before any module is loaded so every module
-- can call hl.* exactly as it would against the real Hyprland Lua API.

-- ─── bootstrap ───────────────────────────────────────────────────────────────

-- Ensure `require` finds sibling modules (gpu/*.lua etc.) regardless of
-- where the script is invoked from.
local script_path = debug.getinfo(1, "S").source:match("^@(.+)$") or "."
local script_dir  = script_path:match("^(.*)/[^/]+$") or "."
package.path = script_dir .. "/?.lua;" .. script_dir .. "/?/init.lua;" .. package.path

-- Expose `hl` as a global so every module can use it without a require.
hl = require("hl")  -- luacheck: ignore

-- ─── helpers ─────────────────────────────────────────────────────────────────

local BANNER = [[# ============================================================
# AUTO-GENERATED – do not edit by hand.
# Source: hypr/lua/  |  Regenerate: cd hypr/lua && lua generate.lua
# ============================================================
]]

local check_mode  = (arg and arg[1] == "--check")
local drift_found = false

--- Write `lines` (from hl.lines()) to `path` with the standard banner.
--- In --check mode, compares instead of writing and sets drift_found.
local function write_conf(path, lines)
    local content = BANNER .. table.concat(lines, "\n") .. "\n"

    if check_mode then
        local fh = io.open(path, "r")
        if fh then
            local existing = fh:read("*a")
            fh:close()
            if existing ~= content then
                io.stderr:write("DRIFT: " .. path .. "\n")
                drift_found = true
            end
        else
            io.stderr:write("MISSING: " .. path .. "\n")
            drift_found = true
        end
        return
    end

    -- Ensure parent directory exists (quote path to handle spaces/metacharacters).
    local dir = path:match("^(.*)/[^/]+$")
    if dir then
        local quoted = "'" .. dir:gsub("'", "'\\''") .. "'"
        os.execute("mkdir -p " .. quoted)
    end

    local fh = assert(io.open(path, "w"), "Cannot open " .. path)
    fh:write(content)
    fh:close()
    print("  wrote " .. path)
end

--- Capture output of a module function into a conf file.
--- `mod_fn` is called with no arguments; it calls hl.* to populate the buffer.
local function gen(out_path, mod_fn)
    hl.reset()
    mod_fn()
    write_conf(out_path, hl.lines())
end

-- ─── resolve output paths relative to the repo root ──────────────────────────
-- generate.lua lives in  hypr/lua/
-- .conf files live in    hypr/  (one level up)

local root = script_dir .. "/.."   -- hypr/

local function p(rel) return root .. "/" .. rel end

-- ─── generation table ────────────────────────────────────────────────────────
-- Each entry: { output_path, module_name }
-- Modules are loaded fresh for each file (package.loaded cleared) so that
-- modules that share a filename prefix don't collide.

print("Generating Hyprland .conf files…")

local files = {
    -- autostart
    { p("autostart/programs.conf"), "programs"    },
    { p("autostart/startup.conf"),  "autostart"   },

    -- environment variables
    { p("env_var/env.conf"),             "env"          },
    { p("env_var/gpu/amd.conf"),         "gpu.amd"      },
    { p("env_var/gpu/nvidia.conf"),      "gpu.nvidia"   },
    { p("env_var/gpu/intel.conf"),       "gpu.intel"    },
    { p("env_var/gpu/generic_gpu.conf"), "gpu.generic"  },

    -- monitors
    { p("monitors/monitors.conf"),   "monitors"     },
    { p("monitors/windows.conf"),    "windows"      },
    { p("monitors/waybar.conf"),     "waybar"       },
    { p("monitors/workspaces.conf"), "workspaces"   },

    -- keyboard
    { p("keyboard/layout.conf"),      "layout"       },
    { p("keyboard/keybindings.conf"), "keybindings"  },

    -- permissions
    { p("permissions/permissions.conf"), "permissions" },

    -- companion apps
    { p("../hypridle.conf"),     "hypridle"     },
    { p("../hyprlock.conf"),     "hyprlock"     },
    { p("../hyprlauncher.conf"), "hyprlauncher" },
    { p("../hyprtoolkit.conf"),  "hyprtoolkit"  },
}

-- NOTE: current_gpu.conf is runtime-selected by scripts/detect_gpu.sh and is
-- NOT regenerated here.  hyprland.conf itself only contains `source =` lines
-- and is also left unchanged.

for _, entry in ipairs(files) do
    local out_path, mod_name = entry[1], entry[2]

    -- Clear cached module so a fresh load always runs the module body.
    package.loaded[mod_name] = nil

    gen(out_path, function()
        require(mod_name)
    end)
end

print("Done.")

if check_mode and drift_found then
    os.exit(1)
end
