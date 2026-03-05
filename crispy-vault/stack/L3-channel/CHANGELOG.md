---
tags: [layer/channel, type/note, status/active]
---
# L3 — Channel Changelog

> All changes to this layer. Each session adds a dated entry.

**Up →** [[stack/L3-channel/_overview]]

---

## 2026-03-05 — Convert ASCII diagrams to Mermaid in telegram/chat-flow.md

### Changed
- `telegram/chat-flow.md` — Replaced ASCII box-art streaming mockup (lines ~203–227, `┌────┐` characters) with `sequenceDiagram` (Crispy → TG → User, three `editMessageText` calls showing block streaming pattern).
- `telegram/chat-flow.md` — Replaced Button Callbacks `flowchart TD` (two subgraphs: Creation Phase + Callback Phase) with `sequenceDiagram` (User, TG, Crispy, State as Lobster State; uses `Note over` for phase labels).
- `telegram/chat-flow.md` — Replaced Full Message Lifecycle `flowchart TD` (numbered nodes 1–9 + WAIT/TAP/RESOLVE) with `sequenceDiagram` (User as Marty, TG, Flash, Crispy, Mem; uses `alt`/`else` for ambiguous vs clear intent, `loop` keyword for streaming blocks).

---

## 2026-03-04 — Multi-instance channels + multi-bot docs + env var fixes

### Changed
- `config-reference.md` — Rewrote `^config-channels` for multi-instance support: `telegram` uses `${TELEGRAM_BOT_TOKEN_CRISPY}` (was `${TELEGRAM_BOT_TOKEN}`), added `telegram1` block for Wenting with `${TELEGRAM_BOT_TOKEN_WENTING}`, `discord` uses `${DISCORD_BOT_TOKEN_CRISPY}` (was `${DISCORD_BOT_TOKEN}`). Added multi-instance naming convention section, updated channel status table with instance counts. STATUS ✅.
- `discord/runbook.md` — Replaced `DISCORD_BOT_TOKEN` → `DISCORD_BOT_TOKEN_CRISPY`, `DISCORD_SERVER_ID` → `DISCORD_GUILD_ID` (all occurrences). Added "Multi-Bot Workspace Setup" section (isolated workspace creation, AGENTS.md, config additions).
- `discord/chat-flow.md` — Replaced `DISCORD_BOT_TOKEN` → `DISCORD_BOT_TOKEN_CRISPY`, `DISCORD_SERVER_ID` → `DISCORD_GUILD_ID` (all occurrences).
- `discord/_overview.md` — Replaced `DISCORD_BOT_TOKEN` → `DISCORD_BOT_TOKEN_CRISPY`. Updated config summary with multi-bot scaling note. Added "Multi-Agent Discord Architecture" section (channel→agent mapping table).
- `telegram/runbook.md` — Updated setup guide token name to `TELEGRAM_BOT_TOKEN_CRISPY`. Added "Multi-Bot Setup (Second Telegram Bot)" section (BotFather, env var, isolated workspace, config, test).

### Cross-Layer Effects
- `build/env-main.md` — Indexed token vars match new channel config names
- L2 `config-reference.md` — Agent bindings reference channel keys defined here

---

## 2026-03-04 — Block format standardization + Codex alias fix + cross-layer notes cleanup

### Changed
- `config-reference.md` — Reformatted `^config-channels` to COMMENT → BLOCK → ID pattern. Removed `json5` fence, using pure `json`. Moved metadata comments before code fence. (T-L3-06)
- `discord/chat-flow.md` — Replaced 5 occurrences of hardcoded "Codex" model name with alias `workhorse` (lines ~40, 499, 545, 878, 920 — Mermaid diagrams and ASCII mockups). (T-L3-05)
- `cross-layer-notes.md` — Deleted 1 resolved note (Integration Map). Marked T-L3-05 as tracked. Left L1 media.md informational note open.

### Verified
- T-L3-01 through T-L3-04 confirmed done per previous session CHANGELOG entries.
- No remaining "Codex" references in L3.

---

## 2026-03-04 — Link fix pass + cross-layer resolution

### Changed
- `telegram/pipelines.md` — Fixed broken link: `[[stack/L6-processing/pipelines/core-pipelines]]` → `[[stack/L6-processing/pipelines/_overview]]` (core-pipelines.md was split into individual files, resolving L6 cross-layer note)

### Cross-Layer Effects
- L1 `sandbox.md` and `runbook.md` — Fixed 3 broken links from `[[stack/L6-processing/coding/workflows]]` → `[[stack/L6-processing/coding/_overview]]` (workflows.md was split into individual files)
- L6 cross-layer note "Inbound links to core-pipelines.md" partially resolved (L3 links updated)

### Verified
- Config block `^config-channels` properly tagged and registered in `build/config-main.md`
- Channel Architecture section present with Telegram/Discord/Gmail roles
- All channel `_overview.md` files have frontmatter properties
- Cross-layer note "discord/chat-flow.md uses Codex" remains open (complex mermaid diagrams, deferred to Discord-focused session)

---

## 2026-03-04 — Full layer audit (session-prompt Phase 2–5)

### Added
- `CHANGELOG.md` — This file. Layer changelog created per session-prompt Phase 3 template.

### Changed
- `_overview.md` — Added `layer_name`, `layer_number`, `layer_slug`, `config_blocks`, `file_count`, `status_summary` frontmatter properties. Added Channel Architecture section documenting Telegram (orchestrator), Discord (council), Gmail (info gathering) roles. Trimmed Integration Map from ~280 lines of L2-owned content (model providers, auth summary, extensions, plugins, storage) to a compact channel-specific table with references to L2. Added CHANGELOG to Pages table.
- `telegram/_overview.md` — Added channel role frontmatter properties (`channel_name`, `channel_slug`, `channel_role`, `interaction_model`, `session_type`, `focus_modes`, `status_connection`). Added Architectural Role section.
- `discord/_overview.md` — Added channel role frontmatter properties. Added Architectural Role section (council/multi-agent pattern).
- `gmail/_overview.md` — Added channel role frontmatter properties. Added Architectural Role section (information gathering, category-aware memory writes).

### Cross-Layer Effects
- Integration Map trim removed L2-owned content (model providers, auth, extensions) — these now reference L2 `_overview.md` and `env.md` instead of duplicating.
- L3 cross-layer note "Integration Map duplicates L2-owned content" can be marked resolved.
- `00-INDEX.md` — Added L3 CHANGELOG link.
