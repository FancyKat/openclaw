---
tags: [layer/processing, type/note, status/active]
---
# L6 — Processing Changelog

> All changes to this layer. Each session adds a dated entry.

**Up →** [[stack/L6-processing/_overview]]

---

## 2026-03-04 — Cron gantt + agent loop state diagram

### Added
- `_overview.md` — Added cron & background schedule gantt chart (Mermaid) showing all L6-owned scheduled tasks: brief (8am PT), email (webhook), health-check (hourly), skill-router (on-demand), git pipelines, media pipelines, agent loop, category classify, compaction. Summary table with schedule, LLM cost, and trigger per pipeline.
- `agent-loop.md` — Added comprehensive agent loop stateDiagram-v2 (Mermaid) showing Idle → ContextAssembly → LLMCall (with fallback chain) → ParseResponse → ToolExecution (permission/sandbox) → UpdateContext → CheckTermination → Compaction cycle.

---

## 2026-03-04 — T-L6-01 through T-L6-04: config reformat + skills fix + pipeline enrichment + descriptions

### Changed (T-L6-01 — Config reformat)
- `config-reference.md` — Reformatted all 4 blocks (`^config-tools`, `^config-plugins`, `^config-cron`, `^config-skills`) to COMMENT→BLOCK→ID format (HTML comments before code fence, pure JSON inside, `^block-id` on line after closing fence). Changed json5 fences to json.

### Changed (T-L6-02 — Skills schema fix)
- `config-reference.md` — `^config-skills` block: replaced incorrect `"installed": ["sag","gog"]` (not a valid OpenClaw field) with correct `"entries": {"sag":{"enabled":true},"gog":{"enabled":true,"env":{...}}}` schema per skills-system.md reference. STATUS updated ✅.
- `build/config-main.md` — §9 Skills status updated from `🔲` to `✅`.

### Fixed (build script — Pattern 4 ordering)
- `build/scripts/build-config.js` — Moved Pattern 4 (code fence + following `^block-id`) to run BEFORE Pattern 2 in `extractBlocks()`. Bug: Pattern 2 was false-matching the closing ``` of a Pattern 4 block as an "opening fence" (empty language matches `\w*`), consuming the block ID and Markdown table as body until the next ``` in the file. Fix: Pattern 4 now registers block IDs in `seenIds` first, preventing Pattern 2 false matches. Affected blocks: `^config-gateway`, `^config-agents`, `^config-tools`, `^config-plugins`, `^config-cron` (any Pattern 4 block with another code fence later in the same file). All 5 blocks now parse correctly.

### Added (T-L6-03 — Pipeline content enrichment)
- `pipelines/brief.md` — Added `## Pipeline YAML` section with real Lobster YAML: load feeds, fetch RSS (Python XML parse), recall seen URLs from memory, dedupe, flash summarize, weather search, git status, inbox check, save seen URLs, compile message.
- `pipelines/email.md` — Added `## Pipeline YAML` section: fetch unread Gmail, classify urgency (flash), format preview digest, approval gate, send.
- `pipelines/health-check.md` — Added `## Pipeline YAML` section: git dirty check, memory folder size (du), disk usage (df), log word count, flash evaluate against thresholds, conditional Telegram notify.
- `pipelines/skill-router.md` — Added `## Pipeline YAML` section: load skill list from TOOLS.md, triage classify with 0.5 confidence threshold, return skill name or null.
- `pipelines/intent-finder.md` — Added `## Pipeline YAML` section: trigger word scan (0 tokens), triage classify if ambiguous, envelope output.
- `pipelines/prompt-builder.md` — Added `## Pipeline YAML` section: recall session context, flash resolve ambiguities + inject file paths, build enriched prompt.
- `pipelines/media.md` — Added `## Pipeline YAML` section: detect MIME type, route to voice/image/document processor (Whisper/Tesseract/pdftotext), write metadata JSON, index in memory.
- `coding/code-review.md` — Added `## Pipeline YAML` section: fetch git diff, run linter, workhorse LLM analysis (security/perf/maintainability/testing), compile report, approval gate, post.
- `coding/deploy.md` — Added `## Pipeline YAML` section: check staging health, run tests, flash preflight, show checklist, approval gate, deploy exec.
- `coding/testing.md` — Added `## Pipeline YAML` section: detect runner (pytest/npm/go/cargo), run suite with coverage, recall baseline, flash parse results, save coverage, report.

### Changed (T-L6-04 — Pipeline descriptions)
- `coding/git-pipelines.md` — Added `description:` field to `^pipeline-git` Lobster YAML.
- `coding/project-routing.md` — Added `description:` field to `^pipeline-project-routing` Lobster YAML. Also renamed `name:` from `project-router` to `project-routing` for consistency with block ID.
- All 10 new pipeline YAML blocks include `description:` as first field after `name:`.

### Verified
- `node build/scripts/build-config.js --only config` — 10/10 config blocks parse correctly (was 5/10 due to Pattern 4 bug). No parse errors except harmless `^config-blockname` from session-prompt.md documentation example. `dist/openclaw.json` has all 8 core keys: gateway, agents, channels, tools, hooks, plugins, cron, skills.
- `node build/scripts/build-config.js --only pipelines` — 38/38 pipelines produced. No duplicate block IDs.

---

## 2026-03-04 — Pipeline block tagging + cleanup pass

### Added
- 12 `^pipeline-*` block IDs across all pipeline/coding files (brief, email, health-check, skill-router, intent-finder, prompt-builder, media, git, code-review, deploy, testing, project-routing)

### Removed
- `daily-logs.md` — Misplaced redirect stub deleted (was L4-owned content)

### Changed
- `skills/inventory.md` — Fixed broken link: `core-pipelines` → `pipelines/_overview`
- `cross-layer-notes.md` — Resolved 3 notes: daily-logs deletion, inbound link fixes, BRAVE key naming

---

## 2026-03-04 — Full layer audit (session-prompt Phase 2–5)

### Added
- `CHANGELOG.md` — This file. Layer changelog created per session-prompt Phase 3 template.

### Changed
- `_overview.md` — Added `layer_name`, `layer_number`, `layer_slug`, `config_blocks`, `file_count`, `status_summary` frontmatter properties per CLAUDE.md § Frontmatter Properties. Added CHANGELOG to Pages table.

### Verified
- Pipeline split already complete: `pipelines/core-pipelines.md` (26K) → redirect stub + 7 individual pipeline files (`brief.md`, `email.md`, `health-check.md`, `skill-router.md`, `intent-finder.md`, `prompt-builder.md`, `media.md`)
- Coding workflow split already complete: `coding/workflows.md` (35K) → redirect stub + 5 individual workflow files (`git-pipelines.md`, `code-review.md`, `deploy.md`, `testing.md`, `project-routing.md`)
- All split files have proper frontmatter, H1, blockquote, and Up links
- Config blocks registered: `^config-tools`, `^config-plugins`, `^config-cron`, `^config-skills` all present in `config-reference.md`

### Cross-Layer Effects
- `00-INDEX.md` — Added L6 CHANGELOG link
- Open cross-layer notes remain: misplaced daily-logs.md (L4), inbound links from L1/L3 to old monolith files, SCAN re-anchoring (L5→L6), heartbeat drift detection (L4→L6)
