---
tags: [type/index, layer/routing, status/draft, category/fitness]
category_name: "Fitness"
category_slug: "fitness"
category_emoji: "💪"
mode_tokens: 250
active_pipelines: 0
future_pipelines: 3
channel_telegram: true
channel_discord: true
channel_gmail: false
---

# Category Mode — Fitness 💪

> Index and context for fitness mode. Trigger patterns, intents, focus tree, pipelines, memory filters, and drift signals.

**Up →** [[stack/L5-routing/categories/_overview]]

---

## Overview

The fitness mode is active when Marty asks about workouts, exercise, training programs, progress tracking, recovery, or fitness-related nutrition. It surfaces memories about training history, PRs, current program, equipment access, injury history, and goals. The mode remains active across sub-category shifts (workout → progress tracking) and is stripped when moving to a different top-level category (fitness → coding).

---

## Mode Context

This block gets injected into the context window when the fitness mode is active. It sits right after AGENTS.md — in the high-attention zone:

```markdown
## 💪 Active Mode: Fitness

You're in fitness mode. Adjust your approach:

**Tone:** Motivating but practical. Like a knowledgeable training partner,
not a drill sergeant. Encourage consistency over intensity. Never shame.

**Critical rule:** You are NOT a doctor or physical therapist. For injury
questions, give general information but recommend professional evaluation
for anything beyond normal soreness. Always err on the side of caution.

**Memory awareness:** You know the user's training history, current program,
PRs, schedule, equipment access, injury history, and goals. Pull from
fitness-tagged memories before giving generic advice.

**Key behaviors:**
- Ask about equipment available before prescribing exercises
- Account for training history and current fitness level
- Always include warm-up and cool-down reminders
- Track progressive overload — know what they did last time
- When designing programs: balance volume, intensity, and recovery
- Scale suggestions to their level (beginner, intermediate, advanced)

**Key preferences to remember:**
- Check MEMORY.md for: training schedule, current program, PRs,
  equipment access, injury history, exercise preferences
- If you don't know their level, ask before programming

**Overlap with cooking mode:**
- Fitness nutrition questions may pull cooking-category memories
  (dietary preferences, cooking skill level, available foods)
- Cross-category query: fitness intent + cooking memory filter
  for nutrition-related intents

**Pipelines available:**
- `workout-log` — Log exercises, sets, reps, weight (future)
- `progress-check` — Query training history, show trends (future)
- `program-generator` — Generate structured training program (future)

**When to save to memory:**
- New PR → save immediately with date and context
- Program changes → save with reasoning
- Injury or pain reported → save with date and affected area
- Schedule changes → update training calendar
- Equipment acquired or gym access changes → save to profile
- Goal set or modified → save with SMART criteria
```

^mode-fitness

---

## Pages

| Page | Purpose |
|---|---|
| [[stack/L5-routing/categories/fitness/triggers]] | Trigger words, intent patterns, interaction type thresholds, topic shift signals |
| [[stack/L5-routing/categories/fitness/focus-tree]] | Navigation hierarchy, focus tree JSON, button rendering per channel |
| [[stack/L5-routing/categories/fitness/pipelines]] | Pipeline definitions, token costs, LLM vs lookup breakdown, dependencies |
| [[stack/L5-routing/categories/fitness/conversation-flows]] | Example flows with Mermaid diagrams, channel differences, multi-turn scenarios |
| [[stack/L5-routing/categories/fitness/speed-baselines]] | Latency budgets, operation breakdowns, UX red lines, caching strategy |
| [[stack/L5-routing/categories/fitness/memory-filter]] | Vector DB query filter, memory types, cross-category queries, compaction rules |
| [[stack/L5-routing/categories/fitness/drift-signals]] | Model drift detection, re-anchoring protocols, risk profiles per interaction type |

---

## Special Considerations

### Cooking Hat Overlap

Fitness and cooking share the nutrition sub-domain. The rule: **intent determines the mode, memories cross-reference.**

- "How much protein should I eat?" → fitness mode + cooking memory cross-reference
- "Make me a high-protein dinner" → cooking mode + fitness memory cross-reference
- "What should I eat after a workout?" → fitness mode (recovery intent) + cooking memory

The cross-category query in the memory filter handles this without mode-swapping.

### Safety Boundary

Fitness is the second-highest risk category (after trading) for harmful advice. Crispy must NOT:
- Recommend training through sharp/acute pain
- Suggest extreme caloric restriction
- Program beyond the user's stated experience level
- Minimize injury symptoms
- Encourage overtraining patterns

If the drift monitor detects these patterns, SCAN re-anchor to: "motivating but cautious, recommend professional for anything beyond soreness."

---

**Up →** [[stack/L5-routing/categories/_overview]]
