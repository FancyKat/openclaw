# habits-habit-reminder.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/habits/pipelines.md

name: habits-habit-reminder
description: >
  Cron-triggered proactive reminder. Runs at the user's configured check-in time, loads
  active habits, and sends a Telegram message with inline buttons for quick completion
  marking. Zero LLM calls — template-based message with dynamic habit list. Must be
  registered as a cron job in openclaw.json. Target latency 100–300ms.
steps:
  - id: load_habits
    command: exec --json --shell 'openclaw memory recall "habits:active" 2>/dev/null | jq "[.[] | select(.status == \"active\")]" || echo "[]"'
  - id: check_already_done
    command: exec --json --shell 'openclaw memory recall "habits:checkin:$(date +%Y-%m-%d)" 2>/dev/null | jq ". != null and (. | length > 0)"'
  - id: send_reminder
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Write a brief, warm morning check-in message listing these habits. Include emoji. Keep it under 100 chars.","input":"$load_habits_json"}'
    condition: $check_already_done.json == false
