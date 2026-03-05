---
tags: [type/index, layer/routing, status/draft, category/design]
category_name: "Design"
category_slug: "design"
category_emoji: "🎨"
mode_tokens: 250
active_pipelines: 3
future_pipelines: 1
channel_telegram: true
channel_discord: true
channel_gmail: false
---

# Category Mode — Design 🎨

> Index and context for design mode. Trigger patterns, intents, focus tree, pipelines, memory filters, and drift signals.

**Up →** [[stack/L5-routing/categories/_overview]]

---

## Overview

The design mode is active when Marty asks about UI/UX, graphic design, presentations, branding, or design feedback. It surfaces memories about brand guidelines, color palettes, font preferences, style direction, past design projects, and accessibility requirements. The mode remains active across sub-category shifts (wireframe → review → branding) and is stripped when moving to a different top-level category (design → cooking).

---

## Mode Context

This block gets injected into the context window when the design mode is active. It sits right after AGENTS.md — in the high-attention zone:

```markdown
## 🎨 Active Mode: Design

You're in design mode. Adjust your approach:

**Tone:** Creative but precise. Like a thoughtful design lead — opinionated
but open-minded. Speak in design language (hierarchy, contrast, whitespace,
rhythm) but translate for non-designers when needed. Show, don't just tell.

**Critical rule:** Design is subjective, but principles aren't. Ground feedback
in design principles (contrast, alignment, repetition, proximity, hierarchy)
rather than personal taste. When the user asks "does this look good?", respond
with principle-based observations, not just "yes" or "no."

**Memory awareness:** You know Marty's design preferences, brand guidelines,
tools they use, past projects, style preferences, and skill level. Pull from
design-tagged memories before suggesting generic approaches.

**Key preferences to remember:**
- Check MEMORY.md for: brand colors, preferred fonts, design tools,
  style preferences (minimal/bold/playful), past project styles,
  accessibility requirements
- If no preferences stored, ask about style direction before creating

**Pipelines available:**
- `pptx` — PowerPoint creation and editing (via skill) ✅
- `canvas-design` — Visual asset creation (via skill) ✅
- `algorithmic-art` — Generative art creation (via skill) ✅
- `brand-audit` — Check assets against brand guidelines (future)

**When to save to memory:**
- Brand guidelines defined or updated → save immediately
- Color palette chosen → save with hex codes
- Font preferences set → save with specific font names
- Style direction established → save with descriptive keywords
- Project-specific design decisions → save with project tag
- Accessibility requirements stated → save to preferences
```

^mode-design

---

## Pages

| Page | Purpose |
|---|---|
| [[stack/L5-routing/categories/design/triggers]] | Trigger words, intent patterns, interaction type thresholds, topic shift signals |
| [[stack/L5-routing/categories/design/focus-tree]] | Navigation hierarchy, focus tree JSON, button rendering per channel |
| [[stack/L5-routing/categories/design/pipelines]] | Pipeline definitions, token costs, LLM vs lookup breakdown, dependencies |
| [[stack/L5-routing/categories/design/conversation-flows]] | Example flows with Mermaid diagrams, channel differences, multi-turn scenarios |
| [[stack/L5-routing/categories/design/speed-baselines]] | Latency budgets, operation breakdowns, UX red lines, caching strategy |
| [[stack/L5-routing/categories/design/memory-filter]] | Vector DB query filter, memory types, cross-category queries, compaction rules |
| [[stack/L5-routing/categories/design/drift-signals]] | Model drift detection, re-anchoring protocols, risk profiles per interaction type |

---

## Special Considerations

### Coding Hat Overlap

Design and coding frequently overlap, especially for UI/UX work. The rule: **intent determines the mode, memories cross-reference.**

- "Design a login page layout" → design mode + coding:frontend memory
- "Build the login page component" → coding mode + design memory
- "Make this button look better" → design mode (visual intent)
- "Fix this button's click handler" → coding mode (functional intent)

### Skill Integration

Design is the most skill-heavy category. Three skills are available immediately:
- `canvas-design` — For creating visual assets (posters, banners, etc.)
- `algorithmic-art` — For generative/code-based visual art
- `pptx` — For presentations and slide decks
- `brand-guidelines` — For Anthropic-specific brand application (if relevant)

The agent should load the appropriate skill when the Focus Tree leads to a creative action.

---

**Up →** [[stack/L5-routing/categories/_overview]]
