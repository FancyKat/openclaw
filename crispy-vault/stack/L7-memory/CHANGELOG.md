---
tags: [layer/memory, type/note, status/active]
---
# L7 — Memory Changelog

> All changes to this layer. Each session adds a dated entry.

**Up →** [[stack/L7-memory/_overview]]

---

## 2026-03-05 — Replace ASCII decay curve with xychart-beta in memory-search.md

### Changed
- `memory-search.md` — Replaced ASCII box-drawing temporal decay curve (lines ~56–64, `├─`, `╲`, `└` characters) with `xychart-beta` Mermaid line chart. Data points: 0d→100%, 10d→83%, 20d→66%, 30d→50%, 40d→41%, 50d→33%, 60d→25%. Title: "Temporal Decay — 30-Day Half-Life".

---

## 2026-03-04 — ER diagram + memory decay timeline + search scoring diagram

### Added
- `_overview.md` — Added ER diagram (Mermaid erDiagram) showing MEMORY_ENTRY, DAILY_LOG, MEMORY_MD, AUDIT_EVENT, SESSION entities with relationships and fields. Added memory decay timeline (Day 0→100%, Day 30→50%, Day 90→12.5%, Day 180+→archive). Entity summary table with storage location, retention, and max size.
- `memory-search.md` — Added search scoring pipeline stateDiagram-v2 (Mermaid) showing Query → VectorEmbed → VectorMatch + BM25Match → HybridMerge (70/30) → ApplyDecay → MMRRerank → ScoreFilter → LimitResults. Notes on embedding dimensions (768), latency (~500ms), MEMORY.md decay exemption.

---

## 2026-03-04 — T-L7-01 through T-L7-03: config reformat + verification + curation rules

### Changed (T-L7-01 — Config reformat)
- `config-reference.md` — Reformatted both blocks (`^config-memory`, `^config-audit`) to COMMENT→BLOCK→ID format: HTML comments before code fence, pure JSON inside (removed `//` comments), `^block-id` on line after closing fence. Changed `json5` fences to `json`. Wrapped both blocks in `{"agents":{"defaults":{...}}}` for correct deepMerge nesting (was bare keys, incorrectly appearing at top level of dist/openclaw.json).

### Verified (T-L7-02 — Schema verification)
- `config-reference.md ^config-memory`: All fields confirmed valid via vault references (openclaw-debugger skill, memory-search.md):
  - `memorySearch` ✅ correct key name under `agents.defaults`
  - `gemini-embedding-001` ✅ valid model string for provider `"gemini"`
  - `hybrid`, `mmr`, `temporalDecay`, `vectorWeight`, `textWeight`, `candidateMultiplier` ✅ all real OpenClaw config fields
  - STATUS updated from `⚠️ needs verification` to `✅ verified`
- `config-reference.md ^config-audit`: `auditLog` present in vault references but not yet confirmed in official docs — STATUS kept `⚠️` with updated note.
- `build/config-main.md` — §5 Memory status updated from `⚠️` to `✅`. §5b Audit Log remains `⚠️`.

### Added (T-L7-03 — MEMORY.md curation rules)
- `memory-md.md` — Added `## Curation Policies` section with:
  - Keep/discard decision table (10 rows, signal → verdict → reason)
  - Aging policy table (< 30 days → > 1 year, 5 rules)
  - Tag taxonomy (8 tags: `#preference`, `#decision`, `#architecture`, `#person`, `#project`, `#lesson`, `#pattern`, `#constraint`)

### Verified
- `node build/scripts/build-config.js --only config` — `dist/openclaw.json` `agents.defaults` now correctly includes `memorySearch` and `auditLog` alongside L2 keys. No parse errors.

---

## 2026-03-04 — Search API contract + audit config block

### Added
- `memory-search.md` — Added "Search API Contract" section with formal request/response JSON5 schemas, scoring formula, and L5 integration table (mode-aware query patterns for coding/research/chatting/briefing)
- `config-reference.md` — Added `^config-audit` block with `agents.defaults.auditLog` config (JSONL, 90-day retention, tool/approval/error/token logging)

### Changed
- `audit-log.md` — Replaced inline config JSON with reference to `config-reference.md ^config-audit` (per CLAUDE.md rule: config JSON only in config-reference.md)
- `_overview.md` — Added `^config-audit` to `config_blocks` frontmatter property

### Cross-Layer Effects
- `build/config-main.md` — Registered `^config-audit` as §5b in assembly order table + added transclusion section
- `stack/L5-routing/cross-layer-notes.md` — Marked "L5 memory filtering depends on L7 search API" as resolved

---

## 2026-03-04 — Full layer audit (session-prompt Phase 2–5)

### Added
- `CHANGELOG.md` — This file. Layer changelog created per session-prompt Phase 3 template.

### Changed
- `_overview.md` — Added `layer_name`, `layer_number`, `layer_slug`, `config_blocks`, `file_count`, `status_summary` frontmatter properties per CLAUDE.md § Frontmatter Properties. Added CHANGELOG and cross-layer-notes to Pages table.

### Verified
- `_overview.md` decomposition already complete (318 lines, down from ~1,100)
- `audit-log.md` already extracted with proper frontmatter, H1, blockquote, Up link (8.6K)
- `sqlite.md` already extracted with proper frontmatter, H1, blockquote, Up link (8.8K)
- Pages table correctly lists 9 entries (daily-logs, memory-md, memory-search, audit-log, sqlite, decisions-log, open-questions, CHANGELOG, cross-layer-notes)
- Config block `^config-memory` registered in `config-reference.md`

### Cross-Layer Effects
- `00-INDEX.md` — Added L7 CHANGELOG link
- Open cross-layer notes remain: audit log config block (L2), search API contract (L5)
