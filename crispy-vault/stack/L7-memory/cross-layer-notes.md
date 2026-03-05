---
tags: [layer/memory, type/notes, status/active]
---
# L7 Cross-Layer Notes

> Notes from L7 sessions that affect other layers.

---

## 2026-03-04 — Audit log config may need new config block in L2
- **from:** L7
- **affects:** L2
- The new `audit-log.md` spec defines an `agents.defaults.auditLog` config section (enabled, location, format, retention, what to log). This may need a dedicated `^config-audit` block registered in L2's `config-reference.md` and `build/config-main.md`. Currently it's documented inline in `audit-log.md` with a comment referencing L2, but no formal block ID exists yet.
- **status:** resolved — `^config-audit` block added to L7 `config-reference.md` (L7 owns auditLog config, merges into agents.defaults). Registered in `build/config-main.md` §5b. Inline config in `audit-log.md` replaced with reference to config-reference.md.

## 2026-03-04 — Cascade violations cleaned in L7
- **from:** L7
- **affects:** L2 (informational)
- Replaced hardcoded model strings in `audit-log.md`, `daily-logs.md`, `memory-md.md`, and `decisions-log.md` with aliases (`researcher`, `workhorse`) and wikilinks to `[[stack/L2-runtime/config-reference]]`. Gemini references left as-is (legitimate embedding provider). DeepSeek references in decisions-log left as-is (historical context with aliases already present).
- **status:** resolved

## 2026-03-04 — L7 audit: duplicate content removed, links fixed
- **from:** L7
- **affects:** L1 (informational)
- Removed `.md` extensions from all L7 wikilinks in `00-INDEX.md`, resolving the L1 cross-layer note about vault-wide `.md` extension cleanup for L7's entries.
- **status:** resolved

## 2026-03-04 — Mem0 content removed from memory-search.md
- **from:** L7
- **affects:** none (informational)
- Removed ~630 lines of duplicate Mem0 documentation and a duplicate "Search System Guide" section from `memory-search.md`. Mem0 is tracked in `_overview.md` Memory Systems table (status: 🟡 Ready). When Mem0 is implemented, a dedicated `mem0.md` file should be created.
- **status:** resolved

## 2026-03-04 — L5 requests search API contract documentation
- **from:** L7 (responding to L5 cross-layer note)
- **affects:** L5
- L5's cross-layer note requests L7 document the `memory_search` API contract (query format, return format, relevance scoring). This is partially covered in `memory-search.md` (search algorithm, config, usage examples) but a formal API contract section (input/output schema) should be added in a future session.
- **status:** resolved — Added "Search API Contract" section to `memory-search.md` with full request/response JSON5 schemas, scoring formula, and L5 integration table (mode-aware query patterns for coding/research/chatting/briefing).

---

**Up →** [[stack/L7-memory/_overview]]
