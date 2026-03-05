# cooking-meal-plan.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/cooking/pipelines.md

{
  "days": 7,
  "cooking_for": 2,
  "preferences": {
    "cuisines": ["Japanese", "Italian"],
    "dietary_restrictions": ["no_cilantro"],
    "equipment": ["air fryer", "instant pot"]
  },
  "pantry_state": "memory:cooking:pantry"
}
```

**Output Schema:**
```json
{
  "plan": [
    {
      "day": "Monday",
      "meal": "Miso-glazed air fryer salmon with rice",
      "prep_time": "5 min",
      "cook_time": "20 min",
      "grocery_items": ["salmon fillet", "miso paste"]
    }
  ],
  "grocery_list": [...],
  "prep_schedule": "Sunday batch: wash produce, marinate salmon"
}
```

**Dependencies:** Agent loop, memory service, formatting service

### Lobster YAML

```yaml
name: cooking-meal-plan
description: >
  Generates a 5–7 day meal plan using the agent loop. Loads user preferences, dietary
  restrictions, equipment, and past recipe ratings from memory, then spawns an agent
  session to compose a weekly plan with grocery list and prep schedule. Three LLM calls
  across 3 agent turns. Requires approval before saving the plan to memory. Target
  latency 8–15s (complex composition). Falls back to raw agent loop.
args:
  days:
    default: "7"
  cooking_for:
    default: "2"
steps:
  - id: load_context
    command: exec --json --shell 'openclaw memory recall "cooking:preferences" 2>/dev/null; openclaw memory recall "cooking:pantry:list" 2>/dev/null; openclaw memory recall "cooking:past-recipes" 2>/dev/null'
  - id: generate_plan
    command: openclaw.invoke --tool sessions_spawn --action run --args-json '{"prompt":"Generate a ${days}-day meal plan for ${cooking_for} people. Use the provided preferences, pantry state, and past recipe history. Output: plan (day+meal+prep+cook times), grocery list (diffed against pantry, by section), and prep schedule.","context":"$load_context_json","model":"workhorse"}'
    timeout: 30000
  - id: review
    command: approve --preview-from-stdin --prompt 'Review this meal plan and grocery list before saving.'
    stdin: $generate_plan.stdout
    approval: required
  - id: save_plan
    command: exec --shell 'openclaw memory store "cooking:meal-plan:current" "$generate_plan_json"'
    condition: $review.approved
  - id: update_grocery
    command: exec --shell 'openclaw memory store "cooking:grocery:list" "$generate_plan_json.grocery_list"'
    condition: $review.approved
  - id: format_response
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format this meal plan as a clean, friendly summary with the grocery list. Include prep schedule highlights.","input":"$generate_plan_json"}'
    condition: $review.approved
