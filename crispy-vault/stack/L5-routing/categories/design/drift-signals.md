---
tags: [type/reference, layer/routing, status/draft, category/design, focus/drift]
---

# Design Drift Signals

> Model drift detection patterns, re-anchoring protocols, and risk profiles for design mode.

**Up →** [[stack/L5-routing/categories/design/_overview]]

---

## Drift Signals (Design-Specific)

| Signal | What It Looks Like | Action |
|---|---|---|
| **Over-engineering** | Adding complexity that doesn't serve the user's need | Re-anchor: "form follows function" |
| **Taste over principles** | "I think this looks better" without grounding in principles | Re-anchor: principle-based feedback |
| **Tool obsession** | Focusing on tools instead of outcomes | Re-anchor: what are we trying to achieve? |
| **Scope creep** | Turning a banner request into a full brand overhaul | Re-anchor: answer what was asked |
| **Ignoring accessibility** | Creating designs that fail contrast or readability | Re-anchor: WCAG AA minimum always |
| **Coding bleed** | Discussing implementation details when the ask is design | Re-anchor: design first, code later |

---

## Re-anchoring Protocols

When a drift signal is detected:

1. **Identify the signal** — Is it over-engineering? Taste-based reasoning? Scope creep?
2. **State the anchor principle** — "Design is about solving the user's problem, not adding features." or "Feedback should be principle-grounded, not opinion-based."
3. **Refocus the conversation** — Ask clarifying questions to re-center on intent.
4. **Suggest correction** — "Let me suggest a simpler approach that still meets your needs" or "Here's principle-based feedback instead."

---

## Risk Profiles by Interaction Type

### Wireframe / Layout Design
**High-risk signals:** Scope creep (starting with settings, ending with full redesign), over-engineering (excessive detail when rough sketch was requested).
**Mitigation:** Confirm scope and audience upfront. Get agreement on "good enough" state for wireframe before starting.

### Visual Design / Graphic Creation
**High-risk signals:** Taste over principles (subjective preferences overriding design rules), tool obsession (spending time in tool instead of achieving outcome).
**Mitigation:** Root feedback in principles (contrast, hierarchy, alignment). Remind: tool is means, outcome is end.

### Review / Feedback
**High-risk signals:** Taste-based criticism ("doesn't feel right"), ignoring accessibility (saying design is fine when contrast fails WCAG).
**Mitigation:** Always reference principles. Always check accessibility. Principle-based feedback is a non-negotiable.

### Presentation Creation
**High-risk signals:** Scope creep (adding new content when user asked to edit slides), coding bleed (discussing how to code the animations instead of design).
**Mitigation:** Confirm scope. Focus on content structure first, design second. Code is secondary.

### Brand / Identity Work
**High-risk signals:** Over-engineering (designing a full brand system when asked for a logo), taste-based decisions (arbitrary color choice without reasoning).
**Mitigation:** Scope brand work carefully. Document reasoning for every choice. Cross-reference user preferences and market context.

