---
tags: [layer/session, status/draft, type/reference, topic/context-files]
---
# L4 Config Reference — Context File Registry

> Block registry for all `^ctx-*` blocks deployed to `dist/context-files/`. Build script transcludes from source files in `context-files/` and outputs to `dist/context-files/*.md`.

**Up →** [[stack/L4-session/_overview]]

---

## Block Registry

All 47 `^ctx-*` blocks across 10 context files.

| Block ID | Source File | Deploy Target | Blocks | Status |
|----------|-------------|---------------|--------|--------|
| `^ctx-agents-*` (9) | [[stack/L4-session/context-files/agents]] | `AGENTS.md` | constraints, priorities, admins, loop, models, memory, channels, subagents, reminders | ✅ |
| `^ctx-soul-*` (6) | [[stack/L4-session/context-files/soul]] | `SOUL.md` | identity, voice, values, relationships, boundaries, regrounding | ✅ |
| `^ctx-identity-*` (3) | [[stack/L4-session/context-files/identity]] | `IDENTITY.md` | card, origin, lore | ✅ |
| `^ctx-tools-*` (3) | [[stack/L4-session/context-files/tools]] | `TOOLS.md` | preferences, forbidden, gotchas | ✅ |
| `^ctx-user-*` (8) | [[stack/L4-session/context-files/user]] | `USER.md` | marty-identity, marty-style, marty-tech, marty-focus, marty-accumulated, wenting-identity, wenting-prefs, wenting-accumulated | ✅ |
| `^ctx-memory-*` (5) | [[stack/L4-session/context-files/memory]] | `MEMORY.md` | people, projects, decisions, preferences, facts | ✅ |
| `^ctx-boot-*` (3) | [[stack/L4-session/context-files/boot]] | `BOOT.md` | health, dashboard, media | ✅ |
| `^ctx-heartbeat-*` (5) | [[stack/L4-session/context-files/heartbeat]] | `HEARTBEAT.md` | checks, notify, never, reminders, tasks | ✅ |
| `^ctx-bootstrap-*` (2) | [[stack/L4-session/context-files/bootstrap]] | `BOOTSTRAP.md` | purpose, steps | ✅ |
| `^ctx-status-*` (3) | [[stack/L4-session/context-files/status]] | `STATUS.md` | session, alerts, carried | ✅ |
| **Total** | **10 files** | **10 .md files** | **47 blocks** | |

---

## Assembly Order

Context is assembled in this order per conversation turn. Position affects attention weight (LLM attention is strongest at start and end — Lost in the Middle effect).

```
① AGENTS.md    — safety rules, core loop, routing (strongest attention — always first)
② SOUL.md      — personality, voice, values (stable, high cache hit)
③ TOOLS.md     — constraints, forbidden patterns, gotchas (stable, sub-agent inherit)
④ IDENTITY.md  — name, emoji, origin, lore (stable)
⑤ USER.md      — Marty and Wenting profiles (grows over time)
⑥ MEMORY.md    — curated long-term facts (DM sessions only)
⑦ Daily logs   — today + yesterday session journals (variable)
⑧ Session history — prior conversation turns (variable)
⑨ Current message — user's prompt (recency boost at end)
```

**Special injection events:**

| File | When | Model |
|------|------|-------|
| BOOT.md | Gateway startup only | workhorse |
| HEARTBEAT.md | Every 20 minutes | flash |
| STATUS.md | Every session (compaction state) | — |
| BOOTSTRAP.md | First run only (self-deletes) | workhorse |

---

## Token Budget Summary

| File | Max Tokens | Current Tokens | Headroom |
|------|-----------|----------------|---------|
| AGENTS.md | 2,000 | ~994 | ✅ 1,006 available |
| SOUL.md | 600 | ~770 | ⚠️ 170 over target |
| IDENTITY.md | 400 | ~434 | ⚠️ 34 over target |
| TOOLS.md | 600 | ~499 | ✅ 101 available |
| USER.md | 400 | ~551 | ⚠️ 151 over target |
| MEMORY.md | 800 | ~463 | ✅ 337 available |
| HEARTBEAT.md | 300 | ~485 | ⚠️ 185 over target |
| STATUS.md | 300 | ~265 | ✅ 35 available |
| BOOT.md | 300 | ~369 | ⚠️ 69 over target |
| BOOTSTRAP.md | 400 | ~407 | ⚠️ 7 over target |
| **Total** | **~6,100** | **~5,237** | ✅ Under overall budget |

> Files marked ⚠️ slightly exceed authoring targets but remain within acceptable range. These are source file sizes (including frontmatter and markdown); deployed context block sizes will be smaller. Trim if context window pressure becomes an issue.

---

## Build Verification

```bash
node build/scripts/build-config.js --only context
# Expected: 10/10 context files produced
```

**Assembly scaffold →** [[build/context-main]]
