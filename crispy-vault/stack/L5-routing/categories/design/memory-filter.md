---
tags: [type/reference, layer/routing, status/draft, category/design, focus/memory]
---

# Design Memory Filter

> Vector DB query filter, memory type definitions, cross-category queries, and compaction rules for design conversations.

**Up →** [[stack/L5-routing/categories/design/_overview]]

---

## Vector DB Query Filter

```json
{
  "category": ["design", "design:ui-ux", "design:graphic", "design:presentation", "design:brand"],
  "cross_category": ["coding:frontend"],
  "exclude_categories": ["finance", "fitness"],
  "boost_fields": ["brand_color", "font_name", "style_keyword", "project_name"],
  "recency_weight": 0.15,
  "semantic_weight": 0.35,
  "category_weight": 0.3,
  "frequency_weight": 0.2
}
```

*Design memories are long-lived — brand guidelines don't change often. Semantic weight is highest because design conversations reference concepts and styles more than recent events. Cross-category with coding:frontend for UI implementation.*

^filter-design

---

## Memory Types to Retrieve

| Memory Type | Example | Priority |
|---|---|---|
| **Brand colors** | "Primary: #2563EB, Secondary: #7C3AED, Accent: #F59E0B" | Always load |
| **Font preferences** | "Headings: Inter Bold, Body: Inter Regular, Code: JetBrains Mono" | Always load |
| **Style direction** | "Minimal, clean, lots of whitespace, subtle animations" | Always load |
| **Design tools** | "Figma for UI, Canva for social, VS Code for CSS" | Load if tool-related |
| **Past projects** | "Designed Crispy's Telegram bot UI — dark theme, orange accents" | Load if related project |
| **Accessibility reqs** | "WCAG AA minimum, high contrast mode for all UI" | Always load |
| **Brand guidelines** | "No gradients, round corners (8px), shadow style: subtle" | Always load |

---

## Compaction Rules

### Preserve
- Brand guideline decisions (colors, fonts, spacing, rules)
- Design system choices (component patterns, naming conventions)
- Project-specific design decisions with reasoning
- Accessibility requirements and standards chosen
- Style direction statements
- Feedback received and actions taken on designs

### Flush
- Step-by-step design process descriptions (the outcome matters, not the steps)
- Specific pixel measurements discussed then changed
- Tool-specific instructions that are regeneratable
- Generic design principle explanations
- Iterative revision discussions (only final decisions matter)

### Compaction Summary Prompt (design-specific)

```
Summarize this design conversation segment.

Preserve exactly:
- Any brand or style decisions made (colors, fonts, patterns)
- Any design system choices or component decisions
- Any accessibility requirements stated
- Any project-specific design outcomes
- Any feedback received and resulting changes

Do NOT include:
- Step-by-step creation process details
- Intermediate measurements or iterations
- Tool instructions that can be re-generated
- Generic design principle explanations

Output: max 200 tokens.
```

^compaction-design
