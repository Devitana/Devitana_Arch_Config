#!/usr/bin/env bash

LOCATION="Memmingen"
CACHE="$HOME/.cache/waybar-weather"
CACHE_TIME=1800

mkdir -p "$(dirname "$CACHE")"

fallback() {
  echo '{"text":"🌡️ --°C","tooltip":"Weather unavailable"}'
  exit 0
}

# Use cache if valid
if [[ -f "$CACHE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$CACHE"))) -lt $CACHE_TIME ]]; then
  cat "$CACHE"
  exit 0
fi

DATA=$(curl -fsS "https://wttr.in/${LOCATION}?format=j1") || fallback
echo "$DATA" | jq empty >/dev/null 2>&1 || fallback

# Current temp + weather code (jq reads)
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

# Day/night aware icons (simple)
HOUR=$(date +%H)
if (( HOUR >= 6 && HOUR < 18 )); then
  # Day icons
  case "$CODE" in
    113) ICON="☀️" ;;
    116) ICON="🌤" ;;
    119|122) ICON="☁️" ;;
    176|263|266|293|296|353) ICON="🌦️" ;;
    179|182|185|281|284|299|302|305|308|311|314|317|356|359|362|365|374|377) ICON="🌧️" ;;
    200|386|392) ICON="⛈️" ;;
    227|320|323|326|368) ICON="🌨️" ;;
    230|329|332|335|338|371|395) ICON="❄️" ;;
    143|248|260) ICON="🌫" ;;
    389) ICON="🌩️" ;;
    *) ICON="❓" ;;
  esac
else
  # Night icons
  case "$CODE" in
    113) ICON="🌙" ;;
    116) ICON="🌥" ;;
    119|122) ICON="☁️" ;;
    176|263|266|293|296|353) ICON="🌦️" ;;
    179|182|185|281|284|299|302|305|308|311|314|317|356|359|362|365|374|377) ICON="🌧️" ;;
    200|386|392) ICON="⛈️" ;;
    227|320|323|326|368) ICON="🌨️" ;;
    230|329|332|335|338|371|395) ICON="❄️" ;;
    143|248|260) ICON="🌫" ;;
    389) ICON="🌩️" ;;
    *) ICON="❓" ;;
  esac
fi

# Build tooltip
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

JSON=$(jq -nc \
  --arg text "<span rise='-3000'>$ICON</span> <span rise='-2000' weight='bold'>$TEMP°C</span>" \
  --arg tooltip "$TOOLTIP" \
  '{text:$text, tooltip:$tooltip}')

echo "$JSON" | tee "$CACHE"