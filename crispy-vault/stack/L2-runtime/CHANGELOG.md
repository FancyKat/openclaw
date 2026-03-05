---
tags: [layer/runtime, type/note, status/active]
---
# L2 — Runtime Changelog

> All changes to this layer. Each session adds a dated entry.

**Up →** [[stack/L2-runtime/_overview]]

---

## 2026-03-04 — Multi-bot agent bindings + workspace isolation

### Changed
- `config-reference.md` — Added `workspace` field to all agents in `^config-agents` list. Added `crispy-wenting` agent with `workspace-wenting`. Added `bindings` array mapping agents to channels (telegram→crispy, telegram1→crispy-wenting, discord→crispy). Added "Agent Bindings" section (binding table, scaling example with per-agent heartbeat override). Added "Workspace Isolation" section (directory layout per agent).

### Cross-Layer Effects
- L3 `config-reference.md` — Multi-instance channel config (telegram, telegram1, discord) maps to agent bindings via `agents.bindings`
- `build/env-main.md` — Indexed token vars (TELEGRAM_BOT_TOKEN_CRISPY, DISCORD_BOT_TOKEN_CRISPY) align with agent bindings

---

## 2026-03-04 — Block format standardization + env-template rewrite + cross-layer notes cleanup

### Changed
- `config-reference.md` — Reformatted `^config-agents` to COMMENT → BLOCK → ID pattern. Removed all inline `//` comments from JSON. Moved metadata comments before code fence. Changed fence language from `json5` to `json`. (T-L2-01)
- `cross-layer-notes.md` — Deleted all 4 resolved notes. File now minimal.
- `build/env-main.md` — Rewrote `^env-template` block with full self-documenting content: logical groupings (Core, Telegram, Tools & Search, Voice, Memory, Discord, Webhooks, Gmail, Skills), per-variable comments (where to get, format, tips), section dividers, header usage block. Moved `^env-template` block ID from heading to after closing fence per block ID convention. (T-L2-02b)
- `build/scripts/build-config.js` — Section 7: switched `.env.example` output to use `buildEnv()` (reads `^env-template`) instead of `buildEnvExample()`. Updated header comment for `.env.example` (safe to commit). (T-L2-02a)

### Verified
- `node build/scripts/build-config.js --only env` → produces `dist/.env.example` with full rich template. (T-L2-02c)

---

## 2026-03-04 — Cross-layer note resolution pass

### Changed
- `cross-layer-notes.md` — Resolved 2 open notes: (1) llm-task model aliases confirmed fixed by L6, (2) BRAVE_API_KEY naming confirmed resolved by L6.

### Verified
- Config block `^config-agents` properly tagged and registered in `build/config-main.md`
- Model aliases table current and consistent with config block
- All wikilinks clean, frontmatter properties present
- File count: 7 files (config-reference, env, gateway, models, runbook, CHANGELOG, cross-layer-notes)

---

## 2026-03-04 — Full layer audit (session-prompt Phase 2–5)

### Added
- `CHANGELOG.md` — This file. Layer changelog created per session-prompt Phase 3 template.

### Changed
- `_overview.md` — Added `layer_name`, `layer_number`, `layer_slug`, `config_blocks`, `file_count`, `status_summary` frontmatter properties per CLAUDE.md § Frontmatter Properties. Added CHANGELOG to Pages table.

### Cross-Layer Effects
- `00-INDEX.md` — Fixed .md extensions in L2 wikilinks (config-reference.md → config-reference, gateway.md → gateway, env.md → env, models.md → models, runbook.md → runbook). Added CHANGELOG link. Resolves L2 cross-layer note "00-INDEX.md has .md extensions in L2 wikilinks".
- L2 cross-layer note "llm-task allowedModels uses old alias names" remains open for L6 to resolve.
- L2 cross-layer note "BRAVE_API_KEY vs BRAVE_SEARCH_KEY" remains open for build layer.
