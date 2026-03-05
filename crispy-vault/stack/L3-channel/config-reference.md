---
tags: [layer/channel, status/draft, type/config]
---
# L3 Config Reference — Channel Layer

> Single source of truth for L3-owned `openclaw.json` config blocks. Build script reads `^config-*` blocks from this file.

**Up →** [[stack/L3-channel/_overview]]

---

## Channel Config

<!-- ^config-channels -->
<!-- STATUS: ✅ -->
<!-- REASON: Multi-instance channel support. Each channel type can have N instances using channelN naming (telegram, telegram1, telegram2...). Agent-to-channel binding in L2 config-reference.md. -->
<!-- NOTE: Telegram is primary (Marty). telegram1 is Wenting's instance. Discord planned. Gmail is webhook-only via ^config-hooks (L1), not a channel block. -->

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "${TELEGRAM_BOT_TOKEN_CRISPY}",
      "dmPolicy": "allowlist",
      "allowFrom": ["tg:${TELEGRAM_MARTY_ID}"],
      "groups": {
        "*": { "requireMention": true }
      },
      "streaming": "partial",
      "customCommands": {
        "brief": { "description": "Morning briefing" },
        "email": { "description": "Email triage" },
        "git": { "description": "Git status" },
        "pipelines": { "description": "List pipelines" }
      },
      "media": {
        "enabled": true,
        "inbound_path": "~/.openclaw/workspace/media/inbound/telegram",
        "keep_sizes": ["large"],
        "max_file_size_mb": 2000,
        "cache_downloaded_24h": true,
        "create_metadata": true,
        "metadata_format": "json"
      }
    },
    "telegram1": {
      "enabled": true,
      "botToken": "${TELEGRAM_BOT_TOKEN_WENTING}",
      "dmPolicy": "allowlist",
      "allowFrom": ["tg:${TELEGRAM_WENTING_ID}"],
      "groups": {
        "*": { "requireMention": true }
      },
      "streaming": "partial",
      "customCommands": {
        "brief": { "description": "Morning briefing" },
        "email": { "description": "Email triage" },
        "git": { "description": "Git status" },
        "pipelines": { "description": "List pipelines" }
      },
      "media": {
        "enabled": true,
        "inbound_path": "~/.openclaw/workspace-wenting/media/inbound/telegram",
        "keep_sizes": ["large"],
        "max_file_size_mb": 2000,
        "cache_downloaded_24h": true,
        "create_metadata": true,
        "metadata_format": "json"
      }
    },
    "discord": {
      "enabled": false,
      "token": "${DISCORD_BOT_TOKEN_CRISPY}",
      "dmPolicy": "pairing",
      "guilds": {
        "${DISCORD_GUILD_ID}": {
          "requireMention": false
        }
      }
    }
  }
}
```
^config-channels

### Multi-Instance Naming Convention

Channel instances follow `{type}{N}` naming. The first instance omits the index:

| Key | Type | Instance | Agent (via binding) |
|-----|------|----------|---------------------|
| `telegram` | Telegram | Primary (Marty) | crispy |
| `telegram1` | Telegram | Second (Wenting) | crispy-wenting |
| `discord` | Discord | Primary guild | crispy |
| `discord1` | Discord | Second guild | discord-bot-1 |
| `discord2` | Discord | Third guild | discord-bot-2 |

**Agent binding:** Each channel instance maps to exactly one agent via `agents.bindings` in [[stack/L2-runtime/config-reference]]. The binding determines which workspace, heartbeat, and model config the channel uses.

**Adding instances:** Copy an existing channel block, increment the suffix, and update the bot token env var to the indexed form (`${DISCORD_BOT_TOKEN_AGENT1}`).

### Channel Status

| Channel | Status | DM Policy | Instances |
|---------|--------|-----------|-----------|
| Telegram | ✅ Active | allowlist | 2 (Marty + Wenting) |
| Discord | 🔲 Planned | pairing | 1 (expandable) |

---

## Voice Config (Planned)

> Voice config blocks in `voice-pipeline.md` are draft/reference only. When voice is production-ready, extract the canonical config here as `^config-voice`.
