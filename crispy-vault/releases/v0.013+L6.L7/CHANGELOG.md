# Release v0.013+L6.L7

| Field | Value |
|-------|-------|
| **Version Tag** | v0.013+L6.L7 |
| **Build Date** | 2026-03-04T23:33:52Z |
| **Changed Layers** | L6,L7 |

---

## Recent Changes (from root CHANGELOG)

## [0.32.0] — 2026-03-04 — Worker Session: L6 Pipeline Enrichment + L7 Memory Config

### Changed
- **`build/scripts/build-config.js`** — Fixed Pattern 4 / Pattern 2 ordering bug in `extractBlocks()`. Pattern 2 was false-matching the closing ` ``` ` of Pattern 4 blocks (no language = matches `\w*`), consuming block IDs and Markdown tables as content. Fix: Pattern 4 now runs FIRST, registering block IDs in `seenIds` before Pattern 2 can false-match. Affected 5 blocks: `^config-gateway`, `^config-agents`, `^config-tools`, `^config-plugins`, `^config-cron`. Result: all 10/10 config blocks parse correctly, `dist/openclaw.json` has all 8 core keys.
- **`stack/L6-processing/config-reference.md`** — Reformatted all 4 blocks to COMMENT→BLOCK→ID format; changed `json5` to `json` fences; fixed `^config-skills` schema (replaced invalid `installed` field with correct `entries` object).
- **`stack/L6-processing/pipelines/*.md`** + **`coding/*.md`** — Added Lobster YAML `## Pipeline YAML` sections with `description:` fields to all 10 pipelines (brief, email, health-check, skill-router, intent-finder, prompt-builder, media, code-review, deploy, testing). Added `description:` to 2 existing YAML blocks (git-pipelines, project-routing). Renamed `project-routing` name from `project-router`. Pipeline build: 12/12 ✅, total 38/38 ✅.
- **`stack/L7-memory/config-reference.md`** — Reformatted both blocks to COMMENT→BLOCK→ID format. Wrapped `memorySearch` and `auditLog` in `{"agents":{"defaults":{...}}}` envelope (was appearing at top level of `dist/openclaw.json`). STATUS: `^config-memory` updated to `✅` (all fields verified via vault refs); `^config-audit` remains `⚠️` pending official docs.
- **`stack/L7-memory/memory-md.md`** — Added `## Curation Policies` section: keep/discard decision table (10 signals), aging policy table (5 age bands), tag taxonomy (8 tags: `#preference`, `#decision`, `#architecture`, `#person`, `#project`, `#lesson`, `#pattern`, `#constraint`).
- **`build/config-main.md`** — §9 Skills `🔲` → `✅`; §5 Memory `⚠️` → `✅`; §5b Audit Log remains `⚠️`.

### Verified
- Config build: 10/10 blocks parse, `dist/openclaw.json` keys: `gateway, agents, channels, tools, hooks, plugins, cron, skills` ✅
- Pipeline build: 38/38 pipelines produced ✅
- `agents.defaults` includes `memorySearch` + `auditLog` alongside L2 keys ✅

---

## Files Included

See README.md for the complete file manifest.
