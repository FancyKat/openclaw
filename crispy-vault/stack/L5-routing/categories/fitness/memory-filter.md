---
tags: [type/reference, layer/routing, status/draft, category/fitness, focus/memory]
---

# Fitness Memory Filter

> Vector database query filter, memory types, cross-category queries, and compaction rules for fitness interactions.

**Up →** [[stack/L5-routing/categories/fitness/_overview]]

---

## Memory Query Filter

```json
{
  "category": ["fitness", "fitness:workout", "fitness:tracking", "fitness:goals", "fitness:recovery"],
  "cross_category": ["cooking:nutrition"],
  "exclude_categories": ["coding", "trading"],
  "boost_fields": ["exercise_name", "pr_value", "injury_area", "program_name"],
  "recency_weight": 0.3,
  "semantic_weight": 0.3,
  "category_weight": 0.25,
  "frequency_weight": 0.15
}
```

*Note the `cross_category` field — fitness is the first hat to explicitly pull from another category (cooking:nutrition). This is how we handle the nutrition overlap without conflating the two hats.*

^filter-fitness

---

## Memory Types to Retrieve

| Memory Type | Example | Priority |
|---|---|---|
| **Current program** | "Running PPL split, 4 days/week, started Feb 15" | Always load |
| **PRs** | "Squat: 225x5, Bench: 185x3, Deadlift: 275x5" | Always load |
| **Training schedule** | "Mon/Wed/Fri lifting, Tue/Thu cardio, weekends off" | Always load |
| **Injury history** | "Tweaked right shoulder doing overhead press, March 1" | Always load |
| **Recent workouts** | "Last leg day: squats 5x5@185, leg press 3x12@270" | Load if same muscle group |
| **Equipment access** | "Home gym: rack, barbell, dumbbells to 50, pull-up bar" | Always load |
| **Goals** | "Goal: bench 225 by June, currently at 185x3" | Load for goal/program intents |
| **Nutrition (cross-cat)** | "Eating ~180g protein/day, 2800 cal" | Load for nutrition intents |

---

## Cross-Category Query Handling

### When Fitness Pulls Cooking Memory

**Scenario:** User asks "How much protein should I eat?"

```
Primary category: fitness:nutrition-check
→ Fitness memory filter active
→ Cross-category boost: cooking:nutrition memories included
→ Query returns:
  - Fitness: current program, training volume
  - Cooking: dietary restrictions, preferred proteins, cooking skill level
→ Response uses both contexts without swapping hats
```

**Rule:** Fitness hat remains primary. Cooking context enriches the response but does not trigger cooking hat mode.

---

### When Cooking Pulls Fitness Memory (Reverse)

**Scenario:** User asks "What high-protein meals can I make?"

```
Primary category: cooking:meal-planning
→ Cooking memory filter active
→ Cross-category boost: fitness:goals, fitness:nutrition memories included
→ Query returns:
  - Cooking: equipment, skill level, dietary restrictions, favorite cuisines
  - Fitness: current protein targets, meal timing preferences (pre/post-workout)
→ Response prioritizes cooking but accounts for fitness context
```

---

## Compaction Rules

### Preserve

- PRs and the context they were set in (date, program phase, how it felt)
- Program designs and the reasoning behind them
- Injury reports with dates and affected areas
- Goal statements with SMART criteria
- Pattern observations ("squats feel better after hip mobility work")
- Training schedule and any changes

### Flush

- Individual workout logs older than 2 weeks (preserve only PRs and trends)
- Generic exercise form descriptions (regeneratable)
- Motivational back-and-forth
- Repeated warm-up/cool-down instructions

---

## Compaction Summary Prompt (fitness-specific)

```
Summarize this fitness conversation segment.

Preserve exactly:
- Any new PRs or notable lifts (exercise, weight, reps, date)
- Any program design decisions or changes
- Any injury or pain mentioned (area, severity, date)
- Any goals set or progress toward goals
- Any schedule or equipment changes
- Training patterns or observations noted

Do NOT include:
- Full set-by-set workout logs (just notable numbers)
- Generic exercise form descriptions
- Motivational conversation
- Information already stored in fitness memories

Output: max 200 tokens.
```

^compaction-fitness

---

## Memory Write Triggers

| Event | Action | Fields |
|---|---|---|
| New PR achieved | Write immediately | exercise, weight, reps, date, program context |
| Workout completed | Log summary | exercises, sets/reps/weight, date, duration |
| Program changed | Write with reasoning | program name, phase, start date, goals |
| Injury reported | Write with priority | area, severity, onset date, suspected cause |
| Goal set | Write with SMART criteria | goal, current, target, deadline, strategy |
| Equipment acquired | Update profile | equipment name, access level, date |
| Schedule changed | Update calendar | new days/times, reason |
| Preference stated | Save once | exercise preference, training style, dietary choice |

---

## Vector Similarity Boosts

When querying memory for fitness context:

- **Exercise name:** Boost exact matches (squat, deadlift) + semantic related (barbell squat, front squat)
- **Program name:** Boost exact program matches + phase references
- **Time-bound:** Recent memories (0-2 weeks) get 1.5x boost; older logs get semantic boost if semantically similar
- **Injury area:** Boost exact anatomical mentions + related muscle groups
- **Goal progress:** Boost memories mentioning current goal
