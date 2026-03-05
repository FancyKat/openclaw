---
tags: [type/reference, layer/routing, status/draft, category/CATEGORY_SLUG]
---
# Category Hat — CATEGORY_NAME EMOJI

> Everything Crispy needs when the conversation enters CATEGORY_NAME territory. Trigger words, intent sub-classification, the mode context injection, pipeline mappings, memory filters, and compaction rules.

**Up →** [[stack/L5-routing/categories/_overview]]

---

## Trigger Words

### High Confidence (→ load mode immediately)
```
word1, word2, word3, ...
```

### Medium Confidence (→ classify with context)
```
ambiguous1, ambiguous2, ...
```

*Explain why medium-confidence words are ambiguous — what other categories could claim them?*

### Sub-Category Signals

| Sub-Category | Additional Triggers |
|---|---|
| **sub1** | "phrase", "another phrase", keyword |
| **sub2** | "phrase", "another phrase", keyword |

---

## Intent Patterns

| Intent | What User Wants | Route | Example |
|---|---|---|---|
| `CATEGORY_SLUG:intent1` | Description | Pipeline → name / Agent loop (type) | "Example user message" |
| `CATEGORY_SLUG:intent2` | Description | Pipeline → name / Agent loop (type) | "Example user message" |
| `CATEGORY_SLUG:learn` | Understand a concept | Agent loop (informational) | "Explain X to me" |
| `CATEGORY_SLUG:preference-update` | Tell Crispy a preference | Memory write → confirm | "I prefer X" |

---

## Sub-Role Context (The Hat)

```markdown
## EMOJI Active Mode: CATEGORY_NAME

You're in CATEGORY_NAME mode. Adjust your approach:

**Tone:** Describe the voice — warm? analytical? creative? Like a [metaphor].

**Critical rule:** What must Crispy NEVER do in this domain?
(e.g., give medical advice, financial recommendations, etc.)

**Memory awareness:** You know the user's [domain-specific preferences].
Pull from CATEGORY_SLUG-tagged memories before giving generic responses.

**Key behaviors:**
- Behavior 1
- Behavior 2
- Behavior 3

**Context to load:**
- Check MEMORY.md for: [relevant memory types]

**Pipelines available:**
- `pipeline-name` — Description (future)

**When to save to memory:**
- Condition → save with [tag]
- Condition → save with [tag]
```

---

## Focus Tree

```
EMOJI CATEGORY_NAME Focus (CP2 active)
├── 🔹 Branch 1                        ← description
│   ├── 🔸 Leaf 1a                    → pipeline or agent loop
│   └── 🔸 Leaf 1b                    → pipeline or agent loop
│
├── 🔹 Branch 2                        ← description
│   ├── 🔸 Leaf 2a                    → pipeline or agent loop
│   └── 🔸 Leaf 2b                    → pipeline or agent loop
│
└── 🔹 Branch 3                        ← description
    └── SMART+ kicks in               ← if planning-related
        → agent loop (planning mode)
```

---

## Pipeline Map

| Pipeline | Trigger | Status | What It Does |
|---|---|---|---|
| `pipeline-name` | "trigger phrase" | 🔲 Future | Description |

---

## Memory Filter

```json
{
  "category": ["CATEGORY_SLUG", "CATEGORY_SLUG:sub1", "CATEGORY_SLUG:sub2"],
  "cross_category": [],
  "exclude_categories": [],
  "boost_fields": ["field1", "field2"],
  "recency_weight": 0.25,
  "semantic_weight": 0.25,
  "category_weight": 0.25,
  "frequency_weight": 0.25
}
```

*Explain why the weights are tuned this way for this domain.*

### Memory Types to Retrieve

| Memory Type | Example | Priority |
|---|---|---|
| **Type 1** | "Example" | Always load |
| **Type 2** | "Example" | Load for specific intents |

---

## Compaction Rules

### Preserve
- Thing 1 (why it matters)
- Thing 2 (why it matters)

### Flush
- Thing 1 (why it's safe to discard)
- Thing 2 (why it's safe to discard)

### Compaction Summary Prompt (CATEGORY_SLUG-specific)
```
Summarize this CATEGORY_NAME conversation segment.

Preserve exactly:
- Key item 1
- Key item 2

Do NOT include:
- Flushable item 1
- Flushable item 2

Output: max 200 tokens.
```

---

## Drift Signals (CATEGORY_NAME-Specific)

| Signal | What It Looks Like | Action |
|---|---|---|
| **Signal 1** | Description | Re-anchor: "phrase" |
| **Scope creep** | Turning a simple question into a full review | Re-anchor: answer what was asked |

---

## Special Considerations

### [Topic-Specific Section]
Explain any unique characteristics of this category — legal boundaries,
safety concerns, cross-category overlaps, skill connections, etc.

---

**Up →** [[stack/L5-routing/categories/_overview]]
