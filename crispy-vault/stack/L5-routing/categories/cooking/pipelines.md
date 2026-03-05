---
tags: [type/reference, layer/routing, status/draft, category/cooking, focus/pipelines]
---

# Cooking Category — Pipelines

> Cooking-specific pipelines with token costs, LLM vs lookup breakdown, schema, and dependencies.

**Up →** [[stack/L5-routing/categories/cooking/_overview]]

---

## Pipeline Map

| Pipeline | Trigger | Status | Token Cost | LLM Calls | What It Does |
|---|---|---|---|---|---|
| `grocery-list` | "add X to grocery list", "shopping list" | 🔲 Future | 300–600 | 0 lookup + 1 format | Maintains structured grocery list, organized by section |
| `recipe-search` | "find that recipe", "what was that dish" | 🔲 Future | 400–800 | 0 vec-search + 1 rank | Searches saved recipes in vector DB by ingredients/cuisine |
| `meal-plan` | "plan meals for", "what should we eat this week" | 🔲 Future | 2K–4K | 2 (compose + format) | Generates weekly meal plan considering preferences + pantry |
| `pantry-check` | "what do I have", "check pantry" | 🔲 Future | 200–500 | 0 memory-query | Lists known pantry items from memory |

---

## Pipeline Details

### `grocery-list`

**Trigger Pattern:** `cooking:grocery-list`
**Status:** Future
**Token Budget:** 300–600 tokens per invocation

**What It Does:**
- View current grocery list
- Add items with quantities
- Mark items as bought
- Remove items
- Organize by store section (produce, dairy, meat, pantry, frozen, other)

**Steps:**

| Step | Type | Cost | Notes |
|---|---|---|---|
| 1. Parse user intent (add/remove/view) | LLM | 150 tok | Flash classifier or simple intent matcher |
| 2. Query memory (current list) | Lookup | 50 tok | Vector DB or flat JSON in memory |
| 3. Update/format list | Lookup | 100 tok | Reorganize by section, calc total items |
| 4. Return response | LLM | 100 tok | Format for display (Telegram, Discord, email) |

**Input Schema:**
```json
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
```
^pipeline-cooking-grocery-list

---

### `recipe-search`

**Trigger Pattern:** `cooking:recipe-search`
**Status:** Future
**Token Budget:** 400–800 tokens per invocation

**What It Does:**
- Search saved recipes by ingredient, cuisine, or name
- Return top 3 matches with ratings
- Allow quick access to past recipes

**Steps:**

| Step | Type | Cost | Notes |
|---|---|---|---|
| 1. Extract query (ingredients/cuisine) | LLM | 100 tok | Intent parsing |
| 2. Vector DB search | Lookup | 200 tok | Semantic search on recipe names + ingredients |
| 3. Rank & filter by preferences | LLM | 200 tok | Consider dietary restrictions, past ratings |
| 4. Format results | Lookup | 100 tok | Recipe cards with steps, times, ratings |

**Input Schema:**
```json
{
  "query": "salmon air fryer",
  "filters": {
    "cuisine": ["Japanese", "Asian"],
    "dietary_restrictions": ["no_cilantro"]
  },
  "limit": 3
}
```

**Output Schema:**
```json
{
  "recipes": [
    {
      "name": "Miso-Glazed Air Fryer Salmon",
      "rating": 4.5,
      "prep_time": "5 min",
      "cook_time": "15 min",
      "key_ingredients": ["salmon fillet", "miso paste", "sesame oil"],
      "memory_ref": "recipe:20250215:salmon_miso"
    }
  ]
}
```

**Dependencies:** Vector DB, memory service

### Lobster YAML

```yaml
name: cooking-recipe-search
description: >
  Searches Crispy's saved recipe memory by ingredient, cuisine, or name. Extracts
  the search query using the flash model, runs a semantic vector search against saved
  recipes, re-ranks results by user preferences and past ratings, then returns top 3
  recipe cards. Two LLM calls (flash for query extraction, main for re-ranking).
  Target latency 500ms–1.2s.
args:
  raw_message:
    default: ""
steps:
  - id: extract_query
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Extract the recipe search intent. Return: {\"query\":\"string\",\"cuisine\":[\"strings\"],\"dietary_restrictions\":[\"strings\"],\"keywords\":[\"strings\"]}","input":"${raw_message}"}'
  - id: vector_search
    command: openclaw.invoke --tool web_fetch --action post --args-json '{"url":"memory://vector/search","body":{"collection":"recipes","query":"$extract_query_json.query","limit":10}}'
  - id: rerank
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"workhorse","prompt":"Re-rank these recipes based on the user query and preferences. Consider dietary restrictions, cuisine preferences, and past ratings. Return top 3 as [{name, rating, prep_time, cook_time, key_ingredients, memory_ref}].","input":{"query":"$extract_query_json","results":"$vector_search_json"}}'
    stdin: $vector_search.stdout
  - id: format_cards
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format these recipe results as a warm, scannable response. Show recipe name, rating, prep+cook time, and top 3 ingredients per recipe.","input":"$rerank_json"}'
    stdin: $rerank.stdout
```
^pipeline-cooking-recipe-search

---

### `meal-plan`

**Trigger Pattern:** `cooking:meal-plan`
**Status:** Future
**Token Budget:** 2K–4K tokens per invocation

**What It Does:**
- Generate 5–7 day meal plan
- Consider favorite cuisines, dietary restrictions, pantry, available equipment
- Output grocery list for the plan
- Suggest prep steps

**Steps:**

| Step | Type | Cost | Notes |
|---|---|---|---|
| 1. Load preferences + pantry | Lookup | 300 tok | Dietary, cuisines, equipment, current items |
| 2. Load past recipes + ratings | Lookup | 200 tok | Avoid low-rated recipes, prefer loved ones |
| 3. Generate plan (agent loop) | LLM | 1.2K tok | Compose 5–7 meals considering constraints |
| 4. Calculate grocery list | LLM | 500 tok | Diff against pantry, organize by section |
| 5. Format + suggest prep | LLM | 800 tok | Days breakdown, prep steps, shopping tips |

**Input Schema:**
```json
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
```
^pipeline-cooking-meal-plan

---

### `pantry-check`

**Trigger Pattern:** `cooking:pantry-check`
**Status:** Future
**Token Budget:** 200–500 tokens per invocation

**What It Does:**
- Query what's in the pantry from memory
- Quick check on whether an item exists
- Suggest using items before they expire

**Steps:**

| Step | Type | Cost | Notes |
|---|---|---|---|
| 1. Query memory (pantry items) | Lookup | 100 tok | Retrieve cooking:pantry memories |
| 2. Format + sort | Lookup | 100 tok | Group by shelf life, organize by type |
| 3. (Optional) LLM suggestion | LLM | 200 tok | "You should use the spinach by Friday" |

**Input Schema:**
```json
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
```
^pipeline-cooking-pantry-check

---

## Pipeline Dependencies

```
grocery-list ← memory (read/write)
recipe-search ← vector DB, memory (read)
meal-plan ← memory (read), agent loop (compose), memory (write)
pantry-check ← memory (read)
```

If memory service is unavailable, all pipelines fail gracefully → fallback to agent loop.

---

## Current Status

*These are pipeline candidates — not built yet. For now, all cooking intents go through the agent loop. As patterns stabilize, the most common flows (grocery-list, pantry-check) get promoted to pipelines.*

---

**Up →** [[stack/L5-routing/categories/cooking/_overview]]
