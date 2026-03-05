# pet-care-grooming-schedule.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/pet-care/pipelines.md

name: pet-care-grooming-schedule
description: >
  Tracks grooming appointments and routines (baths, nail trims, haircuts). Logs
  completed grooming sessions and calculates when the next session is due based on
  the pet's breed/coat and stored frequency preferences. One flash call for intent
  parsing. Target latency 300–600ms. Writes to pets:{name}:grooming with history.
args:
  raw_message:
    default: ""
  pet_name:
    default: ""
steps:
  - id: parse_grooming
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this grooming request. Return: {action: \"log\"|\"schedule\"|\"view\", pet_name: string, grooming_type: \"bath\"|\"nail-trim\"|\"haircut\"|\"full-groom\"|\"other\", date: \"YYYY-MM-DD\"|null, notes: string|null}","input":"${raw_message}"}'
  - id: load_history
    command: exec --json --shell 'openclaw memory recall "pets:${pet_name}:grooming" 2>/dev/null || echo "[]"'
  - id: load_preferences
    command: exec --json --shell 'openclaw memory recall "pets:${pet_name}:grooming-preferences" 2>/dev/null || echo "{\"bath_frequency_days\":14,\"nail_trim_days\":21,\"haircut_days\":60}"'
  - id: add_session
    command: exec --json --shell 'jq -n --argjson h "$load_history_json" --argjson g "$parse_grooming_json" --argjson p "$load_preferences_json" "[\$h[], {type: \$g.grooming_type, date: \$g.date, notes: \$g.notes, next_due: \"(calculated from \$p)\"}]"'
    condition: $parse_grooming.json.action == "log"
  - id: save_history
    command: exec --shell 'openclaw memory store "pets:${pet_name}:grooming" "$add_session_json"'
    condition: $parse_grooming.json.action == "log"
  - id: format_response
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Respond to this grooming update. For log: confirm and state when next session is due. For view: show recent history and upcoming schedule. Be warm and brief.","input":{"action":"$parse_grooming_json","history":"$load_history_json","prefs":"$load_preferences_json"}}'
