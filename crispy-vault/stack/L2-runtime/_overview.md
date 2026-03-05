---
tags: [layer/runtime, status/draft, type/index]
layer_name: "Runtime"
layer_number: 2
layer_slug: "L2-runtime"
config_blocks: ["^config-agents"]
file_count: 7
status_summary: "draft"

# ── VERSION TRACKING (managed by build/build.sh) ──
version_major: 0
version_minor: 0
version_patch: 4
version_full: "0.0.4"
version_changes: 5
version_last_build: 12
version_notes: "Initial — gateway, config, env, models documented"

# ── MODEL CONFIG (source of truth: config-reference.md) ──
model_global_primary: "anthropic/claude-opus-4-6"
model_global_primary_alias: "researcher"
model_workhorse_general: "anthropic/claude-sonnet-4-5"
model_workhorse_general_alias: "workhorse"
model_workhorse_code: "openai/gpt-5.2"
model_workhorse_code_alias: "workhorse-code"
model_fallback_count: 4
---
# L2 — Runtime Layer

> How messages get in and out reliably. The OpenClaw gateway, configuration, secrets, authentication, and startup sequence. This is the "network layer" of the agent — it routes connections and ensures delivery.

**OSI parallel:** Network + Transport — routing, reliability, and connection management.

## Contents

- [[#Diagrams]]
  - [[#What's at This Layer]] · `flowchart`
- [[#Gateway]]
- [[#Config Structure]] · `flowchart`
- [[#Model Cascade]]
- [[#Authentication]]
- [[#Environment Variables (.env)]]
- [[#Startup Sequence]] · `flowchart`
- [[#Pages in This Layer]]
- [[#Layer Boundary]]
- [[#L2 File Review (Live)]]

---

## Diagrams

### What's at This Layer

```mermaid
flowchart TD
    L2["L2 — Runtime"]:::green
    L2 --> GW["Gateway<br>OpenClaw on :18789<br>Receives all inbound traffic"]:::blue
    L2 --> CONFIG["Config<br>openclaw.json<br>Single source of truth"]:::blue
    L2 --> ENV[".env<br>API keys, bot tokens<br>Secrets vault"]:::red
    L2 --> AUTH["Auth<br>Allowlist, DM pairing<br>Who can talk to Crispy"]:::amber
    L2 --> MODELS["Model Cascade<br>3-tier: researcher + 2 workhorse + 4 fallbacks<br>researcher → workhorse → workhorse-code → ..."]:::purple

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

---

## Gateway

The OpenClaw gateway is the single entry point for all traffic:

| Setting | Value | Notes |
|---|---|---|
| **Port** | 18789 | Default, configurable |
| **Health endpoint** | GET /health | Returns 200 if gateway is up |
| **Admin endpoint** | Various | Model switching, config reload |
| **Config file** | `~/.openclaw/openclaw.json` | JSON5 format |
| **Secrets** | `~/.openclaw/.env` | Loaded at startup |

---

## Config Structure

`openclaw.json` is organized into sections that map to layers:

```mermaid
flowchart TD
    JSON["openclaw.json"]:::blue
    JSON --> GW_SEC["gateway{}<br>port, bind, auth"]:::green
    JSON --> AGT_SEC["agents{}<br>defaults + agent list"]:::amber
    AGT_SEC --> AGT_MODEL["agents.defaults.model{}<br>primary + fallbacks"]:::purple
    AGT_SEC --> AGT_MODELS["agents.defaults.models{}<br>aliases, params, thinking"]:::purple
    AGT_SEC --> AGT_LIST["agents.list[]<br>crispy, crispy-code"]:::amber
    JSON --> CH_SEC["channels{}<br>telegram, discord"]:::teal
    JSON --> TOOL_SEC["tools{}<br>alsoAllow, permissions"]:::red
    JSON --> SKILL_SEC["skills{}<br>entries, enabled/disabled"]:::blue
    JSON --> MEM_SEC["memory{}<br>search, compaction"]:::purple

    GW_SEC -.->|"L2"| L2_NOTE["Runtime layer owns this"]:::gray
    AGT_SEC -.->|"L2"| L2_NOTE
    CH_SEC -.->|"L3"| L3_NOTE["Channel layer reads this"]:::gray
    TOOL_SEC -.->|"L6"| L6_NOTE["Processing layer"]:::gray

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
```

---

## Model Cascade

L2 manages the model routing — which model handles which task, and what happens when one fails:

| Tier | Alias | Model | Role |
|---|---|---|---|
| **Global Primary** | **researcher** | Claude Opus 4.6 (Anthropic) | Extended thinking, deep research |
| **Workhorse General** | **workhorse** | Claude Sonnet 4.5 (Anthropic) | Fast, cost-efficient general purpose |
| **Workhorse Code** | **workhorse-code** | GPT 5.2 (OpenAI) | Code generation, function calling |
| **Fallback 1** | **coder** | DeepSeek R1 | Deep reasoning, code gen |
| **Fallback 2** | **triage** | DeepSeek v3.2 | Intent classification (~200 tokens) |
| **Fallback 3** | **flash** | Gemini 2.5 Flash Lite | Cheap/fast tasks, heartbeats |
| **Fallback 4** | **free** | OpenRouter Auto | Emergency fallback |

**Actual fallback chains** (per-agent, from config-reference.md):

- `crispy`: workhorse → researcher → coder → triage → flash → free
- `crispy-code`: workhorse-code → researcher → coder → triage → flash → free
- Global defaults: researcher → coder → triage → flash → free

---

## Authentication

L2 handles who is allowed to talk to Crispy:

| Mechanism | Where | Effect |
|---|---|---|
| **DM Pairing** | Telegram config | Only paired users can DM |
| **Allowlist** | Channel config | Explicit user IDs or handles |
| **requireMention** | Discord server | Ignores messages without @Crispy |
| **Admin flag** | Agent config | Marty + Wenting = full access |

---

## Environment Variables (.env)

All secrets live in `~/.openclaw/.env`. L2 loads them at startup; other layers consume via `${VAR}` interpolation.

```
# 🔴 REQUIRED (gateway won't start without)
OPENCLAW_GATEWAY_TOKEN=oc_...        # Gateway auth
ANTHROPIC_API_KEY=sk-ant-...         # Researcher + workhorse models (Claude Opus 4.6, Sonnet 4.5)
OPENAI_API_KEY=sk-...                # Workhorse-code model (GPT 5.2)
OPENROUTER_API_KEY=sk-or-...         # Model hub (DeepSeek, Gemini, fallbacks)
GEMINI_API_KEY=AI...                 # Embeddings (memory search) + heartbeat model
TELEGRAM_BOT_TOKEN=123456:ABC...     # Primary channel
TELEGRAM_MARTY_ID=5452941776         # Admin allowlist
TELEGRAM_WENTING_ID=...              # Co-admin allowlist

# 🟡 IMPLEMENT NOW (essential for full features)
GITHUB_TOKEN=github_pat_...          # Workspace backup
BRAVE_API_KEY=BSA...                 # Web search tool
ELEVENLABS_API_KEY=...               # TTS for voice messages
ELEVENLABS_VOICE_ID=...              # Voice identity
MEM0_API_KEY=m0-...                  # Auto-memory capture

# 🔵 OPTIONAL (enable when ready)
DISCORD_BOT_TOKEN=...                # Secondary channel
OPENCLAW_HOOKS_TOKEN=...             # Gmail/webhook auth
GOG_KEYRING_PASSWORD=...             # Gaming skill keyring
```

> **Note:** Anthropic Claude Opus uses direct API key. OpenRouter provides fallback models. No OAuth needed.

---

## Startup Sequence

```mermaid
flowchart TD
    START["openclaw start"]:::gray
    START --> LOAD_ENV["Load .env"]:::green
    LOAD_ENV --> LOAD_CONFIG["Parse openclaw.json"]:::green
    LOAD_CONFIG --> VALID{"Config valid?"}:::amber
    VALID -->|No| FAIL["Startup failed<br>(run openclaw doctor)"]:::red
    VALID -->|Yes| MODELS["Initialize model connections"]:::green
    MODELS --> CHANNELS["Connect channels<br>(Telegram, Discord)"]:::teal
    CHANNELS --> PIPE["Load pipeline definitions"]:::blue
    PIPE --> SKILLS["Load skill manifests"]:::blue
    SKILLS --> READY["Gateway ready on :18789"]:::green

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
```

---

## Pages in This Layer

| Page | Covers |
|---|---|
| [[stack/L2-runtime/config-reference]] | Full openclaw.json walkthrough |
| [[stack/L2-runtime/env]] | Environment variables and secrets |
| [[stack/L2-runtime/gateway]] | Gateway setup, health checks, startup |
| [[stack/L2-runtime/models]] | Model cascade, aliases, fallback chain |
| [[stack/L2-runtime/runbook]] | Known issues and fixes needed |
| [[stack/L2-runtime/CHANGELOG]] | Layer changelog — all L2 changes by date |
| [[stack/L2-runtime/cross-layer-notes]] | Cross-layer notes from L2 sessions |

---

## Layer Boundary

**L2 receives from L1:** A running machine with Docker and network access.

**L2 provides to L3:** An authenticated, configured gateway that can route messages to/from channels.

**If L2 breaks:** Messages can't reach Crispy. Check `openclaw doctor`, then config, then .env.

---

## L2 File Review (Live)

```dataview
TABLE WITHOUT ID
  file.link AS "File",
  choice(contains(file.frontmatter.tags, "status/finalized"), "✅",
    choice(contains(file.frontmatter.tags, "status/review"), "🔍",
      choice(contains(file.frontmatter.tags, "status/planned"), "⏳", "📝"))) AS "Status",
  choice(contains(file.frontmatter.tags, "type/guide"), "Guide", "Core") AS "Type",
  dateformat(file.mtime, "yyyy-MM-dd") AS "Last Modified"
FROM "stack/L2-runtime"
WHERE file.name != "_overview"
SORT choice(contains(file.frontmatter.tags, "type/guide"), "Z", "A") ASC, file.name ASC
```

**Legend:** ✅ Finalized · 🔍 Review · 📝 Draft · ⏳ Planned

---

**Up →** [[stack/L3-channel/_overview]]
**Down →** [[stack/L1-physical/_overview]]
**Back →** [[stack/_overview]]
