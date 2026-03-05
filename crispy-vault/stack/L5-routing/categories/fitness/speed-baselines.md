---
tags: [type/reference, layer/routing, status/draft, category/fitness, focus/speed]
---

# Fitness Speed Baselines

> Latency budgets, operation breakdowns, and caching strategy for fitness interactions. UX red lines and performance targets.

**Up →** [[stack/L5-routing/categories/fitness/_overview]]

---

## Latency Budgets

| Operation | Target (ms) | Yellow Line | Red Line | Notes |
|---|---|---|---|---|
| Hat load + memory query | 200 | 250 | 400 | Includes fitness:workout, fitness:goals, fitness:recovery queries |
| Workout plan generation | 1500 | 2000 | 3000 | Creative response, account for form check context |
| PR detection + save | 300 | 400 | 600 | Quick classification + memory write |
| Progress report (trend) | 400 | 600 | 1000 | Requires history aggregation, chart rendering |
| Program design | 2000 | 3000 | 5000 | Complex, multi-week, SMART framework application |
| Nutrition cross-category query | 350 | 500 | 1000 | fitness + cooking memory merge |

---

## Operation Breakdown

### Workout Plan (500-1500ms)

```
Hat load (50ms)
  ├─ Memory query: current program (100ms)
  ├─ Memory query: recent workouts (100ms)
  ├─ Memory query: injuries/limitations (50ms)
  └─ Memory query: equipment access (50ms)
→ Agent LLM planning response (800-1200ms)
→ Format output (100ms)
Total: 1300-1600ms
```

**Caching:** Program name, equipment list (24h); recent workouts (6h)

---

### Progress Report (Trend Query)

```
Memory query: all workouts last 8 weeks (150ms)
  ├─ Filter by muscle group (50ms)
  ├─ Sort by date (30ms)
  └─ Calculate PR + trends (70ms)
→ Format as table/narrative (100ms)
→ Render (100ms)
Total: 500ms
```

**Caching:** Weekly summary snapshots (7d); exercise-specific trends (3d)

---

### Program Design (2000-5000ms)

```
Query memory: current program, goals, injury history (200ms)
→ SMART framework validation (300ms)
→ Agent LLM program generation (1500-3000ms)
→ Format week-by-week breakdown (300ms)
→ Calculate rep/set progression scheme (300ms)
→ Memory save (protocol) (200ms)
Total: 2800-4300ms
```

**Caching:** None for design (always fresh); save template library for reuse

---

## Channel-Specific Latency Targets

### Telegram
- **Workout plan:** <1000ms (quick-response expectation)
- **Progress report:** <600ms
- **Program design:** <3000ms (acceptable for heavy operations)

### Discord
- **Workout plan:** <1500ms (slightly more tolerant)
- **Progress report:** <800ms
- **Program design:** <5000ms (threads allow longer processing)

### Gmail
- **Workout plan:** <3000ms (async expectation)
- **Progress report:** <2000ms
- **Program design:** <5000ms (fully async)

---

## UX Red Lines

1. **Never** keep user waiting >5 seconds without acknowledgment
2. **Always** respond to "log workout" within 1 second (quick confirmation)
3. **Always** show memory query results inline (no silent failures)
4. **If** a query exceeds red line, show partial result + "getting full data..."
5. **Cache aggressively:** Program details, equipment list, injury notes (all 24h)

---

## Caching Strategy

### High-Frequency Queries (Cache 6h)
- Recent workout history (last 10 workouts)
- Current program name + structure
- Equipment access list
- Training schedule

### Medium-Frequency Queries (Cache 24h)
- PRs (with dates)
- Goal statements
- Injury history summary
- Preferences (favorite exercises, training style)

### Never Cache
- Workout logs (write-once, read-once)
- Real-time recovery decisions (always fresh)
- Program design requests (always custom)

---

## Optimization Priorities

1. **Memory query parallelization:** Fetch program + recent workouts simultaneously (saves ~150ms)
2. **Lazy rendering:** Show summary first, detailed breakdown on request
3. **Smart pre-load:** When user is in fitness mode, pre-load next muscle group history
4. **Compression:** Store weekly summaries instead of daily logs after 2 weeks

---

## Testing Methodology

**Measurement points:** `message-received` → `first-token` → `complete-response`; `pipeline-trigger` → `pipeline-complete`.

**Tools:** Telegram `.date` timestamps, `~/.openclaw/logs/gateway.log`, `auditLog` JSONL (`fitness:*` events).

**Conditions:** (1) No pipelines, cold cache; (2) No pipelines, warm cache; (3) + workout-log; (4) + progress-check; (5) + program-generator.

**Sample size:** Minimum 10 messages per condition.

---

## Pipeline Impact Predictions

| Pipeline | LLM Calls | API Calls | Sync/Async | Expected Delta | Notes |
|---|---|---|---|---|---|
| `workout-log` | 1 (flash) | 2 memory R/W | Sync | +400–800ms | PR detection is jq-only |
| `progress-check` | 1 (main) | 1 memory R | Sync | +600ms–1.5s | Main model for analysis |
| `program-generator` | 1 (flash) + agent | memory R/W | Async | +10–20s | Approval gate required |
| `rest-day-check` | 1 (flash) | 1 memory R | Sync | +400–900ms | Lightweight assessment |

---

## Speed Budget (Machine-Readable)

```json
{
  "category": "fitness",
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
    "workout-log":       { "latency_ms": [400,  800],  "llm_calls": 1, "sync": true },
    "progress-check":    { "latency_ms": [600,  1500], "llm_calls": 1, "sync": true },
    "program-generator": { "latency_ms": [10000, 20000], "llm_calls": 2, "sync": false },
    "rest-day-check":    { "latency_ms": [400,  900],  "llm_calls": 1, "sync": true }
  }
}
```
^speed-fitness
