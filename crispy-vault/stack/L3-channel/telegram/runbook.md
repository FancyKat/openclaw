---
tags: [channel/telegram, layer/channel, status/draft, type/runbook]
---

# Telegram Runbook

> Step-by-step implementation guides for Telegram-specific features: setup, pipelines, decision trees, media handling, approvals, quick actions, and notifications.

---

## Setup Guide


Complete Telegram bot configuration: obtaining bot token, setting up polling, environment variables, and testing basic connectivity.

**Steps:**
1. Create bot via BotFather (@BotFather on Telegram)
2. Copy bot token to `.env` as `TELEGRAM_BOT_TOKEN_CRISPY`
3. Add user IDs (`TELEGRAM_MARTY_ID`, `TELEGRAM_WENTING_ID`)
4. Configure polling in `openclaw.json`
5. Test with `/start` command

For full setup details, see [[stack/L3-channel/telegram/_overview]]

---

## Decision Trees Guide


Implementing decision trees in Telegram using inline keyboards. This guide covers:
- Building tree structure in JSON
- Rendering buttons via inline keyboards
- Handling callback_data format
- State management for tree navigation
- Cascading L1 → L2 button flows

**Key points:**
- Tree ID format: `dt_[code]:[option_key]` (max 64 bytes for callback_data)
- All levels pre-built upfront (1 LLM call to create tree)
- Button taps are ~200ms (state lookup only)
- Escape hatch (❓ Other) always included

See [[stack/L5-routing/decision-trees]] for generic tree concepts

---

## Pipeline: Approve/Deny


Binary yes/no approval gates for Lobster pipelines.

**When used:**
- Approval required at pipeline step
- Two-choice decisions
- Confirmation before destructive actions

**Flow:**
```
Pipeline hits approval: required
     ↓
Crispy sends buttons: [✅ Approve] [❌ Deny] [🔍 Details]
     ↓
User taps button (~200ms response)
     ↓
Pipeline resumes with decision
```

**Config:** See [[stack/L3-channel/telegram/pipelines]] for callback structure

---

## Pipeline: Decision Trees


Multi-path decision workflows for Telegram. Use when:
- 3+ distinct paths forward
- Narrowing from broad category to specific choice
- User must decide (not default/obvious)

**Structure:**
- Level 1: Category buttons (3-4 options)
- Level 2: Specific choice (2 buttons)
- Never deeper than 2 levels

**Example:** "Help with project?" → [Web app] [Bot] [Library] [Other]
- Tap [Bot] → "Which platform?" → [Telegram] [Discord]
- Tap [Telegram] → Execute scaffold command

---

## Pipeline: Exec Approve


Command execution with preview and dry-run option.

**When used:**
- `git push`, `rm`, `docker prune`
- Any command that modifies state
- High-confidence but not 100% sure

**Buttons:**
- ✅ Run — execute immediately
- ❌ Skip — cancel
- 🔍 Dry run — show output, keep buttons active

**Key feature:** Dry run keeps buttons so user can tap Run afterward

---

## Pipeline: Media


Processing photos, documents, videos, and voice messages.

**Inbound:**
- Download from Telegram CDN
- Store in `workspace/media/inbound/telegram/`
- Extract text (OCR for images, pdftotext for docs)
- Create metadata sidecar

**Outbound:**
- `send_voice()` — voice message (ogg_opus)
- `send_photo()` — image with caption
- `send_document()` — file attachment

**Size limits:**
- Voice: 20MB (~3 min)
- Photo: 5MB (largest version)
- Document: 2GB

---

## Pipeline: Notify


Routing alerts and notifications by urgency.

**Levels:**
- 🔴 Urgent — immediate, with sound
- 🟡 Medium — immediate, no sound
- 🟢 Low — batched every 10 min

**Usage:**
```yaml
openclaw pipeline run notify \
  --args-json '{
    "level": "urgent",
    "title": "Server down",
    "message": "API unreachable"
  }'
```

---

## Pipeline: Quick Actions


Shortcut menus for frequent tasks.

**Contexts:**
- General: Brief, Email, Git, Other
- Workspace: Old logs, Archive, Git clean, Other
- Dev: Review, Debug, Deploy, Other
- Research: Web, Docs, Memory, Other

**Feature:** Chaining — tap "Email" → email.lobster runs → might chain into approval gate

---

## Multi-Bot Setup (Second Telegram Bot)

To add a second Telegram bot for another user (e.g., Wenting):

1. **Create second bot via BotFather:**
   - Open @BotFather → `/newbot`
   - Name it differently (e.g., "Crispy Wenting")
   - Copy the token

2. **Add to `.env`:**
   ```bash
   TELEGRAM_BOT_TOKEN_WENTING=123456789:ABCdef...  # Second bot token
   ```

3. **Create isolated workspace:**
   ```bash
   mkdir -p ~/.openclaw/workspace-wenting/memory
   cp ~/.openclaw/workspace/SOUL.md ~/.openclaw/workspace-wenting/
   # Write USER.md specific to Wenting's preferences
   ```

4. **Config in `openclaw.json`** (see [[stack/L3-channel/config-reference]]):
   - Add `telegram1` channel entry with `${TELEGRAM_BOT_TOKEN_WENTING}`
   - Set `allowFrom` to only Wenting's user ID
   - Add `crispy-wenting` agent in `agents.list` with `workspace-wenting`
   - Add binding: `{ "agentId": "crispy-wenting", "match": { "channel": "telegram1" } }`

5. **Test:** Message the second bot — it should respond using Wenting's workspace and preferences.

**Key difference from Discord multi-bot:** Each Telegram bot is per-user (one admin per bot), not per-channel. The allowlist ensures only the intended user can interact with their bot.

---

## References

**Core Documentation:**
- [[stack/L3-channel/telegram/_overview]] — Config, behavior rules
- [[stack/L3-channel/telegram/chat-flow]] — Full message lifecycle
- [[stack/L3-channel/telegram/button-patterns]] — 4 button pattern types
- [[stack/L3-channel/telegram/media-handling]] — Media file handling
- [[stack/L3-channel/telegram/pipelines]] — Pipeline definitions

**Decision Tree Concepts:**
- [[stack/L5-routing/decision-trees]] — Generic decision tree patterns (all channels)

**Multi-Bot Architecture:**
- [[stack/L2-runtime/config-reference]] — Agent bindings and workspace config
- [[architecture-diagrams]] — Multi-bot architecture class diagram

---

**Up →** [[stack/L3-channel/telegram/_overview]]
**Core →** [[stack/L3-channel/telegram/chat-flow]]
**Patterns →** [[stack/L3-channel/telegram/button-patterns]]
**Media →** [[stack/L3-channel/telegram/media-handling]]
**Pipelines →** [[stack/L3-channel/telegram/pipelines]]
