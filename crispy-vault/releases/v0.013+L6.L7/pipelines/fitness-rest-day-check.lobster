# fitness-rest-day-check.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/fitness/pipelines.md

name: fitness-rest-day-check
description: >
  Assesses recent training volume and intensity to recommend rest or training. Reads
  the last 7 days of workout logs, calculates total volume per muscle group, checks for
  consecutive training days, and generates a recommendation with rationale. One LLM call
  (flash) for the recommendation. Target latency 400–900ms.
steps:
  - id: load_recent
    command: exec --json --shell 'openclaw memory recall "fitness:workout-log" 2>/dev/null | jq "[.[] | select(.date >= ((now - 7*86400) | strftime(\"%Y-%m-%d\")))]" || echo "[]"'
  - id: assess_volume
    command: exec --json --shell 'jq -n --argjson log "$load_recent_json" "{days_trained: (\$log | length), consecutive_days: (\$log | [.[].date] | sort | reverse | if length > 1 then (.[0:2] | map(strptime(\"%Y-%m-%d\") | mktime) | (.[0] - .[1]) <= 86400) else false end), total_sets: (\$log | [.[].exercises[].sets] | add // 0), last_workout: (\$log | sort_by(.date) | last // null) }"'
  - id: recommend
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Based on this recent training data, give a clear rest or train recommendation with rationale. Keep it brief (2–3 sentences). Consider: consecutive days, total volume, last workout intensity.","input":"$assess_volume_json"}'
    stdin: $assess_volume.stdout
