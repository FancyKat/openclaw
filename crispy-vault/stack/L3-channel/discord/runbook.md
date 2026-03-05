---
tags: [channel/discord, layer/channel, status/draft, type/runbook]
---

# Discord Runbook

> Step-by-step implementation guides for Discord-specific features: setup, decision trees, components, and server configuration.

---

## Discord Setup Guide


Complete Discord bot configuration: creating bot in Developer Portal, token setup, server configuration, and slash command registration.

**Steps:**
1. Create application in Discord Developer Portal
2. Create bot user, copy token to .env as `DISCORD_BOT_TOKEN`
3. Set OAuth2 scopes: `bot` + permissions (message.read, send, embed links, etc.)
4. Get server ID and channel IDs
5. Configure openclaw.json with server/channel setup
6. Register slash commands
7. Test with `/ask` command

**Key config:**
```json5
{
  "discord": {
    "botToken": "${DISCORD_BOT_TOKEN_CRISPY}",
    "serverIds": ["${DISCORD_GUILD_ID}"],
    "channels": {
      "general": { "id": "${DISCORD_GENERAL_ID}", "mode": "casual" },
      "dev": { "id": "${DISCORD_DEV_ID}", "mode": "technical" },
      "logs": { "id": "${DISCORD_LOGS_ID}", "writeOnly": true }
    }
  }
}
```

For full setup details, see [[stack/L3-channel/discord/_overview]]

---

## Decision Trees Guide


Implementing decision trees in Discord using button components and select menus.

**Rendering options:**
- Buttons with emoji labels
- Select menus for multi-select
- Modals for text input
- Embeds for rich formatting

**Example flow:**
```
User: "What would you like to do?"
     ↓
Buttons: [📋 Brief] [📧 Email] [🔀 Git] [❓ Other]
     ↓
User taps [📧 Email]
     ↓
Show: "Running email triage..." + chains to approval buttons
```

**Key differences from Telegram:**
- Button styling (Primary/Secondary/Danger/Success)
- Select menus instead of cascading buttons
- Modals for form input
- Embeds for structured output

---

## Components Reference


Discord interactive elements: buttons, select menus, modals, and rich embeds.

**Buttons:**
- Styles: Primary (blue), Secondary (gray), Danger (red), Success (green)
- Include emojis and labels
- Can be disabled or external links
- Max 5 buttons per row

**Select Menus:**
- Single or multi-select
- Max 25 options
- Placeholder text and descriptions
- Validation on submission

**Modals:**
- Text input forms
- Short (single line) or paragraph input
- Required/optional fields
- Max 5 fields per modal

**Embeds:**
- Rich formatted messages
- Title + description + fields
- Color coding (success/warning/error/info)
- Thumbnail/image support
- Footer with timestamp

**Config:**
```json5
{
  "discord": {
    "components": {
      "buttons": { "maxPerRow": 5 },
      "selects": { "maxOptions": 25 },
      "modals": { "maxFields": 5 },
      "embeds": { "defaultColor": 0x3b82f6, "maxFields": 25 }
    }
  }
}
```

---

## Message Routing

**DM (Direct Message):**
- Full interaction mode
- All components available
- Full context + memory
- Same as Telegram DM minus voice

**@Mention in Channel:**
- Limited mode (brief responses)
- @mention required
- Shorter max length (~500 words)
- Auto-threads for longer responses

**Channel Behavior:**
- `#general`: Casual mode, brief replies
- `#dev`: Technical mode, longer technical replies
- `#crispy-logs`: Write-only (Crispy posts only)

---

## Slash Commands

**Pre-defined commands:**
- `/ask <question>` — Free-form query to agent
- `/status` — System health check (embed)
- `/save [message]` — Commit + push workspace
- `/pipeline <name>` — Run or list pipelines
- `/memory <query>` — Vector search memory
- `/help` — Command list

**Registration:** Done at bot startup via API

---

## Threading

**Auto-threading when:**
- Response exceeds ~500 words
- Main message shows initial response
- Thread created with follow-up blocks

**Flow:**
```
Main: "Here's the answer..."
  ↓
Thread reply 1: "[Block 1]"
  ↓
Thread reply 2: "[Block 2]"
  ↓
Thread reply 3: "[Block 3 - conclusion]"
```

---

## Voice Channel Integration

**Setup:**
```json5
{
  "discord": {
    "voice": {
      "enabled": true,
      "auto_join_on_mention": false,
      "stt": "deepgram",           // streaming STT
      "tts": "elevenlabs",         // streaming TTS
      "silence_timeout_s": 2,
      "max_session_duration_s": 3600
    }
  }
}
```

**Flow:**
1. Bot joins voice channel on user request
2. Listens to audio stream (PCM 48kHz)
3. Buffers 1-2 second chunks
4. Streams to Deepgram STT in real-time
5. When user stops (2s silence), processes with agent
6. TTS synthesizes response
7. Bot speaks back in channel
8. Auto-leaves after timeout or silence

---

## Multi-Bot Workspace Setup

When running multiple Discord bots (each as a separate agent), each needs its own workspace:

```bash
# 1. Create workspace directory for each bot
mkdir -p ~/.openclaw/workspace-discord-1
mkdir -p ~/.openclaw/workspace-discord-2

# 2. Copy shared files from primary workspace
cp ~/.openclaw/workspace/SOUL.md ~/.openclaw/workspace-discord-1/
cp ~/.openclaw/workspace/SOUL.md ~/.openclaw/workspace-discord-2/

# 3. Write specialized AGENTS.md for each bot's role
cat > ~/.openclaw/workspace-discord-1/AGENTS.md << 'EOF'
# Trading Bot Agent
You are a specialized trading channel bot. Focus on market analysis,
position tracking, and financial discussions. Defer non-trading topics
to the main Crispy bot.
EOF

cat > ~/.openclaw/workspace-discord-2/AGENTS.md << 'EOF'
# Coding Bot Agent
You are a specialized coding channel bot. Focus on code review,
debugging, and development workflows. Defer non-coding topics
to the main Crispy bot.
EOF

# 4. Initialize memory directories
mkdir -p ~/.openclaw/workspace-discord-1/memory
mkdir -p ~/.openclaw/workspace-discord-2/memory
```

**Config additions** (in `openclaw.json` — see [[stack/L2-runtime/config-reference]] for agent bindings):

```json5
// agents.list — add specialized bots
{ "id": "discord-bot-1", "workspace": "~/.openclaw/workspace-discord-1",
  "heartbeat": { "every": "1h", "target": "none", "directPolicy": "suppress" } },
{ "id": "discord-bot-2", "workspace": "~/.openclaw/workspace-discord-2",
  "heartbeat": { "every": "1h", "target": "none", "directPolicy": "suppress" } }

// agents.bindings — route channels to bots
{ "agentId": "discord-bot-1", "match": { "channel": "discord1" } },
{ "agentId": "discord-bot-2", "match": { "channel": "discord2" } }

// channels — add channel instances
"discord1": { "token": "${DISCORD_BOT_TOKEN_AGENT1}", "dmPolicy": "pairing",
  "guilds": { "${DISCORD_GUILD_ID}": { "requireMention": false } } },
"discord2": { "token": "${DISCORD_BOT_TOKEN_AGENT2}", "dmPolicy": "pairing",
  "guilds": { "${DISCORD_GUILD_ID}": { "requireMention": false } } }
```

**Env vars** (add to `.env`):
```bash
DISCORD_BOT_TOKEN_AGENT1=    # Bot 1 token from Developer Portal
DISCORD_BOT_TOKEN_AGENT2=    # Bot 2 token from Developer Portal
```

---

## References

**Core Documentation:**
- [[stack/L3-channel/discord/_overview]] — Config, behavior rules
- [[stack/L3-channel/discord/chat-flow]] — Message lifecycle, routing, components, media, slash commands

**Related:**
- [[stack/L5-routing/decision-trees]] — Generic decision tree patterns
- [[stack/L2-runtime/config-reference]] — Agent bindings and workspace config
- [[architecture-diagrams]] — Multi-bot architecture class diagram

---

**Up →** [[stack/L3-channel/discord/_overview]]
**Core →** [[stack/L3-channel/discord/chat-flow]]
