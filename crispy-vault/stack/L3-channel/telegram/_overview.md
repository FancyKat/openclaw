---
tags: [channel/telegram, layer/channel, status/draft, type/index]
channel_name: Telegram
channel_slug: telegram
channel_role: orchestrator
interaction_model: "1:1"
session_type: full
focus_modes: true
status_connection: active
---
# Telegram Channel

> Crispy's primary channel. Full-featured DM experience with inline keyboards, voice transcription, custom commands, and streaming responses.

## Architectural Role

Telegram is the **primary 1:1 orchestrator**. The full Focus Mode Tree system is designed for Telegram first — decision flows, inline keyboards, and execution authority all run here. Marty talks to one Crispy instance with full context.

---

## Config

> Authoritative config → [[stack/L3-channel/config-reference]]. Below is a summary for context.

```json5
"channels": {
  "telegram": {
    "botToken": "${TELEGRAM_BOT_TOKEN}",
    "dmPolicy": "allowlist",
    "allowFrom": ["tg:${TELEGRAM_MARTY_ID}", "tg:${TELEGRAM_WENTING_ID}"],
    "groups": { "*": { "requireMention": true } },
    "streaming": "partial",
    "customCommands": {
      "brief": { "description": "Morning briefing" },
      "email": { "description": "Email triage" },
      "git": { "description": "Git status" },
      "pipelines": { "description": "List pipelines" }
    }
  }
}
```

---

## Behavior Rules

| Rule | Detail |
|---|---|
| **Voice** | Voice messages → transcribe → process as text → respond with voice |
| **Buttons** | Use inline keyboards when 2+ choices. Max 2x2 grid with escape hatch |
| **Streaming** | Responses stream in real-time (edit-in-place) |
| **DM context** | Full bootstrap + memory + session history |
| **Group context** | Not currently enabled |

---

## Pages

| Page | Covers |
|---|---|
| [[stack/L3-channel/telegram/chat-flow]] | Full Telegram message lifecycle + conversation flows |
| [[stack/L3-channel/telegram/button-patterns]] | 4 button pattern types + depth rules + chaining |
| [[stack/L3-channel/telegram/media-handling]] | Media handling (voice, photo, video, docs) |
| [[stack/L3-channel/telegram/pipelines]] | All pipeline patterns: approve-deny, exec-approve, decision-tree, quick-actions, notify, media |
| [[stack/L3-channel/telegram/runbook]] | Setup + operations guide |

---

**Up →** [[stack/L3-channel/_overview]]
**Back →** [[stack/_overview]]
