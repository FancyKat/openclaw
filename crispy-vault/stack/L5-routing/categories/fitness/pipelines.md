---
tags: [type/reference, layer/routing, status/draft, category/fitness, focus/pipelines]
---

# Fitness Pipelines

> Pipeline definitions for fitness category. Includes trigger conditions, status, token costs, and dependencies.

**Up →** [[stack/L5-routing/categories/fitness/_overview]]

---

## Pipeline Map

| Pipeline | Trigger | Status | What It Does |
|---|---|---|---|
| `workout-log` | "I did X", "log this workout", "record" | 🔲 Future | Structured workout logging with sets/reps/weight |
| `progress-check` | "how am I doing", "my PRs", "progress" | 🔲 Future | Queries workout history, shows trends and PRs |
| `program-generator` | "build me a program", "training plan" | 🔲 Future | Multi-week program design with periodization |
| `rest-day-check` | "should I rest today", "recovery status" | 🔲 Future | Checks recent volume/intensity, recommends rest or training |

---

## Pipeline Details

### workout-log

**Purpose:** Record a completed workout with structured fields

**Trigger:** User says "I did X", "log this workout", "record", etc.

**Input Schema:**
```json
{
  "exercises": [
    {
      "name": "string",
      "sets": "integer",
      "reps": "integer",
      "weight": "number (lbs or kg)",
      "notes": "string (optional)"
    }
  ],
  "date": "ISO date (optional, defaults to today)",
  "duration": "minutes (optional)",
  "notes": "string (optional)"
}
```

**Output:** Confirmation with PR detection, memory save, progress summary

**Memory Impact:** Write to fitness:workout-log with date and details

---

### progress-check

**Purpose:** Query training history and show trends, PRs, recent workouts

**Trigger:** User asks "how am I doing", "my PRs", "progress", "how's X trending"

**Input:** Exercise name (optional), timeframe (optional, defaults to last 8 weeks)

**Output:** Table of PRs, trend chart (text-based), recent sessions

**Memory Impact:** Read from fitness:workout-log, fitness:goals

---

### program-generator

**Purpose:** Design a multi-week training program with periodization

**Trigger:** User says "build me a program", "create a training plan", "design a split"

**Input Schema:**
```json
{
  "goal": "string (e.g., 'get stronger', 'build muscle', 'improve endurance')",
  "duration_weeks": "integer",
  "frequency": "integer (days per week)",
  "equipment": "array of strings",
  "experience_level": "beginner|intermediate|advanced",
  "injuries_or_limitations": "string (optional)",
  "current_program": "string (optional)"
}
```

**Output:** Week-by-week program with exercise selection, rep/set schemes, progression logic

**Memory Impact:** Write to fitness:program with design rationale

---

### rest-day-check

**Purpose:** Assess recent training volume/intensity and recommend rest or training

**Trigger:** User asks "should I rest today", "recovery status", "am I overtraining"

**Input:** Recent workout history (queried from memory)

**Output:** Recovery recommendation + rationale

**Memory Impact:** Read from fitness:workout-log, fitness:recovery-notes

---

## Lobster YAML Definitions

### `workout-log`

```yaml
name: fitness-workout-log
description: >
  Logs a completed workout session to structured memory with PR detection. Parses
  exercises, sets, reps, and weights from the user message via flash model. Checks
  for personal records by comparing against stored history, saves the session, and
  returns a confirmation with any PR announcements. One LLM call (flash) for parsing.
  Target latency 400–800ms. Writes to fitness:workout-log with full session data.
args:
  raw_message:
    default: ""
steps:
  - id: parse_workout
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this workout log. Return: {date: \"YYYY-MM-DD\" (default today), duration_min: number|null, exercises: [{name, sets, reps, weight_lbs, notes}], notes: string|null}","input":"${raw_message}"}'
  - id: load_history
    command: exec --json --shell 'openclaw memory recall "fitness:workout-log" 2>/dev/null | jq "[.[] | select(.date >= (now - 90*86400 | strftime(\"%Y-%m-%d\")))]" || echo "[]"'
  - id: detect_prs
    command: exec --json --shell 'jq -n --argjson new "$parse_workout_json" --argjson hist "$load_history_json" "[\$new.exercises[] | . as \$ex | {exercise: \$ex.name, new_weight: \$ex.weight_lbs, prev_max: ([\$hist[].exercises[] | select(.name == \$ex.name) | .weight_lbs] | max // 0), is_pr: (\$ex.weight_lbs > ([\$hist[].exercises[] | select(.name == \$ex.name) | .weight_lbs] | max // 0))}]"'
  - id: save_session
    command: exec --shell 'openclaw memory store "fitness:workout-log" "$(openclaw memory recall '"'"'fitness:workout-log'"'"' 2>/dev/null | jq ". + [$parse_workout_json]" || echo "[$parse_workout_json]")"'
  - id: format_response
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Confirm this workout was logged. Celebrate any PRs with 🎉. Show session summary (exercises, top sets). Be encouraging and brief.","input":{"session":"$parse_workout_json","prs":"$detect_prs_json"}}'
```
^pipeline-fitness-workout-log

---

### `progress-check`

```yaml
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
```
^pipeline-fitness-progress-check

---

### `program-generator`

```yaml
name: fitness-program-generator
description: >
  Designs a multi-week training program using the agent loop with memory of the user's
  goals, experience, equipment, and injury history. Spawns an agent session for complex
  creative composition with periodization logic. Requires approval before saving. Three
  agent turns: structure → detail → finalize. Target latency 10–20s (complex composition).
args:
  raw_message:
    default: ""
steps:
  - id: parse_params
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Extract program design parameters: {goal, duration_weeks, frequency_per_week, equipment: [], experience_level: beginner|intermediate|advanced, injuries: string|null}","input":"${raw_message}"}'
  - id: load_context
    command: exec --json --shell 'openclaw memory recall "fitness:goals" 2>/dev/null; openclaw memory recall "fitness:workout-log" 2>/dev/null | jq "[.[-10:]]"'
  - id: generate_program
    command: openclaw.invoke --tool sessions_spawn --action run --args-json '{"prompt":"Design a ${parse_params_json.duration_weeks}-week training program. Use periodization (progressive overload, deload weeks). Include: weekly structure, exercise selection, rep/set schemes, progression logic, and coaching notes. Account for experience level and any injuries.","context":"$load_context_json","model":"workhorse"}'
    timeout: 45000
  - id: review
    command: approve --preview-from-stdin --prompt 'Review this training program before saving to memory.'
    stdin: $generate_program.stdout
    approval: required
  - id: save_program
    command: exec --shell 'openclaw memory store "fitness:program:current" "$generate_program_json"'
    condition: $review.approved
```
^pipeline-fitness-program-generator

---

### `rest-day-check`

```yaml
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
```
^pipeline-fitness-rest-day-check

---

## Future Pipeline Considerations

- **nutrition-calculator** — Estimate daily macros based on goals, weight, activity
- **injury-tracker** — Log and monitor injury reports with recovery timeline
- **equipment-swap** — Suggest alternative exercises based on available equipment
