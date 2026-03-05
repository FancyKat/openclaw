---
tags: [status/draft, type/index]
---
# Changelog

All notable changes to the Crispy Kitsune vault.

---

## v1.0 — 2026-03-05 — Stable Baseline + Cleanup

### Version Bump
- Promoted from v0.013 (build 13) → **v1.0 (build 14)**
- `versions.json`: `production.current` 0 → 1, `build.current` 13 → 14
- New release snapshot: `releases/v1.0/` (dist copy of v0.013 baseline)

### Deleted (Retired Scaffolding)
- **`session-prompt.md`** — Worker session scaffolding retired; vault is stable
- **`manager-session-prompt.md`** — Manager session scaffolding retired
- **`versions.json.bak`** — Stale backup removed

### Deleted (Old Release Snapshots)
- **`releases/v0.001`** through **`releases/v0.012`** (11 folders) — Captured in git history; only v0.013 (promoted to v1.0) kept

### Changed
- **`CLAUDE.md`** — Replaced "Session Roles & Permission Boundaries" section with "Working Conventions" (simplified); added "Project Status" section (v1.0, next steps, skills); cleaned all `session-prompt.md`/`manager-session-prompt.md` references from Frontmatter Properties and Changelog Convention sections
- **`versions.json`** — Bumped production→1, build→14, added v1.0 release entry, trimmed releases list to v1.0 + v0.013

---

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

## [0.31.0] — 2026-03-04 — Manager Session: Skills, Build Fixes, A-B Testing Complete

### Added
- **`.claude/skills/`** — 10 skills (78 files) copied from Cowork for Claude Code worker access: openclaw-debugger, openclaw-context-engineer, drift-guardian, mcp-builder, skill-creator, openclaw-telegram-bot-skill, openclaw-pipeline-creator, engineering-system-design, engineering-code-review, operations-process-optimization
- **`session-prompt.md` T-L2-02** — New task: rewrite `^env-template` block with grouped sections, portal URLs, format hints, and tips

### Changed
- **`build/scripts/build-config.js`** — Removed `buildEnv()` call from section 7; env build now outputs only `dist/.env.example` (secrets stay out of `dist/`)
- **`CLAUDE.md`** — Updated env build outputs (removed `dist/.env`), added `.claude/skills/` to Source of Truth Paths, added task-scoped exception rule for worker build script edits, documented dual-environment skill loading
- **`session-prompt.md`** — Added skill loading instructions (`.claude/skills/{name}/SKILL.md`), fixed plugin skill names to match directory names (dashes not colons), added T-L2-02 with permission note for build script edit
- **`manager-session-prompt.md`** — Resolved skills blocker, completed A-B build testing (env/pipelines/focus), audited cross-layer notes (27 resolved, 6 open), updated source of truth paths, dual-environment skill docs

### Removed
- **`dist/.env`** — Stale file deleted; build no longer produces it

### A-B Build Testing Results
- Env: `--only env` → `dist/.env.example` ✅
- Pipelines: `--only pipelines` → 9/12 ✅ (3 missing due to extractBlocks regex bug)
- Focus: `--only focus` → 42/42 ✅

### Cross-Layer Notes Audit
- 27 resolved notes across L1–L7 (workers will strip during cleanup)
- 6 open notes across 4 threads (tracked in manager-session-prompt.md)

---

## [0.30.0] — 2026-03-04 — Full L1–L7 Audit Pass

### Added
- **`stack/L7-memory/memory-search.md`** — Search API Contract section with request/response JSON5 schemas, scoring formula, L5 integration table
- **`stack/L7-memory/config-reference.md`** — `^config-audit` block for `agents.defaults.auditLog` config
- **`stack/L4-session/context-files/_overview.md`** — Dual token budget callout (authoring targets vs window allocations)

### Changed
- **`stack/L7-memory/audit-log.md`** — Moved inline config to `config-reference.md` per vault rules
- **`stack/L7-memory/_overview.md`** — Added `^config-audit` to `config_blocks` frontmatter
- **`build/config-main.md`** — Registered `^config-audit` as §5b with transclusion section
- **`stack/L6-processing/pipelines/*.md`** + **`coding/*.md`** — Added 12 `^pipeline-*` block IDs (pipeline build: 0/12 → 12/12)
- **`stack/L1-physical/sandbox.md`**, **`runbook.md`** — Fixed broken links to split L6 files (`coding/workflows` → `coding/_overview`)
- **`stack/L3-channel/telegram/pipelines.md`** — Fixed broken link (`core-pipelines` → `pipelines/_overview`)
- **`stack/L6-processing/skills/inventory.md`** — Fixed broken link (`core-pipelines` → `pipelines/_overview`)

### Removed
- **`stack/L1-physical/_overview.md.bak`** — Leftover backup file deleted
- **`stack/L6-processing/daily-logs.md`** — Misplaced L4 redirect stub deleted

### Resolved Cross-Layer Notes
- L1: `.md` extensions in wikilinks
- L2: llm-task model aliases, BRAVE_API_KEY naming
- L4: dual token budget confusion
- L5→L7: search API contract documentation
- L6: daily-logs deletion, inbound link fixes, BRAVE key naming
- L7→L2: audit log config block formalized as `^config-audit`

### Build Impact
- Pipeline build: 0/12 → **12/12** ✅
- Config build: 9 sections → **10 sections** (added §5b Audit Log)

---

## [0.29.0] — 2026-03-04 — Build System: New Scaffolds + Context Fix + Focus Mode Build

### Added
- **`build/pipeline-main.md`** — Pipeline assembly scaffold registering 12 pipelines (7 core + 5 coding) from L6 source files, deploy target `dist/pipelines/*.lobster`
- **`build/focus-main.md`** — Focus mode assembly scaffold registering 42 blocks (7 categories × 6 block types) from L5 category files, deploy target `dist/focus/{category}/`

### Changed
- **`build/scripts/build-config.js`** — Fixed critical context prefix bug (`^ctx-soul-*` blocks now correctly resolve to SOUL.md instead of showing as unmapped); added focus mode builder (`dist/focus/{slug}/` with hat.md, tree.json, triggers.json, filter.json, compaction.md, speed.json per category); updated pipeline list to match pipeline-main.md (12 pipelines); fixed IDENTITY.md mapping (`identity` not `id`); added focus block coverage to audit mode
- **`build/build.sh`** — Added `--yes`/`-y` flag for non-interactive builds; release CHANGELOGs now pull real changes from root and layer changelogs instead of placeholder templates
- **`CLAUDE.md`** — Documented 5 scaffold files (was 3) with block pattern → scaffold → deploy target table; updated block ID list, build system description, source of truth paths, adding files instructions
- **`manager-session-prompt.md`** — Added all 5 scaffolds and both build scripts to Key Files You Manage table; added pipeline-main.md and focus-main.md to Source of Truth paths; updated L5/L6/L7 project state
- **`session-prompt.md`** — Added build scaffold mapping table to Phase 2c; updated L5 block registration to reference focus-main.md; added pipeline block tagging instructions with full table for L6 workers; updated Layer Quick Reference to show all block types per layer

### Build
- Context file build: 0/10 → **10/10** ✅ (was broken due to `ctx-` prefix mismatch)
- Focus mode build: **42/42** blocks across 7 categories
- Pipeline build: 0/12 (workers need to tag `^pipeline-*` blocks in L6 files)
- Config build: 9/9 ✅ (unchanged)

---

## [0.28.0] — 2026-03-04 — L7 Audit: Frontmatter Properties + Decomposition Verification

### Added
- **`stack/L7-memory/CHANGELOG.md`** — Layer changelog

### Changed
- **`stack/L7-memory/_overview.md`** — Added `layer_name`, `layer_number`, `layer_slug`, `config_blocks`, `file_count`, `status_summary` frontmatter properties; added CHANGELOG and cross-layer-notes to Pages table
- **`00-INDEX.md`** — Added L7 CHANGELOG link

### Verified
- `_overview.md` decomposition complete (318 lines, down from ~1,100)
- `audit-log.md` and `sqlite.md` both extracted with proper format
- Config block `^config-memory` registered in `config-reference.md`

---

## [0.27.0] — 2026-03-04 — L6 Audit: Frontmatter Properties + Split Verification

### Added
- **`stack/L6-processing/CHANGELOG.md`** — Layer changelog

### Changed
- **`stack/L6-processing/_overview.md`** — Added `layer_name`, `layer_number`, `layer_slug`, `config_blocks`, `file_count`, `status_summary` frontmatter properties; added CHANGELOG to Pages table
- **`00-INDEX.md`** — Added L6 CHANGELOG link

### Verified
- Pipeline split complete: `core-pipelines.md` → redirect stub + 7 individual files
- Coding workflow split complete: `workflows.md` → redirect stub + 5 individual files
- Config blocks `^config-tools`, `^config-plugins`, `^config-cron`, `^config-skills` all registered

---

## [0.26.0] — 2026-03-04 — L5 Audit: Category Expansion (7×7) + Frontmatter Properties

### Added
- **`stack/L5-routing/CHANGELOG.md`** — Layer changelog
- **42 new category focus files** (7 categories × 6 new files each): `triggers.md`, `focus-tree.md`, `pipelines.md`, `conversation-flows.md`, `speed-baselines.md`, `memory-filter.md`, `drift-signals.md` for cooking, coding, finance, fitness, habits, pet-care, design

### Changed
- **`stack/L5-routing/_overview.md`** — Added frontmatter properties; updated `file_count` from 15 to 64; added CHANGELOG to Pages table
- **7 category `_overview.md` files** — Trimmed to index format with category-specific frontmatter properties, `^hat-{slug}` block IDs, Pages tables
- **`stack/L5-routing/cross-layer-notes.md`** — Added note for new transclusion block IDs ready for upstream consumption
- **`00-INDEX.md`** — Added L5 CHANGELOG link + all 56 category sub-file links

### Block IDs Added
- `^hat-*`, `^triggers-*`, `^tree-*`, `^filter-*`, `^compaction-*`, `^speed-*` across all 7 categories

---

## [0.25.0] — 2026-03-04 — L4 Audit: Frontmatter Properties + Context Verification

### Added
- **`stack/L4-session/CHANGELOG.md`** — Layer changelog

### Changed
- **`stack/L4-session/_overview.md`** — Added `layer_name`, `layer_number`, `layer_slug`, `file_count`, `status_summary` frontmatter properties; added CHANGELOG to Pages table
- **`00-INDEX.md`** — Added L4 CHANGELOG link

### Verified
- `build/context-main.md` transclusion scaffold — 47 `^ctx-*` block IDs across 10 context-files all match

---

## [0.24.0] — 2026-03-04 — L3 Audit: Channel Architecture + Integration Map Trim

### Added
- **`stack/L3-channel/CHANGELOG.md`** — Layer changelog

### Changed
- **`stack/L3-channel/_overview.md`** — Added frontmatter properties, Channel Architecture section (Telegram orchestrator, Discord council, Gmail info gathering), trimmed Integration Map from ~280 lines to compact channel-specific table with L2 references
- **`stack/L3-channel/telegram/_overview.md`** — Added channel role frontmatter properties and Architectural Role section
- **`stack/L3-channel/discord/_overview.md`** — Added channel role frontmatter properties and Architectural Role section
- **`stack/L3-channel/gmail/_overview.md`** — Added channel role frontmatter properties and Architectural Role section
- **`stack/L3-channel/cross-layer-notes.md`** — Marked "Integration Map duplicates L2 content" as resolved
- **`00-INDEX.md`** — Added L3 CHANGELOG link

---

## [0.23.0] — 2026-03-04 — L2 Audit: Frontmatter Properties + Link Fixes

### Added
- **`stack/L2-runtime/CHANGELOG.md`** — Layer changelog created per session-prompt Phase 3 template

### Changed
- **`stack/L2-runtime/_overview.md`** — Added `layer_name`, `layer_number`, `layer_slug`, `config_blocks`, `file_count`, `status_summary` frontmatter properties; added CHANGELOG to Pages table
- **`stack/L2-runtime/cross-layer-notes.md`** — Marked "00-INDEX.md .md extensions" note as resolved
- **`00-INDEX.md`** — Fixed .md extensions in L2 wikilinks; added L2 CHANGELOG link

---

## [0.22.0] — 2026-03-04 — L1 Audit: Remove Skill Reference + Frontmatter Properties

### Removed
- **`stack/L1-physical/l1-skill-reference.md`** — Redundant file (255 lines) deleted; content already covered by individual L1 source files (hardware.md, sandbox.md, network.md, media.md, runbook.md, config-reference.md)

### Added
- **`stack/L1-physical/CHANGELOG.md`** — Layer changelog created per session-prompt Phase 3 template

### Changed
- **`stack/L1-physical/_overview.md`** — Added `layer_name`, `layer_number`, `layer_slug`, `config_blocks`, `file_count`, `status_summary` frontmatter properties; removed l1-skill-reference from Pages table
- **`stack/L1-physical/filesystem.md`** — Updated directory listing: replaced l1-skill-reference entry with CHANGELOG.md
- **`00-INDEX.md`** — Removed l1-skill-reference link, added CHANGELOG link

---

## [0.21.0] — 2026-03-03 — CLAUDE.md + 3-Tier Model Architecture

### Added
- **CLAUDE.md** — project rules, conventions, file template, and growth plan for maintaining the vault across sessions
- **3-tier model architecture** — researcher (`anthropic/claude-opus-4-6` with extended thinking), workhorse general (`anthropic/claude-sonnet-4-5` for crispy), workhorse code (`openai/gpt-5.2` for crispy-code)
- **Per-agent model overrides** in `agents.list` — each agent gets its own primary workhorse with shared fallback chain
- **`OPENAI_API_KEY`** added to env blueprint (§1 Required) for direct GPT-5.2 auth
- **Dataview frontmatter** for model config in L2 `_overview.md`

### Changed
- **Model config** — migrated from single primary (`anthropic/claude-opus-4-6`) to 3-tier architecture across 16 files
- **`build/env-main.md`** — added `OPENAI_API_KEY`, updated delivery mechanisms and build status counts
- **`stack/L7-memory/decisions-log.md`** — updated model and auth decisions to reflect 3-tier architecture
- **`00-INDEX.md`** — added CLAUDE.md to Quick Links

---

## [0.20.0] — 2026-03-03 — Per-Layer Config References + OpenClaw Spec Compliance

### Added
- **Per-layer `config-reference.md` files** — single source of truth for each layer's openclaw.json config blocks:
  - `stack/L1-physical/config-reference.md` — `^config-gateway`, `^config-hooks`
  - `stack/L2-runtime/config-reference.md` — `^config-agents` (models inside agents per spec)
  - `stack/L3-channel/config-reference.md` — `^config-channels`
  - `stack/L6-processing/config-reference.md` — `^config-tools`, `^config-plugins`, `^config-cron`, `^config-skills`
  - `stack/L7-memory/config-reference.md` — `^config-memory`
- **`validateOpenClawSchema()`** in build-config.js — warns on non-compliant keys/structures
- **Dedup logic** in JSON5 builder — prevents duplicate keys in config output

### Changed
- **`build/config-main.md`** — rewritten as assembly guide with Obsidian transclusions only (no `^config-*` blocks)
- **`build/scripts/build-config.js`** — removed `_version`/`_built` meta keys, removed top-level `models`/`auth` keys, updated property order
- **OpenClaw spec field name fixes:**
  - `groupPolicy` → `groups: { "*": { requireMention: true } }`
  - `streamMode` → `streaming: "partial"`
  - `maxConcurrent` → `maxConcurrentRuns`
- **Context file headers** — HTML comments replaced with clean `# Title` headers
- **Model structure** — moved from top-level `"models"` key to `agents.defaults.model.primary` + `agents.defaults.model.fallbacks` + `agents.defaults.models` (alias definitions)
- **00-INDEX.md** — fixed dead link to deleted `config.md`, added all `config-reference.md` entries

### Removed
- `stack/L2-runtime/config.md` — replaced by per-layer `config-reference.md` files
- Top-level `_version`, `_built`, `models`, `auth` keys from openclaw.json output
- 8 duplicate `^config-*` block IDs that existed across multiple files

### Build
- **v0.002** released — zero duplicates, zero schema warnings, all validation checks passed

---

## [0.19.0] — 2026-03-03 — Vault Consolidation + Versioned Build System

### Changed
- **Vault consolidated** — 152 stack files merged to 55 active files across 7 layers (zero content loss)
- **Archives removed** — 96 archived files deleted; originals recoverable from git commit `278bec1`
- **Build system** — `build/build.sh` orchestrates versioned releases with per-layer tracking
- **`build-config.js` extended** — dual output (openclaw.json5 + openclaw.json), .env.example, LAYERS-MANIFEST.json
- **Version frontmatter** — all 7 layer `_overview.md` files now track `version_full`, `version_changes`, `version_last_build`
- **`versions.json`** — master version metadata at project root

### Added
- `build/build.sh` — versioned build orchestrator (`--layers`, `--force`, `--auto`, `--commit`, `--prod`, `--status`)
- `build/git-hooks.sh` — git validation, commit helpers, pre-commit hooks, change detection
- `build/version-dashboard.md` — Obsidian Dataview dashboard with live layer versions and file status
- `releases/` directory for versioned build outputs (format: `v{PROD}.{BUILD}+{LAYERS}`)

---

## Build Releases

Starting from this version, each build produces a versioned release in `releases/`. See [[build/version-dashboard]] for live tracking.

---

## [0.18.0] — 2026-03-02 — Visual Polish: CSS Theme + 27 New Diagrams

### Added
- **`crispy-kitsune.css`** — Full vault theme with 22 sections:
  - Layer-specific accent colors on H1 borders, sidebar folders, tab headers, and Mermaid diagram bars
  - Color-coded tag pills (status, layer, channel, topic namespaces)
  - Custom callout types: `[!L1]`–`[!L7]`, `[!pipeline]`, `[!hook]`, `[!config]`, `[!security]`, `[!todo]`, `[!crispy]`
  - Styled Mermaid containers with gradient accent bars, responsive SVGs, rounder nodes
  - Code block language tints (JSON = amber, bash = green, YAML = purple)
  - Dark mode overrides for all Mermaid node colors
  - Table hover highlighting, checkbox styling, list bullet colors, search highlighting
- **27 new Mermaid flowcharts** added to files that had none:
  - L1 (3): hardware.md, hardware-guide, media-guide
  - L2 (2): env.md, config-audit.md
  - L3 (5): telegram/conversation-flows, gmail/privacy-security, email-pipeline-guide, notification-rules-guide, pipeline-quick-actions-guide
  - L4 (9): all bootstrap docs (agents-md, soul-md, tools-md, identity-md, user-md, heartbeat-md, boot-md, bootstrap-md, daily-logs)
  - L5 (3): output-validation-guide, input-sanitization-guide, message-routing-guide
  - L6 (5): skills/config, skills/authoring, skills/builders, pipelines-guide, skills-guide

### Changed
- **Hardware status indicators** — CPU and Memory show degraded status visually in the new hardware diagram
- **Mermaid diagram count** — vault now has 360+ Mermaid blocks across 120+ files (up from 336 across 95)

---

## [0.17.0] — 2026-03-02 — Dead File Cleanup + Tag Normalization

### Removed
- **9 empty L4 bootstrap guide stubs** (6-line shells with no content)
- **2 redirect files** (notify-pipeline-guide.md, media-pipeline-guide.md)
- **2 legacy bootstrap/ files** (_overview.md, files.md) + bootstrap/ folder
- **1 bootstrap guides _overview.md** (all referenced stubs deleted)
- Updated L4 `_overview.md` and `guides/_overview.md` to remove dead links

### Fixed (Tag Normalization)
- **2 guide files**: Added missing `channel/telegram` and `channel/discord` tags
- **3 pipeline files**: Standardized `type/reference` → `type/pipeline`, removed redundant `topic/pipeline`
- **38 files**: Added missing `topic/` tags for better Obsidian graph navigation (100% topic coverage)

---

## [0.16.0] — 2026-03-02 — Dataview Integration + Live File Review Tables

### Added
- **Dataview plugin support** — all file review tables and vault statistics are now live queries
- **`build/dataview-setup.md`** — install guide for Dataview plugin with query pattern reference
- **Last Modified column** — every layer file review table now shows `file.mtime` for tracking changes
- **Vault dashboard** in `00-INDEX.md` — status overview, recently modified files, files needing work

### Changed
- **All 7 layer `_overview.md` files** — static file review tables replaced with live Dataview queries
- **Section headers renamed** — "Marty TODO" → "L# File Review (Live)" across all layer overviews
- **`stack/L1-physical/filesystem.md`** — vault statistics converted to live Dataview queries with static fallback
- **L3 file review** includes dynamic Channel column (Telegram/Discord/Gmail/Core)
- **L4 file review** includes dynamic Category column (Core/Bootstrap/Guide) with legacy note
- **L6 file review** includes dynamic Category column (Core/Coding/Pipeline/Skill)

---

## [0.15.0] — 2026-03-02 — Vault Audit + Status Maturity + Hardware Finalized

### Added
- **Marty TODO checklists** in every layer `_overview.md` (L1-L7) — file review tracking per layer
- **VAULT-AUDIT.md** — Full vault health check with maturity assessment and recommendations
- **Hardware future upgrades** — Compatible GPU options (RTX 4070 Ti SUPER through 5090), CPU RMA guidance, SSD vector DB setup guide in `L1-physical/hardware.md`
- **SSD vector database note** — 870 EVO 1TB identified as dedicated Qdrant storage volume

### Changed (Status Maturity)
- **45 files promoted** from `status/draft` → `status/review` (substantial content, ready for live verification)
- **2 files promoted** to `status/finalized`:
  - `CHANGELOG.md` — accurate historical record
  - `stack/L1-physical/hardware.md` — specs confirmed, known issues documented, upgrades listed
- **New status model** proposed: planned → draft → review → finalized

### Fixed (Tag Cleanup)
- **9 files**: `topic/pipelines` normalized to `topic/pipeline` (singular)
- **1 file**: `project-routing.md` type corrected (`type/guide` → `type/reference`)
- **2 files**: Orphan tags fixed (bare `research`, `memory`, `mem0` → proper `topic/` namespace)
- **1 file**: Malformed `<tags>`, `<relevant>` placeholders replaced with real tags

### Verified
- `media-inbound-flow.md` confirmed in correct location (L1 — cross-layer tags handle graph)
- 7-layer CKS model reviewed — no merges or splits needed (see audit notes)

---

## [0.14.0] — 2026-03-02 — The Great Integration

### Added
- **`build/` folder** with comprehensive install guide:
  - `build/README.md` — 7-phase install guide with all prereq commands
  - `build/.env.example` — Annotated environment variable template

### Changed (Template → L4 Integration)
- All 10 template files from `setup-install/templates/` integrated into corresponding L4 session files:
  - `agents-md.md` — added Content Guide table (include/exclude)
  - `boot-md.md` — added BOOT.md vs BOOTSTRAP.md comparison table
  - `bootstrap-md.md` — added Open Questions section
  - `heartbeat-md.md` — added Content Guide table + Related Pipeline reference
  - `identity-md.md` — added "What Bootstrap Refines" section
  - `tools-md.md` — added Content Guide table
  - `user-md.md` — added Content Guide table
  - `memory-md.md` — added Memory Hierarchy mermaid diagram
  - `soul-md.md` — template reference removed (content already present)
  - CONFIG.md template → full annotated config reference in `stack/L2-runtime/config.md`

### Changed (Setup Docs → Stack Integration)
- `setup-install/env-setup.md` → integrated into `stack/L2-runtime/env.md` (key acquisition guide, security, troubleshooting)
- `setup-install/model-routing.md` → integrated into `stack/L2-runtime/models.md` (task routing diagram, auth profiles, decisions)
- `setup-install/memory-planning.md` → integrated into `stack/L7-memory/_overview.md` (4 methods comparison, session lifecycle, setup priority)
- `setup-install/plugin-setup.md` → integrated into `stack/L6-processing/tools.md` (Lobster engine, llm-task plugin)
- `setup-install/browser-tools.md` → integrated into `stack/L6-processing/tools.md` (CDP tool, snapshot modes, profiles)
- `setup-install/pre-onboard-checklist.md` → consolidated into `build/README.md`
- `setup-install/seed-workspace.md` → consolidated into `build/README.md`
- `setup-install/_overview.md` → consolidated into `build/README.md`
- `setup-install/.env.example` → moved to `build/.env.example`

### Removed
- **`setup-install/` folder** (21 files) — all content integrated into stack layers and build/
- **`setup-install/templates/` subfolder** (11 files) — all template content merged into L4 files
- All `**Template →**` references removed from L4 bootstrap files

### Updated
- `00-INDEX.md` — replaced Setup & Install section with Build & Install, updated file counts
- All `[[setup-install/...]]` wikilinks updated across the vault

---

## [0.13.1] — 2026-03-02 — INDEX Cleanup

### Removed
- **Complete File Inventory** section from 00-INDEX.md — all ~188 files are already linked with descriptions in the categorized sections above, making the flat inventory redundant

---

## [0.13.0] — 2026-03-02 — Vault Audit + Env Cleanup + Install Checklist

### Fixed (Vault Audit)
- **442 broken wikilinks** fixed across 91+ files:
  - 138 template paths (`[[templates/X]]` → `[[setup-install/templates/X]]`)
  - 41 prereqs paths (`[[prereqs/X]]` → correct new locations)
  - 147 short guides/skills/pipelines paths (now use full `[[stack/...]]` format)
  - 31 dead architecture/diagram links removed
- **5 frontmatter tag fixes**:
  - L5-routing/conversation-flows.md, message-lifecycle.md — added `layer/routing`
  - L7-memory/decisions-log.md, open-questions.md — added `layer/memory`
  - L3-channel/gmail/_overview.md — `type/reference` → `type/index`
- **00-INDEX.md file inventory** corrected:
  - Gmail section updated (setup/email-pipeline/notification-rules → webhook-flow/email-triage/privacy-security)
  - Added media-inbound-flow.md to L1, media-sort.md to L6, decision-trees-guide to Telegram
  - File counts updated (~188 total)

### Changed (Env & Keys)
- `stack/_overview.md` secrets diagram — added Discord, Brave, ElevenLabs, Mem0, GOG
- `stack/L2-runtime/_overview.md` .env block — replaced stale direct API keys with correct tiered list (required/implement now/optional)
- `setup-install/env-setup.md` — moved Discord + Mem0 from "Future" to "Recommended", added GOG to Optional
- Fixed stale `prereqs/04-config-audit` reference in L2 overview

### Changed (Install Checklist)
- `setup-install/pre-onboard-checklist.md` — complete rewrite as link-based checklist
  - Each step links to the relevant deep-dive file instead of duplicating content
  - Bootstrap Phase 3 now has template + deep-dive columns per file
  - Added Phase 5 sections for Discord, Gmail hooks, media pipeline, BOOT.md
  - Added post-install verification checklist

---

## [0.12.0] — 2026-03-02 — Bootstrap Files Split + Hooks Integration

### Added
- **Individual bootstrap context file docs** — each context file gets its own deep-dive at L4 root level:
  - `stack/L4-session/agents-md.md` — ① AGENTS.md operating contract
  - `stack/L4-session/soul-md.md` — ② SOUL.md personality & values
  - `stack/L4-session/tools-md.md` — ③ TOOLS.md capability inventory
  - `stack/L4-session/identity-md.md` — ④ IDENTITY.md identity card
  - `stack/L4-session/user-md.md` — ⑤ USER.md human profiles
  - `stack/L4-session/memory-md.md` — ⑥ MEMORY.md long-term memory
  - `stack/L4-session/heartbeat-md.md` — ⑦ HEARTBEAT.md health check
  - `stack/L4-session/daily-logs.md` — ⑧ Daily logs session journal
  - `stack/L4-session/bootstrap-md.md` — ⑨ BOOTSTRAP.md first-run ritual
  - `stack/L4-session/boot-md.md` — BOOT.md startup hook + dashboard
  - `stack/L4-session/bootstrap-config.md` — Shared config, limits, dependency graph, checklist

### Changed
- `stack/L4-session/_overview.md` — Rewritten: flat file structure, hooks section, updated page tables
- `00-INDEX.md` — Updated L4 section with individual context file links, updated file inventory count
- `bootstrap/files.md` and `bootstrap/_overview.md` marked as legacy (content preserved, replaced by flat files)

### Added (Hooks)
- Hooks section in L4 overview documenting gateway-level hook triggers (media-sort, Gmail webhook)
- Hook lifecycle note: hooks fire before context assembly, zero LLM tokens
- Context assembly diagram now shows hook check before bootstrap injection

---

## [0.11.0] — 2026-03-02 — Media Hook Pipeline + Session Templates + Coding Lifecycle

### Added
- **4-layer media inbound system** (hook → agent → boot → cron):
  - `stack/L1-physical/media-inbound-flow.md` — Full flow diagram showing how media lands and gets sorted
  - `stack/L6-processing/pipelines/media-sort.md` — Gateway-level hook pipeline with per-type routing + quarantine for unknowns
  - Quarantine system for unrecognized/suspicious files (MIME mismatch, double extensions, executables, oversized)
  - media-catchup.lobster (cron every 30 min) and media-cleanup.lobster (cron daily 2am) designs

- **Session templates** — 6 session types with different boot visuals and focus:
  - `stack/L4-session/session-templates.md` — Coding, Research, Planning, Debug, Media, Chat
  - BOOT.md detection logic (explicit trigger, project detection, quarantine check, error detection)
  - Token budget allocation per session type
  - Mid-session type switching

- **Coding session lifecycle**:
  - `stack/L4-session/coding-session-lifecycle.md` — Feature boundaries, PROJECT-STATUS.md, boot visuals
  - BOOT.md dashboard showing project, branch, task progress, blockers, quick actions
  - Feature A → Feature B transition flow with session reset

### Changed
- `stack/L4-session/_overview.md` — Added session templates, coding lifecycle, and bootstrap failure modes table
- `stack/L7-memory/open-questions.md` — Added BOOT.md and media pipeline open questions
- `00-INDEX.md` — Added 4 new files

---

## [0.10.0] — 2026-03-02 — 4-Stage Classification Pipeline

### Added
- **4-stage intent classification pipeline** replacing simple triage:
  1. Trigger word scan (zero-token fast path)
  2. Triage model classification
  3. Prompt enrichment
  4. Message routing decision
  
- New L5-routing files:
  - `stack/L5-routing/trigger-words.md` — Zero-token keyword classification (covers 60-70% of messages)
  
- Rewritten L5-routing file:
  - `stack/L5-routing/intent-classifier.md` — 5 intent types (informational, assistance, action, creative, meta) layered on top of existing 8 intent classes

- New L6-processing/pipelines files:
  - `stack/L6-processing/pipelines/intent-finder.md` — Pipeline that chains trigger scan + triage model (replaces pure triage for deterministic routing)
  - `stack/L6-processing/pipelines/prompt-builder.md` — Backend prompt enrichment pipeline that resolves ambiguities, injects file paths, suggests approach before agent loop

### Changed
- `stack/L5-routing/message-routing.md` — Updated with new classification pipeline section showing trigger words → triage → prompt builder → router flow
- `stack/L5-routing/_overview.md` — Added reference to trigger-words.md in pages table
- `stack/L6-processing/pipelines/_overview.md` — Added references to intent-finder.md and prompt-builder.md in pipeline inventory and pages table

---

## [0.9.0] — 2026-03-02 — File Reorganization Complete

### Added
- Gmail channel folder created with structured organization:
  - `stack/L3-channel/gmail/_overview.md` — Gmail integration overview
  - `stack/L3-channel/gmail/setup.md` — Gmail setup and authentication
  - `stack/L3-channel/gmail/email-pipeline.md` — Email processing pipeline
  - `stack/L3-channel/gmail/notification-rules.md` — Gmail notification rules
  - `stack/L3-channel/gmail/guides/_overview.md` — Gmail guides index
  - `stack/L3-channel/gmail/guides/gmail-setup-guide.md` — Gmail setup guide
  - `stack/L3-channel/gmail/guides/email-pipeline-guide.md` — Email pipeline guide
  - `stack/L3-channel/gmail/guides/notification-rules-guide.md` — Notification rules guide
  - `stack/L3-channel/gmail/guides/gmail-debug-guide.md` — Gmail debugging guide

### Changed
- File reorganization across stack layers:
  - `message-lifecycle.md` moved from stack root to `stack/L5-routing/`
  - `conversation-flows.md` moved from stack root to `stack/L5-routing/`
  - `decisions-log.md` moved from stack root to `stack/L7-memory/`
  - `open-questions.md` moved from stack root to `stack/L7-memory/`
- Decision trees split and restructured:
  - Generic decision tree core moved to `stack/L3-channel/decision-trees.md`
  - Channel-specific decision tree guides created:
    - `stack/L3-channel/telegram/guides/decision-trees-guide.md`
    - `stack/L3-channel/discord/guides/decision-trees-guide.md`
- Old monolithic `gmail.md` replaced with structured `gmail/` folder
- Updated layer overview pages to reference newly relocated files:
  - `stack/L5-routing/_overview.md` — References message-lifecycle.md and conversation-flows.md
  - `stack/L7-memory/_overview.md` — References decisions-log.md and open-questions.md
  - `stack/_overview.md` — Removed root-level references to relocated files
- Updated 00-INDEX.md:
  - Moved message-lifecycle.md and conversation-flows.md to L5-routing section
  - Moved decisions-log.md and open-questions.md to L7-memory section
  - Added gmail/ folder section with all 9 files
  - Added decision-trees.md to L3-channel core files
  - Removed old gmail.md entry

---

## [0.8.0] — 2026-03-02 — Core vs Guide Split Complete

### Added
- Core vs Guide split completed across all 7 layers (L1-L7)
- All guide files renamed to `<name>-guide.md` convention
- Per-channel guide folders added to L3
  - `stack/L3-channel/telegram/guides/` — Telegram-specific guides
  - `stack/L3-channel/discord/guides/` — Discord-specific guides
- L5-routing guides created
  - `stack/L5-routing/guides/message-routing-guide.md` — Message routing deep dive
  - `stack/L5-routing/guides/guardrails-guide.md` — Guardrails framework guide
  - `stack/L5-routing/guides/input-sanitization-guide.md` — Input sanitization patterns
  - `stack/L5-routing/guides/output-validation-guide.md` — Output validation guide
- New stack-level documents:
  - `stack/message-lifecycle.md` — 10 situational flowcharts covering message flow from entry to exit across all layers
  - `stack/conversation-flows.md` — 6 conversation flow types, user profiles, SMART goals framework, memory categorization system
- Voice guide extracted from voice-pipeline.md
  - `stack/L3-channel/guides/voice-guide.md` — Voice integration guide

### Changed
- All L1-L7 guides now follow `-guide.md` naming convention
- L3 guides reorganized: general guides in `L3-channel/guides/`, channel-specific in `telegram/guides/` and `discord/guides/`

---

## [0.7.0] — 2026-03-02 — Voice, Media & Tags

### Added
- `stack/L3-channel/voice-pipeline.md` — Full STT → agent → TTS pipeline (Telegram, Discord, phone)
- `stack/L1-physical/media-storage.md` — Media filesystem (inbound/outbound/cache/archive)
- `stack/L6-processing/pipelines/media-pipeline.md` — Media processing + cleanup pipeline
- `stack/L3-channel/telegram/media-handling.md` — Telegram-specific media (voice, photo, video, docs)
- `stack/L3-channel/discord/media-handling.md` — Discord-specific media (attachments, voice channels)
- `setup-install/.env.example` — Standalone .env template file
- Comprehensive YAML frontmatter tags on ALL 146 .md files (type, layer, topic, status, channel)

### Changed
- `stack/L1-physical/filesystem.md` — Complete rewrite with updated vault tree + media storage + vault statistics
- `stack/L1-physical/_overview.md` — Added media storage to layer diagram and pages table
- `00-INDEX.md` — Added voice pipeline, media handling, and media-pipeline entries

### Removed
- `projects/` folder — working within stack/ instead

---

## [0.6.0] — 2026-03-02 — The Great Cleanup

### Added
- `setup-install/` — Top-level folder for all pre-boot setup (env, plugins, model routing, templates, seed script)
- `guides/` subfolders in every stack layer — deep-dive how-to guides live alongside their layer
- `CHANGELOG.md` — This file
- `stack/open-questions.md` and `stack/decisions-log.md` — Planning docs moved into stack

### Changed
- Vault reduced to 4 top-level items: `setup-install/`, `stack/`, `00-INDEX.md`, `CHANGELOG.md`
- All legacy guides migrated into `stack/L[N]/guides/` per layer
- All architecture docs migrated into appropriate stack layer guides
- All pipeline docs migrated into `stack/L6-processing/` and `stack/L3-channel/guides/`
- All skill docs migrated into `stack/L6-processing/skills/`
- All diagram content merged into stack pages
- All prereq docs migrated into `setup-install/`
- All template files migrated into `setup-install/templates/`

### Removed
- `architecture/` — content in stack layers
- `brainstorm/` — moved to `stack/`
- `diagrams/` — merged into stack pages
- `guides/` — distributed to layer guides/
- `pipelines/` — in `stack/L6-processing/`
- `prereqs/` — in `setup-install/`
- `scripts/` — in `setup-install/`
- `skills/` — in `stack/L6-processing/skills/`
- `templates/` — in `setup-install/templates/`

---

## [0.5.0] — 2026-03-02 — CKS Stack

### Added
- 7-layer Crispy Kitsune Stack (CKS) model inspired by OSI
- `stack/` folder with L1-Physical through L7-Memory
- 58 stack sub-pages covering all system components
- `_overview.md` in every folder for navigation

---

## [0.4.0] — 2026-03-02 — Skills & Pipelines

### Added
- 14 skill pack documentation files
- Guardrails safety architecture (Phase 1-3)
- Pipeline designs: brief, email, git, health-check, skill-router
- Telegram pipeline patterns: approve-deny, exec-approve, decision-tree, quick-actions

---

## [0.3.0] — 2026-03-01 — Architecture & Diagrams

### Added
- 9 Mermaid diagrams (onboard, relationships, channels, chat flows, lifecycle, config, buttons, routing)
- 7 architecture documents (topology, agent design, integrations, research, workspace, skills, decision trees)
- 7 prerequisite documents

---

## [0.2.0] — 2026-03-01 — Guides & Templates

### Added
- Channel guides (Telegram, Discord)
- Config guides (env, gateway, openclaw.json)
- Infrastructure guides (hardware, workspace, sessions, memory systems, pipelines, skills)
- Bootstrap guides for all 9 workspace files
- 10 bootstrap template files + master CONFIG template

---
