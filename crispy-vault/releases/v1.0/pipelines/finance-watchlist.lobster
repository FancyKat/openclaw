# finance-watchlist.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/finance/pipelines.md

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
