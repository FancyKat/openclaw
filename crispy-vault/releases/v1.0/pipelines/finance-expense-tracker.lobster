# finance-expense-tracker.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/finance/pipelines.md

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
