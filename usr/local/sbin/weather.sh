#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="/etc/default/weather"
DEFAULT_CITY="Timisoara"

# Încarcă CITY din /etc/default/weather dacă există
if [ -f "$ENV_FILE" ]; then
  set -a; . "$ENV_FILE"; set +a
fi
CITY="${CITY:-$DEFAULT_CITY}"

mode="${1:---today}"   # --today (default) sau --week
out_file="/etc/motd"   # implicit scriem în MOTD
stdout_only="no"
if [[ "${2:-}" == "--stdout" ]]; then
  stdout_only="yes"
fi

write_motd() {
  local city_line="$1" body="$2"
  {
    echo "==== Welcome to your Dev VM ===="
    echo "City: ${city_line}"
    echo -e "${body}"
    echo "Hostname: $(hostname)"
    echo "Time: $(date -Is)"
    echo "==============================="
  } > "$out_file"
}

if [[ "$mode" == "--today" ]]; then
  command -v curl >/dev/null 2>&1 || { echo "need curl"; exit 1; }
  today=$(curl -fsS "https://wttr.in/${CITY}?format=3" || echo "unavailable")
  write_motd "${CITY}" "Weather today: ${today}"

elif [[ "$mode" == "--week" ]]; then
  command -v curl >/dev/null 2>&1 || { echo "need curl"; exit 1; }
  command -v jq   >/dev/null 2>&1 || { echo "need jq"; exit 1; }

  # Geocoding
  enc_city=$(printf %s "$CITY" | sed 's/ /%20/g')
  geo=$(curl -fsS "https://geocoding-api.open-meteo.com/v1/search?name=${enc_city}&count=1&language=en&format=json" || true)
  lat=$(echo "$geo" | jq -r '.results[0].latitude // empty')
  lon=$(echo "$geo" | jq -r '.results[0].longitude // empty')
  label_city=$(echo "$geo" | jq -r '.results[0].name // empty')
  if [[ -z "${lat}" || -z "${lon}" ]]; then
    write_motd "${CITY}" "Weather today: unavailable (geocoding failed)"
    [[ "$stdout_only" == "yes" ]] && cat "$out_file"
    exit 0
  fi

  # Forecast 7 zile
  forecast=$(curl -fsS "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&timezone=auto&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_sum&forecast_days=7")

  # Mapare coduri meteo
  declare -A WCODE=(
    [0]="Clear" [1]="Mainly clear" [2]="Partly cloudy" [3]="Overcast"
    [45]="Fog" [48]="Rime fog" [51]="Drizzle" [53]="Drizzle" [55]="Drizzle"
    [61]="Rain" [63]="Rain" [65]="Heavy rain" [66]="Freezing rain" [67]="Freezing rain"
    [71]="Snow" [73]="Snow" [75]="Heavy snow" [77]="Snow grains"
    [80]="Rain showers" [81]="Rain showers" [82]="Heavy showers"
    [85]="Snow showers" [86]="Snow showers" [95]="Thunderstorm"
    [96]="Thund. hail" [99]="Thund. heavy hail"
  )

  tmp=$(mktemp)
  {
    # rezumatul zilei curente
    today_line=$(echo "$forecast" | jq -r '.daily as $d
      | "Today: max " + ($d.temperature_2m_max[0]|floor|tostring)
      + "° / min " + ($d.temperature_2m_min[0]|floor|tostring) + "°"')
    echo "$today_line"
    printf "%-12s | %-14s | %-8s | %-8s\n" "Date" "Cond" "Max/Min" "Prec(mm)"
    echo "-----------------------------------------------------------"
    for i in $(seq 0 6); do
      d=$(echo "$forecast" | jq -r ".daily.time[$i]")
      code=$(echo "$forecast" | jq -r ".daily.weathercode[$i]")
      tmax=$(echo "$forecast" | jq -r ".daily.temperature_2m_max[$i]|floor")
      tmin=$(echo "$forecast" | jq -r ".daily.temperature_2m_min[$i]|floor")
      prec=$(echo "$forecast" | jq -r ".daily.precipitation_sum[$i]")
      cond=${WCODE[$code]:-?}
      printf "%-12s | %-14s | %2d°/%2d°   | %-8s\n" "$d" "$cond" "$tmax" "$tmin" "$prec"
    done
  } > "$tmp"

  write_motd "${label_city:-$CITY}" "$(cat "$tmp")"
  rm -f "$tmp"

else
  echo "Usage: weather.sh [--today|--week] [--stdout]"
  exit 1
fi

# Afișare pe ecran dacă s-a cerut --stdout
if [[ "$stdout_only" == "yes" ]]; then
  cat "$out_file"
fi
