---
tags: [type/reference, layer/routing, status/draft, category/habits, focus/pipelines]
---

# Habits: Pipelines

> Pipeline definitions, token budgets, and trigger conditions for habits mode.

**Up →** [[stack/L5-routing/categories/habits/_overview]]

---

## Pipeline Registry

| Pipeline | Trigger | Status | Token Budget | What It Does |
|---|---|---|---|---|
| `habit-checkin` | "check in", "did my habits", "logging habits" | 🔲 Future | ~150 | Quick daily habit check-in, marks completion, updates streak |
| `habit-review` | "how'd I do", "this week", "habit report" | 🔲 Future | ~200 | Daily or weekly summary with streaks and consistency rate |
| `streak-check` | "my streaks", "longest streak", "how consistent" | 🔲 Future | ~120 | Shows current active streaks for all tracked habits |
| `habit-update` | "change habit", "pause", "modify", "scale up" | 🔲 Future | ~180 | Modifies existing habit parameters or status |
| `habit-reminder` | cron-triggered at user's check-in time | 🔲 Future | ~100 | Proactive check-in prompt via Telegram |

---

## Pipeline Details

### habit-checkin

**Trigger:** User says "check in", "did my habits", "logging habits" or taps "Check In" button

**Input:**
- Active habits list (from memory)
- Optional: specify habits to log

**Output:**
- Habit completion form (inline buttons or quick reply)
- Updated streak counters
- Encouragement message

**Token breakdown:**
- Fetch active habits: 30 tokens
- Render form: 40 tokens
- Process completion: 50 tokens
- Update memory: 30 tokens

---

### habit-review

**Trigger:** User says "how'd I do", "habit report", "this week"

**Input:**
- Time window (today or week)
- Active habits list
- Consistency data

**Output:**
- Summary table (habits + completion %)
- Streak status for each
- Insights ("You're strongest on mornings")

**Token breakdown:**
- Fetch data: 50 tokens
- Aggregate stats: 60 tokens
- Render report: 70 tokens
- Generate insight: 20 tokens

---

### streak-check

**Trigger:** User says "my streaks", "longest streak", "how consistent"

**Input:**
- All tracked habits
- Current streak counters

**Output:**
- Streak leaderboard
- Current vs. personal best
- Milestone celebrations if applicable

**Token breakdown:**
- Fetch habits: 30 tokens
- Sort/rank: 40 tokens
- Render leaderboard: 40 tokens
- Format message: 10 tokens

---

### habit-update

**Trigger:** User says "change habit", "pause", "modify", "too hard"

**Input:**
- Habit name
- New parameters (frequency, difficulty, status)

**Output:**
- Confirmation of change
- Optional: reminder of old parameters
- Updated streak handling (paused = preserve, retired = archive)

**Token breakdown:**
- Parse input: 40 tokens
- Fetch habit record: 30 tokens
- Apply changes: 50 tokens
- Save & confirm: 40 tokens
- Memory log: 20 tokens

---

### habit-reminder

**Trigger:** Cron job at user's preferred check-in time

**Input:**
- User's check-in time preference
- Today's date
- Active habits list

**Output:**
- Telegram message with habit list as inline buttons
- Quick tap to mark complete/skip

**Token breakdown:**
- Fetch habits: 30 tokens
- Format message: 40 tokens
- Render buttons: 20 tokens
- Send: 10 tokens

---

## Lobster YAML Definitions

### `habit-checkin`

```yaml
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
```
^pipeline-habits-habit-checkin

---

### `habit-review`

```yaml
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
```
^pipeline-habits-habit-review

---

### `streak-check`

```yaml
name: habits-streak-check
description: >
  Queries all active habit streaks and returns a ranked leaderboard with current vs
  personal-best streaks. Compares current streaks to stored personal bests, highlights
  milestones, and celebrates new records. Zero LLM calls — fully deterministic. Target
  latency 100–300ms.
steps:
  - id: load_streaks
    command: exec --json --shell 'openclaw memory recall "habits:streaks" 2>/dev/null || echo "{}"'
  - id: load_personal_bests
    command: exec --json --shell 'openclaw memory recall "habits:personal-bests" 2>/dev/null || echo "{}"'
  - id: build_leaderboard
    command: exec --json --shell 'jq -n --argjson s "$load_streaks_json" --argjson pb "$load_personal_bests_json" "[(\$s | to_entries[] | {habit: .key, current: .value, personal_best: (\$pb[.key] // .value), is_record: (.value >= (\$pb[.key] // .value))})] | sort_by(-.current)"'
  - id: update_personal_bests
    command: exec --shell 'jq -n --argjson l "$build_leaderboard_json" "[\$l[] | select(.is_record)] | map({(.habit): .current}) | add // {}" | openclaw memory store "habits:personal-bests" -'
  - id: format_leaderboard
    command: exec --shell 'echo "$build_leaderboard_json" | jq -r ".[] | \"🔥 \(.habit): \(.current) days\(if .is_record then \" 🏆 new record!\" else \" (best: \(.personal_best))\" end)\""'
    stdin: $build_leaderboard.stdout
```
^pipeline-habits-streak-check

---

### `habit-update`

```yaml
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
```
^pipeline-habits-habit-update

---

### `habit-reminder`

```yaml
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
```
^pipeline-habits-habit-reminder

---

## Dependencies

- `habit-checkin`, `habit-review`, `streak-check` depend on **memory**: active habits list, streak counters, check-in history
- `habit-update` depends on **memory write**: save old params + reasoning for audit
- `habit-reminder` depends on **cron** (L6 heartbeat), **user preferences**, **Telegram channel**

---

## Future Enhancements

- Webhook integration for external habit trackers (Habitica, Done, etc.)
- Habit analytics: correlation with other activities
- Predictive streak warnings ("You're 2 days away from 30-day milestone")

---

**Up →** [[stack/L5-routing/categories/habits/_overview]]
