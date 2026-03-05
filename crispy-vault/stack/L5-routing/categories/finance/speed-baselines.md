---
tags: [type/reference, layer/routing, status/draft, category/finance, focus/speed]
---

# Speed Baselines — Finance

> Latency budgets, operation breakdowns, UX red lines, and caching strategy for finance operations.

**Up →** [[stack/L5-routing/categories/finance/_overview]]

---

## Operation Latency Table

| Operation | Expected Latency | Limit | Notes |
|---|---|---|---|
| **Intent classification** | 100ms | 200ms | Medium-confidence triggers need context — "price" could be cooking or finance |
| **Memory load (watchlist)** | 50ms | 100ms | Always preload top 5 watched tickers |
| **Hat injection** | 20ms | 50ms | Sub-role context into context window |
| **Market-brief pipeline** | 2-4s | 5s | API call to market data + LLM formatting |
| **Position-check pipeline** | 1-2s | 3s | Broker API latency-dependent |
| **Budget-review pipeline** | 800ms | 1.5s | Local memory query + calculation + formatting |
| **Expense-tracker pipeline** | 300ms | 800ms | Memory write + category inference |
| **Backtest pipeline** | 5-15s | 20s | NautilusTrader simulation (depends on timeframe) |
| **Analysis agent loop** | 2-4s | 6s | Reasoning with memory context |
| **Strategy discussion** | 2-3s | 5s | Creative mode with user's rules |
| **Learning response** | 1-2s | 3s | Informational (no memory load) |

---

## UX Red Lines

- **< 500ms:** Feels instant (pipeline launch, expense log)
- **500ms - 2s:** Expected wait (budget review, simple analysis)
- **2s - 5s:** Longer thought (market-brief, backtest start)
- **> 5s:** User may perceive delay; show progress indicator or "thinking..." message

---

## Caching Strategy

### High-Frequency Cache (Telegram/Discord)
- **Watchlist prices:** Cache for 30-60 seconds (stale quickly in markets)
- **User's strategy rules:** Cache for session (doesn't change mid-conversation)
- **Budget categories & targets:** Cache for session or until user updates
- **Risk tolerance:** Cache for session

### Medium-Frequency Cache (User-Initiated)
- **Recent backtest results:** Cache for 5 minutes (user may refine parameters)
- **Budget summaries:** Cache until user logs new expense
- **Position snapshots:** Cache for 2-5 minutes (refresh if user asks again)

### No Cache
- **Real-time market data:** Always fresh (if API connected)
- **Individual expense logs:** Always fresh (memory source of truth)
- **News/earnings data:** Always fresh query

---

## LLM vs Lookup Breakdown

### market-brief Pipeline
- LLM reasoning: 40% (format data, contextualize sectors, mention watchlist)
- API lookup: 50% (indices, sector ETF prices, watchlist prices)
- Memory load: 10% (user's watchlist list)
- **Total: ~200-300 tokens of LLM + 2-3s API latency**

### position-check Pipeline
- LLM reasoning: 30% (calculate P&L, format display)
- API lookup: 70% (broker positions, current prices)
- **Total: ~150-200 tokens + 1-2s broker latency**

### budget-review Pipeline
- LLM reasoning: 40% (summarize variance, call out outliers)
- Memory lookup: 60% (expense logs, budget targets)
- **Total: ~250-350 tokens, no external API**

### backtest Pipeline
- LLM reasoning: 20% (interpret results, frame lessons)
- Simulation: 80% (NautilusTrader backtesting engine)
- **Total: ~200-300 tokens + 5-15s simulation**

### analysis Agent Loop
- LLM reasoning: 90% (TA/FA analysis with context)
- Memory load: 10% (strategy rules, trading style)
- **Total: ~400-600 tokens, ~2-4s**

---

## Optimization Priorities

1. **Always preload watchlist** (< 100ms impact, huge UX win)
2. **Cache user's strategy rules** within session (reuse across multiple analyses)
3. **Use budget summaries locally** — don't fetch from API
4. **Show "Analyzing..." or "Running backtest..." for > 2s operations**
5. **Batch small queries** (e.g., multiple tickers in one API call)

---

---

## Testing Methodology

**Measurement points:**
- `message-received` → `first-token` — from gateway webhook to first token sent
- `first-token` → `complete-response` — streaming completion time
- `pipeline-trigger` → `pipeline-complete` — Lobster trace total

**Tools:** Telegram `.date` timestamps, `~/.openclaw/logs/gateway.log`, `auditLog` JSONL (`finance:*` events)

**Conditions:** (1) No pipelines, cold cache; (2) No pipelines, warm cache; (3) + expense-tracker; (4) + market-brief; (5) + backtest

**Sample size:** Minimum 10 messages per condition.

---

## Pipeline Impact Predictions

| Pipeline | LLM Calls | API Calls | Sync/Async | Expected Delta | Notes |
|---|---|---|---|---|---|
| `market-brief` | 1 (flash) | 2 web_search | Sync | +2–4s | External API is bottleneck |
| `position-check` | 1 (flash) | 2 broker API | Sync | +1–3s | Broker API latency varies |
| `backtest` | 1 (flash) + approval | NautilusTrader | Async | +5–20s | Requires approval gate |
| `watchlist` | 1 (flash) | 1 memory R/W | Sync | +300–800ms | Fast — local only |
| `budget-review` | 1 (flash) | 2 memory R | Sync | +800ms–1.5s | Aggregation is CPU-bound |
| `expense-tracker` | 1 (flash) | 2 memory R/W | Sync | +300–800ms | Fastest write pipeline |

---

## Speed Budget (Machine-Readable)

```json
{
  "category": "finance",
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
    "market-brief":     { "latency_ms": [2000, 4000], "llm_calls": 1, "sync": true },
    "position-check":   { "latency_ms": [1000, 3000], "llm_calls": 1, "sync": true },
    "backtest":         { "latency_ms": [5000, 20000], "llm_calls": 1, "sync": false },
    "watchlist":        { "latency_ms": [300,  800],  "llm_calls": 1, "sync": true },
    "budget-review":    { "latency_ms": [800,  1500], "llm_calls": 1, "sync": true },
    "expense-tracker":  { "latency_ms": [300,  800],  "llm_calls": 1, "sync": true }
  }
}
```
^speed-finance

**Up →** [[stack/L5-routing/categories/finance/_overview]]
