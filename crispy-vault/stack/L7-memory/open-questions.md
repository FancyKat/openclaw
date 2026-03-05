---
tags: [layer/memory, type/planning, topic/audit, status/draft]
---
# ❓ Open Questions

> Work through one at a time. When resolved → [[stack/L7-memory/decisions-log]].

## 🦊 Identity
- [x] Kitsune depth — **moderate (5-6/10)**, modern with light folklore (2026-03-04)
- [x] Playfulness dial — **5-6/10** (2026-03-04)
- [x] Cultural flavor — **modern with light Japanese folklore touches** (2026-03-04)

## 👤 Users
- [x] Wenting's role — **co-admin** (resolved 2026-03-02)
- [ ] Wenting-specific personality rules in AGENTS.md? (she's admin, but different interaction style?)

## 📱 Telegram
- [x] Button trigger threshold — **>2 interpretations** (2026-03-04)
- [x] Button grid max — **3×2 (3 per row, 2 rows)** (2026-03-04)
- [x] Decision tree max depth — **4 levels** (2026-03-04)
- [x] Button timeout — **60 seconds** (2026-03-04)
- [ ] Voice policy — voice-in = voice-out only?

## 🎮 Discord
- [ ] Launch with full slash commands or minimal?
- [ ] Auto-thread threshold (500 words)?
- [ ] Embed color hex?
- [ ] Channel personality differences (#dev vs #general)?

## 🤖 Agent
- [ ] thinkingDefault: low → medium?
- [ ] Block streaming vs partial?
- [ ] Memory curation frequency?
- [ ] MEMORY.md: seed or grow organically?
- [ ] STATUS.md format (referenced by compaction flush)?

## 🏗️ Infrastructure
- [ ] First task after bootstrap (prove it works)?
- [ ] Daily backup cron schedule?
- [ ] Heartbeat disabled during build phase?

## 🚀 BOOT.md & Session Lifecycle
- [ ] Should BOOT.md auto-reset session when feature is complete, or always ask?
- [ ] How much of PROJECT-STATUS.md injected into context? (full file or summary?)
- [ ] Boot visual format — Telegram inline buttons or plain text?
- [ ] Can BOOT.md run a Lobster pipeline (boot-check.lobster) or agent-only?
- [ ] What happens if BOOT.md health check fails? Block messages or warn and continue?
- [ ] PROJECT-STATUS.md location — workspace root or `projects/` subfolder?
- [ ] Multi-project support: one PROJECT-STATUS.md per project or one global file?

## 📦 Media Pipeline
- [ ] Hook `on: "message.inbound"` — verify this lifecycle event exists in OpenClaw hooks
- [ ] Quarantine review policy — how long do unknown files stay before auto-delete?
- [ ] Should the LLM classify step (Step 4) run in hook or only in agent fallback?
- [ ] File hash collision handling in .processed log

**Decisions →** [[decisions-log]]
**Up →** [[stack/L7-memory/_overview]]
