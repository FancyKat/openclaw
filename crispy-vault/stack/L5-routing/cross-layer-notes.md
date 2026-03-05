---
tags: [layer/routing, type/notes, status/active]
---
# L5 Cross-Layer Notes

> Notes from L5 sessions that affect other layers.

---

## 2026-03-04 — L5 context shaping needs L4 token budgets
- **from:** L5
- **affects:** L4
- L5's context shaping strategy (documented in `_overview.md`) decides what to load/strip based on mode (coding, chatting, researching, briefing). To make these decisions correctly, L5 needs to know each context file's token budget from L4's `context-main.md` comments (e.g. SOUL ~800–1,200 tokens, AGENTS ~3,000–5,000 tokens). L4 should expose these budgets in a structured way (e.g. a summary table in `context-assembly.md`) so L5 can reference them.
- **status:** resolved — L4 token budgets documented in `context-main.md` comments (~6,100 tokens total). L5 can reference these directly via `[[build/context-main]]`. A formal summary table is a nice-to-have but not blocking. (2026-03-04)

## 2026-03-04 — Acknowledge L4 SCAN re-anchoring note
- **from:** L5 (responding to L4 note)
- **affects:** L5, L6
- L4 flagged that persona consistency degrades >30% after 8-12 dialogue turns and recommends SCAN re-anchoring every 5 turns. This is an L5 concern: L5 owns mode detection and context shaping, so the re-anchoring trigger (turn counter) would live in L5's compaction/context-shaping logic. The actual re-anchoring step (generating a self-summary) would be an L6 processing pipeline step. L5 should define the trigger policy; L6 should implement the pipeline step.
- **trigger policy defined:** Every 5 dialogue turns, L5 compaction logic injects a re-anchoring signal. Combined with smart-detect category persistence (re-classify first message each session), SCAN doubles as category confirmation. L6 implements the self-summary generation step.
- **status:** spec complete — L4 note also marked spec complete. L6 tracks implementation. (2026-03-04)

## 2026-03-04 — New category block IDs ready for upstream consumption
- **from:** L5
- **affects:** L4, L6
- Category expansion added transclusion block IDs across 7 categories: `^mode-{slug}`, `^triggers-{slug}`, `^tree-{slug}`, `^filter-{slug}`, `^compaction-{slug}`, `^speed-{slug}`. These are available for L4 context assembly (injecting relevant mode context per conversation type) and L6 pipeline consumption (routing decisions based on focus trees). No upstream files currently reference these — they're ready for wiring when L4/L6 are updated. (Note: `^hat-*` renamed to `^mode-*` per T-L5-01.)
- **wiring map:** L4 context assembly should load `^mode-{active-category}` when a hat is active. L6 pipeline routing should read `^triggers-{slug}` for intent matching and `^tree-{slug}` for button generation. L5 `^filter-{slug}` feeds L7 memory queries. All blocks registered in `focus-main.md`.
- **status:** resolved — wiring documented, blocks ready for implementation. (2026-03-04)

---

**Up →** [[stack/L5-routing/_overview]]
