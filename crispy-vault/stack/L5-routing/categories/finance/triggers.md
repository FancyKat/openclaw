---
tags: [type/reference, layer/routing, status/draft, category/finance, focus/triggers]
---

# Triggers — Finance

> Trigger words, intent patterns, and interaction type thresholds for the Finance category. Finance is Informational + Assistance heavy due to legal boundary constraints.

**Up →** [[stack/L5-routing/categories/finance/_overview]]

---

## Trigger Words

### High Confidence (→ load hat immediately)
```
trade, trading, stock, stocks, market, portfolio, position,
ticker, equity, options, futures, forex, crypto, chart, candle,
candlestick, backtest, backtesting, indicator,
buy, sell, long, short, stop loss, take profit, risk management,
budget, budgeting, savings, bank account, credit card, debt,
401k, IRA, Roth, investment, investing, compound interest,
net worth, income, expense, paycheck, bills
```

### Medium Confidence (→ classify with context)
```
price, value, volume, trend, breakout, support, resistance,
moving average, RSI, MACD, Bollinger, earnings, dividend,
sector, ETF, index, SPY, QQQ, hedge, leverage, margin,
alpha, beta, Sharpe, drawdown, P&L, PnL,
money, spend, spending, afford, cost, save, saving,
interest rate, mortgage, loan, refinance, APR, credit score,
tax, deduction, capital gains, write-off, W2, 1099
```

*Medium-confidence words like "price" or "save" need context — could be cooking (price of groceries), habits (save time), or finance.*

### Sub-Category Signals

| Sub-Category | Additional Triggers |
|---|---|
| **markets** | "what do you think about", "how's X looking", chart mentions, TA terms |
| **positions** | "my portfolio", "current positions", "what am I holding", "P&L" |
| **strategy** | "strategy for", "approach to", "when should I", "entry/exit" |
| **backtesting** | "backtest", "historical", "would this have worked", "simulate" |
| **budget** | "budget", "spending", "how much did I", "this month's expenses" |
| **planning** | "save for", "retirement", "goal", "emergency fund", "down payment" |
| **news** | "market news", "what happened", "earnings", "Fed", "CPI" |
| **learning** | "explain", "what is", "how does X work", options terminology, finance concepts |

^triggers-finance

---

## Intent Patterns

| Intent | What User Wants | Route | Example |
|---|---|---|---|
| `finance:market-check` | Current market overview | Pipeline → market-brief | "How's the market today?" |
| `finance:position-check` | Portfolio/position status | Pipeline → position-check | "What am I holding?" |
| `finance:analysis` | Analysis of a specific ticker/setup | Agent loop (reasoning) | "How's AAPL looking on the daily?" |
| `finance:strategy-discuss` | Discuss or develop a trading strategy | Agent loop (creative) | "I want to build a mean reversion strategy" |
| `finance:backtest` | Test a strategy historically | Pipeline → backtest | "Backtest this RSI strategy on SPY" |
| `finance:budget-review` | Review spending or budget | Pipeline → budget-review | "How'd I do on my budget this month?" |
| `finance:expense-track` | Log or categorize an expense | Pipeline → expense-tracker | "I spent $45 on groceries today" |
| `finance:plan-goal` | Set or review a financial goal | Agent loop + SMART+ | "I want to save $10K for an emergency fund" |
| `finance:news-check` | Market news and events | Pipeline → market-brief | "Any important earnings this week?" |
| `finance:risk-assess` | Evaluate risk on a position or portfolio | Agent loop (analytical) | "What's my portfolio risk right now?" |
| `finance:learn` | Understand a finance concept | Agent loop (informational) | "Explain iron condors to me" |
| `finance:preference-update` | Tell Crispy a financial preference | Memory write → confirm | "My risk tolerance is moderate" / "I get paid biweekly" |

---

**Up →** [[stack/L5-routing/categories/finance/_overview]]
