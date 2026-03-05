# Crispy Kitsune Vault — Project Rules

## Hard Constraints
- Config JSON goes ONLY in `config-reference.md` files. The build system ignores everything else.
- Context file directives go ONLY in `stack/L4-session/context-files/*.md`. Never edit `build/context-main.md` directly — it assembles via transclusion (`![[...#^block-id]]`) from the individual files.
- Never change block IDs (`^config-*`, `^ctx-*`, `^env-*`, `^pipeline-*`, `^mode-*`, `^tree-*`, `^triggers-*`, `^filter-*`, `^compaction-*`, `^speed-*`) without updating the appropriate `-main` scaffold and `build/scripts/build-config.js`.
- Every new file MUST be linked from both `00-INDEX.md` and its parent `_overview.md` — unlinked files are invisible.
- Model strings live in `stack/L2-runtime/config-reference.md` only. Never duplicate them elsewhere.
- Env vars live in `build/env-main.md` only. Adding one requires updating that file, its `.env Template` section, and `build/README.md`.

## Project Status

**Version:** v1.0 (build 14) — stable baseline, tested on Mac
**Architecture:** L1–L7 vault builder → `dist/openclaw.json` + context/pipeline/focus artifacts
**Next:** Feature development on `crispy-onboard-builder` branch — interactive onboarding builder
**Feature goal:** Interactive onboarding builder — guides new users through bot count, env vars, security/sandbox config before first gateway start. Target: upstream PR to openclaw.

**Keep for reference:** `releases/v1.0/` — last known-good dist snapshot
**Skills:** Loaded from a separate private repo. If `.claude/skills/` is empty, clone it before starting work.

## Integration Context

This vault lives at `crispy-vault/` inside a fork of `openclaw/openclaw` at `FancyKat/openclaw`.

**Repo layout (from repo root):**
```
crispy-claw/
├── src/, extensions/, apps/   ← upstream openclaw code (don't touch unless on feature branch)
├── crispy-vault/               ← this vault (you are here)
│   ├── build/scripts/          ← build assembler (run with: node build/scripts/build-config.js)
│   ├── dist/                   ← generated output (not committed, rebuild anytime)
│   ├── releases/v1.0/          ← committed snapshot of last known-good dist
│   ├── stack/                  ← L1–L7 layer files
│   └── test/build.test.js      ← run with: node test/build.test.js
└── .github/workflows/
    ├── ci.yml                  ← upstream CI (don't touch)
    └── crispy-vault.yml        ← vault CI (triggers on crispy-vault/** changes)
```

**Running the build:** Always `cd` into `crispy-vault/` first — the build script resolves paths relative to its own location.
```bash
cd crispy-vault
node build/scripts/build-config.js        # full build
node build/scripts/build-config.js --audit  # block coverage check
node test/build.test.js                   # validate output
```
Or use npm scripts: `npm run build`, `npm run audit`, `npm test`

**Git remotes:**
- `origin` → `FancyKat/openclaw` (your fork, push here)
- `upstream` → `openclaw/openclaw` (the real repo, never push here)

**Staying current with upstream:**
```bash
git fetch upstream
git checkout main
git rebase upstream/main   # keep fork's main current
git checkout crispy-onboard-builder
git rebase main            # keep feature branch current
```

**Branch strategy:**
- `main` — fork's main, tracks upstream closely. Vault lives here.
- `crispy-onboard-builder` — feature work (TypeScript in `src/`). Branch off main, PR to upstream when ready.

**CLAUDE.md stack:** Opening from `crispy-vault/` loads this file + the parent `AGENTS.md` (openclaw's coding rules). Opening from `crispy-claw/` root loads only `AGENTS.md`. Work on vault files from `crispy-vault/`, work on feature code from `crispy-claw/`.

**Known issue:** `dist/focus/{cooking,coding,design,fitness}/filter.json` contain prose instead of JSON — pre-existing bug in L5 `^filter-*` source blocks. Tracked, not urgent.

## Layer Cascade (Source of Truth)
- Layers build upward (L1 → L7). When a property appears in multiple layers, the **lowest layer** that defines it is the source of truth.
- Higher layers reference down, never duplicate. Use aliases (e.g. `researcher` instead of `claude-opus-4-6`) or wikilinks to the owning layer's file.
- Example: Model strings are owned by L2 (`config-reference.md`). L4/L6/L7 should use aliases or `[[stack/L2-runtime/models]]` references — not hardcoded model strings.
- When editing a property, update the owning layer first, then verify higher layers still reference correctly.
- **Cleanup rule:** Before finishing work on any layer, scan your changed files for hardcoded values that belong to a lower layer (model strings, port numbers, env var names, etc.). Replace them with aliases or wikilinks to the owning layer. Every session leaves the cascade cleaner than it found it.

## Scaffold Files (`*-main` Convention)
- Five files in `build/` are **transclusion-only scaffolds**:

| Scaffold | Block Pattern | Source Files | Deploy Target |
|----------|--------------|-------------|---------------|
| `config-main.md` | `^config-*` | `stack/*/config-reference.md` | `dist/openclaw.json` |
| `context-main.md` | `^ctx-*` | `stack/L4-session/context-files/*.md` | `dist/context-files/*.md` |
| `env-main.md` | `^env-*` | (self-contained) | `dist/.env.example` |
| `pipeline-main.md` | `^pipeline-*` | `stack/L6-processing/pipelines/*.md` + `coding/*.md` | `dist/pipelines/*.lobster` |
| `focus-main.md` | `^mode-*`, `^tree-*`, `^triggers-*`, `^filter-*`, `^compaction-*`, `^speed-*` | `stack/L5-routing/categories/*/` | `dist/focus/{category}/` |

- These assemble final output from `^block-id` references across the vault. Never hand-edit their content sections — only edit the source files they transclude from.
- If you need to add a new block, add it in the correct source file, then register its `^block-id` in the appropriate `-main` scaffold.
- Any file with the `-main` suffix is a build scaffold. Treat it as generated output.
- The build script uses scaffolds as **manifests** — it reads the transclusion references to discover which blocks to extract, rather than scanning the full vault.

## Prerequisites & Setup
- Any new system dependency, tool, or setup step required before the build runs MUST be documented in `build/README.md` under its Prerequisites section.
- This includes: Node/npm versions, global packages, OS-level tools, vault structure requirements, or any manual step a fresh clone would need.

## Obsidian Vault Rules
- All links use `[[wikilink]]` syntax. No `.md` extensions in links.
- Repeated filenames (`_overview.md`, `config-reference.md`, `runbook.md`, `chat-flow.md`) MUST use full paths: `[[stack/L2-runtime/runbook]]`.
- Unique filenames use basename only: `[[hardware]]`, `[[decisions-log]]`.
- After any rename/delete, grep for broken links: `grep -rn "\[\[old-name" stack/ build/`

## File Format
Every stack file requires: (1) YAML frontmatter with `tags` array using `namespace/value` pattern, (2) level-1 heading, (3) one-line blockquote description, (4) `**Up →**` link to parent `_overview.md`.

Tags: `layer/` + `status/` + `type/` minimum. Full namespace table:

| Namespace | Values | Purpose |
|---|---|---|
| `layer/` | physical, runtime, channel, session, routing, processing, memory | Which layer owns the file |
| `status/` | draft, review, active, finalized, planned | Maturity level |
| `type/` | index, reference, config, guide, note, template | What kind of file |
| `channel/` | telegram, discord, gmail | Channel-specific files |
| `topic/` | skill, config, hardware, sandbox, network, media | Domain within a layer |
| `category/` | cooking, coding, finance, fitness, pet-care, design, habits | L5 Focus Mode categories |
| `focus/` | triggers, pipelines, flows, speed, memory, drift, tree | L5 category file types |

## Frontmatter Properties on `_overview.md`
Every layer `_overview.md` should carry queryable properties for Dataview and the build system. At minimum:

```yaml
layer_name: "Physical"
layer_number: 1
layer_slug: "L1-physical"
config_blocks: ["^config-gateway", "^config-hooks"]
file_count: 9
status_summary: "review"
```

Layers that own config blocks list them. Layers that don't (L4, L5) omit `config_blocks`. Channel-specific and category-specific property templates follow the same pattern — add `channel:` or `category:` keys as applicable.

## Build System
`build/scripts/build-config.js` is the **assembler** — it reads `-main.md` scaffolds as manifests, follows their transclusion references to find `^block-id` tagged content in layer files, and builds `dist/` artifacts. `build/build.sh` is the **orchestrator** — it handles versioning, release snapshots, and calls the assembler. Block IDs go on the line AFTER the code block they tag.

Build outputs: `dist/openclaw.json` (config), `dist/context-files/*.md` (context), `dist/.env.example` (env template), `dist/pipelines/*.lobster` (pipelines), `dist/focus/{category}/` (focus mode files). Note: The build does NOT output `dist/.env` — secrets stay out of `dist/`.

## Adding Files
1. Place in correct layer (L1–L7) or `build/`.
2. Use frontmatter + H1 + blockquote + `**Up →**` link.
3. Link from `00-INDEX.md` AND parent `_overview.md`.
4. Register any new blocks in the appropriate scaffold: `^config-*` → `config-main.md`, `^ctx-*` → `context-main.md`, `^pipeline-*` → `pipeline-main.md`, focus blocks (`^mode-*`, `^tree-*`, etc.) → `focus-main.md`.
5. Log the new file in the layer's `CHANGELOG.md` immediately (see Changelog Convention below).
6. Verify: `grep -rn "[[new-filename" stack/ build/` shows 2+ inbound links.

Subdirectories: create only when 3+ files share a domain scope. Every subdirectory needs its own `_overview.md`.

## Things That Break Builds
- Don't recreate `guides/` directories — they were consolidated.
- Don't create subdirectories without `_overview.md`.
- Don't orphan files when restructuring — update all inbound links first.
- `_overview.md` frontmatter is source of truth for Dataview properties. Don't duplicate values elsewhere.

## Key People
Marty — primary admin, config/infra decisions. Wenting — co-admin, equal elevated access.

## Working Conventions

The worker/manager session scaffolding has been retired. Work now happens directly with Claude Code as a collaborative partner. The principles that mattered are preserved here:

- **No silent edits.** Every file change gets logged in the appropriate `CHANGELOG.md`.
- **Cascade compliance.** Before finishing, scan for hardcoded values that belong to lower layers. Replace with aliases or wikilinks to the owning layer.
- **Cross-layer discipline.** When a change affects another layer, write a cross-layer note rather than editing out of scope. The files are the memory — not the conversation.
- **Context preservation.** If context is getting heavy, save state to files before stopping.

## Source of Truth Paths
- Context files (AGENTS, SOUL, TOOLS, etc.): `stack/L4-session/context-files/*.md`
- Models, env vars, gateway config: `stack/L2-runtime/config-reference.md`
- Per-layer config blocks: `stack/L[X]-[name]/config-reference.md`
- Cross-layer notes: `stack/L[X]-[name]/cross-layer-notes.md`
- Decisions: `stack/L7-memory/decisions-log.md`
- Config assembly: `build/config-main.md`
- Context assembly: `build/context-main.md`
- Env assembly: `build/env-main.md`
- Pipeline assembly: `build/pipeline-main.md`
- Focus mode assembly: `build/focus-main.md`
- Build scripts: `build/scripts/build-config.js` (assembler), `build/build.sh` (orchestrator)
- Build guide: `build/README.md`
- Skills (Claude Code reference): `.claude/skills/{skill-name}/SKILL.md`
- Skills (OpenClaw platform): `stack/L6-processing/config-reference.md` → `^config-skills`
- Skills inventory: `stack/L6-processing/skills/inventory.md`
- Root changelog (aggregated): `CHANGELOG.md`
- Layer changelogs (detailed): `stack/L[X]-[name]/CHANGELOG.md`
- Versions: `versions.json`
- Release snapshots: `releases/`

## External References (OpenClaw)
- Official docs: https://docs.openclaw.ai/ — GitHub: https://github.com/openclaw/openclaw
- Before working on any layer, check the docs and GitHub for current information relevant to that layer's responsibilities (gateway, channels, tools, context, etc.).
- When vault documentation conflicts with official docs, the official docs win. Update the vault to match.


## Skills (Claude Code vs OpenClaw)
Two separate skill systems exist. Don't confuse them.

- **Claude Code skills** (`.claude/skills/{name}/SKILL.md`) — Project-local reference materials for Claude Code workers. Docs, scripts, decision trees. Workers load these via `read .claude/skills/{name}/SKILL.md` for domain expertise. They do NOT produce `^config-*` or `^pipeline-*` blocks and are not part of the build system.
- **OpenClaw platform skills** (`^config-skills` in `stack/L6-processing/config-reference.md`) — ClawHub skill packs configured in `openclaw.json`. These are runtime capabilities the agent can invoke.

Adding a Claude Code skill: Place `SKILL.md` (+ optional `references/`, `scripts/`) in `.claude/skills/{name}/`. Link from `00-INDEX.md`. If the skill relates to a layer's domain, cross-reference it in that layer's docs.

Current Claude Code skills (13): openclaw-debugger, openclaw-pipeline-creator, openclaw-context-engineer, openclaw-telegram-bot-skill, qdrant-database-engineer, drift-guardian, engineering-code-review, engineering-system-design, operations-process-optimization, mcp-builder, skill-creator, claude-developer-platform, keybindings-help.

Note: The qdrant-database-engineer skill is for building *custom* vector systems (RAG, knowledge bases). It is separate from L7's built-in `memorySearch` (Gemini embeddings, `memory_search` tool), which handles Crispy's internal session memory.

## Changelog Convention
Changes are tracked at two levels — per-layer and root. No silent edits.

- **Per-layer `CHANGELOG.md`** (`stack/L[X]-[name]/CHANGELOG.md`) — detailed, layer-scoped. Every file create, edit, move, and delete gets logged here. This is the layer's own memory of what happened.
- **Root `CHANGELOG.md`** — aggregated view across all layers. Updated at commit time from the layer changelogs. Full paths, version numbers, shared file changes.

Every layer should have a `CHANGELOG.md`. If one doesn't exist, create it when starting work on that layer — use the same format as existing layer changelogs.

Both levels exist so changes are saved in two places — if one gets missed, the other has the history. Any session that edits layer files (worker or manager) logs the change in the layer's `CHANGELOG.md`.

## Versioning
After significant vault changes (new files, restructures, config edits), run `./build/build.sh --auto --commit` to bump layer versions. Use `--layers L4 L6` to target specific layers. Use `--dry-run` first to preview. The script updates `versions.json` (including per-layer file counts) + `_overview.md` frontmatter + creates a release snapshot in `releases/`. Use `--status` to check current state.

## Reminders
Config JSON only in `config-reference.md`. Link every new file from 00-INDEX.md + _overview.md. Log every change in the layer's `CHANGELOG.md`. Use full paths for repeated filenames. Never hand-edit `*-main.md` scaffolds — edit source files, then transclusion handles the rest. New prerequisites go in `build/README.md`. Run the build/version script after batch edits. See [[build/version-dashboard]] for current state.
