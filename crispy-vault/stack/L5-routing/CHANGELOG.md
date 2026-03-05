---
tags: [layer/routing, type/note, status/active]
---
# L5 — Routing Changelog

> All changes to this layer. Each session adds a dated entry.

**Up →** [[stack/L5-routing/_overview]]

---

## 2026-03-05 — Fix reserved keyword `participant Loop` + convert ASCII flows to Mermaid

### Changed
- `categories/cooking/conversation-flows.md` — Renamed `participant Loop` → `participant AgentLoop` (display label unchanged). Updated all arrow/note references: `L5->>Loop`, `Note right of Loop`, `Loop-->>TG`.
- `categories/coding/conversation-flows.md` — Same `Loop` → `AgentLoop` rename; updated `Note over L5,Loop`, `L5->>Loop`, `Loop->>Loop`, `TG->>Loop`, `Loop-->>TG` (multiple occurrences).
- `categories/finance/conversation-flows.md` — Same `Loop` → `AgentLoop` rename; updated `L5->>Loop`, `Note right of Loop`, `Loop-->>TG`.
- `categories/fitness/conversation-flows.md` — Same `Loop` → `AgentLoop` rename; updated `L5->>Loop`, `Note right of Loop`, `Loop-->>TG`.
- `categories/design/conversation-flows.md` — Same `Loop` → `AgentLoop` rename; updated `L5->>Loop` (×2), `Note right of Loop` (×2), `Loop-->>TG` (×2).
- `categories/pet-care/conversation-flows.md` — Same `Loop` → `AgentLoop` rename in participant declaration.
- `categories/habits/conversation-flows.md` — Converted Flow 1 (Daily Check-In) and Flow 2 (Weekly Review) from plain-text `↓` blocks to `sequenceDiagram` with participants matching the file's top-level diagram (User, TG, L5, Mem).

---

## 2026-03-04 — Real conversation diagram added to conversation-flows.md

### Added
- `conversation-flows.md` — "Real Conversation — What Happens on Each Side" section: full dual-column ASCII diagram showing 7-exchange conversation between user (Telegram) and Crispy (system). Shows all 3 routing paths (pipeline, button, agent loop), 2 category shifts with compaction, heartbeat check, memory recall via dual-tag, and a summary table of token costs per exchange.

---

## 2026-03-04 — Phase B: conversation flows, pipelines, speed baselines (T-L5-02/03/04)

### Added (T-L5-02 — Conversation Flows)
- `categories/*/conversation-flows.md` (7 files) — Added `sequenceDiagram` Mermaid diagrams with `Note over` pipeline insertion annotations (`⚡ pipeline-name [FUTURE]` format) and Speed Impact tables. pet-care full buildout (was 19-line stub). design full buildout (had key interaction patterns but no diagrams).

### Added (T-L5-03 — Pipelines Lobster YAML)
- `categories/cooking/pipelines.md` — Lobster YAML for: `^pipeline-cooking-grocery-list`, `^pipeline-cooking-recipe-search`, `^pipeline-cooking-meal-plan`, `^pipeline-cooking-pantry-check`
- `categories/finance/pipelines.md` — Lobster YAML for: `^pipeline-finance-market-brief`, `^pipeline-finance-position-check`, `^pipeline-finance-backtest`, `^pipeline-finance-watchlist`, `^pipeline-finance-budget-review`, `^pipeline-finance-expense-tracker`
- `categories/fitness/pipelines.md` — Lobster YAML for: `^pipeline-fitness-workout-log`, `^pipeline-fitness-progress-check`, `^pipeline-fitness-program-generator`, `^pipeline-fitness-rest-day-check`
- `categories/habits/pipelines.md` — Lobster YAML for: `^pipeline-habits-habit-checkin`, `^pipeline-habits-habit-review`, `^pipeline-habits-streak-check`, `^pipeline-habits-habit-update`, `^pipeline-habits-habit-reminder`. Removed erroneous `^pipelines-habits` block ID.
- `categories/pet-care/pipelines.md` — Lobster YAML for: `^pipeline-pet-care-medication-tracker`, `^pipeline-pet-care-appointment`, `^pipeline-pet-care-feeding-schedule`, `^pipeline-pet-care-supply-list`, `^pipeline-pet-care-training-log`, `^pipeline-pet-care-grooming-schedule`
- `categories/design/pipelines.md` — Lobster YAML for: `^pipeline-design-brand-audit`

### Added (T-L5-04 — Speed Baselines)
- `categories/*/speed-baselines.md` (7 files) — Added: testing methodology, pipeline impact predictions table, Speed Budget JSON block. Fixed `^speed-*` block IDs from standalone Pattern 5 (extracted Markdown table → wrong) to Pattern 4 (code fence + block ID → valid JSON output for `dist/focus/{slug}/speed.json`).

### Changed
- `build/pipeline-main.md` — Added "### L5 Category Pipelines" section (§13–38) with all 26 new pipeline block IDs registered
- `build/scripts/build-config.js` — Added 26 L5 category pipelines to build list; updated `expectedPipelines` audit array (T-L5-03 — pipeline registration scope granted by session-prompt)

### Verified
- `node build/scripts/build-config.js --only pipelines` → 38/38 pipelines produced (12 L6 + 26 L5). ✅ No duplicate block IDs.
- `node build/scripts/build-config.js --only focus` → 42/42 focus files produced with `mode.md`. ✅

### Cross-Layer Effects
- `build/pipeline-main.md` — New §13–38 section added with 26 L5 category pipeline transclusions

---

## 2026-03-04 — hat → mode rename across all categories (T-L5-01)

### Changed
- `categories/*/`_overview.md` (7 files)` — Renamed `hat_tokens` → `mode_tokens` (frontmatter), `^hat-{slug}` → `^mode-{slug}` (block ID), `## Sub-Role Context (The Hat)` → `## Mode Context` (heading), H1 `# Category Hat —` → `# Category Mode —`, all body text "hat"/"The Hat" → "mode". (T-L5-01)
- `build/focus-main.md` — Updated all `^hat-{slug}` transclusion refs → `^mode-{slug}`. Updated Architecture table and section headers: `hat.md` → `mode.md`, `### Hat (hat.md)` → `### Mode (mode.md)`. (T-L5-01)
- `build/scripts/build-config.js` — `FOCUS_BLOCK_MAP`: `'hat'` entry renamed `'mode'`, `hat.md` → `mode.md`. `NON_CONTEXT_PREFIXES`: `'hat'` → `'mode'`. Updated all related comments. (T-L5-01 — explicit build script scope granted by session-prompt)

### Verified
- `node build/scripts/build-config.js --only focus` → 42 files produced. All 7 categories output `mode.md` (not `hat.md`).
- `grep -rn "hat-" stack/L5-routing/ build/focus-main.md build/scripts/build-config.js` → zero actual block ID matches (false positives only: "chat-flow" substring, historical CHANGELOG entries).
- Stale `dist/focus/*/hat.md` files removed.

### Cross-Layer Effects
- `stack/L5-routing/cross-layer-notes.md` — Updated block ID reference in upstream-consumption note: `^hat-{slug}` → `^mode-{slug}`. Deleted 2 resolved notes (L7 search API, L6 message-routing dedup).

---

## 2026-03-04 — Verification pass

### Verified
- 42/42 focus block IDs present across 7 categories × 6 block types
- `build/focus-main.md` scaffold correctly references all 7 categories
- 58 category files total (7 categories × 8 files each + 2 top-level overviews)
- Open cross-layer notes tracked: L5 context shaping needs L4 token budgets, L5 memory filtering needs L7 search API, SCAN re-anchoring trigger policy, category block IDs ready for upstream

---

## 2026-03-04 — Full layer audit + category expansion (session-prompt Phase 2–5)

### Added
- `CHANGELOG.md` — This file. Layer changelog created per session-prompt Phase 3 template.
- **42 new category focus files** (7 categories × 6 new files each):
  - `categories/cooking/` — `triggers.md`, `focus-tree.md`, `pipelines.md`, `conversation-flows.md`, `speed-baselines.md`, `memory-filter.md`, `drift-signals.md`
  - `categories/coding/` — `triggers.md`, `focus-tree.md`, `pipelines.md`, `conversation-flows.md`, `speed-baselines.md`, `memory-filter.md`, `drift-signals.md`
  - `categories/finance/` — `triggers.md`, `focus-tree.md`, `pipelines.md`, `conversation-flows.md`, `speed-baselines.md`, `memory-filter.md`, `drift-signals.md`
  - `categories/fitness/` — `triggers.md`, `focus-tree.md`, `pipelines.md`, `conversation-flows.md`, `speed-baselines.md`, `memory-filter.md`, `drift-signals.md`
  - `categories/habits/` — `triggers.md`, `focus-tree.md`, `pipelines.md`, `conversation-flows.md`, `speed-baselines.md`, `memory-filter.md`, `drift-signals.md`
  - `categories/pet-care/` — `triggers.md`, `focus-tree.md`, `pipelines.md`, `conversation-flows.md`, `speed-baselines.md`, `memory-filter.md`, `drift-signals.md`
  - `categories/design/` — `triggers.md`, `focus-tree.md`, `pipelines.md`, `conversation-flows.md`, `speed-baselines.md`, `memory-filter.md`, `drift-signals.md`

### Changed
- `_overview.md` — Added `layer_name`, `layer_number`, `layer_slug`, `file_count`, `status_summary` frontmatter properties per CLAUDE.md § Frontmatter Properties. Added CHANGELOG to Pages table. Updated `file_count` from 15 to 64.
- **7 category `_overview.md` files trimmed** — Each category overview reduced to index format with frontmatter properties (`category_name`, `category_slug`, `category_emoji`, `hat_tokens`, `active_pipelines`, `future_pipelines`, channel flags), Sub-Role Context (The Hat) with `^hat-{slug}` block ID, Pages table, and Special Considerations.

### Block IDs Added
- `^hat-cooking`, `^hat-coding`, `^hat-finance`, `^hat-fitness`, `^hat-habits`, `^hat-pet-care`, `^hat-design` — Sub-role context blocks in category `_overview.md` files
- `^triggers-{slug}` — Trigger word/pattern blocks in each `triggers.md`
- `^tree-{slug}` — Focus tree decision blocks in each `focus-tree.md`
- `^filter-{slug}` — Memory filter blocks in each `memory-filter.md`
- `^compaction-{slug}` — Compaction strategy blocks in each `conversation-flows.md`
- `^speed-{slug}` — Speed baseline blocks in each `speed-baselines.md`

### Cross-Layer Effects
- `00-INDEX.md` — Added L5 CHANGELOG link + category sub-file links
- New transclusion block IDs (`^hat-*`, `^tree-*`, `^filter-*`, `^compaction-*`, `^speed-*`) available for L4 context assembly and L6 pipeline consumption
- Cross-layer note added: new block IDs ready for upstream consumption
