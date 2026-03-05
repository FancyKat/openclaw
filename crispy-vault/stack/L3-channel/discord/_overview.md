---
tags: [channel/discord, layer/channel, status/draft, type/index]
channel_name: Discord
channel_slug: discord
channel_role: council
interaction_model: "many-to-many"
session_type: multi-agent
focus_modes: true
status_connection: planned
---
# Discord Channel

> Crispy's secondary channel. DMs mirror Telegram (minus voice). Server mode uses @mention, embeds, slash commands, and auto-threading.

## Architectural Role

Discord is the **council / multi-agent** channel. Multiple Crispy bots run in separate Docker containers, each with a different role. They connect and talk to each other and to users like a council. Family members can join. Users can bring their own OpenClaw instance. Focus Modes on Discord are per-bot, not per-conversation — multiple hats can be active simultaneously across bot instances.

---

## Config

> Authoritative config → [[stack/L3-channel/config-reference]]. Below is a summary for context.

```json5
// Primary Discord bot (bound to crispy agent)
"channels": {
  "discord": {
    "enabled": false,
    "token": "${DISCORD_BOT_TOKEN_CRISPY}",
    "dmPolicy": "pairing",
    "guilds": {
      "${DISCORD_GUILD_ID}": { "requireMention": false }
    }
  }
}

// Multi-bot scaling: add discord1, discord2, etc.
// Each instance gets its own bot token and agent binding.
// See config-reference for the full multi-instance pattern.
```

### Multi-Agent Discord Architecture

Multiple bots can serve the same guild, each with a specialized role and isolated workspace:

```
discord   → crispy          → workspace/              (general)
discord1  → discord-bot-1   → workspace-discord-1/    (trading)
discord2  → discord-bot-2   → workspace-discord-2/    (coding)
```

Each bot has its own AGENTS.md, MEMORY.md, and daily logs. SOUL.md can be shared (same personality) or specialized. See [[stack/L3-channel/discord/runbook#Multi-Bot Workspace Setup]] for setup instructions and [[stack/L2-runtime/config-reference]] for agent bindings.

---

## Behavior Rules

### DMs
- Same as Telegram DMs minus voice
- Full context (bootstrap + memory + history)
- No inline buttons (use Discord components instead)

### Server
- Only responds when @Crispy mentioned
- Embeds for structured output (tables, code blocks, status)
- Auto-creates thread when response exceeds ~500 characters
- #crispy-logs channel = write-only (Crispy posts, doesn't read)
- Shorter responses in group context

---

## Pages

| Page | Covers |
|---|---|
| [[stack/L3-channel/discord/chat-flow]] | Discord message lifecycle, event handling, embeds, slash commands, auto-threading |
| [[stack/L3-channel/discord/runbook]] | Discord setup + operations guide |

---

**Up →** [[stack/L3-channel/_overview]]
**Back →** [[stack/_overview]]
