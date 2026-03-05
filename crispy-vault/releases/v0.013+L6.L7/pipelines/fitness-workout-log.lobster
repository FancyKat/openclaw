# fitness-workout-log.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/fitness/pipelines.md

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
