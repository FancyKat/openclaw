---
tags: [type/reference, layer/routing, status/draft, category/cooking, focus/memory]
---

# Cooking Category — Memory Filter & Compaction

> Memory retrieval filters, write rules, aging policies, and compaction summaries for cooking mode.

**Up →** [[stack/L5-routing/categories/cooking/_overview]]

---

## Memory Filter (Vector DB Query)

When the cooking hat is on, L5 queries the vector DB with these filters:

^filter-cooking

```json
{
  "category": ["cooking", "cooking:recipe", "cooking:grocery", "cooking:meal-prep", "cooking:nutrition"],
  "exclude_categories": ["coding", "trading"],
  "boost_fields": ["preferences", "restrictions", "equipment"],
  "recency_weight": 0.2,
  "semantic_weight": 0.4,
  "category_weight": 0.3,
  "frequency_weight": 0.1
}
```

**Weights Explanation:**
- **Recency weight (0.2):** Don't over-prioritize recent cooking notes; preferences are stable
- **Semantic weight (0.4):** High weight — "what can I make with X?" needs semantic matching of ingredients
- **Category weight (0.3):** Cooking-tagged memories are strongly preferred
- **Frequency weight (0.1):** Low weight — avoid over-emphasizing frequently accessed memories

---

## Memory Types to Retrieve

| Memory Type | Example | Priority | Boost | Refresh |
|---|---|---|---|---|
| **Dietary restrictions** | "Marty doesn't like cilantro" | Always load | +++ | Every session |
| **Cuisine preferences** | "Loves Japanese, Italian, Mexican" | Always load | +++ | Every 30 days |
| **Kitchen equipment** | "Has an Instant Pot, air fryer, sous vide" | Always load | ++ | Every 60 days |
| **Household info** | "Cooking for 2" | Always load | ++ | Every 90 days |
| **Recent recipes discussed** | "Made chicken parmesan last Tuesday" | Load if relevant | + | Every 7 days |
| **Grocery patterns** | "Usually shops at Trader Joe's" | Load for grocery intents | + | Every 30 days |
| **Pantry state** | "Always has: olive oil, garlic, onions" | Load for recipe intents | ++ | Every 2 days |
| **Meal plan history** | "Typically meal preps Sunday evening" | Load for meal-plan intents | + | Every 30 days |
| **Recipe ratings** | "Loved pad thai (4.8★), hated baked cod (2★)" | Load for recipe-search | ++ | Every 14 days |

---

## Cross-Category Memory Queries

When in cooking mode, also consider querying adjacent categories:

### Fitness Category (when relevant)
**Trigger:** User asks about nutrition, calories, macros, or mentions fitness goals
```json
{
  "query": "nutrition + cooking",
  "categories": ["cooking", "fitness"],
  "focus": "nutrition facts, macros, health goals"
}
```

**Example:** "How many calories in chicken parmesan?" → Load fitness goals (e.g., calorie budget) + cooking memories (past recipes) → give calorie count + fit to goals

### Finance Category (when relevant)
**Trigger:** User mentions budget, cost, shopping
```json
{
  "query": "grocery + budget",
  "categories": ["cooking", "finance"],
  "focus": "grocery budget, cost per meal"
}
```

**Example:** "I need to save money on groceries" → Load finance goals (budget) + cooking memories (usual spending) → suggest budget meals

### Health Category (when relevant)
**Trigger:** User mentions allergies, dietary conditions, medication interactions with food
```json
{
  "query": "dietary restrictions + health",
  "categories": ["cooking", "health"],
  "focus": "allergies, intolerances, medical diet restrictions"
}
```

**Example:** "I'm on a new medication — what can I eat?" → Load health/medical info + cooking memories → filter recipes accordingly

---

## Memory Write Rules

**When to save to memory:**

| Event | Memory Type | Urgency | TTL | Notes |
|---|---|---|---|---|
| User mentions dietary preference/restriction | `cooking:dietary_restriction` | IMMEDIATE | Forever | "I don't like cilantro" → save instantly, confirm |
| User mentions kitchen equipment purchased | `cooking:equipment` | High | Forever | "Just got an air fryer" → update profile |
| Recipe discussed with strong opinion | `cooking:recipe_rating` | Medium | 90 days | "Loved that pad thai" (4.8★) or "Hated baked cod" (2★) |
| Meal plan generated | `cooking:meal_plan` | Medium | 7 days | Save plan + outcome (did they follow it?) |
| Grocery patterns observed | `cooking:grocery_pattern` | Low | 30 days | "Always buys spinach on Tuesdays" |
| Cuisine preference mentioned | `cooking:cuisine_preference` | Medium | 90 days | "I'm really into Thai food lately" |
| Household cooking info | `cooking:household_info` | Medium | Forever | "Cooking for 2" or "Dinner at 6pm" |

**Write confirmation:** For dietary/equipment/preference changes, always confirm: "Got it — I'll remember you don't like cilantro."

---

## Memory Aging

| Memory Age | Status | Action |
|---|---|---|
| **<1 month** | Hot (high recency weight) | Use as-is |
| **1–3 months** | Warm (normal weight) | Use; consider refresh if seasonal |
| **3–6 months** | Cool (lower weight) | Use; flag for potential refresh |
| **6–12 months** | Cold (background) | Use only if highly semantic match |
| **>12 months** | Archived | Archive to cold storage; ask user to confirm before using |

### Seasonal Refresh (Cooking-Specific)

Certain memories should auto-refresh seasonally:
- **Cuisine preferences:** Every season (Mexican in summer, comfort food in winter?)
- **Pantry staples:** Every 3 months (seasonal produce shifts)
- **Meal prep patterns:** Every 3 months (time availability changes)

---

## Compaction Rules

When compaction fires while the cooking hat is on:

### Preserve (write to vector DB with cooking tag)
- Specific recipes discussed (ingredients, steps, outcome)
- Dietary preferences or restrictions mentioned
- Grocery lists generated
- Meal plans created
- Cooking techniques explained (user might ask again)
- Equipment preferences

### Flush (don't store)
- Back-and-forth about what to cook (decision process)
- Generic cooking advice that's easily regeneratable
- Repeated information already in memory

### Compaction Summary Prompt (cooking-specific)

^compaction-cooking

```
Summarize this cooking conversation segment in ~150 tokens.

Preserve exactly:
- Any recipe discussed: name, key ingredients, prep time, cook time, outcome/rating
- Any dietary preference or restriction mentioned
- Any grocery items needed or purchased
- Any kitchen equipment discussed
- Any meal planning decisions made

Do NOT include:
- The back-and-forth decision process
- Generic cooking tips
- Information already stored in cooking memories
- How the user felt about the cooking experience (unless strong rating)

Output format:
<recipe name>: [ingredients], [time], [rating]
Preference: [dietary restriction or food preference]
Equipment: [item mentioned]
Grocery: [items added/removed]
Meal Plan: [dates, focus]

Max 200 tokens. Be concise and factual.
```

### Compaction Trigger Events

| Event | Latency | Action |
|---|---|---|
| **Hat swap** (cooking → other category) | Immediate | Fire compaction, save summary, flush hat |
| **Session end** | On exit | Fire compaction if cooking hat was active |
| **Long idle** (30+ min) | Lazy | Fire compaction on next message if hat was active |
| **Memory threshold** (>100 cooking items in session) | On threshold | Fire early compaction to manage token overhead |

---

## Memory Retrieval for Common Intents

### `cooking:find-recipe`
**Retrieve:**
1. Dietary restrictions (must-filter)
2. Cuisine preferences (boost)
3. Kitchen equipment (boost)
4. Pantry state (semantic match with ingredients)
5. Past recipe ratings (avoid low-rated)

### `cooking:grocery-list`
**Retrieve:**
1. Pantry state (cross-check: what's already there?)
2. Grocery patterns (typical store, typical day)
3. Recent meal plan (what's planned for?)
4. Staples list (always buy)
5. Budget (if relevant)

### `cooking:meal-plan`
**Retrieve:**
1. Dietary restrictions (must-filter)
2. Cuisine preferences (guide plan)
3. Kitchen equipment (shape recipes)
4. Pantry state (use what's available)
5. Past meal plan history (avoid repetition)
6. Household info (cooking for how many?)

### `cooking:nutrition-check`
**Retrieve:**
1. Fitness goals (if stored; cross-category)
2. Dietary restrictions (contextualize)
3. Allergy/health info (cross-category)

### `cooking:preference-update`
**Retrieve:**
1. Current preference (check if duplicate)
2. Frequency (how often updated?)

---

**Up →** [[stack/L5-routing/categories/cooking/_overview]]
