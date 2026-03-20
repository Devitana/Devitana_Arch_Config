#!/usr/bin/env bash

# ============================================================================
# CONFIGURATION
# ============================================================================

LOCATION="${WEATHER_LOCATION:-Memmingen,Germany}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE_FILE="$CACHE_DIR/waybar-weather-$LOCATION"
CACHE_TIME=${WEATHER_CACHE_TIME:-1800}
CURL_TIMEOUT=10

# Full paths (important for Waybar)
CURL="/usr/bin/curl"
JQ="/usr/bin/jq"
TIMEOUT="/usr/bin/timeout"
DATE="/usr/bin/date"
STAT="/usr/bin/stat"

DEBUG_LOG="$CACHE_DIR/weather-debug.log"

# ============================================================================
# FUNCTIONS
# ============================================================================

fallback() {
    echo '{"text":"🌡️ --°C","tooltip":"Weather unavailable"}'
    echo "[$($DATE)] Fallback triggered" >> "$DEBUG_LOG"
    exit 0
}

log() {
    echo "[$($DATE)] $1" >> "$DEBUG_LOG"
}

mkdir -p "$CACHE_DIR" 2>/dev/null

# ============================================================================
# CACHE
# ============================================================================

if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(($($DATE +%s) - $($STAT -c %Y "$CACHE_FILE" 2>/dev/null)))

    if [[ $CACHE_AGE -lt $CACHE_TIME ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# ============================================================================
# FETCH DATA (FIXED USER-AGENT)
# ============================================================================

log "Fetching weather for $LOCATION"

DATA=$($TIMEOUT "$CURL_TIMEOUT" $CURL -A "curl" -fsS "https://wttr.in/${LOCATION}?format=j1" 2>/dev/null)

if [[ -z "$DATA" ]]; then
    log "Empty response"
    fallback
fi

# Validate JSON
echo "$DATA" | $JQ empty >/dev/null 2>&1 || {
    log "Invalid JSON"
    fallback
}

# ============================================================================
# PARSE (COMPATIBLE WITH BOTH FORMATS)
# ============================================================================

TEMP=$(echo "$DATA" | $JQ -r '(.current_condition[0].temp_C // .data.current_condition[0].temp_C) // empty')
FEELS=$(echo "$DATA" | $JQ -r '(.current_condition[0].FeelsLikeC // .data.current_condition[0].FeelsLikeC) // empty')
CODE=$(echo "$DATA" | $JQ -r '(.current_condition[0].weatherCode // .data.current_condition[0].weatherCode) // empty')
WIND=$(echo "$DATA" | $JQ -r '(.current_condition[0].windspeedKmph // .data.current_condition[0].windspeedKmph) // empty')
WINDDIR=$(echo "$DATA" | $JQ -r '(.current_condition[0].winddir16Point // .data.current_condition[0].winddir16Point) // empty')
HUMIDITY=$(echo "$DATA" | $JQ -r '(.current_condition[0].humidity // .data.current_condition[0].humidity) // empty')
PRECIP=$(echo "$DATA" | $JQ -r '(.current_condition[0].precipMM // .data.current_condition[0].precipMM) // empty')
PRESSURE=$(echo "$DATA" | $JQ -r '(.current_condition[0].pressure // .data.current_condition[0].pressure) // empty')
UV=$(echo "$DATA" | $JQ -r '(.current_condition[0].uvIndex // .data.current_condition[0].uvIndex) // empty')

SUNRISE=$(echo "$DATA" | $JQ -r '(.weather[0].astronomy[0].sunrise // .data.weather[0].astronomy[0].sunrise) // empty')
SUNSET=$(echo "$DATA" | $JQ -r '(.weather[0].astronomy[0].sunset // .data.weather[0].astronomy[0].sunset) // empty')

if [[ -z "$TEMP" || -z "$CODE" ]]; then
    log "Missing TEMP or CODE"
    fallback
fi

# ============================================================================
# ICONS
# ============================================================================

HOUR=$($DATE +%H)
IS_DAY=$(( (HOUR >= 6 && HOUR < 18) ? 1 : 0 ))

get_icon() {
    local code=$1
    local is_day=$2

    if [[ $is_day -eq 1 ]]; then
        case "$code" in
            113) echo "☀️" ;;
            116) echo "🌤" ;;
            119|122) echo "☁️" ;;
            176|263|266|293|296|353) echo "🌦️" ;;
            179|182|185|281|284|299|302|305|308|311|314|317|356|359|362|365|374|377) echo "🌧️" ;;
            200|386|392) echo "⛈️" ;;
            227|320|323|326|368) echo "🌨️" ;;
            230|329|332|335|338|371|395) echo "❄️" ;;
            143|248|260)
                if [[ $is_day -eq 1 ]]; then
                    echo "🌫"
                else
                    echo "🌁"
                fi
            ;;
            389) echo "🌩️" ;;
            *) echo "❓" ;;
        esac
    else
        case "$code" in
            113) echo "🌙" ;;
            116) echo "🌥" ;;
            *) get_icon "$code" 1 ;;
        esac
    fi
}

ICON=$(get_icon "$CODE" "$IS_DAY")

# ============================================================================
# FORECAST
# ============================================================================

FORECAST=$(echo "$DATA" | $JQ -r '
(.weather // .data.weather)[0:3]
| map(
    (.date | strptime("%Y-%m-%d") | strftime("%a %d"))
    + "  "
    + (.mintempC + "° / " + .maxtempC + "°  ")
    + .hourly[4].weatherDesc[0].value
)
| join("\n")
' 2>/dev/null)

TOOLTIP="<tt>
${FORECAST}

🌡 Feels like: ${FEELS}°C
💧 Humidity : ${HUMIDITY}%
🌧 Precip   : ${PRECIP} mm
📈 Pressure : ${PRESSURE} hPa
☀️ UV       : ${UV}

🧭 Wind: ${WIND} km/h ${WINDDIR}
🌅 Sunrise: ${SUNRISE}
🌇 Sunset: ${SUNSET}
</tt>"

# ============================================================================
# OUTPUT
# ============================================================================

JSON=$($JQ -nc \
    --arg text "$ICON $TEMP°C" \
    --arg tooltip "$TOOLTIP" \
    '{text:$text, tooltip:$tooltip}')

echo "$JSON" | tee "$CACHE_FILE"

log "Success: $TEMP°C, code $CODE"

exit 0