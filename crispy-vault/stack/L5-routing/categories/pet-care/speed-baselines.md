---
tags: [type/reference, layer/routing, status/draft, category/pet-care, focus/speed]
---

# Pet Care Speed Baselines

> Latency budgets, operation breakdowns, UX red lines, and caching strategy for pet care interactions.

**Up →** [[stack/L5-routing/categories/pet-care/_overview]]

---

## Overview

This file defines performance targets and latency requirements for pet care operations, ensuring responsive interactions across channels.

---

## Latency Budget Table

| Operation | Expected Latency | Notes |
|---|---|---|
| Intent classification | 100–200ms | pet-care triggers are specific (medication, vet, feeding) |
| Mode load | 50–100ms | Always pre-load primary pet name from memory |
| medication-tracker pipeline | 300–700ms | Memory R/W — no LLM for log action |
| appointment pipeline | 300–600ms | Memory R/W — one flash call for parse |
| feeding-schedule pipeline | 200–500ms | Fastest — memory append only |
| supply-list pipeline | 300–700ms | Same as grocery-list pattern |
| training-log pipeline | 200–500ms | Memory append + flash for response |
| grooming-schedule pipeline | 300–600ms | Memory R/W + flash for response |
| Agent loop (health/advice) | 1–2.5s | For complex queries needing reasoning |

---

## Testing Methodology

**Measurement points:** `message-received` → `first-token` → `complete-response`; `pipeline-trigger` → `pipeline-complete`.

**Tools:** Telegram `.date` timestamps, OpenClaw gateway logs, `auditLog` JSONL (`pets:*` events).

**Conditions:** (1) No pipelines, cold cache; (2) No pipelines, warm cache; (3) + medication-tracker; (4) + full pipeline stack.

**Sample size:** Minimum 10 messages per condition.

---

## Pipeline Impact Predictions

| Pipeline | LLM Calls | API Calls | Sync/Async | Expected Delta | Notes |
|---|---|---|---|---|---|
| `medication-tracker` | 1 (flash) | 2 memory R/W | Sync | +300–700ms | Parse + log |
| `appointment` | 1 (flash) | 2 memory R/W | Sync | +300–600ms | Parse + store |
| `feeding-schedule` | 1 (flash) | 1 memory R/W | Sync | +200–500ms | Lightweight |
| `supply-list` | 1 (flash) | 2 memory R/W | Sync | +300–700ms | Grocery pattern |
| `training-log` | 1 (flash) | 2 memory R/W | Sync | +200–500ms | Log + celebrate |
| `grooming-schedule` | 1 (flash) | 2 memory R/W | Sync | +300–600ms | History + freq |

---

## Speed Budget (Machine-Readable)

```json
{
  "category": "pet-care",
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
    "medication-tracker":  { "latency_ms": [300, 700], "llm_calls": 1, "sync": true },
    "appointment":         { "latency_ms": [300, 600], "llm_calls": 1, "sync": true },
    "feeding-schedule":    { "latency_ms": [200, 500], "llm_calls": 1, "sync": true },
    "supply-list":         { "latency_ms": [300, 700], "llm_calls": 1, "sync": true },
    "training-log":        { "latency_ms": [200, 500], "llm_calls": 1, "sync": true },
    "grooming-schedule":   { "latency_ms": [300, 600], "llm_calls": 1, "sync": true }
  }
}
```
^speed-pet-care

---

**Up →** [[stack/L5-routing/categories/pet-care/_overview]]
