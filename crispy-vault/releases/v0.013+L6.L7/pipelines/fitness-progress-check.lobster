# fitness-progress-check.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/fitness/pipelines.md

name: fitness-progress-check
description: >
  Queries workout history from memory and returns a progress summary with PRs, trends,
  and recent sessions. Reads up to 8 weeks of history, aggregates by exercise, detects
  trends (improving/plateau/declining), and formats a readable report. One LLM call
  (main model) for analysis and insight. Target latency 600ms–1.5s.
args:
  exercise:
    default: ""
  weeks:
    default: "8"
steps:
  - id: load_history
    command: exec --json --shell 'openclaw memory recall "fitness:workout-log" 2>/dev/null | jq "[.[] | select(.date >= (now - (${weeks}*7)*86400 | strftime(\"%Y-%m-%d\")))]" || echo "[]"'
  - id: load_goals
    command: exec --json --shell 'openclaw memory recall "fitness:goals" 2>/dev/null || echo "{}"'
  - id: aggregate
    command: exec --json --shell 'jq -n --argjson h "$load_history_json" --argjson g "$load_goals_json" --arg ex "${exercise}" "{goals: \$g, history: (\$h | if \$ex != \"\" then [.[].exercises[] | select(.name | test(\$ex;\"i\"))] else [.[].exercises[]] end | group_by(.name) | map({exercise: .[0].name, sessions: length, max_weight: map(.weight_lbs) | max, recent: (sort_by(.date) | last)}) )}"'
  - id: analyze
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"workhorse","prompt":"Analyze this training history. Show PRs, trends (improving/plateau/declining), and recent sessions. Compare to goals if available. Add one motivational insight. Be concise but detailed.","input":"$aggregate_json"}'
    stdin: $aggregate.stdout
