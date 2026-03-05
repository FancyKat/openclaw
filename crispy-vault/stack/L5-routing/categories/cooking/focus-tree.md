---
tags: [type/reference, layer/routing, status/draft, category/cooking, focus/tree]
---

# Cooking Category — Focus Tree

> Navigation hierarchy and inline button structure for cooking mode. Telegram, Discord, and email button rendering.

**Up →** [[stack/L5-routing/categories/cooking/_overview]]

---

## Focus Tree Navigation

The cooking hat exposes a nested menu of cooking intents and pipelines. Users navigate via inline buttons (Telegram, Discord) or link suggestions (email).

```
🍳 COOKING
├─ 📋 Recipe
│  ├─ Find Recipe
│  ├─ Browse Saved Recipes
│  └─ Rate Last Recipe
├─ 🛒 Grocery
│  ├─ View List
│  ├─ Add Items
│  └─ Mark Bought
├─ 🍽️ Meal Plan
│  ├─ Generate Plan
│  ├─ View This Week
│  └─ Update Plan
├─ 🔍 Pantry
│  ├─ What I Have
│  ├─ Check Item
│  └─ Update Stock
├─ 👨‍🍳 Techniques
│  └─ How to...
└─ ⚙️ Preferences
   ├─ Dietary Restrictions
   ├─ Favorite Cuisines
   └─ Kitchen Equipment
```

---

## Focus Tree JSON

^tree-cooking

Callback data follows the convention `cooking:node:action`:

```json
{
  "tree_id": "cooking",
  "tree_name": "Cooking Focus Tree",
  "root": {
    "id": "cooking:root",
    "label": "🍳 What can I help with?",
    "children": [
      {
        "id": "cooking:recipe",
        "label": "📋 Recipe",
        "children": [
          {
            "id": "cooking:recipe:find",
            "label": "Find a Recipe",
            "action": "agent_loop",
            "context": "find-recipe",
            "leaf": true
          },
          {
            "id": "cooking:recipe:browse",
            "label": "Browse Saved",
            "action": "pipeline",
            "pipeline_id": "recipe-search",
            "leaf": true
          },
          {
            "id": "cooking:recipe:rate",
            "label": "Rate Last Recipe",
            "action": "memory_write",
            "memory_type": "recipe_rating",
            "leaf": true
          }
        ]
      },
      {
        "id": "cooking:grocery",
        "label": "🛒 Grocery",
        "children": [
          {
            "id": "cooking:grocery:view",
            "label": "View My List",
            "action": "pipeline",
            "pipeline_id": "grocery-list",
            "operation": "view",
            "leaf": true
          },
          {
            "id": "cooking:grocery:add",
            "label": "Add Items",
            "action": "agent_loop",
            "context": "grocery-list",
            "leaf": true
          },
          {
            "id": "cooking:grocery:mark",
            "label": "Mark as Bought",
            "action": "pipeline",
            "pipeline_id": "grocery-list",
            "operation": "mark_bought",
            "leaf": true
          }
        ]
      },
      {
        "id": "cooking:meal-plan",
        "label": "🍽️ Meal Plan",
        "children": [
          {
            "id": "cooking:meal-plan:generate",
            "label": "Generate Plan",
            "action": "agent_loop",
            "context": "meal-plan",
            "leaf": true
          },
          {
            "id": "cooking:meal-plan:view",
            "label": "View This Week",
            "action": "pipeline",
            "pipeline_id": "meal-plan",
            "operation": "view",
            "leaf": true
          },
          {
            "id": "cooking:meal-plan:update",
            "label": "Update",
            "action": "agent_loop",
            "context": "meal-plan",
            "leaf": true
          }
        ]
      },
      {
        "id": "cooking:pantry",
        "label": "🔍 Pantry",
        "children": [
          {
            "id": "cooking:pantry:view",
            "label": "What I Have",
            "action": "pipeline",
            "pipeline_id": "pantry-check",
            "leaf": true
          },
          {
            "id": "cooking:pantry:check",
            "label": "Check Item",
            "action": "agent_loop",
            "context": "pantry-check",
            "leaf": true
          },
          {
            "id": "cooking:pantry:update",
            "label": "Update Stock",
            "action": "memory_write",
            "memory_type": "pantry",
            "leaf": true
          }
        ]
      },
      {
        "id": "cooking:technique",
        "label": "👨‍🍳 Techniques",
        "children": [
          {
            "id": "cooking:technique:ask",
            "label": "How to...",
            "action": "agent_loop",
            "context": "technique",
            "leaf": true
          }
        ]
      },
      {
        "id": "cooking:preferences",
        "label": "⚙️ Preferences",
        "children": [
          {
            "id": "cooking:preferences:dietary",
            "label": "Dietary Restrictions",
            "action": "agent_loop",
            "context": "preference-update",
            "memory_type": "dietary_restriction",
            "leaf": true
          },
          {
            "id": "cooking:preferences:cuisines",
            "label": "Favorite Cuisines",
            "action": "memory_write",
            "memory_type": "cuisine_preference",
            "leaf": true
          },
          {
            "id": "cooking:preferences:equipment",
            "label": "Kitchen Equipment",
            "action": "memory_write",
            "memory_type": "equipment",
            "leaf": true
          }
        ]
      }
    ]
  },
  "navigation": {
    "back_button": {
      "id": "cooking:back",
      "label": "← Back",
      "action": "navigate",
      "target": "parent"
    },
    "escape_hatch": {
      "id": "cooking:escape",
      "label": "❌ Exit Cooking",
      "action": "hat_swap",
      "target": "generic"
    }
  }
}
```

---

## Telegram Inline Button Rendering

When responding in Telegram during cooking mode, inline buttons are rendered like:

```
🍳 What can I help with?

[📋 Recipe]  [🛒 Grocery]  [🍽️ Meal Plan]
[🔍 Pantry]  [👨‍🍳 Techniques]  [⚙️ Prefs]

[❌ Exit Cooking]
```

Callback data for each button: `cooking_tree:cooking:recipe` (format: `cooking_tree:{tree_node_id}`)

Sub-menus (after clicking "Recipe"):

```
📋 Recipe — What would you like to do?

[🔎 Find Recipe]  [📚 Browse Saved]
[⭐ Rate Last]

[← Back]  [❌ Exit Cooking]
```

---

## Discord Button Rendering

Discord uses custom Components with select menus and buttons:

```
Embed Title: "🍳 Cooking Assistant"

Select Menu:
- Recipe
- Grocery
- Meal Plan
- Pantry
- Techniques
- Preferences

Buttons:
[← Back] [Exit Cooking]
```

Interaction follows the same tree structure; sub-menus update the select options.

---

## Email Link Rendering

In email responses, cooking navigation appears as inline links:

```
Want to explore further?

• [Find a Recipe](link?action=cooking:recipe:find)
• [View Grocery List](link?action=cooking:grocery:view)
• [Generate Meal Plan](link?action=cooking:meal-plan:generate)
• [Update Preferences](link?action=cooking:preferences:dietary)

[Exit Cooking Mode](link?action=hat_swap&target=generic)
```

---

## Leaf Actions & Escape Hatch

**Leaf actions** (terminal nodes with no children):
- Route to agent loop for `agent_loop` actions
- Trigger pipeline for `pipeline` actions
- Write to memory for `memory_write` actions

**Back Navigation:**
- Every non-root node has an implicit `← Back` button
- Back navigates to parent in the tree
- Root level back closes the focus tree

**Escape Hatch:**
- Always available: `❌ Exit Cooking`
- Triggers hat swap to generic mode
- Saves cooking context via compaction
- User re-enters at last non-cooking message

---

**Up →** [[stack/L5-routing/categories/cooking/_overview]]
