# env-main.md — Environment Variables Blueprint
<!-- This is the master blueprint for ~/.openclaw/.env -->
<!-- All secrets and identifiers referenced by openclaw.json -->
<!-- Each variable has a ^block-id for transclusion: ![[env-main#^block-id]] -->

> **Status key:** 🔲 = TODO | ⚠️ = needs refinement | ✅ = confirmed
> **Context →** [[build/context-main]] | **Config →** [[build/config-main]]

---

## §1 — Required (Gateway Won't Start Without These)

### `OPENCLAW_GATEWAY_TOKEN` ^env-gateway-token
<!-- REASON: Gateway auth token; protects the control UI and API from unauthorized access -->
<!-- STATUS: ✅ -->

| Field | Value |
|-------|-------|
| Source | `openclaw doctor --generate-gateway-token` |
| Format | `oc_...` |
| Cost | Free (generated locally) |
| Delivery | `${VAR}` interpolation in `openclaw.json` |
| Used by | §1 Gateway (`gateway.auth.token`) |

---

### `ANTHROPIC_API_KEY` ^env-anthropic
<!-- REASON: Direct auth for researcher (claude-opus-4-6) and workhorse (claude-sonnet-4-5) -->
<!-- STATUS: ✅ -->

| Field | Value |
|-------|-------|
| Source | [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys) |
| Format | `sk-ant-...` |
| Cost | Pay-per-use via Anthropic billing |
| Delivery | shellEnv auto-pickup |
| Used by | §2 Models — researcher (`anthropic/claude-opus-4-6`) + workhorse (`anthropic/claude-sonnet-4-5`) |

---

### `OPENAI_API_KEY` ^env-openai
<!-- REASON: Direct auth for workhorse-code model openai/gpt-5.2 — crispy-code agent default -->
<!-- STATUS: ✅ -->

| Field | Value |
|-------|-------|
| Source | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |
| Format | `sk-...` |
| Cost | Pay-per-use via OpenAI billing |
| Delivery | shellEnv auto-pickup |
| Used by | §2 Models — workhorse-code (`openai/gpt-5.2`) |

---

### `OPENROUTER_API_KEY` ^env-openrouter
<!-- REASON: Routes fallback models (DeepSeek, Google, etc.) through single key -->
<!-- STATUS: ✅ -->

| Field | Value |
|-------|-------|
| Source | [openrouter.ai/keys](https://openrouter.ai/keys) |
| Format | `sk-or-...` |
| Cost | Pay-per-use; free models available (20 req/min, 200 req/day); $5 credit unlocks 1,000 req/day |
| Delivery | shellEnv auto-pickup |
| Used by | §2 Models — fallback models (coder, triage, flash, free) |

---

### `GEMINI_API_KEY` ^env-gemini
<!-- REASON: Powers embedding vectors for memory search (text-embedding-004); free tier covers hybrid search needs -->
<!-- STATUS: ✅ -->

| Field | Value |
|-------|-------|
| Source | [aistudio.google.dev/apikey](https://aistudio.google.dev/apikey) |
| Format | `AI...` |
| Cost | Free tier: 5-15 req/min, 1,000 req/day; paid unlocks 100-500 RPM |
| Delivery | shellEnv auto-pickup |
| Used by | §6 Memory (`memory.search.provider: gemini`) |
| Note | Free tier data may be used for model training; paid tier opts out |

---

### `TELEGRAM_BOT_TOKEN_CRISPY` ^env-telegram-token
<!-- REASON: Bot identity for Crispy's primary Telegram channel (Marty) -->
<!-- STATUS: ✅ -->
<!-- MULTI-BOT: Indexed token pattern. Additional bots use TELEGRAM_BOT_TOKEN_{SUFFIX} -->

| Field | Value |
|-------|-------|
| Source | Telegram → [@BotFather](https://t.me/BotFather) → `/newbot` |
| Format | `123456789:ABCdef...` |
| Cost | Free |
| Delivery | `${VAR}` interpolation |
| Used by | §4 Channels (`channels.telegram.botToken`) |
| Note | One token per bot; if leaked, `/revoke` via BotFather immediately |

### `TELEGRAM_BOT_TOKEN_WENTING` ^env-telegram-token-wenting
<!-- REASON: Bot identity for Wenting's Telegram channel (telegram1) -->
<!-- STATUS: ✅ -->

| Field | Value |
|-------|-------|
| Source | Telegram → [@BotFather](https://t.me/BotFather) → `/newbot` (second bot) |
| Format | `123456789:ABCdef...` |
| Cost | Free |
| Delivery | `${VAR}` interpolation |
| Used by | §4 Channels (`channels.telegram1.botToken`) |
| Note | Separate bot from Crispy; each user gets their own BotFather bot |

---

### `TELEGRAM_MARTY_ID` ^env-telegram-marty
<!-- REASON: Numeric user ID for Marty's Telegram; used in allowlist and notification routing -->
<!-- STATUS: ✅ -->

| Field | Value |
|-------|-------|
| Source | Telegram → [@userinfobot](https://t.me/userinfobot) |
| Format | Numeric string (e.g., `5452941776`) |
| Cost | Free |
| Delivery | `${VAR}` interpolation |
| Used by | §4 Channels (`channels.telegram.admins[0]`), pipeline notifications |

---

### `TELEGRAM_WENTING_ID` ^env-telegram-wenting
<!-- REASON: Numeric user ID for Wenting's Telegram; equal access co-admin -->
<!-- STATUS: ✅ -->

| Field | Value |
|-------|-------|
| Source | Telegram → [@userinfobot](https://t.me/userinfobot) |
| Format | Numeric string |
| Cost | Free |
| Delivery | `${VAR}` interpolation |
| Used by | §4 Channels (`channels.telegram.admins[1]`) |

---

## §2 — Implement Now (Ready to Set Up)

### `GITHUB_TOKEN` ^env-github
<!-- REASON: Fine-grained PAT for workspace backup, repo tools, and git operations from inside sandbox -->
<!-- STATUS: ✅ -->

| Field | Value |
|-------|-------|
| Source | [github.com/settings/tokens?type=beta](https://github.com/settings/tokens?type=beta) |
| Format | `github_pat_...` |
| Cost | Free |
| Delivery | shellEnv auto-pickup |
| Scopes | Repo: `FancyKat/crispy-kitsune` — Contents (rw), Metadata (read) |
| Note | Fine-grained tokens expire; set reasonable duration and renew |

---

### `BRAVE_API_KEY` ^env-brave
<!-- REASON: Web search via Brave Search API; used by the web_search tool for research tasks -->
<!-- STATUS: ✅ — naming resolved: BRAVE_API_KEY everywhere -->

| Field | Value |
|-------|-------|
| Source | [api-dashboard.search.brave.com](https://api-dashboard.search.brave.com/app/plans) |
| Format | `BSA...` |
| Cost | $5/month free credit (~1,000 queries); $5 per 1,000 after |
| Delivery | shellEnv auto-pickup |
| Used by | §5 Tools (`tools.web`) |

---

### `ELEVENLABS_API_KEY` ^env-elevenlabs-key
<!-- REASON: Text-to-speech API for Telegram voice responses -->
<!-- STATUS: ✅ -->

| Field | Value |
|-------|-------|
| Source | [elevenlabs.io](https://elevenlabs.io) → Profile → API Keys |
| Format | Hex string |
| Cost | Free: 10,000 chars/month (~20 min); Starter: $5/month (commercial rights) |
| Delivery | shellEnv auto-pickup |
| Used by | Voice pipeline (L3), `talk` tool |

---

### `ELEVENLABS_VOICE_ID` ^env-elevenlabs-voice
<!-- REASON: Selects Crispy's specific TTS voice; tied to kitsune personality -->
<!-- STATUS: ✅ -->

| Field | Value |
|-------|-------|
| Source | ElevenLabs → Speech Synthesis → pick voice → copy ID |
| Format | Hex string |
| Cost | — |
| Delivery | `${VAR}` interpolation |
| Used by | `talk` tool (`talk.voiceId`) |
| Note | Use model `eleven_v3` (not `eleven_multilingual_v2`) |

---

### `MEM0_API_KEY` ^env-mem0
<!-- REASON: Auto-memory plugin for passive capture and recall across sessions -->
<!-- STATUS: ✅ -->

| Field | Value |
|-------|-------|
| Source | [app.mem0.ai](https://app.mem0.ai) (cloud) or self-host (no key needed) |
| Format | `m0-...` |
| Cost | Cloud free: 10,000 memories, 1,000 retrieval/month; Starter: $19/month; Self-hosted: free |
| Delivery | `${VAR}` interpolation |
| Used by | §6 Memory (L7 memory plugin) |
| Note | Self-hosted recommended for privacy — desktop has resources |

---

## §3 — Optional (Enable When Ready)

### `DISCORD_BOT_TOKEN_CRISPY` ^env-discord-token
<!-- REASON: Crispy's primary Discord bot identity; planned channel, not yet active -->
<!-- STATUS: 🔲 Phase 5 — Discord channel launch -->
<!-- MULTI-BOT: Indexed token pattern. Additional bots use DISCORD_BOT_TOKEN_{SUFFIX} -->

| Field | Value |
|-------|-------|
| Source | [discord.com/developers/applications](https://discord.com/developers/applications) |
| Format | Long base64 string |
| Cost | Free |
| Delivery | `${VAR}` interpolation |
| Used by | §4 Channels (`channels.discord.token`) |
| Note | Each Discord bot needs its own application + token. Additional bots: `DISCORD_BOT_TOKEN_AGENT1`, `DISCORD_BOT_TOKEN_AGENT2`, etc. |

---

### `DISCORD_GUILD_ID` ^env-discord-guild
<!-- REASON: Target Discord server for Crispy; needed for channel routing -->
<!-- STATUS: 🔲 Phase 5 -->
<!-- ✅ Reconciled: DISCORD_GUILD_ID used everywhere (DISCORD_SERVER_ID updated in chat-flow.md) -->

| Field | Value |
|-------|-------|
| Source | Discord → Server Settings → Widget → Server ID |
| Format | Numeric string |
| Cost | Free |
| Delivery | `${VAR}` interpolation |
| Used by | §4 Channels (`channels.discord.guildId`) |

---

### `OPENCLAW_HOOKS_TOKEN` ^env-hooks-token
<!-- REASON: Auth token for inbound webhooks (Gmail push notifications, etc.) -->
<!-- STATUS: 🔲 Phase — Gmail integration -->
<!-- ✅ Reconciled: OPENCLAW_HOOKS_TOKEN used everywhere -->

| Field | Value |
|-------|-------|
| Source | `openssl rand -hex 32` or let OpenClaw generate |
| Format | Hex string |
| Cost | Free (local) |
| Delivery | `${VAR}` interpolation |
| Used by | §7 Hooks (`hooks` auth), Gmail webhooks |

---

### `GOG_KEYRING_PASSWORD` ^env-gog
<!-- REASON: Passphrase for the gog ClawHub skill's encrypted keyring -->
<!-- STATUS: 🔲 when gaming skill is deployed -->

| Field | Value |
|-------|-------|
| Source | Self-set passphrase |
| Format | String |
| Cost | Free |
| Delivery | skill env injection |
| Used by | §10 Skills (`gog` skill) |

---

## §4 — Gmail Integration (Future)

### `GMAIL_SERVICE_ACCOUNT_KEY` ^env-gmail-sa
<!-- REASON: GCP service account JSON for Gmail API access; enables push notifications -->
<!-- STATUS: 🔲 Phase — Gmail channel -->

| Field | Value |
|-------|-------|
| Source | GCP Console → IAM → Service Accounts → Create Key (JSON) |
| Format | JSON string (escaped in .env) |
| Cost | Free (GCP free tier) |
| Delivery | `${VAR}` interpolation |
| Used by | Gmail channel config (`channels.gmail.serviceAccountKey`) |

---

### `GMAIL_USER_ID` ^env-gmail-user
<!-- REASON: Email address for Gmail API scope; identifies which inbox to monitor -->
<!-- STATUS: 🔲 Phase — Gmail channel -->

| Field | Value |
|-------|-------|
| Source | Your Gmail address |
| Format | `user@example.com` |
| Cost | Free |
| Delivery | `${VAR}` interpolation |
| Used by | Gmail channel config (`channels.gmail.userId`) |

---

### `GMAIL_WEBHOOK_SECRET` ^env-gmail-webhook
<!-- REASON: Shared secret for verifying inbound Gmail push notifications -->
<!-- STATUS: 🔲 Phase — Gmail channel -->

| Field | Value |
|-------|-------|
| Source | `openssl rand -hex 32` |
| Format | Hex string |
| Cost | Free |
| Delivery | `${VAR}` interpolation |
| Used by | Gmail channel config (`channels.gmail.webhookSecret`) |

---

### `GCP_PROJECT` ^env-gcp-project
<!-- REASON: GCP project ID for Pub/Sub topic name in Gmail push subscription -->
<!-- STATUS: 🔲 Phase — Gmail channel -->

| Field | Value |
|-------|-------|
| Source | GCP Console → Project selector |
| Format | `my-project-id` |
| Cost | Free |
| Delivery | `${VAR}` interpolation |
| Used by | Gmail channel config (`channels.gmail.topicName`) |

---

## §5 — Special Auth (Not in .env)

### Anthropic (Direct) ^env-anthropic-note
<!-- REASON: claude-opus-4-6 (researcher) + claude-sonnet-4-5 (workhorse) use direct Anthropic auth -->
<!-- STATUS: ✅ -->

> Both researcher (`anthropic/claude-opus-4-6`) and workhorse (`anthropic/claude-sonnet-4-5`) use direct `ANTHROPIC_API_KEY` (see §1). No OpenRouter passthrough — better latency, no markup. Workhorse-code (`openai/gpt-5.2`) uses direct `OPENAI_API_KEY` (see §1). Fallback models still route through OpenRouter.

---

## .env Template

```bash
# ══════════════════════════════════════════════════════════════════════
# Crispy Kitsune — .env configuration template
# ══════════════════════════════════════════════════════════════════════
#
# Usage:
#   cp .env.example .env
#   chmod 600 .env          ← restrict file permissions (secrets!)
#   nano .env               ← fill in your actual values
#
# NEVER commit .env to git. It contains secrets.
# This file (.env.example) is safe to commit — values are blank.
#
# Source of truth: build/env-main.md
# ══════════════════════════════════════════════════════════════════════


# ─── CORE (gateway won't start without these) ────────────────────────
# All five are required before running `openclaw start`.
#
# OPENCLAW_GATEWAY_TOKEN
#   Get: openclaw doctor --generate-gateway-token
#   Format: oc_... (generated locally, free)
#   Tip: Protects the gateway control API. Rotate if the host changes.
OPENCLAW_GATEWAY_TOKEN=
#
# ANTHROPIC_API_KEY
#   Get: https://console.anthropic.com/settings/keys
#   Format: sk-ant-...
#   Tip: Pay-per-use. Powers researcher (claude-opus-4-6) + workhorse (claude-sonnet-4-5).
ANTHROPIC_API_KEY=
#
# OPENAI_API_KEY
#   Get: https://platform.openai.com/api-keys
#   Format: sk-...
#   Tip: Pay-per-use. Powers workhorse-code (gpt-5.2) for crispy-code agent.
OPENAI_API_KEY=
#
# OPENROUTER_API_KEY
#   Get: https://openrouter.ai/keys
#   Format: sk-or-...
#   Tip: Routes fallback models (coder, triage, flash, free). Free tier: 200 req/day.
#        $5 credit unlocks 1,000 req/day.
OPENROUTER_API_KEY=
#
# GEMINI_API_KEY
#   Get: https://aistudio.google.dev/apikey
#   Format: AI...
#   Tip: Powers memory embedding (text-embedding-004). Free tier covers hybrid search needs.
#        Note: Free tier data may be used for model training; paid tier opts out.
GEMINI_API_KEY=


# ─── TELEGRAM (primary + multi-bot) ──────────────────────────────────
# Each bot needs its own token from BotFather.
# Naming: TELEGRAM_BOT_TOKEN_{SUFFIX} — suffix matches agent identity.
#
# TELEGRAM_BOT_TOKEN_CRISPY
#   Get: Telegram → @BotFather → /newbot
#   Format: 123456789:ABCdef...
#   Tip: Primary bot (Marty's). If leaked, /revoke via BotFather immediately.
TELEGRAM_BOT_TOKEN_CRISPY=
#
# TELEGRAM_BOT_TOKEN_WENTING
#   Get: Telegram → @BotFather → /newbot (second bot for Wenting)
#   Format: 123456789:ABCdef...
#   Tip: Separate bot from Crispy. Each user gets their own BotFather bot.
TELEGRAM_BOT_TOKEN_WENTING=
#
# TELEGRAM_MARTY_ID
#   Get: Telegram → @userinfobot → it replies with your numeric ID
#   Format: numeric string (e.g., 5452941776)
TELEGRAM_MARTY_ID=
#
# TELEGRAM_WENTING_ID
#   Get: Same as above — @userinfobot
#   Format: numeric string
TELEGRAM_WENTING_ID=


# ─── TOOLS & SEARCH ──────────────────────────────────────────────────
#
# GITHUB_TOKEN
#   Get: https://github.com/settings/tokens?type=beta (fine-grained PAT)
#   Format: github_pat_...
#   Tip: Scope to FancyKat/crispy-kitsune only — Contents (rw), Metadata (read).
#        Fine-grained tokens expire; set a reasonable duration and renew.
GITHUB_TOKEN=
#
# BRAVE_API_KEY
#   Get: https://api-dashboard.search.brave.com/app/plans
#   Format: BSA...
#   Tip: $5/month free credit (~1,000 queries). $5 per 1,000 after.
BRAVE_API_KEY=


# ─── VOICE ───────────────────────────────────────────────────────────
# Both values are from ElevenLabs — set up together.
#
# ELEVENLABS_API_KEY
#   Get: https://elevenlabs.io → Profile → API Keys
#   Format: hex string
#   Tip: Free: 10,000 chars/month (~20 min). Starter: $5/month (commercial rights).
ELEVENLABS_API_KEY=
#
# ELEVENLABS_VOICE_ID
#   Get: ElevenLabs → Speech Synthesis → pick voice → copy ID
#   Format: hex string
#   Tip: Use model eleven_v3 (not eleven_multilingual_v2).
ELEVENLABS_VOICE_ID=


# ─── MEMORY ──────────────────────────────────────────────────────────
#
# MEM0_API_KEY
#   Get: https://app.mem0.ai (cloud) — or self-host (no key needed)
#   Format: m0-...
#   Tip: Cloud free: 10,000 memories, 1,000 retrieval/month.
#        Self-hosted recommended for privacy — desktop has the resources.
MEM0_API_KEY=


# ─── DISCORD (future channel — multi-bot ready) ─────────────────────
# Each bot needs its own Discord application + token.
# Naming: DISCORD_BOT_TOKEN_{SUFFIX} — suffix matches agent identity.
# Uncomment when Discord channel goes live (Phase 5).
#
# DISCORD_BOT_TOKEN_CRISPY
#   Get: https://discord.com/developers/applications → Bot → Token
#   Format: long base64 string
#   Tip: Primary Discord bot. Additional bots: DISCORD_BOT_TOKEN_AGENT1, etc.
# DISCORD_BOT_TOKEN_CRISPY=
#
# DISCORD_GUILD_ID
#   Get: Discord → Server Settings → Widget → Server ID
#   Format: numeric string
# DISCORD_GUILD_ID=


# ─── WEBHOOKS ────────────────────────────────────────────────────────
# Required when Gmail integration goes live.
#
# OPENCLAW_HOOKS_TOKEN
#   Get: openssl rand -hex 32
#   Format: hex string (64 chars)
#   Tip: Protects inbound webhook endpoint. Rotate if exposed.
# OPENCLAW_HOOKS_TOKEN=


# ─── GMAIL INTEGRATION (future) ──────────────────────────────────────
# All four values are part of one GCP setup session.
# Uncomment when Gmail channel goes live.
#
# GMAIL_SERVICE_ACCOUNT_KEY
#   Get: GCP Console → IAM → Service Accounts → Create Key (JSON)
#   Format: JSON string (escaped for .env)
# GMAIL_SERVICE_ACCOUNT_KEY=
#
# GMAIL_USER_ID
#   Get: Your Gmail address
#   Format: user@example.com
# GMAIL_USER_ID=
#
# GMAIL_WEBHOOK_SECRET
#   Get: openssl rand -hex 32
#   Format: hex string
# GMAIL_WEBHOOK_SECRET=
#
# GCP_PROJECT
#   Get: GCP Console → Project selector
#   Format: my-project-id
# GCP_PROJECT=


# ─── SKILLS ──────────────────────────────────────────────────────────
#
# GOG_KEYRING_PASSWORD
#   Get: Set your own passphrase
#   Format: any string
#   Tip: Used by the gog ClawHub skill's encrypted keyring.
# GOG_KEYRING_PASSWORD=
```
^env-template

---

## Delivery Mechanisms ^env-delivery

| Method | Variables | How It Works |
|--------|-----------|-------------|
| `${VAR}` interpolation | `OPENCLAW_GATEWAY_TOKEN`, `TELEGRAM_BOT_TOKEN_*`, `TELEGRAM_*_ID`, `ELEVENLABS_VOICE_ID`, `OPENCLAW_HOOKS_TOKEN`, `MEM0_API_KEY`, `DISCORD_BOT_TOKEN_*`, `DISCORD_GUILD_ID`, Gmail vars | OpenClaw replaces `${VAR}` in `openclaw.json` at startup |
| shellEnv auto-pickup | `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `OPENROUTER_API_KEY`, `GEMINI_API_KEY`, `BRAVE_API_KEY`, `GITHUB_TOKEN`, `ELEVENLABS_API_KEY` | Gateway reads from shell environment; no config reference needed |
| Skill env injection | `GOG_KEYRING_PASSWORD` | Passed to skill container via `env` block in skill config |

---

## Naming Reconciliation ^env-reconcile
<!-- Resolved in multi-bot architecture session — all naming is now consistent -->

| Issue | Resolution | Status |
|-------|-----------|--------|
| Brave search key | `BRAVE_API_KEY` everywhere — `BRAVE_SEARCH_KEY` removed from L6 config | ✅ Resolved |
| Hooks token | `OPENCLAW_HOOKS_TOKEN` everywhere — `HOOKS_SECRET` updated in email pipeline | ✅ Resolved |
| Discord server | `DISCORD_GUILD_ID` everywhere — `DISCORD_SERVER_ID` updated in chat-flow | ✅ Resolved |
| Telegram token | `TELEGRAM_BOT_TOKEN_CRISPY` (indexed) — old `TELEGRAM_BOT_TOKEN` retired | ✅ Updated |
| Discord token | `DISCORD_BOT_TOKEN_CRISPY` (indexed) — old `DISCORD_BOT_TOKEN` retired | ✅ Updated |

---

## Build Status

| Section | Variables | ✅ | ⚠️ | 🔲 |
|---------|-----------|---|---|---|
| §1 Required | 7 | 7 | 0 | 0 |
| §2 Implement Now | 5 | 4 | 1 | 0 |
| §3 Optional | 4 | 0 | 0 | 4 |
| §4 Gmail | 4 | 0 | 0 | 4 |
| §5 Special Auth | 2 | 2 | 0 | 0 |
| **Total** | **22** | **13** | **1** | **8** |

> **13/22 confirmed** — 8 are future/optional, 1 needs naming reconciliation.
> **Context →** [[build/context-main]] | **Config →** [[build/config-main]]
