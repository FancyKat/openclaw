---
tags: [type/reference, layer/routing, status/draft, category/finance, focus/pipelines]
---

# Pipelines — Finance

> Pipeline definitions, trigger conditions, and current status. Finance has both future market-data pipelines and local budget pipelines.

**Up →** [[stack/L5-routing/categories/finance/_overview]]

---

## Pipeline Map

| Pipeline | Trigger | Status | What It Does |
|---|---|---|---|
| `market-brief` | "/market", "how's the market", "market update" | 🔲 Future | Fetches indices, sector performance, watchlist prices |
| `position-check` | "/positions", "what am I holding", "P&L" | 🔲 Future | Queries connected broker for current positions |
| `backtest` | "/backtest", "test this strategy" | 🔲 Future | Runs NautilusTrader backtest with specified parameters |
| `watchlist` | "/watchlist", "add X to watchlist" | 🔲 Future | Maintains and queries a personal watchlist |
| `budget-review` | "/budget", "how'd I do this month" | 🔲 Future | Monthly spending review against budget targets |
| `expense-tracker` | "I spent", "log expense", "bought" | 🔲 Future | Logs and categorizes individual expenses |

*Market pipelines require external connections (broker API, market data). Budget pipelines can work locally with structured memory. Pipeline infrastructure builds out as NautilusTrader integration matures.*

---

## Lobster YAML Definitions

### `market-brief`

```yaml
name: finance-market-brief
description: >
  Fetches current market data for key indices (SPY, QQQ, VIX) and the user's watchlist
  tickers via web_search, then formats a concise brief with sector performance and price
  changes. One LLM call (flash) for formatting. Target latency 2–4s (API-bound). Falls
  back to agent loop if web_search is unavailable.
steps:
  - id: fetch_indices
    command: openclaw.invoke --tool web_search --args-json '{"query":"SPY QQQ VIX stock price today","num_results":3}'
  - id: load_watchlist
    command: exec --json --shell 'openclaw memory recall "finance:watchlist" 2>/dev/null || echo "[]"'
  - id: fetch_watchlist
    command: openclaw.invoke --tool web_search --args-json '{"query":"$load_watchlist_json[].ticker stock price today","num_results":5}'
  - id: format_brief
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format a concise market brief from these data points. Show indices with % change, then watchlist tickers. Keep it scannable. Lead with market sentiment (bullish/bearish/neutral).","input":{"indices":"$fetch_indices_json","watchlist":"$fetch_watchlist_json"}}'
```
^pipeline-finance-market-brief

---

### `position-check`

```yaml
name: finance-position-check
description: >
  Queries connected broker API for current open positions with entry price, current
  price, P&L, and percentage gain per position. Formats a clean summary with portfolio
  totals. Requires BROKER_API_KEY env var and broker integration to be configured.
  Target latency 1–3s (broker API latency). Falls back with error message if no broker
  is configured.
steps:
  - id: check_broker
    command: exec --json --shell 'test -n "$BROKER_API_KEY" && echo "{\"configured\":true}" || echo "{\"configured\":false}"'
  - id: fetch_positions
    command: exec --json --shell 'curl -s -H "Authorization: Bearer $BROKER_API_KEY" "$BROKER_API_URL/v1/positions" | jq .'
    condition: $check_broker.json.configured == true
  - id: fetch_quotes
    command: exec --json --shell 'echo "$fetch_positions_json" | jq -r ".[].symbol" | tr "\n" "," | xargs -I{} curl -s "$BROKER_API_URL/v1/quotes?symbols={}" | jq .'
    condition: $check_broker.json.configured == true
  - id: format_positions
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format these broker positions as a clean P&L summary. Show: symbol, qty, entry, current, unrealized P&L ($), unrealized P&L (%). Add portfolio totals row.","input":{"positions":"$fetch_positions_json","quotes":"$fetch_quotes_json"}}'
    condition: $check_broker.json.configured == true
  - id: not_configured
    command: exec --shell 'echo "No broker integration configured. Set BROKER_API_KEY and BROKER_API_URL in .env to enable position tracking."'
    condition: $check_broker.json.configured == false
```
^pipeline-finance-position-check

---

### `backtest`

```yaml
name: finance-backtest
description: >
  Runs a strategy backtest using NautilusTrader with user-specified entry/exit rules
  and parameters. Requires NAUTILUS_PATH configured. Parses strategy parameters from
  the user message via LLM, constructs the backtest config, runs NautilusTrader in
  a subprocess, and returns a formatted metrics table. Target latency 5–20s (simulation
  time-dependent). Approval required before running (computationally expensive).
args:
  raw_message:
    default: ""
  symbol:
    default: "SPY"
  lookback_months:
    default: "6"
steps:
  - id: parse_strategy
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Extract backtest parameters from this request: {symbol, lookback_months, entry_rule, exit_rule, position_size_pct}","input":"${raw_message}"}'
  - id: confirm
    command: approve --preview-from-stdin --prompt 'Run backtest with these parameters?'
    stdin: $parse_strategy.stdout
    approval: required
  - id: run_backtest
    command: exec --json --shell 'python3 $NAUTILUS_PATH/run_backtest.py --config "$parse_strategy_json" --output json'
    timeout: 60000
    condition: $confirm.approved
  - id: format_results
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format these backtest results as a clean metrics table: Sharpe ratio, max drawdown, win rate, total return, number of trades, expectancy. Add a one-sentence interpretation of the key metrics.","input":"$run_backtest_json"}'
    condition: $confirm.approved
```
^pipeline-finance-backtest

---

### `watchlist`

```yaml
name: finance-watchlist
description: >
  Manages the user's ticker watchlist stored in memory. Accepts add/remove/view actions,
  updates the watchlist, and optionally fetches current prices for viewed tickers. One
  flash LLM call for intent parsing; view with prices adds one web_search call. Target
  latency 300–800ms (view without prices), 1–2s (view with prices).
args:
  raw_message:
    default: ""
steps:
  - id: parse_intent
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this watchlist request. Return: {action: \"add\"|\"remove\"|\"view\", tickers: [\"string\"]}","input":"${raw_message}"}'
  - id: recall_watchlist
    command: exec --json --shell 'openclaw memory recall "finance:watchlist" 2>/dev/null || echo "[]"'
  - id: apply_change
    command: exec --json --shell 'jq -n --argjson p "$parse_intent_json" --argjson w "$recall_watchlist_json" "if \$p.action == \"add\" then \$w + [\$p.tickers[] | {ticker: .}] | unique_by(.ticker) elif \$p.action == \"remove\" then \$w | map(select(.ticker as \$t | \$p.tickers | index(\$t) == null)) else \$w end"'
  - id: save_watchlist
    command: exec --shell 'openclaw memory store "finance:watchlist" "$apply_change_json"'
    condition: $parse_intent.json.action != "view"
  - id: format_response
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format this watchlist update as a brief, clear response. For view action show the full list. For add/remove confirm the change.","input":{"action":"$parse_intent_json.action","watchlist":"$apply_change_json"}}'
```
^pipeline-finance-watchlist

---

### `budget-review`

```yaml
name: finance-budget-review
description: >
  Aggregates logged expenses for the current month and compares against budget targets
  stored in memory. Groups by category, calculates variance, and flags over/under-spend.
  Zero LLM calls for data aggregation; one flash call for formatting and insights.
  Target latency 800ms–1.5s. Falls back to agent loop if expense log is empty.
args:
  month:
    default: ""
steps:
  - id: load_targets
    command: exec --json --shell 'openclaw memory recall "finance:budget:targets" 2>/dev/null || echo "{}"'
  - id: load_expenses
    command: exec --json --shell 'openclaw memory recall "finance:expenses:${month:-$(date +%Y-%m)}" 2>/dev/null || echo "[]"'
  - id: aggregate
    command: exec --json --shell 'jq -n --argjson t "$load_targets_json" --argjson e "$load_expenses_json" "{ month: \"${month:-$(date +%Y-%m)}\", categories: (\$e | group_by(.category) | map({ category: .[0].category, spent: (map(.amount) | add // 0), target: (\$t[.[0].category] // null), variance: (((map(.amount) | add // 0) - (\$t[.[0].category] // 0))) }) ) }"'
  - id: format_review
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format this monthly budget review. Show each category with spent vs target and variance ($). Flag over-budget categories with ⚠️. End with a one-line summary.","input":"$aggregate_json"}'
    stdin: $aggregate.stdout
```
^pipeline-finance-budget-review

---

### `expense-tracker`

```yaml
name: finance-expense-tracker
description: >
  Logs a single expense from the user's message to structured memory. Parses amount,
  description, and category via flash model, saves to the current month's expense log,
  and confirms with running category total. One LLM call (flash) for parsing. Target
  latency 300–800ms. Idempotency: deduplicates by timestamp+amount.
args:
  raw_message:
    default: ""
steps:
  - id: parse_expense
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this expense log entry. Return: {amount: number, currency: \"USD\", description: string, category: \"groceries\"|\"dining\"|\"transport\"|\"utilities\"|\"entertainment\"|\"health\"|\"shopping\"|\"other\", date: \"YYYY-MM-DD\" (default today)}","input":"${raw_message}"}'
  - id: load_month_log
    command: exec --json --shell 'openclaw memory recall "finance:expenses:$(date +%Y-%m)" 2>/dev/null || echo "[]"'
  - id: append_expense
    command: exec --json --shell 'jq -n --argjson e "$parse_expense_json" --argjson log "$load_month_log_json" "[\$log[], (\$e + {id: \"exp-$(date +%s)\"})]"'
  - id: save_log
    command: exec --shell 'openclaw memory store "finance:expenses:$(date +%Y-%m)" "$append_expense_json"'
  - id: calc_category_total
    command: exec --json --shell 'echo "$append_expense_json" | jq --argjson cat "$parse_expense_json.category" "[.[] | select(.category == \$cat)] | map(.amount) | add // 0"'
    stdin: $append_expense.stdout
  - id: confirm
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Confirm this expense was logged. Show: amount, category, and running monthly total for that category. Be brief.","input":{"expense":"$parse_expense_json","category_total":"$calc_category_total_json"}}'
```
^pipeline-finance-expense-tracker

---

**Up →** [[stack/L5-routing/categories/finance/_overview]]

### market-brief
**Trigger:** User asks for market overview, indices, watchlist prices, or sector performance.
**Dependencies:** External market data API (future: NautilusTrader or broker integration)
**Output:** Summary of key indices, sector winners/losers, user's watchlist status
**Token cost:** ~200-300 tokens (LLM reasoning) + API latency

### position-check
**Trigger:** User asks "what am I holding", current positions, P&L status
**Dependencies:** Broker API connection (future)
**Output:** Current positions with entry price, current price, P&L, percentage gain
**Token cost:** ~150-200 tokens (formatting + context)

### backtest
**Trigger:** User requests historical strategy test (e.g., "backtest this RSI strategy on SPY")
**Dependencies:** NautilusTrader (future), market data
**Output:** Metrics table (Sharpe, max drawdown, win rate, total return, expectancy)
**Token cost:** ~400-500 tokens (setup + metric interpretation)

### watchlist
**Trigger:** User adds/removes/checks watchlist items
**Dependencies:** Memory storage (local)
**Output:** Watchlist display with current prices, % change
**Token cost:** ~100-150 tokens

### budget-review
**Trigger:** User asks "how'd I do this month", "budget check"
**Dependencies:** Memory categories and targets, expense logs
**Output:** Spending by category vs budget target, variance, recommendations
**Token cost:** ~250-350 tokens

### expense-tracker
**Trigger:** User logs expense ("I spent $45 on groceries")
**Dependencies:** Memory category definitions
**Output:** Confirmation, category suggestion, updated totals
**Token cost:** ~100-150 tokens

---

**Up →** [[stack/L5-routing/categories/finance/_overview]]
