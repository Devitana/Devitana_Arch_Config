#!/usr/bin/env python3

import os, time, json, requests
from datetime import datetime

# ============================================================================
# CONFIG
# ============================================================================

LAT = float(os.getenv("LAT", "48.05"))
LON = float(os.getenv("LON", "10.12"))

CACHE_DIR = os.getenv("XDG_CACHE_HOME", os.path.expanduser("~/.cache"))
CACHE_FILE = f"{CACHE_DIR}/waybar-weather-openmeteo"
CACHE_TIME = int(os.getenv("WEATHER_CACHE_TIME", 1800))
DEBUG_LOG = f"{CACHE_DIR}/weather-debug.log"

os.makedirs(CACHE_DIR, exist_ok=True)

def log(msg):
    try:
        with open(DEBUG_LOG, "a") as f:
            f.write(f"[{datetime.now()}] {msg}\n")
    except:
        pass

def fallback():
    print('{"text":"🌡️ --°C","tooltip":"Weather unavailable"}')
    raise SystemExit

# ============================================================================
# CACHE
# ============================================================================

try:
    if time.time() - os.path.getmtime(CACHE_FILE) < CACHE_TIME:
        with open(CACHE_FILE, "r") as f:
            print(f.read())
        raise SystemExit
except:
    pass

# ============================================================================
# OPEN-METEO FETCH (HOURLY + DAILY)
# ============================================================================

url = (
    "https://api.open-meteo.com/v1/forecast"
    f"?latitude={LAT}&longitude={LON}"
    "&hourly=temperature_2m,apparent_temperature,precipitation_probability,weathercode,relative_humidity_2m,pressure_msl,wind_speed_10m,wind_direction_10m,uv_index"
    "&daily=weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset"
    "&timezone=auto"
)

try:
    data = requests.get(url, timeout=5).json()
except Exception as e:
    log(f"Request failed: {e}")
    fallback()

hourly = data.get("hourly", {})
daily = data.get("daily", {})
times = hourly.get("time", [])
temps = hourly.get("temperature_2m", [])
feels = hourly.get("apparent_temperature", [])
rain = hourly.get("precipitation_probability", [])
humidity = hourly.get("relative_humidity_2m", [])
pressure = hourly.get("pressure_msl", [])
wind = hourly.get("wind_speed_10m", [])
winddir = hourly.get("wind_direction_10m", [])
uv = hourly.get("uv_index", [])
codes = hourly.get("weathercode", [])

# ============================================================================
# ICONS
# ============================================================================

DAY_ICONS = {
    0: "☀️",      # clear
    1: "🌤",      # mostly clear
    2: "⛅",      # partly cloudy
    3: "☁️",      # overcast
    45: "🌫",     # fog
    48: "🌫",
    51: "🌦", 53: "🌦", 55: "🌦",
    61: "🌧", 63: "🌧", 65: "🌧",
    66: "🌧", 67: "🌧",
    71: "🌨", 73: "🌨", 75: "🌨",
    77: "🌨",
    80: "🌦", 81: "🌦", 82: "🌧",
    85: "🌨", 86: "🌨",
    95: "⛈",
    96: "⛈", 99: "⛈"
}
NIGHT_OVERRIDE = {
    0: "🌙",
    1: "🌙",
    2: "☁️",
    3: "☁️"
}
def icon(code, hour):
    if 6 <= hour < 18:
        return DAY_ICONS.get(code, "❓")
    return NIGHT_OVERRIDE.get(code, DAY_ICONS.get(code, "❓"))

# ============================================================================
# CURRENT VALUES
# ============================================================================

now_hour = datetime.now().hour

current_index = 0
for i, t in enumerate(times):
    if int(t[11:13]) == now_hour:
        current_index = i
        break

TEMP = temps[current_index] if temps else "--"
FEELS = feels[current_index] if feels else "--"
CODE = codes[current_index] if codes else 0
ICON = icon(CODE, now_hour)
HUMIDITY = humidity[current_index] if humidity else "--"
PRESSURE = pressure[current_index] if pressure else "--"
WIND = wind[current_index] if wind else "--"
WINDDIR = winddir[current_index] if winddir else "--"
UV = uv[current_index] if uv else "--"

# ============================================================================
# 3 DAY FORECAST
# ============================================================================

forecast_lines = []

for i in range(min(3, len(daily.get("time", [])))):
    try:
        date = daily["time"][i]
        dt = datetime.strptime(date, "%Y-%m-%d")
        forecast_lines.append(
            f"{dt.strftime('%a %d')}  "
            f"{daily['temperature_2m_min'][i]:>3}° / "
            f"{daily['temperature_2m_max'][i]:<3}°  "
            f"{DAY_ICONS.get(daily['weathercode'][i], '❓')}"
        )
    except:
        continue

FORECAST = "\n".join(forecast_lines)

# ============================================================================
# HOURLY TABLE (24 HOURS + HIGHLIGHT)
# ============================================================================

lines = ["<b>Hr |  Temp  |  Feel  | Rain</b>"]
append = lines.append

for i in range(min(24, len(times))):
    try:
        hour = int(times[i][11:13])
        line = (
            f"{hour:02} | "
            f"{temps[i]:>4}°C | "
            f"{feels[i]:>4}°C | "
            f"{rain[i]:>3}%"
        )
        if hour == now_hour:
            line = f"<span color='#ffcc66'><b>{line}</b></span>"
        append(line)
    except:
        continue

HOURLY_OUTPUT = "<tt>" + "\n".join(lines) + "</tt>"

# ============================================================================
# TOOLTIP
# ============================================================================

TOOLTIP = (
    "<tt>\n"
    f"{FORECAST}\n\n"
    f"🌡 Feels like  : {FEELS:>5}°C\n"
    f"💧 Humidity   : {HUMIDITY:>5}%\n"
    f"🌧 Precip     : {rain[current_index] if rain else '--':>5}%\n"
    f"📈 Pressure   : {PRESSURE:>5} hPa\n"
    f"☀️ UV         : {UV:>5}\n"
    f"🧭 Wind       : {WIND:>5} km/h\n"
    f"🌅 Sunrise    : {daily['sunrise'][0][11:16] if daily.get('sunrise') else '--'}\n"
    f"🌇 Sunset     : {daily['sunset'][0][11:16] if daily.get('sunset') else '--'}\n\n"
    "HOURLY FORECAST:\n"
    f"{HOURLY_OUTPUT}\n"
    "</tt>"
)

# ============================================================================
# OUTPUT
# ============================================================================

output = json.dumps({
    "text": f"{ICON} {TEMP}°C",
    "tooltip": TOOLTIP
}, separators=(",", ":"))
print(output)

# ============================================================================
# CACHE WRITE
# ============================================================================

try:
    with open(CACHE_FILE, "w") as f:
        f.write(output)
except:
    pass
log(f"OK {TEMP}°C")