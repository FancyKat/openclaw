# habits-habit-review.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/habits/pipelines.md

name: habits-habit-review
description: >
  Generates a daily or weekly habit completion summary. Loads check-in history, active
  habits, and streak data, then aggregates completion rates per habit and formats a
  summary report with insights. One LLM call (flash) for the insight sentence. Target
  latency 300–600ms.
args:
  period:
    default: "week"
steps:
  - id: load_habits
    command: exec --json --shell 'openclaw memory recall "habits:active" 2>/dev/null || echo "[]"'
  - id: load_checkins
    command: exec --json --shell 'openclaw memory recall "habits:checkins:$(date +%Y-%m)" 2>/dev/null || echo "[]"'
  - id: load_streaks
    command: exec --json --shell 'openclaw memory recall "habits:streaks" 2>/dev/null || echo "{}"'
  - id: aggregate
    command: exec --json --shell 'jq -n --argjson h "$load_habits_json" --argjson c "$load_checkins_json" --argjson s "$load_streaks_json" "{ period: \"${period}\", habits: [\$h[] | {name: .name, streak: (\$s[.name] // 0), completions: [\$c[] | select(.completed[] == .name)] | length, skips: [\$c[] | select(.skipped[] == .name)] | length }] }"'
  - id: format_review
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format this habit review as a clean summary table. Show habit, completion %, current streak. End with one motivational insight about the strongest or most improved habit.","input":"$aggregate_json"}'
    stdin: $aggregate.stdout
