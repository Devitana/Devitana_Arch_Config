#!/usr/bin/env python3

import json
import math
import os
import tempfile
import time
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

import requests

# ============================================================================
# CONFIG
# ============================================================================

LAT = float(os.getenv("LAT", "48.05"))
LON = float(os.getenv("LON", "10.12"))

CACHE_DIR = os.getenv("XDG_CACHE_HOME", os.path.expanduser("~/.cache"))
CACHE_FILE = os.path.join(CACHE_DIR, "waybar-weather-openmeteo")
CACHE_TIME = int(os.getenv("WEATHER_CACHE_TIME", "1800"))
CACHE_VERSION = 2
DEBUG_LOG = os.path.join(CACHE_DIR, "weather-debug.log")

URL = (
    "https://api.open-meteo.com/v1/forecast"
    f"?latitude={LAT}&longitude={LON}"
    "&hourly=temperature_2m,apparent_temperature,precipitation_probability,weathercode,relative_humidity_2m,pressure_msl,wind_speed_10m,wind_direction_10m,uv_index"
    "&daily=weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset"
    "&timezone=auto&past_days=1"
)


def log(message):
    try:
        with open(DEBUG_LOG, "a", encoding="utf-8") as handle:
            handle.write(f"[{datetime.now()}] {message}\n")
    except OSError:
        pass


def emit(output):
    print(json.dumps(output, separators=(",", ":")))


def valid_output(value):
    return (
        isinstance(value, dict)
        and isinstance(value.get("text"), str)
        and isinstance(value.get("tooltip"), str)
    )


def item_at(section, key, index):
    values = section.get(key)
    if not isinstance(values, list) or index is None or not 0 <= index < len(values):
        return None
    return values[index]


def number_at(section, key, index):
    value = item_at(section, key, index)
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        return "--"
    if isinstance(value, float) and not math.isfinite(value):
        return "--"
    return value


def parse_time(value):
    if not isinstance(value, str):
        return None
    try:
        return datetime.fromisoformat(value)
    except ValueError:
        return None


def forecast_now(data):
    # Open-Meteo's hourly ISO timestamps use the response's fixed UTC offset.
    offset = data.get("utc_offset_seconds")
    if isinstance(offset, (int, float)) and not isinstance(offset, bool):
        if math.isfinite(offset) and abs(offset) < 86400:
            return datetime.now(timezone(timedelta(seconds=offset))).replace(tzinfo=None)
    try:
        zone = ZoneInfo(data.get("timezone", ""))
    except (ZoneInfoNotFoundError, TypeError, ValueError):
        return datetime.now()
    return datetime.now(zone).replace(tzinfo=None)


# ============================================================================
# ICONS
# ============================================================================

DAY_ICONS = {
    0: "☀️", 1: "🌤", 2: "⛅", 3: "☁️",
    45: "🌫", 48: "🌫",
    51: "🌦", 53: "🌦", 55: "🌦",
    61: "🌧", 63: "🌧", 65: "🌧", 66: "🌧", 67: "🌧",
    71: "🌨", 73: "🌨", 75: "🌨", 77: "🌨",
    80: "🌦", 81: "🌦", 82: "🌧", 85: "🌨", 86: "🌨",
    95: "⛈", 96: "⛈", 99: "⛈",
}
NIGHT_OVERRIDE = {0: "🌙", 1: "🌙", 2: "☁️", 3: "☁️"}


def icon(code, hour):
    if 6 <= hour < 18:
        return DAY_ICONS.get(code, "❓")
    return NIGHT_OVERRIDE.get(code, DAY_ICONS.get(code, "❓"))


# ============================================================================
# FORMAT THE CURRENT WEATHER AND FORECAST
# ============================================================================

def render_weather(data, now=None):
    if not isinstance(data, dict) or not isinstance(data.get("hourly"), dict):
        raise ValueError("Missing hourly weather data")
    hourly = data["hourly"]
    daily = data.get("daily")
    if not isinstance(daily, dict):
        daily = {}

    current_hour = (now or forecast_now(data)).replace(minute=0, second=0, microsecond=0)
    times = hourly.get("time")
    if not isinstance(times, list):
        raise ValueError("Missing hourly timestamps")
    indices = {}
    for index, value in enumerate(times):
        timestamp = parse_time(value)
        if timestamp is not None:
            indices[timestamp] = index
    current_index = indices.get(current_hour)
    if current_index is None:
        raise ValueError("No weather data for the current date and hour")

    temp = number_at(hourly, "temperature_2m", current_index)
    feels = number_at(hourly, "apparent_temperature", current_index)
    code = number_at(hourly, "weathercode", current_index)
    humidity = number_at(hourly, "relative_humidity_2m", current_index)
    pressure = number_at(hourly, "pressure_msl", current_index)
    wind = number_at(hourly, "wind_speed_10m", current_index)
    uv = number_at(hourly, "uv_index", current_index)
    rain = number_at(hourly, "precipitation_probability", current_index)

    # past_days=1 also adds yesterday to daily arrays; keep today's summary first.
    forecast_lines = []
    daily_times = daily.get("time")
    today_index = None
    for index, value in enumerate(daily_times if isinstance(daily_times, list) else []):
        day = parse_time(value)
        if day is None or day.date() < current_hour.date():
            continue
        if day.date() == current_hour.date():
            today_index = index
        forecast_lines.append(
            f"{day.strftime('%a %d')}  "
            f"{number_at(daily, 'temperature_2m_min', index):>3}° / "
            f"{number_at(daily, 'temperature_2m_max', index):<3}°  "
            f"{DAY_ICONS.get(number_at(daily, 'weathercode', index), '❓')}"
        )
        if len(forecast_lines) == 3:
            break
    forecast = "\n".join(forecast_lines)

    sunrise = parse_time(item_at(daily, "sunrise", today_index))
    sunset = parse_time(item_at(daily, "sunset", today_index))
    sunrise_text = sunrise.strftime("%H:%M") if sunrise is not None else "--"
    sunset_text = sunset.strftime("%H:%M") if sunset is not None else "--"

    # 24 chronological rows: 11 previous hours, the current hour, 12 future hours.
    lines = ["<b>Hr |  Temp  |  Feel  | Rain</b>"]
    for offset in range(-11, 13):
        timestamp = current_hour + timedelta(hours=offset)
        index = indices.get(timestamp)
        line = (
            f"{timestamp.hour:02} | "
            f"{number_at(hourly, 'temperature_2m', index):>4}°C | "
            f"{number_at(hourly, 'apparent_temperature', index):>4}°C | "
            f"{number_at(hourly, 'precipitation_probability', index):>3}%"
        )
        if offset == 0:
            line = f"<span color='#ffcc66'><b>{line}</b></span>"
        lines.append(line)
    hourly_output = "<tt>" + "\n".join(lines) + "</tt>"

    tooltip = (
        "<tt>\n"
        f"{forecast}\n\n"
        f"🌡 Feels like  : {feels:>5}°C\n"
        f"💧 Humidity   : {humidity:>5}%\n"
        f"🌧 Precip     : {rain:>5}%\n"
        f"📈 Pressure   : {pressure:>5} hPa\n"
        f"☀️ UV         : {uv:>5}\n"
        f"🧭 Wind       : {wind:>5} km/h\n"
        f"🌅 Sunrise    : {sunrise_text}\n"
        f"🌇 Sunset     : {sunset_text}\n\n"
        "HOURLY FORECAST:\n"
        f"{hourly_output}\n"
        "</tt>"
    )
    return {"text": f"{icon(code, current_hour.hour)} {temp}°C", "tooltip": tooltip}


# ============================================================================
# CACHE (VALIDATED READS AND ATOMIC WRITES)
# ============================================================================

def load_cache():
    try:
        with open(CACHE_FILE, encoding="utf-8") as handle:
            cache = json.load(handle)
        # Keep a valid cache from the old script available for offline fallback,
        # but fetch the new hourly window before treating it as fresh.
        if valid_output(cache):
            return None, cache, False
        if not isinstance(cache, dict):
            return None, None, False
        if cache.get("version") != CACHE_VERSION or cache.get("location") != [LAT, LON]:
            return None, None, False
        output = cache.get("output")
        if not valid_output(output):
            output = None
        fresh = time.time() - os.path.getmtime(CACHE_FILE) < CACHE_TIME
        return cache.get("data"), output, fresh
    except (OSError, ValueError, UnicodeError):
        return None, None, False


def write_cache(data, output):
    temporary_path = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8", dir=CACHE_DIR,
            prefix=".waybar-weather-", delete=False,
        ) as handle:
            temporary_path = handle.name
            json.dump({
                "version": CACHE_VERSION,
                "location": [LAT, LON],
                "data": data,
                "output": output,
            }, handle, separators=(",", ":"), allow_nan=False)
        os.replace(temporary_path, CACHE_FILE)
    except (OSError, ValueError) as error:
        log(f"Cache write failed: {error}")
    finally:
        if temporary_path is not None:
            try:
                os.unlink(temporary_path)
            except OSError:
                pass


def fallback(cached_data, cached_output):
    try:
        output = render_weather(cached_data)
    except ValueError:
        output = dict(cached_output) if valid_output(cached_output) else None
    if output is None:
        emit({"text": "🌡️ --°C", "tooltip": "Weather unavailable"})
    else:
        output["tooltip"] += "\n\nWeather refresh failed; showing cached data."
        emit(output)


def main():
    try:
        os.makedirs(CACHE_DIR, exist_ok=True)
    except OSError as error:
        log(f"Cache directory unavailable: {error}")
    cached_data, cached_output, fresh = load_cache()
    if fresh:
        try:
            # Render cached observations again so the window and highlight move
            # with the clock, even when the data does not need another fetch.
            output = render_weather(cached_data)
        except ValueError:
            pass
        else:
            emit(output)
            return
    try:
        response = requests.get(URL, timeout=5)
        response.raise_for_status()
        data = response.json()
        output = render_weather(data)
    except (requests.RequestException, ValueError) as error:
        log(f"Weather refresh failed: {error}")
        fallback(cached_data, cached_output)
        return
    emit(output)
    write_cache(data, output)
    log(f"OK {output['text']}")


if __name__ == "__main__":
    main()
