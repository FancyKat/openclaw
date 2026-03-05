# finance-market-brief.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/finance/pipelines.md

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
