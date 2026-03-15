#!/usr/bin/env bash

# ============================================================================
# CONFIGURATION
# ============================================================================

LOCATION="${WEATHER_LOCATION:-Memmingen}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE_FILE="$CACHE_DIR/waybar-weather-$LOCATION"
CACHE_TIME=${WEATHER_CACHE_TIME:-1800} # 30 minutes
CURL_TIMEOUT=10

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

fallback() {
    echo '{"text":"🌡️ --°C","tooltip":"Weather unavailable"}'
    exit 0
}

# Ensure cache directory exists
mkdir -p "$CACHE_DIR" 2>/dev/null || true

# ============================================================================
# CHECK CACHE
# ============================================================================

if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(($(date +%s) - $(stat -c%Y "$CACHE_FILE" 2>/dev/null || stat -f%m "$CACHE_FILE" 2>/dev/null)))
    
    if [[ $CACHE_AGE -lt $CACHE_TIME ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# ============================================================================
# FETCH WEATHER DATA
# ============================================================================

DATA=$(timeout "$CURL_TIMEOUT" curl -fsS "https://wttr.in/${LOCATION}?format=j1" 2>/dev/null) || fallback

# Validate JSON
if ! echo "$DATA" | jq empty >/dev/null 2>&1; then
    fallback
fi

# ============================================================================
# PARSE WEATHER DATA
# ============================================================================

TEMP=$(echo "$DATA" | jq -r '.current_condition[0].temp_C // empty')
FEELS=$(echo "$DATA" | jq -r '.current_condition[0].FeelsLikeC // empty')
CODE=$(echo "$DATA" | jq -r '.current_condition[0].weatherCode // empty')
WIND=$(echo "$DATA" | jq -r '.current_condition[0].windspeedKmph // empty')
WINDDIR=$(echo "$DATA" | jq -r '.current_condition[0].winddir16Point // empty')
SUNRISE=$(echo "$DATA" | jq -r '.weather[0].astronomy[0].sunrise // empty')
SUNSET=$(echo "$DATA" | jq -r '.weather[0].astronomy[0].sunset // empty')
HUMIDITY=$(echo "$DATA" | jq -r '.current_condition[0].humidity // empty')
PRECIP=$(echo "$DATA" | jq -r '.current_condition[0].precipMM // empty')
PRESSURE=$(echo "$DATA" | jq -r '.current_condition[0].pressure // empty')
UV=$(echo "$DATA" | jq -r '.current_condition[0].uvIndex // empty')

[[ -z "$TEMP" || -z "$CODE" ]] && fallback

# ============================================================================
# SELECT WEATHER ICON (DAY/NIGHT AWARE)
# ============================================================================

HOUR=$(date +%H)

get_icon() {
    local code=$1
    local is_day=$2
    
    if [[ $is_day -eq 1 ]]; then
        # Day icons
        case "$code" in
            113) echo "☀️" ;;
            116) echo "🌤" ;;
            119|122) echo "☁️" ;;
            176|263|266|293|296|353) echo "🌦️" ;;
            179|182|185|281|284|299|302|305|308|311|314|317|356|359|362|365|374|377) echo "🌧️" ;;
            200|386|392) echo "⛈️" ;;
            227|320|323|326|368) echo "🌨️" ;;
            230|329|332|335|338|371|395) echo "❄️" ;;
            143|248|260) echo "🌫" ;;
            389) echo "🌩️" ;;
            *) echo "❓" ;;
        esac
    else
        # Night icons
        case "$code" in
            113) echo "🌙" ;;
            116) echo "🌥" ;;
            119|122) echo "☁️" ;;
            176|263|266|293|296|353) echo "🌦️" ;;
            179|182|185|281|284|299|302|305|308|311|314|317|356|359|362|365|374|377) echo "🌧️" ;;
            200|386|392) echo "⛈️" ;;
            227|320|323|326|368) echo "🌨️" ;;
            230|329|332|335|338|371|395) echo "❄️" ;;
            143|248|260) echo "🌫" ;;
            389) echo "🌩️" ;;
            *) echo "❓" ;;
        esac
    fi
}

IS_DAY=$(( (HOUR >= 6 && HOUR < 18) ? 1 : 0 ))
ICON=$(get_icon "$CODE" "$IS_DAY")

# ============================================================================
# BUILD TOOLTIP WITH FORECAST
# ============================================================================

FORECAST=$(echo "$DATA" | jq -r '
.weather[0:3]
| map(
    (.date | strptime("%Y-%m-%d") | strftime("%a %d"))
    + "  "
    + (if (.hourly[4].weatherCode | tonumber) == 113 then "☀" 
       elif (.hourly[4].weatherCode | tonumber) == 116 then "🌤"
       elif (.hourly[4].weatherCode | tonumber) == 227 then "🌨"
       else "❄" end)
    + "  "
    + (.mintempC + "° / " + .maxtempC + "°  ")
    + .hourly[4].weatherDesc[0].value
  )
| join("\n")
' 2>/dev/null)

TOOLTIP="<tt>
${FORECAST}

🌡  Feels like   : ${FEELS}°C
💧  Humidity     : ${HUMIDITY} %
🌧  Precip       : ${PRECIP} mm
📈  Pressure     : ${PRESSURE} hPa
☀️  UV index     : ${UV}

🧭  Wind         : ${WIND} km/h ${WINDDIR}
🌅  Sunrise      : ${SUNRISE}
🌇  Sunset       : ${SUNSET}
</tt>"

# ============================================================================
# OUTPUT FOR WAYBAR
# ============================================================================

JSON=$(jq -nc \
    --arg text "<span rise='-3000'>$ICON</span> <span rise='-2000' weight='bold'>$TEMP°C</span>" \
    --arg tooltip "$TOOLTIP" \
    '{text:$text, tooltip:$tooltip}')

echo "$JSON" | tee "$CACHE_FILE"
exit 0