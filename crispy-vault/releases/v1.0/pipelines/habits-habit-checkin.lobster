# habits-habit-checkin.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/habits/pipelines.md

name: habits-habit-checkin
description: >
  Runs the daily habit check-in flow. Loads the user's active habits, renders an
  inline button list in Telegram for marking complete/skip, processes the completions,
  updates streak counters, saves results, and sends an encouragement response. Zero LLM
  calls — fully deterministic memory R/W. Celebrates streak milestones. Target latency
  200–500ms. Triggered by user text or habit-reminder button tap.
args:
  completed_habits:
    default: "[]"
  skipped_habits:
    default: "[]"
steps:
  - id: load_habits
    command: exec --json --shell 'openclaw memory recall "habits:active" 2>/dev/null || echo "[]"'
  - id: load_streaks
    command: exec --json --shell 'openclaw memory recall "habits:streaks" 2>/dev/null || echo "{}"'
  - id: update_streaks
    command: exec --json --shell 'jq -n --argjson h "$load_habits_json" --argjson s "$load_streaks_json" --argjson done "${completed_habits}" --argjson skip "${skipped_habits}" "{\$s | to_entries | map(if (.key | IN(\$done[])) then .value += 1 elif (.key | IN(\$skip[])) then . else . end) | from_entries}"'
  - id: detect_milestones
    command: exec --json --shell 'echo "$update_streaks_json" | jq "[to_entries[] | select(.value | IN(7,14,21,30,60,90,100,365)) | {habit: .key, days: .value}]"'
    stdin: $update_streaks.stdout
  - id: save_completion
    command: exec --shell 'openclaw memory store "habits:checkin:$(date +%Y-%m-%d)" "{\"completed\":${completed_habits},\"skipped\":${skipped_habits}}" && openclaw memory store "habits:streaks" "$update_streaks_json"'
  - id: format_response
    command: exec --shell 'echo "$(jq -r '\''"Done! \([$completed_habits | length])/\([$load_habits_json | length]) today. \(if $detect_milestones_json | length > 0 then "🎉 Milestone: \($detect_milestones_json[0].habit) \($detect_milestones_json[0].days) days!" else "" end)"'\'' <<< "{}")"'
