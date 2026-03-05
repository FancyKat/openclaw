# finance-backtest.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/finance/pipelines.md

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
