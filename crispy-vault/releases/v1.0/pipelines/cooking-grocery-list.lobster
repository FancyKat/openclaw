# cooking-grocery-list.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/cooking/pipelines.md

{
  "action": "add|remove|view|mark_bought",
  "items": [
    { "name": "chicken thighs", "qty": 2, "unit": "lbs", "section": "meat" }
  ],
  "memory_key": "cooking:grocery:list"
}
```

**Output Schema:**
```json
{
  "status": "ok",
  "list": [
    { "section": "Produce", "items": [{"name": "spinach", "qty": 1, "unit": "bunch"}] },
    { "section": "Meat", "items": [{"name": "chicken thighs", "qty": 2, "unit": "lbs"}] }
  ],
  "item_count": 12,
  "marked_bought": ["milk"]
}
```

**Dependencies:** Memory service (write), formatting service

### Lobster YAML

```yaml
name: cooking-grocery-list
description: >
  Manages the grocery list in Crispy's memory. Parses user text to identify the
  action (add/remove/view/mark_bought) and items using the flash model. Reads the
  current list from memory, applies the change, saves it back (skipped for view),
  then formats and returns the updated list grouped by store section. One LLM call
  (flash) for intent parsing — all other steps are deterministic. Target latency
  400–800ms. Falls back to agent loop if memory is unavailable.
args:
  raw_message:
    default: ""
  memory_key:
    default: "cooking:grocery:list"
steps:
  - id: parse_intent
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this grocery request. Return JSON: {\"action\":\"add|remove|view|mark_bought\",\"items\":[{\"name\":\"string\",\"qty\":\"string\",\"unit\":\"string\",\"section\":\"produce|dairy|meat|pantry|frozen|other\"}]}","input":"${raw_message}"}'
  - id: recall_list
    command: exec --json --shell 'openclaw memory recall "${memory_key}" 2>/dev/null || echo "[]"'
  - id: apply_change
    command: exec --json --shell 'jq -n --argjson p "$parse_intent_json" --argjson l "$recall_list_json" "if \$p.action == \"view\" then \$l elif \$p.action == \"add\" then \$l + \$p.items elif \$p.action == \"remove\" then \$l | map(select(.name as \$n | \$p.items | map(.name) | index(\$n) == null)) else \$l | map(if (.name as \$n | \$p.items | map(.name) | index(\$n) != null) then .bought = true else . end) end"'
  - id: save_list
    command: exec --shell 'openclaw memory store "${memory_key}" "$apply_change_json"'
    condition: $parse_intent.json.action != "view"
  - id: format_response
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format this grocery list update as a friendly, concise response. Group items by store section (Produce, Dairy, Meat, Pantry, Frozen, Other). Show total item count.","input":"$apply_change_json"}'
    stdin: $apply_change.stdout
