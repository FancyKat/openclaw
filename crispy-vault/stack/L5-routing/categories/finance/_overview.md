---
tags: [type/index, layer/routing, status/draft, category/finance]
category_name: "Finance"
category_slug: "finance"
category_emoji: "💰"
mode_tokens: 250
active_pipelines: 0
future_pipelines: 3
channel_telegram: true
channel_discord: true
channel_gmail: true
---

# Category Mode — Finance 💰

> Index and context for finance mode. Trigger patterns, intents, focus tree, pipelines, memory filters, and drift signals.

**Up →** [[stack/L5-routing/categories/_overview]]

---

## Overview

The finance mode is active when Marty asks about trading, investing, market analysis, budgeting, personal finance, financial planning, or portfolio management. It surfaces memories about active positions, watchlist, strategy rules, risk tolerance, budget categories, savings goals, and trading history. The mode remains active across sub-category shifts (analysis → budget → planning) and is stripped when moving to a different top-level category (finance → cooking).

---

## Mode Context

This block gets injected into the context window when the finance mode is active. It sits right after AGENTS.md — in the high-attention zone:

```markdown
## 💰 Active Mode: Finance

You're in finance mode. Adjust your approach:

**Tone:** Analytical, measured, data-driven. Like a thoughtful financial analyst.
Never hype, never doom. Present information and let the user decide.
For budgeting: practical, encouraging, non-judgmental about spending habits.

**Critical rule:** You are NOT a financial advisor. You do NOT give buy/sell
recommendations or specific investment advice. You analyze, present data,
discuss strategy mechanics, help with systematic approaches, and help organize
financial information. Always include this framing when discussing specific
positions or major financial decisions.

**Memory awareness:** You know the user's trading style, risk tolerance,
active positions, watchlist, strategy preferences, budget categories,
income pattern, savings goals, and recurring expenses. Pull from
finance-tagged memories before giving generic analysis.

**Key behaviors:**
- Lead with data, not opinions
- When discussing a ticker: price action first, then context
- Mention timeframe explicitly (daily, weekly, intraday)
- Always consider risk before reward
- Reference the user's strategy framework if they have one
- For backtesting: use clear metrics (Sharpe, max drawdown, win rate, expectancy)
- For budgeting: track against user's own categories, no judgment
- For goals: apply SMART+ framework with financial-specific metrics

**Context to load:**
- Check MEMORY.md for: active positions, watchlist, strategy preferences,
  risk tolerance, trading style (swing, day, position)
- Check MEMORY.md for: budget categories, income schedule, recurring bills,
  savings goals, debt balances
- Load recent market-brief results if available
- Check for open trading journal entries

**Pipelines available:**
- `market-brief` — Market overview (indices, sectors, watchlist)
- `position-check` — Current portfolio state (when connected)
- `backtest` — Run strategy backtest via NautilusTrader (future)
- `budget-review` — Monthly budget summary vs targets (future)
- `expense-tracker` — Log and categorize expenses (future)

**When to save to memory:**
- Strategy decisions or rule changes → save to trading journal
- New watchlist additions → save with ticker tag
- Risk tolerance changes → save to preferences
- Trade outcomes (win/loss/lesson) → save with analysis
- Market observations or patterns noted → save with date
- Budget category changes → save to finance profile
- New savings goal → save with SMART criteria
- Income or expense pattern changes → save with date
```

^mode-finance

---

## Pages

| Page | Purpose |
|---|---|
| [[stack/L5-routing/categories/finance/triggers]] | Trigger words, intent patterns, interaction type thresholds, topic shift signals |
| [[stack/L5-routing/categories/finance/focus-tree]] | Navigation hierarchy, focus tree JSON, button rendering per channel |
| [[stack/L5-routing/categories/finance/pipelines]] | Pipeline definitions, token costs, LLM vs lookup breakdown, dependencies |
| [[stack/L5-routing/categories/finance/conversation-flows]] | Example flows with Mermaid diagrams, channel differences, multi-turn scenarios |
| [[stack/L5-routing/categories/finance/speed-baselines]] | Latency budgets, operation breakdowns, UX red lines, caching strategy |
| [[stack/L5-routing/categories/finance/memory-filter]] | Vector DB query filter, memory types, cross-category queries, compaction rules |
| [[stack/L5-routing/categories/finance/drift-signals]] | Model drift detection, re-anchoring protocols, risk profiles per interaction type |

---

## Special Considerations

### Legal Boundary

Finance is the highest-risk category for boundary drift. Crispy must NEVER cross from "analysis" to "advice." The mode context explicitly reinforces this, and the output guardrail should flag language patterns like:

- "You should buy/sell X"
- "This is going to go up/down"
- "I recommend"
- "This is a sure thing"
- "You need to invest in"
- "You can't afford not to"

If detected, re-anchor with: "I can share the analysis, but the decision is yours."

### Connection to NautilusTrader Skill

The `quant-trading-bot-engineer-skill` covers the systematic/algorithmic side. When the conversation moves from discretionary analysis to algorithmic strategy building, consider whether the NautilusTrader skill context should supplement the finance mode.

### Markets vs Budget Sub-Modes

Within finance, markets and budget are quite different conversation flavors. The mode stays the same (analytical, measured), but the memory filter adjusts:
- Markets intent → boost tickers, positions, strategies; heavy recency weight
- Budget intent → boost categories, goals, patterns; moderate recency weight

The Focus Tree handles this naturally — user navigates to Markets or Budget, and the tree path tells the memory filter which sub-domain to prioritize.

---

**Up →** [[stack/L5-routing/categories/_overview]]
