# finance-position-check.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/finance/pipelines.md

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
