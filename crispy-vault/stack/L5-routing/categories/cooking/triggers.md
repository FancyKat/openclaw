---
tags: [type/reference, layer/routing, status/draft, category/cooking, focus/triggers]
---

# Cooking Category — Trigger Words & Intent Patterns

> Flash classifier triggers and intent sub-classification rules for cooking mode. Interaction type thresholds and topic shift signals.

**Up →** [[stack/L5-routing/categories/cooking/_overview]]

---

## Trigger Words

These are matched by the flash model classifier and the triage trigger-word scan (stage ①):

### High Confidence (→ load hat immediately)
```
recipe, cook, cooking, bake, baking, ingredient, ingredients,
grocery, groceries, meal prep, meal plan, kitchen, oven, stove,
fridge, pantry, sous vide, air fryer, slow cooker, instant pot,
dinner, lunch, breakfast, snack, appetizer, dessert, marinade,
seasoning, spice, herb
```

### Medium Confidence (→ classify with context)
```
chicken, beef, fish, tofu, pasta, rice, bread, sauce, soup,
salad, pizza, taco, curry, stir fry, grill, roast, sauté,
chop, dice, mince, blanch, simmer, boil, steam
```

*Medium-confidence words need surrounding context. "Chicken" alone could be grocery, recipe, nutrition, or even a ticker symbol. The flash model uses the last 3 messages to disambiguate.*

### Sub-Category Signals

| Sub-Category | Additional Triggers |
|---|---|
| **recipe** | "how to make", "recipe for", "what can I cook", "I want to make" |
| **grocery** | "I need to buy", "shopping list", "running low on", "out of", "grocery store" |
| **meal-prep** | "meal prep", "for the week", "batch cook", "leftovers", "containers" |
| **nutrition** | "calories", "protein", "carbs", "macros", "healthy", "diet" |
| **equipment** | "knife", "pan", "pot", "blender", "thermometer", "cutting board" |

---

## Intent Patterns

When the cooking hat is on, the triage model sub-classifies into these intents:

| Intent | What User Wants | Route | Example |
|---|---|---|---|
| `cooking:find-recipe` | A recipe or cooking instructions | Agent loop (needs creativity/search) | "What can I make with salmon and asparagus?" |
| `cooking:grocery-list` | Build or update a shopping list | Pipeline → grocery-list | "Add chicken thighs to my grocery list" |
| `cooking:meal-plan` | Plan meals for a period | Agent loop (complex) | "Plan dinners for the week, I have ground beef" |
| `cooking:what-can-i-make` | Use what's on hand | Agent loop + memory recall | "I have eggs, cheese, and spinach — what can I make?" |
| `cooking:nutrition-check` | Nutritional information | Agent loop (lookup) | "How many calories in chicken parmesan?" |
| `cooking:technique` | How to do something | Agent loop (informational) | "How do I properly sear a steak?" |
| `cooking:equipment` | Tool recommendation or usage | Agent loop (informational) | "What temperature for sous vide chicken?" |
| `cooking:preference-update` | Tell Crispy a food preference | Memory write → confirm | "I don't like cilantro" / "We're trying to eat less red meat" |

---

## Interaction Type Thresholds

Token budgets and context length thresholds for routing decisions:

^triggers-cooking

| Interaction Type | Token Range | Use Case | Hat State |
|---|---|---|---|
| **Informational** | 2K–5K tokens | "How do I X?", technique/equipment questions | Hat always on |
| **Assistance** | 5K–15K tokens | Recipe suggestions, ingredient lookups, preference queries | Hat on, memory preloaded |
| **Action** | 0–800 tokens | Pipeline triggers (grocery list, memory write) | Hat on, fast-path |
| **Creative** | 5K–20K tokens | Meal planning, recipe innovation, complex composition | Hat on, full context |
| **Meta** | 200–1K tokens | Preference setting, hat state changes | Hat on or off depending on intent |

### Cooking Distribution

- **Action-heavy:** Grocery updates, quick questions (60% of interactions)
- **Creative-heavy:** Meal planning, recipe discovery (25% of interactions)
- **Informational:** Techniques, equipment, nutrition (12% of interactions)
- **Meta:** Preference changes, mode shifts (3% of interactions)

---

## Topic Shift Signals

### Signals In (Entering Cooking)

- **High confidence triggers** (section above) + context from last 2 messages
- **Sub-category signal** in message + cooking hat already partially loaded
- **Soft shift:** "Wait, can you also..." from non-cooking mode → add to hat, don't swap

Examples:
- "While we're at it, what groceries do I need?" (soft)
- "Actually, let me focus on dinner planning for this week" (soft)

### Signals Out (Leaving Cooking)

- **Absence of cooking words** for 2+ turns after hat loaded
- **Explicit category trigger** from another domain (coding, fitness, finance, etc.)
- **Question scope** changes to non-food domain
- **Hard shift:** Save compaction summary, flush hat, load new hat

Examples:
- "Let's talk about something else — what's the git status?" (hard)
- "OK, moving on to my workout plan" (hard)
- "So about that Python script..." (hard)

### Re-Entry Rules

- If user returns to cooking within same session, reload hat (don't resume old context)
- If cooking was a soft shift, restore full hat context
- If cooking was a hard shift, load fresh hat

---

**Up →** [[stack/L5-routing/categories/cooking/_overview]]
