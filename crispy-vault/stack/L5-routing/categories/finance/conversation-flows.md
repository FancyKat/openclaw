---
tags: [type/reference, layer/routing, status/draft, category/finance, focus/flows]
---

# Conversation Flows — Finance

> Example multi-turn flows with Mermaid diagrams, channel differences, and legal boundary handling.

**Up →** [[stack/L5-routing/categories/finance/_overview]]

---

## Sequence Diagram — Full Pipeline Path (Annotated)

**Scenario:** Market query triggers market-brief pipeline → expense log → budget review.

```mermaid
sequenceDiagram
    actor User
    participant TG as Telegram
    participant Flash as Flash (classify)
    participant L5 as L5 Router
    participant Mem as Memory
    participant AgentLoop as Agent Loop

    User->>TG: "How's the market today?"
    TG->>Flash: classify intent
    Note right of Flash: ~150ms
    Flash-->>L5: finance:markets (0.91)
    Note over L5: Load finance mode context
    L5->>Mem: recall(watchlist, trading style, risk rules)
    Note right of Mem: ~300ms — vec DB
    Note over L5,Mem: ⚡ market-brief pipeline [FUTURE]
    L5->>AgentLoop: fetch market data + format summary
    Note right of AgentLoop: ~2–4s — API + LLM
    AgentLoop-->>TG: Indices summary + watchlist prices
    TG->>User: Market brief + [📊 Details] [🔍 Backtest] buttons

    User->>TG: "I spent $45 on groceries"
    TG->>Flash: classify intent
    Flash-->>L5: finance:expense-log
    Note over L5,Mem: ⚡ expense-tracker pipeline [FUTURE]
    L5->>Mem: recall(budget:groceries category)
    L5->>Mem: store(expense: $45 groceries 2026-03-04)
    Mem-->>L5: ok — groceries total: $280 of $600 target
    L5-->>TG: "Logged! Groceries: $280/$600 (47% of budget)"
    TG->>User: Expense confirmation
```

### Speed Impact

| Step | Latency | Adds Latency? |
|---|---|---|
| Flash classify | 100–200ms | LLM call (flash) |
| Mode load | 20–50ms | Memory lookup |
| market-brief pipeline [FUTURE] | 2–4s | External API + LLM |
| expense-tracker pipeline [FUTURE] | 300–800ms | Memory R/W only |
| Agent loop (analysis) | 2–4s | LLM call + reasoning |
| **Total (market brief)** | **~2.5–4.5s** | — |
| **Total (expense log)** | **~400ms–1s** | — |

---

## Flow: Market Analysis with Legal Boundary

```mermaid
sequenceDiagram
    participant User
    participant Crispy
    participant Memory
    participant Agent

    User->>Crispy: "How's AAPL looking on the daily?"
    activate Crispy
    Crispy->>Memory: Load watchlist + active positions
    Crispy->>Agent: Intent: finance:markets:analysis
    activate Agent
    Agent->>Agent: Check memory for AAPL strategy rules
    Agent->>Agent: Check memory for trading style
    Agent->>Agent: Build technical analysis context
    Agent-->>Crispy: Return analysis (price, support/resistance, trend)
    deactivate Agent
    Crispy->>Crispy: Scan output for advice language<br/>("should buy", "go long", "this will go up")
    alt Boundary Violation Detected
        Crispy->>Crispy: Re-anchor: "analyst, not advisor"
        Crispy-->>User: "AAPL chart shows X and Y.<br/>The decision is yours."
    else Clean Output
        Crispy-->>User: Technical analysis with timeframe,<br/>support/resistance, volume context
    end
    deactivate Crispy
```

---

## Flow: Budget Review (Local Pipeline)

```mermaid
sequenceDiagram
    participant User
    participant Crispy
    participant Memory
    participant Pipeline

    User->>Crispy: "How'd I do on my budget this month?"
    activate Crispy
    Crispy->>Memory: Load budget categories & targets
    Crispy->>Memory: Load expense logs (March 2026)
    Crispy->>Pipeline: Invoke budget-review pipeline
    activate Pipeline
    Pipeline->>Pipeline: Group expenses by category
    Pipeline->>Pipeline: Calculate variance vs target
    Pipeline->>Pipeline: Identify under/over-spend
    Pipeline-->>Crispy: Spending summary + variance analysis
    deactivate Pipeline
    Crispy-->>User: "March Summary:<br/>Rent: $1,800 (target), Groceries: $580 (-$20),<br/>Dining: $220 (+$20 over target)"
    deactivate Crispy
```

---

## Flow: Strategy Discussion (Agent Loop)

```mermaid
sequenceDiagram
    participant User
    participant Crispy
    participant Memory
    participant Agent

    User->>Crispy: "I'm thinking about trying a mean reversion strategy. Entry at -2σ, exit at +1σ"
    activate Crispy
    Crispy->>Memory: Load existing strategy rules + trading history
    Crispy->>Agent: Intent: finance:strategy-discuss, Mode: creative
    activate Agent
    Agent->>Agent: Analyze proposed entry/exit logic
    Agent->>Agent: Check for contradictions with user's risk tolerance
    Agent->>Agent: Suggest metrics to backtest (Sharpe, drawdown, win rate)
    Agent->>Agent: Reference user's swing trading style
    Agent-->>Crispy: Discussion points + systematic questions
    deactivate Agent
    Crispy-->>User: "That entry/exit has merit for mean reversion.<br/>Questions: holding period? position size?<br/>Would you want to backtest this on SPY?"
    User->>Crispy: "Yes, let's test it on the last 6 months of SPY"
    Crispy->>Memory: Save strategy rule candidate
    Crispy->>Pipeline: Invoke backtest pipeline with parameters
    activate Pipeline
    Pipeline->>Pipeline: Run backtest (6 months SPY, -2σ/+1σ rules)
    Pipeline-->>Crispy: Backtest metrics (Sharpe, max DD, win rate, etc.)
    deactivate Pipeline
    Crispy-->>User: "Backtest results: Sharpe 1.8, max DD 8%, win rate 62%.<br/>Comparable to your current strategy?"
    deactivate Crispy
```

---

## Flow: Preference Update (Memory Write)

```mermaid
sequenceDiagram
    participant User
    participant Crispy
    participant Memory

    User->>Crispy: "My risk tolerance is moderate. I don't want to risk more than 2% per trade."
    activate Crispy
    Crispy->>Memory: Prepare memory entry (finance:risk-tolerance)
    Crispy->>Memory: Tag: finance, preference, dated 2026-03-04
    Crispy->>Memory: Save: "Max 2% per trade, 10% portfolio drawdown limit"
    Memory-->>Crispy: Stored
    Crispy-->>User: "Got it. Risk tolerance: max 2% per trade, 10% portfolio limit.<br/>I'll use this for future analysis."
    deactivate Crispy
```

---

## Channel Differences

### Telegram
- Focus Tree rendered as inline menu buttons (emoji + label)
- Analysis responses are more concise (shorter latency expectation)
- Charts/tables rendered as monospace text blocks
- Watchlist updates as quick bullet lists

### Discord
- Focus Tree as button components (with callbacks)
- More detailed analysis with formatted code blocks for metrics
- Embedded images/charts possible
- Thread-based for multi-turn analysis discussions

### Gmail
- Budget reviews can be longer, formatted (markdown → HTML)
- Detailed analysis with charts attached as images
- Strategy discussion as full email threads
- Monthly digest format for budget summaries

---

## Legal Boundary Handling

When drift is detected (advice language, emotional hype, specific recommendations):

1. **Detect:** Output scanner flags language like "you should", "buy", "invest in", "can't afford not to"
2. **Re-anchor:** Inject template: "I can share the analysis, but the decision is yours."
3. **Rephrase:** Reframe as data + user choice:
   - ❌ "You should buy AAPL; it's going up"
   - ✅ "AAPL chart shows bullish divergence on the weekly. Entry/exit are your call."
4. **Context:** Remind user of their risk tolerance and strategy rules (pull from memory)

---

**Up →** [[stack/L5-routing/categories/finance/_overview]]
