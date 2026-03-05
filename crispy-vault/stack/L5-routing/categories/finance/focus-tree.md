---
tags: [type/reference, layer/routing, status/draft, category/finance, focus/tree]
---

# Focus Tree — Finance

> Navigation hierarchy and focus tree JSON with callback convention `finance:budget:review`.

**Up →** [[stack/L5-routing/categories/finance/_overview]]

---

## Focus Tree Hierarchy

```
💰 Finance Focus (CP2 active)
├── 📊 Markets                         ← trading and investing
│   ├── 📈 Analysis                    → agent loop (TA/FA)
│   ├── 💼 Positions                   → position-check pipeline
│   └── 🧪 Backtest                    → backtest pipeline
│
├── 💵 Budget                           ← personal finance
│   ├── 📋 Review                      → budget-review pipeline
│   └── 📊 Track                       → expense-tracker pipeline
│
└── 📅 Plan                            ← financial planning
    └── SMART+ kicks in                ← goals? timeline? risk?
        → agent loop (planning mode)
```

---

## Focus Tree JSON

```json
{
  "category": "finance",
  "emoji": "💰",
  "name": "Finance",
  "nodes": [
    {
      "id": "finance:markets",
      "label": "Markets",
      "emoji": "📊",
      "description": "Trading and investing analysis",
      "children": [
        {
          "id": "finance:markets:analysis",
          "label": "Analysis",
          "emoji": "📈",
          "callback": "finance:markets:analysis",
          "action": "agent_loop",
          "mode": "reasoning"
        },
        {
          "id": "finance:markets:positions",
          "label": "Positions",
          "emoji": "💼",
          "callback": "finance:markets:positions",
          "action": "pipeline",
          "pipeline": "position-check"
        },
        {
          "id": "finance:markets:backtest",
          "label": "Backtest",
          "emoji": "🧪",
          "callback": "finance:markets:backtest",
          "action": "pipeline",
          "pipeline": "backtest"
        }
      ]
    },
    {
      "id": "finance:budget",
      "label": "Budget",
      "emoji": "💵",
      "description": "Personal finance and spending",
      "children": [
        {
          "id": "finance:budget:review",
          "label": "Review",
          "emoji": "📋",
          "callback": "finance:budget:review",
          "action": "pipeline",
          "pipeline": "budget-review"
        },
        {
          "id": "finance:budget:track",
          "label": "Track",
          "emoji": "📊",
          "callback": "finance:budget:track",
          "action": "pipeline",
          "pipeline": "expense-tracker"
        }
      ]
    },
    {
      "id": "finance:plan",
      "label": "Plan",
      "emoji": "📅",
      "description": "Financial planning and goals",
      "children": [
        {
          "id": "finance:plan:goal",
          "label": "Goal",
          "emoji": "🎯",
          "callback": "finance:plan:goal",
          "action": "agent_loop",
          "mode": "planning",
          "framework": "SMART+"
        }
      ]
    }
  ]
}
```

^tree-finance

---

## Callback Convention

The focus tree uses callbacks in the format `finance:<branch>:<leaf>` to identify which sub-flow is active:

- `finance:markets:analysis` — Ticker/setup analysis (agent loop, reasoning mode)
- `finance:markets:positions` — Current holdings check (pipeline)
- `finance:markets:backtest` — Strategy backtest (pipeline)
- `finance:budget:review` — Monthly budget review (pipeline)
- `finance:budget:track` — Expense logging (pipeline)
- `finance:plan:goal` — Goal setting/tracking (agent loop + SMART+)

Each callback routes to a specific action and primes the memory filter to load relevant context.

---

**Up →** [[stack/L5-routing/categories/finance/_overview]]
