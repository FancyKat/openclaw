# pet-care-medication-tracker.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/pet-care/pipelines.md

name: pet-care-medication-tracker
description: >
  Tracks pet medication schedules, logs administration, and calculates next due dates.
  Handles log/check/schedule actions. Reads current med schedule from memory, updates
  the log, calculates the next dose date based on frequency, and confirms. Zero LLM
  calls for log/check actions; one flash call for scheduling questions. Target latency
  300–700ms. Writes to pets:{name}:medications with dose history and next_due.
args:
  raw_message:
    default: ""
  pet_name:
    default: ""
steps:
  - id: parse_intent
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this medication request. Return: {action: \"log\"|\"check\"|\"schedule\", pet_name: string, medication: string|null, date: \"YYYY-MM-DD\"|null}","input":"${raw_message}"}'
  - id: load_schedule
    command: exec --json --shell 'openclaw memory recall "pets:${pet_name}:medications" 2>/dev/null || echo "[]"'
  - id: log_dose
    command: exec --json --shell 'jq -n --argjson s "$load_schedule_json" --argjson p "$parse_intent_json" "[\$s[] | if .medication == \$p.medication then . + {last_given: \$p.date, next_due: (.frequency | if . == \"monthly\" then (\$p.date | split(\"-\") | .[0] + \"-\" + (.[1] | tonumber + 1 | tostring | if length == 1 then \"0\" + . else . end) + \"-\" + .[2]) else . end)} else . end]"'
    condition: $parse_intent.json.action == "log"
  - id: save_schedule
    command: exec --shell 'openclaw memory store "pets:${pet_name}:medications" "$log_dose_json"'
    condition: $parse_intent.json.action == "log"
  - id: format_response
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format a brief medication response. For log: confirm and state next due date. For check: show what is due today/soon. Be warm and brief.","input":{"action":"$parse_intent_json.action","schedule":"$load_schedule_json","updated":"$log_dose_json"}}'
