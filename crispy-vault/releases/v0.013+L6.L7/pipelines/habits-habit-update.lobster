# habits-habit-update.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/habits/pipelines.md

name: habits-habit-update
description: >
  Modifies an existing habit's parameters: name, frequency, difficulty, or status
  (active/paused/retired). Parses the update request via flash model, loads the current
  habit record, applies the change, saves back to memory, and confirms. Handles streak
  preservation for paused habits and archiving for retired ones. One LLM call (flash).
  Target latency 300–700ms.
args:
  raw_message:
    default: ""
steps:
  - id: parse_update
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this habit update request. Return: {habit_name: string, changes: {frequency?: string, difficulty?: string, status?: \"active\"|\"paused\"|\"retired\", new_name?: string}}","input":"${raw_message}"}'
  - id: load_habit
    command: exec --json --shell 'openclaw memory recall "habits:active" 2>/dev/null | jq ".[] | select(.name == \"$parse_update_json.habit_name\")" || echo "null"'
  - id: apply_change
    command: exec --json --shell 'jq -n --argjson h "$load_habit_json" --argjson u "$parse_update_json" "\$h * \$u.changes + {name: (\$u.changes.new_name // \$h.name)}"'
  - id: save_habit
    command: exec --shell 'openclaw memory store "habits:active" "$(openclaw memory recall '"'"'habits:active'"'"' | jq "map(if .name == \"$parse_update_json.habit_name\" then $apply_change_json else . end)")"'
  - id: confirm
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Confirm this habit was updated. Briefly describe what changed. If status changed to paused, note the streak is preserved.","input":{"original":"$load_habit_json","updated":"$apply_change_json"}}'
