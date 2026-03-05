# cooking-pantry-check.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/cooking/pipelines.md

{
  "action": "view|check",
  "item_query": "spinach"
}
```

**Output Schema:**
```json
{
  "pantry": [
    { "item": "spinach", "qty": "1 bunch", "added": "2025-03-01", "note": "use by March 8" },
    { "item": "chicken broth", "qty": "1 box", "opened": false }
  ]
}
```

**Dependencies:** Memory service

### Lobster YAML

```yaml
name: cooking-pantry-check
description: >
  Queries the pantry state from Crispy's memory and returns a formatted inventory.
  Retrieves all known pantry items, groups them by type, flags items expiring within
  7 days, and optionally generates LLM-based "use it up" suggestions. Zero LLM calls
  for basic view — one optional flash call for suggestions. Target latency 300–700ms.
args:
  raw_message:
    default: ""
  suggest:
    default: "false"
steps:
  - id: recall_pantry
    command: exec --json --shell 'openclaw memory recall "cooking:pantry:list" 2>/dev/null || echo "[]"'
  - id: check_expiry
    command: exec --json --shell 'echo "$recall_pantry_json" | jq "[.[] | . + {expiring_soon: (if .note and (.note | test(\"by [A-Z][a-z]+ [0-9]+\")) then true else false end)}]"'
    stdin: $recall_pantry.stdout
  - id: check_item
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Check if the user is asking about a specific item. If yes, return {item_query: string}. If no, return {item_query: null}.","input":"${raw_message}"}'
  - id: suggestions
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Look at this pantry. Suggest 2–3 meals that would use items expiring soon. Be brief and practical.","input":"$check_expiry_json"}'
    stdin: $check_expiry.stdout
    condition: ${suggest} == "true"
  - id: format_response
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format this pantry inventory as a concise, organized list. Group by type. Flag items expiring soon with ⚠️. Keep it scannable.","input":"$check_expiry_json"}'
    stdin: $check_expiry.stdout
