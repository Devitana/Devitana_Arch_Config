#!/usr/bin/env bash
# hypr/generate.sh – Regenerate all Hyprland .conf files from Lua sources.
#
# Usage:
#   ./hypr/generate.sh          # regenerate
#   ./hypr/generate.sh --check  # check for drift (exit 1 if any file changed)
#
# Prefers the Lua generator when `lua` is in PATH; falls back to Python 3.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LUA_DIR="$SCRIPT_DIR/lua"

# Prefer generic 'lua', then versioned binaries (lua5.4, lua5.3, lua5.1, luajit).
LUA_BIN=""
for _candidate in lua lua5.4 lua5.3 lua5.1 luajit; do
  if command -v "$_candidate" &>/dev/null; then
    LUA_BIN="$_candidate"
    break
  fi
done

if [ -n "$LUA_BIN" ]; then
  echo "Using Lua generator ($LUA_BIN)..."
  exec "$LUA_BIN" "$LUA_DIR/generate.lua" "$@"
elif command -v python3 &>/dev/null; then
  echo "Using Python generator (Lua not found)..."
  exec python3 "$LUA_DIR/generate.py" "$@"
else
  echo "Error: no Lua interpreter (lua/lua5.4/lua5.3/luajit) nor python3 found in PATH." >&2
  exit 1
fi
