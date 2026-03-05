---
tags: [type/guide, status/draft, layer/build]
---
# Crispy Kitsune — Build & Install Guide

> Everything you need to get Crispy running. Follow these phases in order.
> For architecture details, see [[stack/_overview]].

---

## Prerequisites

- OpenClaw CLI installed (`npm install -g @openclaw/cli` or from [docs.openclaw.ai](https://docs.openclaw.ai))
- Node.js 22+ and npm (OpenClaw requires ≥22; see [docs.openclaw.ai](https://docs.openclaw.ai))
- Docker Desktop (for sandbox mode)
- Git configured with SSH or HTTPS
- A Telegram account (for primary channel)
- Chromium browser (for browser tool)

---

## Phase 1 — Initial Setup

### 1a. Run OpenClaw Onboard

```bash
openclaw onboard
# Creates ~/.openclaw/ directory structure
# Generates initial openclaw.json
```

### 1b. Create .env File

```bash
mkdir -p ~/.openclaw
nano ~/.openclaw/.env
```

Paste the contents from `build/.env.example` and fill in your actual keys.

```bash
chmod 600 ~/.openclaw/.env
```

### 1c. Get Required API Keys

| Key | Where to Get It | Cost |
|---|---|---|
| `OPENCLAW_GATEWAY_TOKEN` | `openclaw doctor --generate-gateway-token` | Free |
| `ANTHROPIC_API_KEY` | [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys) | Pay-per-use (researcher + workhorse) |
| `OPENAI_API_KEY` | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) | Pay-per-use (workhorse-code) |
| `OPENROUTER_API_KEY` | [openrouter.ai/keys](https://openrouter.ai/keys) | Pay-per-use (fallbacks) |
| `TELEGRAM_BOT_TOKEN` | Telegram → @BotFather → `/newbot` | Free |
| `GEMINI_API_KEY` | [aistudio.google.dev/apikey](https://aistudio.google.dev/apikey) | Free tier |

### 1d. Get Recommended API Keys

| Key | Where to Get It | Cost |
|---|---|---|
| `TELEGRAM_MARTY_ID` | Telegram → @userinfobot → `/start` | Free |
| `TELEGRAM_WENTING_ID` | Same as above | Free |
| `GITHUB_TOKEN` | [github.com/settings/tokens?type=beta](https://github.com/settings/tokens?type=beta) | Free |
| `BRAVE_API_KEY` | [api-dashboard.search.brave.com](https://api-dashboard.search.brave.com) | Free $5/mo |
| `ELEVENLABS_API_KEY` | [elevenlabs.io](https://elevenlabs.io) | Free 10K chars/mo |
| `MEM0_API_KEY` | [app.mem0.ai](https://app.mem0.ai) | Free 10K memories |

### 1e. Verify Model Access

```bash
openclaw models status
# Should show anthropic/claude-opus-4-6 as global primary (researcher)
# Should show anthropic/claude-sonnet-4-5 (workhorse) and openai/gpt-5.2 (workhorse-code)
# Should show fallback models via OPENROUTER_API_KEY
```

---

## Phase 2 — Config Fixes

Fix known issues in `openclaw.json` before boot.

See [[stack/L2-runtime/runbook.md]] for full details.

```bash
# Open config
nano ~/.openclaw/openclaw.json
```

| Fix | What to Change |
|---|---|
| Circular fallback | Remove 7th entry from `agents.defaults.model.fallbacks` |
| ElevenLabs model | Change `modelId` to `"eleven_v3"` |
| Hardcoded Telegram ID | Replace raw IDs with `${TELEGRAM_MARTY_ID}` |
| Streaming behavior | Decide `blockStreamingDefault`: `"on"` or `"off"` |
| Thinking depth | Decide `thinkingDefault`: `"low"` or `"medium"` |

---

## Phase 3 — Infrastructure

### 3a. Create Directories

```bash
mkdir -p ~/.openclaw/pipelines
mkdir -p ~/.openclaw/workspace/memory
mkdir -p ~/.openclaw/workspace/research
mkdir -p ~/.openclaw/workspace/inbox
mkdir -p ~/.openclaw/skills
```

### 3b. Install Browser

```bash
sudo apt install chromium-browser
# Or on macOS: brew install chromium
```

### 3c. Run Doctor

```bash
openclaw doctor --fix
```

---

## Phase 4 — Seed Workspace

Write all 9 bootstrap files to `~/.openclaw/workspace/`.

**Option A (recommended):** Run the seed script:

```bash
chmod +x scripts/seed-workspace.sh
./scripts/seed-workspace.sh
```

**Option B (manual):** Write each file by hand using the templates in [[stack/L4-session/_overview]].

### Bootstrap Files Created

| File | Purpose | Lifecycle |
|---|---|---|
| `AGENTS.md` | Operating contract | Persistent, self-updating |
| `SOUL.md` | Personality + values | Rarely changed |
| `TOOLS.md` | Tool inventory + paths | Persistent |
| `IDENTITY.md` | Name, emoji, vibe | Written during bootstrap |
| `USER.md` | User profiles (Marty + Wenting) | Grows over time |
| `MEMORY.md` | Long-term curated memory | Grows over time |
| `HEARTBEAT.md` | Periodic checks (every 20min) | Persistent |
| `BOOTSTRAP.md` | First-run ritual | Self-deletes after use |
| `BOOT.md` | Startup health check | Persistent |

### Verify

```bash
ls -la ~/.openclaw/workspace/*.md
# Should show all 9 files
```

---

## Phase 5 — Go Live

### 5a. Enable Bootstrap

```bash
# In openclaw.json, set:
# "agents.defaults.skipBootstrap": false
nano ~/.openclaw/openclaw.json
```

### 5b. Start Gateway

```bash
openclaw gateway restart
```

### 5c. First Contact

1. Open Telegram
2. DM your bot (the one you created with @BotFather)
3. BOOTSTRAP.md ritual begins — Crispy discovers its identity through conversation
4. After bootstrap: IDENTITY.md, USER.md, SOUL.md are populated
5. BOOTSTRAP.md self-deletes

### 5d. Push to GitHub

```bash
cd ~/.openclaw/workspace
git add -A
git commit -m "Crispy bootstrap complete"
git push origin main
```

---

## Phase 6 — Verify

```bash
openclaw doctor                        # All checks pass
openclaw models status                 # All models accessible
openclaw channels status --probe       # Channels connected
```

In Telegram DM:
- `/status` — should respond with system status
- `/brief` — test daily brief pipeline
- `/memory search "test"` — verify memory search works

Wait 20 minutes and verify heartbeat fires.

---

## Phase 7 — Optional Extras

### Discord

See [[stack/L3-channel/discord/runbook.md]]

```bash
# Add DISCORD_BOT_TOKEN to .env
# Set channels.discord.enabled: true in openclaw.json
openclaw gateway restart
```

### Gmail Hooks

See [[stack/L3-channel/gmail/runbook.md]]

### Lobster Pipelines

Create pipeline files in `~/.openclaw/pipelines/`:

```bash
# See designs in:
# [[stack/L6-processing/pipelines/core-pipelines.md]] (brief, email)
# [[stack/L6-processing/pipelines/media.md]] (media-sort)
```

### Mem0 (Auto-Memory)

See [[stack/L7-memory/memory-search.md]]

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Port 18789 in use | `lsof -i :18789` then `kill -9 <PID>` |
| "ANTHROPIC_API_KEY not set" | Check `~/.openclaw/.env` exists and has the key |
| "OPENROUTER_API_KEY not set" | Needed for fallback models — check `~/.openclaw/.env` |
| Gateway starts but Telegram silent | Verify `TELEGRAM_BOT_TOKEN` with `openclaw channels status --probe` |
| "skipBootstrap is true" | Set to `false` in openclaw.json ONLY after all .md files are in place |
| Memory search returns nothing | Verify `GEMINI_API_KEY`: `openclaw models status` |
| "openclaw doctor reports errors" | Read output carefully, fix config mismatches |
| ".env: Permission denied" | `chmod 600 ~/.openclaw/.env` |

---

## Architecture Reference

For the full 7-layer architecture model, see [[stack/_overview]].

| Layer | What It Does |
|---|---|
| **L1 — Physical** | Hardware, Docker, filesystem |
| **L2 — Runtime** | Gateway, config, auth |
| **L3 — Channel** | Telegram, Discord, Gmail |
| **L4 — Session** | Context, bootstrap, compaction |
| **L5 — Routing** | Intent classification, guardrails |
| **L6 — Processing** | LLM reasoning, tools, skills, pipelines |
| **L7 — Memory** | Daily logs, MEMORY.md, Mem0, SQLite |

---

**Back →** [[00-INDEX]]
