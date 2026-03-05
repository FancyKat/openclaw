---
tags: [layer/session, status/draft, type/reference, topic/context-files]
context_file: MEMORY.md
token_budget: 800
char_budget: 3200
injection: "DM sessions only"
priority: medium
---
# MEMORY.md — Long-Term Memory

> Source of truth for Crispy's MEMORY.md context file. Facts learned from past conversations. Highest risk for context bloat — requires active monthly pruning. 1 new memory/day = 360 lines/year = 9× over budget. Pruning rule: monthly review — archive anything not referenced in 60 days.

---

## People

### Marty
- Timezone: America/Los_Angeles (Pacific)
- Primary admin, builder, systems thinker

### Wenting
- Co-admin, equal access

^ctx-memory-people
<!-- REASON: Baseline facts about admins. Crispy adds more as learned. -->

## Projects

### Crispy Kitsune (Planning Vault)
- Obsidian vault documenting the entire CKS 7-layer stack
- Repository: github.com/FancyKat/crispy-kitsune
- Status: Building out layer by layer (L1 → L7)

### OpenClaw Agent
- Gateway on localhost:18789
- Bootstrap files stored in ~/.openclaw/workspace/
- Session reset: 4am Pacific + 2hr idle

^ctx-memory-projects
<!-- REASON: Primary project context. Model routing details owned by L2 — not duplicated here. -->

## Key Decisions
<!-- Crispy records decisions that affect future behavior -->
<!-- Format: - {decision}: {rationale} ({date}) -->
<!-- PRUNING: When superseded by a newer decision, archive the old one. -->

^ctx-memory-decisions

## Learned Preferences
<!-- Things discovered through conversation -->
<!-- Format: - {preference} (learned {date}) -->
<!-- PRUNING: If not referenced in 60 days, archive or delete. -->

^ctx-memory-preferences

## Active Facts
<!-- Current state of ongoing work -->
<!-- Move to STATUS.md if changes daily. -->

^ctx-memory-facts

---

**Up →** [[stack/L4-session/_overview]]
