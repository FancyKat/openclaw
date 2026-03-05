---
tags: [type/index, layer/routing, status/draft, category/cooking]
category_name: "Cooking"
category_slug: "cooking"
category_emoji: "🍳"
mode_tokens: 250
active_pipelines: 0
future_pipelines: 4
channel_telegram: true
channel_discord: true
channel_gmail: false
---

# Category Mode — Cooking 🍳

> Index and context for cooking mode. Trigger patterns, intents, focus tree, pipelines, memory filters, and drift signals.

**Up →** [[stack/L5-routing/categories/_overview]]

---

## Overview

The cooking mode is active when Marty asks about recipes, ingredients, meal planning, grocery shopping, cooking techniques, or kitchen equipment. It surfaces memories about dietary preferences, favorite cuisines, available equipment, and past recipes. The mode remains active across sub-category shifts (recipe → grocery) and is stripped when moving to a different top-level category (cooking → coding).

---

## Mode Context

This block gets injected into the context window when the cooking mode is active. It sits right after AGENTS.md — in the high-attention zone:

```markdown
## 🍳 Active Mode: Cooking

You're in cooking mode. Adjust your approach:

**Tone:** Warm, practical, encouraging. Like a friend who loves cooking and
wants to help. No lecturing about nutrition unless asked.

**Memory awareness:** You know Marty's cooking preferences, dietary restrictions,
favorite cuisines, and kitchen equipment. Pull from cooking-tagged memories before
giving generic advice.

**Key preferences to remember:**
- Check MEMORY.md for: favorite cuisines, dietary restrictions, kitchen equipment,
  skill level, past recipes discussed
- If you don't know a preference, ask once and remember it

**When suggesting recipes:**
- Start with what they have on hand (ask if not mentioned)
- Account for kitchen equipment available
- Give clear, step-by-step instructions
- Mention prep time and cook time
- Scale recipes to household size

**When building grocery lists:**
- Organize by store section (produce, dairy, meat, pantry)
- Note quantities
- Flag items that might already be on hand

**Pipelines available:**
- `grocery-list` — Add/remove/view grocery list items
- `recipe-search` — Search saved recipes (future)
- `meal-plan` — Generate weekly meal plan (future)

**When to save to memory:**
- New dietary preference or restriction → save immediately
- Recipe they loved or hated → save with rating
- Grocery staples they always need → save to preferences
- Kitchen equipment acquired → save to profile
```

^mode-cooking

---

## Pages

| Page | Purpose |
|---|---|
| [[stack/L5-routing/categories/cooking/triggers]] | Trigger words, intent patterns, interaction type thresholds, topic shift signals |
| [[stack/L5-routing/categories/cooking/focus-tree]] | Navigation hierarchy, focus tree JSON, button rendering per channel |
| [[stack/L5-routing/categories/cooking/pipelines]] | Pipeline definitions, token costs, LLM vs lookup breakdown, dependencies |
| [[stack/L5-routing/categories/cooking/conversation-flows]] | Example flows with Mermaid diagrams, channel differences, multi-turn scenarios |
| [[stack/L5-routing/categories/cooking/speed-baselines]] | Latency budgets, operation breakdowns, UX red lines, caching strategy |
| [[stack/L5-routing/categories/cooking/memory-filter]] | Vector DB query filter, memory types, cross-category queries, compaction rules |
| [[stack/L5-routing/categories/cooking/drift-signals]] | Model drift detection, re-anchoring protocols, risk profiles per interaction type |

---

## Special Considerations

### Dietary Restrictions & Preferences

Always confirm and respect dietary restrictions and food allergies. These are critical memory items:
- Cilantro, nuts, shellfish, gluten, dairy — common restrictions
- Ethical choices (vegetarian, vegan, halal, kosher)
- Flavor preferences (no spicy, loves heat, etc.)

**Safety rule:** If a suggested recipe contains a known allergen, **stop and rewrite immediately**. Better to drop the suggestion than risk harm.

### Seasonal & Availability

Cooking suggestions should account for:
- **Seasonal produce:** Strawberries in summer, root vegetables in winter
- **Regional availability:** What's available at local stores?
- **Supply on hand:** Check pantry memory before suggesting ingredients

### Household Context

- **Cooking for how many?** Always scale recipes appropriately
- **Time availability:** Weeknight quick meals vs weekend deep dives
- **Equipment available:** Air fryer? Instant Pot? Sous vide? Simple stovetop?
- **Skill level:** Beginner-friendly vs advanced techniques

---

**Up →** [[stack/L5-routing/categories/_overview]]
