# pet-care-supply-list.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/pet-care/pipelines.md

name: pet-care-supply-list
description: >
  Manages the pet supply shopping list stored in memory. Mirrors the cooking grocery-list
  pipeline but scoped to pet supplies (food, treats, medications, accessories). Handles
  add/remove/view actions. One LLM call (flash) for intent parsing. Target latency
  300–700ms. Writes to pets:supplies:list grouped by supply type.
args:
  raw_message:
    default: ""
steps:
  - id: parse_intent
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this pet supply request. Return: {action: \"add\"|\"remove\"|\"view\", items: [{name, qty, unit, type: \"food\"|\"treats\"|\"medication\"|\"accessories\"|\"hygiene\"|\"other\"}]}","input":"${raw_message}"}'
  - id: load_list
    command: exec --json --shell 'openclaw memory recall "pets:supplies:list" 2>/dev/null || echo "[]"'
  - id: apply_change
    command: exec --json --shell 'jq -n --argjson p "$parse_intent_json" --argjson l "$load_list_json" "if \$p.action == \"add\" then \$l + \$p.items elif \$p.action == \"remove\" then \$l | map(select(.name as \$n | \$p.items | map(.name) | index(\$n) == null)) else \$l end"'
  - id: save_list
    command: exec --shell 'openclaw memory store "pets:supplies:list" "$apply_change_json"'
    condition: $parse_intent.json.action != "view"
  - id: format_response
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format this pet supply list update as a friendly, concise response. Group by type (Food, Treats, Medication, Accessories). Show total item count.","input":"$apply_change_json"}'
