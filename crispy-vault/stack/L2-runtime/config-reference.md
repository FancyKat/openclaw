---
tags: [layer/runtime, status/draft, topic/config, type/reference]
---
# L2 Config Reference — Runtime Layer
<!-- Single source of truth for L2-owned openclaw.json config blocks -->
<!-- Build script reads ^config-* blocks from this file -->

> Single source of truth for the `agents` section of openclaw.json — models, aliases, fallback chains, agent routing, and sandbox config.

**Owner:** L2-Runtime | **Produces:** `agents` section of openclaw.json

| Property | Value |
|----------|-------|
| **Global primary** | `anthropic/claude-opus-4-6` (alias: researcher) — deep research, extended thinking |
| **Workhorse (general)** | `anthropic/claude-sonnet-4-5` (alias: workhorse) — crispy default |
| **Workhorse (code)** | `openai/gpt-5.2` (alias: workhorse-code) — crispy-code default |
| **Auth** | `ANTHROPIC_API_KEY` (researcher + workhorse) · `OPENAI_API_KEY` (workhorse-code) · `OPENROUTER_API_KEY` (fallbacks) |

---

## Agents Config

<!-- ^config-agents -->
<!-- STATUS: ✅ -->
<!-- REASON: All model routing lives in agents per OpenClaw spec — primary + fallbacks pattern. skipBootstrap set to false — bootstrap complete. -->
<!-- NOTE: Researcher + workhorse use ANTHROPIC_API_KEY; workhorse-code uses OPENAI_API_KEY; fallbacks route through OPENROUTER_API_KEY. L7 adds agents.defaults.memorySearch and agents.defaults.auditLog via deepMerge. -->
<!-- MULTI-BOT: Each agent gets its own workspace, optional heartbeat override. Bindings map agents to channels. Additional agents scale via --agents CLI or manual JSON entries. -->

```json
{
  "agents": {
    "defaults": {
      "workspace": "~/.openclaw/workspace",
      "model": {
        "primary": "anthropic/claude-opus-4-6",
        "fallbacks": [
          "openrouter/deepseek/deepseek-r1",
          "openrouter/deepseek/deepseek-chat-v3.2",
          "openrouter/google/gemini-2.5-flash-lite-preview",
          "openrouter/openrouter/auto"
        ]
      },
      "models": {
        "anthropic/claude-opus-4-6": {
          "alias": "researcher",
          "params": {
            "extended_thinking": true,
            "thinking": "high",
            "maxTokens": 16384
          }
        },
        "anthropic/claude-sonnet-4-5": {
          "alias": "workhorse",
          "params": { "maxTokens": 8192 }
        },
        "openai/gpt-5.2": {
          "alias": "workhorse-code",
          "params": { "maxTokens": 8192 }
        },
        "openrouter/deepseek/deepseek-r1": { "alias": "coder" },
        "openrouter/deepseek/deepseek-chat-v3.2": { "alias": "triage" },
        "openrouter/google/gemini-2.5-flash-lite-preview": { "alias": "flash" },
        "openrouter/openrouter/auto": { "alias": "free" }
      },
      "compaction": {
        "enabled": true,
        "model": "flash"
      },
      "skipBootstrap": false,
      "heartbeat": {
        "every": "20m",
        "target": "last",
        "directPolicy": "allow"
      },
      "sandbox": {
        "mode": "all",
        "scope": "session",
        "workspaceAccess": "rw",
        "docker": {
          "enabled": true,
          "image": "openclaw-sandbox:bookworm-slim",
          "readOnlyRoot": true,
          "network": "bridge",
          "memory": "2g",
          "cpus": 2
        }
      }
    },
    "list": [
      {
        "id": "crispy",
        "default": true,
        "workspace": "~/.openclaw/workspace",
        "identity": { "name": "Crispy", "emoji": "🦊" },
        "model": {
          "primary": "anthropic/claude-sonnet-4-5",
          "fallbacks": [
            "anthropic/claude-opus-4-6",
            "openrouter/deepseek/deepseek-r1",
            "openrouter/deepseek/deepseek-chat-v3.2",
            "openrouter/google/gemini-2.5-flash-lite-preview",
            "openrouter/openrouter/auto"
          ]
        }
      },
      {
        "id": "crispy-code",
        "workspace": "~/.openclaw/workspace",
        "identity": { "name": "Crispy Code", "emoji": "🔧" },
        "model": {
          "primary": "openai/gpt-5.2",
          "fallbacks": [
            "anthropic/claude-opus-4-6",
            "openrouter/deepseek/deepseek-r1",
            "openrouter/deepseek/deepseek-chat-v3.2",
            "openrouter/google/gemini-2.5-flash-lite-preview",
            "openrouter/openrouter/auto"
          ]
        }
      },
      {
        "id": "crispy-wenting",
        "workspace": "~/.openclaw/workspace-wenting",
        "identity": { "name": "Crispy", "emoji": "🦊" },
        "model": {
          "primary": "anthropic/claude-sonnet-4-5",
          "fallbacks": [
            "anthropic/claude-opus-4-6",
            "openrouter/deepseek/deepseek-r1",
            "openrouter/deepseek/deepseek-chat-v3.2",
            "openrouter/google/gemini-2.5-flash-lite-preview",
            "openrouter/openrouter/auto"
          ]
        }
      }
    ],
    "bindings": [
      { "agentId": "crispy", "match": { "channel": "telegram" } },
      { "agentId": "crispy-wenting", "match": { "channel": "telegram1" } },
      { "agentId": "crispy", "match": { "channel": "discord" } }
    ]
  }
}
```
^config-agents

### Agent Bindings

Bindings route channels to agents. Each binding has an `agentId` and a `match` pattern:

| Binding | Agent | Channel | Workspace |
|---------|-------|---------|-----------|
| telegram → crispy | crispy | telegram | `~/.openclaw/workspace` |
| telegram1 → crispy-wenting | crispy-wenting | telegram1 | `~/.openclaw/workspace-wenting` |
| discord → crispy | crispy | discord | `~/.openclaw/workspace` |

**Scaling:** Add more agents and bindings as needed. Discord multi-bot example:

```json5
// Add to agents.list:
{ "id": "discord-bot-1", "workspace": "~/.openclaw/workspace-discord-1",
  "heartbeat": { "every": "1h", "target": "none", "directPolicy": "suppress" }
}

// Add to agents.bindings:
{ "agentId": "discord-bot-1", "match": { "channel": "discord1" } }
```

**Per-agent overrides:** Any agent in the list can override `heartbeat`, `model`, `compaction`, or `sandbox` from defaults. Only specified fields are overridden — everything else inherits from `agents.defaults`.

### Workspace Isolation

Each agent owns its own workspace directory. Workspaces are isolated — an agent cannot see another agent's memory or context files:

```
~/.openclaw/workspace/              ← crispy (primary)
    SOUL.md, AGENTS.md, MEMORY.md, daily_logs/, sessions/
~/.openclaw/workspace-wenting/      ← crispy-wenting
    SOUL.md, AGENTS.md, MEMORY.md, daily_logs/, sessions/
~/.openclaw/workspace-discord-1/    ← discord-bot-1
    SOUL.md, AGENTS.md, MEMORY.md, daily_logs/, sessions/
```

**Setup:** Copy shared files (SOUL.md) from the primary workspace. Write specialized AGENTS.md for each agent's role. See [[stack/L3-channel/discord/runbook]] for multi-bot workspace setup.

### Model Aliases Quick Reference

| Alias | Provider | Model ID | Thinking | Use Case |
|-------|----------|----------|----------|----------|
| researcher | anthropic (direct) | claude-opus-4-6 | extended, high | **Global primary** — research, planning, complex reasoning, learning |
| workhorse | anthropic (direct) | claude-sonnet-4-5 | — | **Crispy default** — general tasks, conversation, daily work |
| workhorse-code | openai (direct) | gpt-5.2 | — | **Crispy Code default** — code generation, refactoring, debugging |
| coder | openrouter | deepseek-r1 | — | Fallback code generation |
| triage | openrouter | deepseek-chat-v3.2 | — | Quick classification, routing |
| flash | openrouter | gemini-2.5-flash-lite | — | Cheap tasks, heartbeat, summaries |
| free | openrouter | openrouter/auto | — | Fallback — free tier |

Switch at runtime: `/model <alias>`

### Model Routing

```
crispy (general)   → sonnet-4-5 → opus-4-6 → deepseek-r1 → deepseek-v3.2 → gemini-flash → auto
crispy-code        → gpt-5.2    → opus-4-6 → deepseek-r1 → deepseek-v3.2 → gemini-flash → auto
/model researcher  → opus-4-6   (manual escalation for deep research)
```

### Model Properties (Single Source of Truth)

These values are the canonical reference for model configuration across the vault:

| Property | Value |
|----------|-------|
| `model_global_primary` | `anthropic/claude-opus-4-6` |
| `model_global_primary_alias` | `researcher` |
| `model_workhorse_general` | `anthropic/claude-sonnet-4-5` |
| `model_workhorse_general_alias` | `workhorse` |
| `model_workhorse_code` | `openai/gpt-5.2` |
| `model_workhorse_code_alias` | `workhorse-code` |
| `model_primary_provider` | `anthropic` |
| `model_primary_auth` | `ANTHROPIC_API_KEY` |
| `model_primary_thinking` | `extended, high` |
| `model_workhorse_code_provider` | `openai` |
| `model_workhorse_code_auth` | `OPENAI_API_KEY` |
| `model_fallback_count` | `4` |
| `model_fallback_provider` | `openrouter` |
| `model_fallback_auth` | `OPENROUTER_API_KEY` |

> To change models: update this file, then run `build.sh` to regenerate openclaw.json. All other files reference this config-reference as the source of truth.

---

**Up →** [[stack/L2-runtime/_overview]]
