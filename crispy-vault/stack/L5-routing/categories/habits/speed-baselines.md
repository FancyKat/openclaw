---
tags: [type/reference, layer/routing, status/draft, category/habits, focus/speed]
---

# Habits: Speed Baselines

> Latency budgets, operation breakdowns, and UX red lines for habits interactions.

**Up →** [[stack/L5-routing/categories/habits/_overview]]

---

## Speed Targets

| Operation | Budget | Red Line | Notes |
|---|---|---|---|
| Detect habits intent | 50 ms | 100 ms | Router pattern match on triggers |
| Load active habits from memory | 100 ms | 200 ms | Vector DB query + filter |
| Render check-in form | 80 ms | 150 ms | Generate inline buttons or text |
| Process check-in submission | 120 ms | 250 ms | Mark complete, update streak, save |
| Habit review (daily) | 150 ms | 300 ms | Aggregate stats + render report |
| Habit review (weekly) | 200 ms | 400 ms | More data, trend calculation |
| Streak check | 100 ms | 200 ms | Sort and rank active streaks |
| Habit update | 150 ms | 300 ms | Fetch, modify, save, confirm |
| Habit reminder (cron) | 100 ms | 200 ms | Fetch habits + send message |

---

## Testing Methodology

**Measurement points:** `message-received` → `first-token` → `complete-response`; `pipeline-trigger` → `pipeline-complete`.

**Tools:** Telegram `.date` timestamps, OpenClaw gateway logs, `auditLog` JSONL (`habits:*` events).

**Conditions:** (1) No pipelines, cold cache; (2) No pipelines, warm cache; (3) + habit-checkin; (4) + habit-review; (5) Full pipeline stack.

**Sample size:** Minimum 10 messages per condition.

---

## Pipeline Impact Predictions

| Pipeline | LLM Calls | API Calls | Sync/Async | Expected Delta | Notes |
|---|---|---|---|---|---|
| `habit-checkin` | 0 | 2 memory R/W | Sync | +200–500ms | Fastest — no LLM |
| `habit-review` | 1 (flash) | 3 memory R | Sync | +300–600ms | One insight LLM call |
| `streak-check` | 0 | 2 memory R | Sync | +100–300ms | jq comparison only |
| `habit-update` | 1 (flash) | 2 memory R/W | Sync | +300–700ms | Parse + apply |
| `habit-reminder` | 1 (flash) | 1 memory R | Sync | +100–300ms | Cron-triggered |

---

## Speed Budget (Machine-Readable)

```json
{
  "category": "habits",
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
    "habit-checkin":  { "latency_ms": [200, 500], "llm_calls": 0, "sync": true },
    "habit-review":   { "latency_ms": [300, 600], "llm_calls": 1, "sync": true },
    "streak-check":   { "latency_ms": [100, 300], "llm_calls": 0, "sync": true },
    "habit-update":   { "latency_ms": [300, 700], "llm_calls": 1, "sync": true },
    "habit-reminder": { "latency_ms": [100, 300], "llm_calls": 1, "sync": true }
  }
}
```
^speed-habits

---

## Operation Breakdown

### Daily Check-In (Fastest Path)

```
User input → Router (10 ms)
            → Fetch habits (80 ms)
            → Render buttons (40 ms)
            → Return (total: 130 ms)

User submits → Parse input (20 ms)
             → Update streaks (60 ms)
             → Save to memory (40 ms)
             → Format response (30 ms)
             → Return (total: 150 ms)
```

**Total user-facing latency:** 280 ms (under budget)

---

### Weekly Review

```
User input → Router (10 ms)
           → Fetch week of habits (120 ms)
           → Aggregate stats (40 ms)
           → Generate insights (50 ms)
           → Render report (30 ms)
           → Return (total: 250 ms)
```

**Total user-facing latency:** 250 ms (under budget)

---

### Habit Update (Complex)

```
User input → Router (10 ms)
           → Fetch habit record (70 ms)
           → Parse changes (20 ms)
           → Apply modifications (50 ms)
           → Save old + new params (40 ms)
           → Format confirmation (20 ms)
           → Return (total: 210 ms)
```

**Total user-facing latency:** 210 ms (under budget)

---

## Caching Strategy

### Cache Layer 1: In-Memory (Session)

- Active habits list (update every check-in)
- Current streaks (update on check-in)
- User's check-in time preference (long TTL)

**TTL:** 5 minutes (refresh on any habit operation)

### Cache Layer 2: Memory DB (Vector)

- Last 7 days of check-in history (for weekly review)
- Pattern observations (long TTL)
- Milestone records (permanent)

**TTL:** 24 hours for recent checks, 30 days for observations

### Cache Invalidation

- Trigger: New check-in submitted, habit updated, or pause/retire
- Action: Flush active habits cache, update streak cache, mark review cache stale
- Fallback: Cold fetch from main memory store (100-150 ms)

---

## Critical Path Optimization

**Habits is action-heavy, not context-heavy.** Prioritize:

1. **Check-in speed:** Users want to log and move on. Minimize wait time. (130 ms target)
2. **Streak/review rendering:** Aggregate locally, avoid re-fetching for each habit.
3. **Batch operations:** When updating multiple habits, do it in one memory write.

---

## UX Red Lines

If any operation approaches or exceeds red line (250+ ms):
- Acknowledge user input immediately ("Got it, logging your habits...")
- Perform operation in background
- Push result to Telegram/Discord asynchronously
- Example: "Your check-in is saved. Here's your daily report..." (sent 200 ms later)

---

## Connection Reliability

### Loss of Memory Connection

If vector DB is unreachable:
- Check-in still works (use in-memory cache for 1 user habit)
- Skip streaming history-dependent insights
- Queue habit operation for retry when connection restored

### Timeout Handling

- If fetch exceeds 200 ms: timeout, use stale cache if available
- If update exceeds 300 ms: timeout, queue for retry, inform user
- Never block user on slow operations

---

## Load Testing Assumptions

- 10 concurrent users checking in simultaneously
- Peak: 9 PM (user's check-in time)
- Each check-in: 2-3 habits
- Weekly review: 1-2x per user per week

**Estimated throughput:** 50+ check-ins/second without degradation

---

**Up →** [[stack/L5-routing/categories/habits/_overview]]
