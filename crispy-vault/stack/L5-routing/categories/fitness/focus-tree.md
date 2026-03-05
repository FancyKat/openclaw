---
tags: [type/reference, layer/routing, status/draft, category/fitness, focus/tree]
---

# Fitness Focus Tree

> Navigation hierarchy and focus tree for fitness interactions. Defines button structure and sub-category navigation per channel (Telegram, Discord, Gmail).

**Up →** [[stack/L5-routing/categories/fitness/_overview]]

---

## Navigation Hierarchy

When the fitness hat is active, Crispy can offer quick-navigation buttons to guide users into sub-categories:

- **Workout Planning** — Design or get a workout for today
- **Tracking & Progress** — Log workouts, check trends, review PRs
- **Nutrition** — Protein targets, meal timing, macros
- **Recovery & Rest** — Soreness, stretching, rest day decisions
- **Goals & Programs** — Set goals, design longer programs
- **Form & Learning** — Exercise technique, training principles

---

## Focus Tree JSON

```json
{
  "category": "fitness",
  "root_options": [
    {
      "id": "workout-plan",
      "label": "💪 Workout",
      "sublabels": ["Today", "Upper Body", "Lower Body", "Full Body", "Cardio"],
      "intent_class": "fitness:workout-plan"
    },
    {
      "id": "tracking",
      "label": "📊 My Progress",
      "sublabels": ["View PRs", "Weekly Summary", "Log Workout"],
      "intent_class": "fitness:tracking"
    },
    {
      "id": "nutrition",
      "label": "🥗 Nutrition",
      "sublabels": ["Protein Goal", "Meal Timing", "Macros"],
      "intent_class": "fitness:nutrition-check"
    },
    {
      "id": "recovery",
      "label": "😴 Recovery",
      "sublabels": ["Soreness?", "Stretching", "Rest Today?"],
      "intent_class": "fitness:recovery-advice"
    },
    {
      "id": "goals",
      "label": "🎯 Goals",
      "sublabels": ["Set New Goal", "Review Goal", "Progress Check"],
      "intent_class": "fitness:goal-set"
    },
    {
      "id": "learning",
      "label": "📚 How To",
      "sublabels": ["Exercise Form", "Training Principles", "Program Design"],
      "intent_class": "fitness:form-check"
    }
  ]
}
```

---

## Channel Rendering Rules

### Telegram
- Show 2-3 primary buttons per message
- Hierarchical: root → sublabels on second message
- Compact labels, emoji + text
- Long-press for menu (if supported)

### Discord
- Embed with select menus
- Root level in first select, sublabels in follow-up
- Rich formatting with code blocks for technical info
- Thread-based for multi-turn

### Gmail
- Text-based menu with numbered options
- Compact: keep to 6-8 options per message
- Follow with explanation

^tree-fitness
