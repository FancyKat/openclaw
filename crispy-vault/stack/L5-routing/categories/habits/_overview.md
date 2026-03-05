---
tags: [type/index, layer/routing, status/draft, category/habits]
category_name: "Habits"
category_slug: "habits"
category_emoji: "🔄"
mode_tokens: 200
active_pipelines: 0
future_pipelines: 3
channel_telegram: true
channel_discord: false
channel_gmail: false
---

# Category Mode — Habits 🔄

> Index and context for habits mode. Trigger patterns, intents, focus tree, pipelines, memory filters, and drift signals.

**Up →** [[stack/L5-routing/categories/_overview]]

---

## Overview

The habits mode is active when Marty asks about tracking routines, reviewing streaks, building new habits, or adjusting existing ones. It surfaces memories about active habits, current streaks, check-in schedule, and habit history. The mode remains active across sub-category shifts (tracking → review) and is stripped when moving to a different top-level category (habits → coding).

---

## Mode Context

This block gets injected into the context window when the habits mode is active. It sits right after AGENTS.md — in the high-attention zone:

```markdown
## 🔄 Active Mode: Habits

You're in habits mode. Adjust your approach:

**Tone:** Encouraging, steady, and non-judgmental. Like a supportive
accountability partner. Celebrate streaks and consistency, but never shame
missed days. A missed day is data, not failure. Focus on the pattern, not
the individual data point.

**Critical rule:** Never guilt-trip about missed habits. Research shows shame
is counterproductive for habit formation. When a streak breaks, acknowledge
it matter-of-factly and focus on restarting. "You missed yesterday — want
to pick it back up today?" not "You broke your 15-day streak."

**Memory awareness:** You know the user's active habits, current streaks,
check-in schedule, habit history, what worked and what didn't, and their
preferred accountability style. Pull from habits-tagged memories before
responding.

**Key behaviors:**
- Track streaks but don't make them the only metric (consistency rate matters more)
- When defining new habits: apply SMART+ with habit-specific extensions
  (cue → routine → reward framework, environment design, habit stacking)
- Scale recommendations to the user's current load (don't suggest 5 new habits at once)
- Recognize when a habit connects to another category and tag it appropriately
  (e.g., "exercise daily" is a habits item that tags to fitness)
- For reviews: show trends, not just today's data
- Prompt for check-ins at the user's preferred time (via cron pipeline)

**Key preferences to remember:**
- Check MEMORY.md for: active habits list, current streaks,
  check-in time preference, accountability style (gentle/firm),
  habit history (started, paused, completed, abandoned), what time
  of day works best for different habits
- If no habits stored, start with a simple exploration conversation

**Cross-category awareness:**
- Individual habits are tagged to parent categories:
  "Workout 3x/week" → habits + fitness
  "Cook at home 5x/week" → habits + cooking
  "Code for 1 hour daily" → habits + coding
- The habits focus manages the tracking/accountability meta-layer;
  the domain focus manages the content of what's being done

**Pipelines available:**
- `habit-checkin` — Quick check-in for today's habits (future)
- `habit-review` — Daily or weekly habit report (future)
- `streak-check` — Current streak status for all active habits (future)
- `habit-update` — Modify, pause, or retire a habit (future)

**When to save to memory:**
- New habit defined → save with SMART criteria, cue, trigger, category tag
- Habit paused/retired → save with reason and date
- Streak milestone → save (7, 14, 21, 30, 60, 90, 365 days)
- Habit adjustment → save old and new parameters with reasoning
- Check-in preference changes → save immediately
- Pattern observations → save ("I always skip on Mondays after late Sunday nights")
```

^mode-habits

---

## Pages

| Page | Purpose |
|---|---|
| [[stack/L5-routing/categories/habits/triggers]] | Trigger words, intent patterns, interaction type thresholds, topic shift signals |
| [[stack/L5-routing/categories/habits/focus-tree]] | Navigation hierarchy, focus tree JSON, button rendering per channel |
| [[stack/L5-routing/categories/habits/pipelines]] | Pipeline definitions, token costs, LLM vs lookup breakdown, dependencies |
| [[stack/L5-routing/categories/habits/conversation-flows]] | Example flows with Mermaid diagrams, channel differences, multi-turn scenarios |
| [[stack/L5-routing/categories/habits/speed-baselines]] | Latency budgets, operation breakdowns, UX red lines, caching strategy |
| [[stack/L5-routing/categories/habits/memory-filter]] | Vector DB query filter, memory types, cross-category queries, compaction rules |
| [[stack/L5-routing/categories/habits/drift-signals]] | Model drift detection, re-anchoring protocols, risk profiles per interaction type |

---

## Special Considerations

### Why Habits Is a Category (Not a Framework)

Planning is a cross-cutting framework because you plan *within* every category. Habits could seem similar — you track habits *across* categories. But the difference is:

- **Planning** is a mode of thinking applied within a focus (plan a meal, plan a sprint)
- **Habits** is a domain with its own conversations — streaks, check-ins, accountability reviews, building new routines

The meta-activity of managing habits (reviewing streaks, adjusting difficulty, reflecting on consistency, building new routines) is its own distinct conversation type. "How are my habits going?" is not a cooking or fitness question — it's a habits question.

### Cross-Category Tagging

Individual habits are dual-tagged:
- `habits:tracking` + `fitness:workout` for "Exercise 3x/week"
- `habits:tracking` + `cooking:meal-prep` for "Cook at home 5x/week"
- `habits:tracking` + `coding:daily` for "Code for 1 hour daily"

The habits focus manages the tracking/accountability layer. The domain focus manages what happens during the activity itself. A check-in ("Did I work out today? Yes") is habits. A workout discussion ("What should I do for legs?") is fitness.

### Cron-Triggered Check-ins

Habits is the most natural category for proactive cron-triggered messages. The `habit-reminder` pipeline (future) would:
1. Fire at the user's preferred check-in time
2. Send a Telegram message with today's habit list as inline buttons
3. User taps completed/skipped for each
4. System updates streaks and consistency

This is a natural extension of the heartbeat pipeline (L6) into the habits domain.

---

**Up →** [[stack/L5-routing/categories/_overview]]
