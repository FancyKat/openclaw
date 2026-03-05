# finance-budget-review.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/finance/pipelines.md

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
