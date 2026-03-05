---
tags: [type/reference, layer/routing, status/draft, category/cooking, focus/speed]
---

# Cooking Category — Speed Baselines

> Latency budgets and token costs for cooking mode operations. Fastest path, heaviest path, UX red lines.

**Up →** [[stack/L5-routing/categories/cooking/_overview]]

---

## Speed Budget (Machine-Readable)

```json
{
  "category": "cooking",
  "targets": {
    "first_token_ms": 1500,
    "complete_response_ms": 5000,
    "pipeline_overhead_ms": 500
  },
  "thresholds": {
    "button_tap_ms": 500,
    "initial_response_ms": 1500,
    "multi_turn_ms": 3000,
    "complex_operation_ms": 8000,
    "hang_threshold_ms": 8000
  },
  "pipelines": {
    "grocery-list": { "latency_ms": [400, 800], "llm_calls": 1, "sync": true },
    "recipe-search": { "latency_ms": [500, 1200], "llm_calls": 2, "sync": true },
    "meal-plan": { "latency_ms": [8000, 15000], "llm_calls": 3, "sync": false },
    "pantry-check": { "latency_ms": [300, 700], "llm_calls": 0, "sync": true }
  }
}
```
^speed-cooking

## Testing Methodology

**Measurement points:**
- `message-received` → `first-token` — time from gateway webhook to first token sent
- `first-token` → `complete-response` — streaming completion time
- `pipeline-trigger` → `pipeline-complete` — pipeline step total (from Lobster trace)

**Tools:**
- Telegram message timestamps (`.date` field in webhook payload)
- OpenClaw gateway logs (`~/.openclaw/logs/gateway.log`)
- `auditLog` JSONL timestamps (`cooking:*` events in audit-log)

**Baseline conditions:**
1. **No pipelines** — agent loop only, cold cache (first session)
2. **No pipelines** — agent loop only, warm cache (2nd+ turn)
3. **+ one pipeline** — add `grocery-list` or `pantry-check`
4. **Full pipeline stack** — all 4 cooking pipelines active

**Sample size:** Minimum 10 messages per condition per channel.

---

## Pipeline Impact Predictions

| Pipeline | LLM Calls | API Calls | Sync/Async | Expected Delta | Notes |
|---|---|---|---|---|---|
| `grocery-list` | 1 (flash) | 1 memory R, 1 memory W | Sync | +400–800ms | Fast path — no main LLM |
| `recipe-search` | 2 (flash + main) | 1 vector search | Sync | +500ms–1.2s | Vector search is the bottleneck |
| `meal-plan` | 3 (agent turns) | multiple memory R/W | Async | +8–15s | Show progress indicator |
| `pantry-check` | 0 (basic) / 1 opt | 1 memory R | Sync | +300–700ms | LLM only for suggestions |

---

## Latency Budget Table

| Operation | Token Cost | Latency | LLM Calls | Notes |
|---|---|---|---|---|
| **Flash classification** (detect cooking) | 50–150 | 100–300ms | 0 | Trigger-word scan + context |
| **Hat loading** (inject cooking context) | 0 | 50–150ms | 0 | Memory lookup + context assembly |
| **Focus tree navigation** (button tap) | 0–100 | 50–200ms | 0 | Callback routing, no LLM |
| **Memory retrieval** (preferences, pantry) | 0 | 200–500ms | 0 | Vector DB query, cold cache can spike to 1s |
| **Pantry-check pipeline** | 200–500 | 300–700ms | 0 | Lookup only, no LLM |
| **Grocery-list pipeline** (add/view/mark) | 300–600 | 400–800ms | 0 | Lookup + format, no LLM |
| **Recipe-search pipeline** (vec DB + rank) | 400–800 | 500–1200ms | 1 rank | Vector search + single LLM rerank |
| **Agent loop start** (initial question) | 500–1.2K | 1–3s | 1–2 | Load hat, query memory, initial response |
| **Agent loop continuation** (multi-turn) | 300–800 | 600ms–2s | 1 | Context already loaded, just respond |
| **Meal-plan generation** | 2K–4K | 3–8s | 2–3 | Complex composition, multi-step |
| **Memory compaction** (topic shift) | 600–1.2K | 1–2s | 1 | Summarize + save to vector DB |
| **Hat swap** (cooking → other category) | 0 | 200–500ms | 0 | Compaction + hat strip + hat load |

---

## Operation Breakdown

### Fastest Path: Quick Question in Cooking Mode

**User:** "How do I sear a steak?"
**Total latency:** ~1.2 seconds

| Step | Operation | Latency | Cost |
|---|---|---|---|
| 1 | Message received + parsing | 50ms | 0 |
| 2 | Flash classify (trigger: "sear") | 150ms | 100 tok |
| 3 | Hat already loaded (same category) | 0ms | 0 |
| 4 | Memory query (cooking preferences) | 300ms | 0 |
| 5 | Agent loop (1 LLM call) | 700ms | 400 tok |
| 6 | Render response | 50ms | 0 |
| **Total** | | **1.25s** | **500 tok** |

---

### Heaviest Path: Meal Plan Generation + Shift to New Hat

**User:** "Plan my dinners for next week" → [later] "Check my emails"
**Total latency:** ~12 seconds (meal plan) + 600ms (shift)

| Step | Operation | Latency | Cost | Notes |
|---|---|---|---|---|
| 1 | Flash classify (meal-plan) | 150ms | 100 tok | |
| 2 | Hat load + memory (preferences, pantry, past recipes) | 400ms | 0 | Multiple vec DB queries |
| 3 | Agent loop turn 1 (generate plan skeleton) | 2s | 800 tok | Create 7-day outline |
| 4 | Agent loop turn 2 (fill in recipes + times) | 3s | 1.2K tok | Cross-reference memory, add details |
| 5 | Agent loop turn 3 (calculate grocery list) | 2s | 600 tok | Diff pantry, organize by section |
| 6 | Render meal plan + grocery list | 100ms | 0 | Format for display |
| 7 | Compaction fires (topic shift) | 1.5s | 800 tok | Summarize plan, save to memory |
| 8 | Hat swap (cooking → generic) | 300ms | 0 | Strip + load generic |
| 9 | Memory query (email context) | 200ms | 0 | If category exists |
| 10 | Route to email agent | 100ms | 0 | |
| **Total** | | **~10–12s** | **~3.5K tok** | Meal plan only; email query separate |

---

### Memory Retrieval Latency Breakdown

| Query Type | Latency | Notes |
|---|---|---|
| Cached preference (hot memory) | 50–100ms | Already in context window |
| Single vector query (dietary) | 200–400ms | One embedding, DB hit |
| Multi-field query (preferences + pantry + past recipes) | 400–800ms | 3+ vec DB calls in parallel |
| Cold cache (first query of session) | 500ms–1.5s | Vector DB warm-up, embedding generation |
| Cross-category memory (cooking + fitness) | 600ms–2s | Multiple category filters + merge |

---

## UX Red Lines

| Threshold | Guideline | Action |
|---|---|---|
| **<500ms** | Button tap response in Telegram/Discord | Always hit for focus tree nav, pantry-check |
| **<1.5s** | Initial response in agent loop | Acceptable for cooking questions (users expect composition time) |
| **<3s** | Multi-turn agent loop continuation | Aim for this; exceeding causes perceived lag |
| **<8s** | Complex operation (meal plan, recipe search + rank) | Acceptable; show "thinking..." or progress indicator |
| **>8s** | User perception of hang | Display progress, offer escape hatch, break into steps |

---

## Category-Specific Baselines

### Action Queries (Fast)
- Flash classify → hat load → pipeline → response
- **Target:** <1s total
- **Example:** "Add milk to grocery list"
- **Actual:** 400–700ms (no LLM)

### Creative Queries (Moderate)
- Flash classify → hat load → memory query → agent loop → response
- **Target:** 1–3s total
- **Example:** "Plan dinners for this week"
- **Actual:** 3–8s (complex composition)

### Informational Queries (Moderate)
- Flash classify → hat load → agent loop (lookup) → response
- **Target:** 1–2s total
- **Example:** "How do I sear a steak?"
- **Actual:** 1–1.5s (single LLM call + retrieval)

---

## Overhead Delta

**Sessions cost:** ~200–400ms per message (parsing, routing)
**Hat load cost:** ~50–150ms per category swap
**Memory query cost:** ~200–500ms (varies with query complexity)
**LLM call cost:** ~300–800ms per call (depends on model, input length, output length)

**Total overhead (no LLM):** ~500–1200ms for a fast path
**Total overhead + 1 LLM call:** ~800–2000ms for a typical agent loop turn

---

## Caching Strategy

To stay under red lines:

1. **Hat context:** Cache for 5–10 minutes after load
2. **Memory queries:** Cache dietary restrictions indefinitely; refresh preferences every 30 min
3. **Recipe searches:** Cache top 5 results per cuisine for 1 hour
4. **Pantry state:** Cache for 2–5 minutes (user updates frequently)
5. **Flash classifier:** Cache trigger words + patterns (no expiry)

---

**Up →** [[stack/L5-routing/categories/cooking/_overview]]
