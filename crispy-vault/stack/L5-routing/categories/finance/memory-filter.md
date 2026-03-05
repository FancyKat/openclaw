---
tags: [type/reference, layer/routing, status/draft, category/finance, focus/memory]
---

# Memory Filter — Finance

> Vector DB query filter, memory types to retrieve, and finance-specific compaction rules with strong "no financial advice" boundary.

**Up →** [[stack/L5-routing/categories/finance/_overview]]

---

## Vector DB Filter

```json
{
  "category": ["finance", "finance:markets", "finance:positions", "finance:strategy", "finance:budget", "finance:goals"],
  "exclude_categories": ["cooking", "fitness:workout"],
  "boost_fields": ["ticker", "strategy_name", "risk_level", "budget_category", "goal_name"],
  "recency_weight": 0.35,
  "semantic_weight": 0.25,
  "category_weight": 0.25,
  "frequency_weight": 0.15
}
```

^filter-finance

*Market memories are heavily recency-weighted — market context changes fast. Budget and goal memories are more stable but still need recency for "this month" vs "last month" distinctions.*

---

## Memory Types to Retrieve

| Memory Type | Example | Priority |
|---|---|---|
| **Active positions** | "Long AAPL 150 shares, avg cost $178" | Always load |
| **Watchlist** | "Watching: NVDA, TSLA, BTC, GLD" | Always load |
| **Strategy rules** | "Mean reversion: buy at -2σ, sell at +1σ, stop at -3σ" | Load for strategy/analysis intents |
| **Risk tolerance** | "Max 2% per trade, 10% portfolio drawdown limit" | Always load |
| **Trading style** | "Swing trader, holds 3-14 days, prefers tech sector" | Always load |
| **Recent analyses** | "Analyzed NVDA bearish divergence on weekly, March 1" | Load if same ticker |
| **Trade journal** | "AAPL trade: entered $175, exited $183, +4.5%, held 5 days" | Load for learning/review |
| **Budget categories** | "Monthly: rent $1800, groceries $600, dining $200, fun $150" | Load for budget intents |
| **Savings goals** | "Emergency fund: $4,200 of $10,000 target by Dec 2026" | Load for planning intents |
| **Income pattern** | "Paid biweekly, ~$3,400 net per check" | Load for budget/planning intents |
| **Recurring bills** | "Subscriptions: Netflix $15, gym $50, insurance $180" | Load for budget intents |

---

## Compaction Rules

### Preserve

- **Strategy rules and modifications** — Exact entry/exit/stop criteria (the core rules)
- **Trade journal entries** — Entry, exit, P&L, lesson learned (learning from actual trades)
- **Risk tolerance decisions and changes** — When user updates limits (always needed)
- **Watchlist changes and the reasoning** — Why user added/removed a ticker
- **Market observations tied to specific dates and tickers** — Context-rich analysis
- **Backtesting results** — Parameters + metrics (Sharpe, max DD, win rate, expectancy)
- **Budget goal progress updates** — How far toward target ($X of $Y by date)
- **New financial goals or goal modifications** — SMART criteria, timeline, risk level
- **Income or expense pattern changes** — When user's paycheck amount or budget category changes

### Flush

- **Real-time price discussion** — Stale within hours, regeneratable from API
- **Generic market commentary** — "The market was up today" (not actionable)
- **News summaries** — Regeneratable from web search
- **Repeated explanations of known concepts** — User already knows RSI, Sharpe, etc.
- **Individual expense logs already captured by pipeline** — Logged to memory structure, can be deleted after aggregation
- **Generic budgeting advice** — User has seen the advice before

---

## Compaction Summary Prompt (Finance-Specific)

```
Summarize this finance conversation segment.

Preserve exactly:
- Any strategy rules discussed (entry, exit, stop, position sizing)
- Any specific trade decisions or journal entries
- Any risk tolerance changes
- Any watchlist additions/removals with reasoning
- Any backtesting parameters and results
- Any budget changes or goal progress updates
- Any new financial goals or modifications
- Any income/expense pattern changes

Do NOT include:
- Real-time price levels (they're stale now)
- Generic market commentary
- News that can be re-fetched
- Explanations of well-known finance concepts
- Individual expense entries already logged

Output: max 200 tokens.
```

^compaction-finance

---

## Memory Load Examples

### Intent: finance:markets:analysis (AAPL daily chart check)
**Load strategy for:**
- AAPL-specific notes (recent journal entry? past analysis?)
- User's overall trading style (swing/day/position trader)
- Risk tolerance (affects how we frame risk/reward)
- Watchlist (context: is this a new ticker or known watch?)

**Filter:**
```json
{
  "query": "AAPL trading analysis",
  "category": ["finance:markets", "finance:positions", "finance:strategy"],
  "boost_fields": ["ticker", "strategy_name"],
  "recency_weight": 0.5,
  "semantic_weight": 0.3
}
```

### Intent: finance:budget:review (March spending check)
**Load strategy for:**
- Budget categories and monthly targets
- Recent expense logs (this month only)
- Income pattern (when did user get paid?)
- Known recurring bills (Netflix, gym, etc.)

**Filter:**
```json
{
  "query": "budget spending March 2026",
  "category": ["finance:budget", "finance:goals"],
  "boost_fields": ["budget_category", "goal_name"],
  "recency_weight": 0.6,
  "date_range": "2026-03-01 to 2026-03-31"
}
```

### Intent: finance:plan:goal (emergency fund progress)
**Load strategy for:**
- Existing savings goals and their targets
- Progress toward emergency fund ($X of $10K)
- Income/expense patterns (can user increase savings rate?)
- Risk tolerance (affects investment vehicle recommendation)

**Filter:**
```json
{
  "query": "emergency fund savings goal",
  "category": ["finance:goals", "finance:budget"],
  "boost_fields": ["goal_name"],
  "recency_weight": 0.4,
  "semantic_weight": 0.5
}
```

---

**Up →** [[stack/L5-routing/categories/finance/_overview]]
