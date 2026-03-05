# pet-care-feeding-schedule.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/pet-care/pipelines.md

name: pet-care-feeding-schedule
description: >
  Tracks the pet feeding routine, portions, and food brand. Handles log/check/update
  actions. Logs each meal with timestamp and portion, checks the last feeding time,
  or updates the schedule parameters. Zero LLM calls for log/check. Target latency
  200–500ms. Writes to pets:{name}:feeding-log with daily meal history.
args:
  raw_message:
    default: ""
  pet_name:
    default: ""
steps:
  - id: parse_feeding
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this feeding request. Return: {action: \"log\"|\"check\"|\"update\", pet_name: string, meal_time: \"YYYY-MM-DDTHH:MM\"|null, portion: string|null, food: string|null}","input":"${raw_message}"}'
  - id: load_log
    command: exec --json --shell 'openclaw memory recall "pets:${pet_name}:feeding-log" 2>/dev/null | jq "[.[] | select(.date == \"$(date +%Y-%m-%d)\")]" || echo "[]"'
  - id: append_meal
    command: exec --json --shell 'jq -n --argjson log "$load_log_json" --argjson meal "$parse_feeding_json" "[\$log[], {time: \$meal.meal_time, portion: \$meal.portion, food: \$meal.food}]"'
    condition: $parse_feeding.json.action == "log"
  - id: save_log
    command: exec --shell 'openclaw memory store "pets:${pet_name}:feeding-log:$(date +%Y-%m-%d)" "$append_meal_json"'
    condition: $parse_feeding.json.action == "log"
  - id: format_response
    command: exec --shell 'echo "Logged! ${pet_name} fed at $(echo $parse_feeding_json | jq -r .meal_time | cut -c12-16). Today: $(echo $append_meal_json | jq length) meals."'
