---
tags: [layer/processing, status/draft, type/config]
---
# L6 Config Reference — Processing Layer

> Single source of truth for L6-owned openclaw.json config blocks: tools, plugins, cron, skills.

**Up →** [[stack/L6-processing/_overview]]

<!-- Build script reads ^config-* blocks from this file -->
<!-- **Owner:** L6-Processing | **Produces:** `tools`, `plugins`, `cron`, `skills` sections of openclaw.json -->

---

## Tools Config

<!-- ^config-tools -->
<!-- STATUS: ✅ -->
<!-- REASON: Tool permissions — lobster for pipeline execution, Brave for web search, audio enabled for voice -->
<!-- NOTE: `alsoAllow: ["lobster"]` grants Lobster pipeline tool access alongside agent tools. Brave search requires BRAVE_API_KEY in .env. Audio enabled for voice message processing (L3 voice pipeline). -->

```json
{
  "tools": {
    "alsoAllow": ["lobster"],
    "web": {
      "search": {
        "provider": "brave",
        "apiKey": "${BRAVE_API_KEY}"
      }
    },
    "media": {
      "audio": { "enabled": true }
    }
  }
}
```
^config-tools

---

## Plugins Config

<!-- ^config-plugins -->
<!-- STATUS: ✅ -->
<!-- REASON: Lobster for pipeline execution, llm-task for lightweight sub-tasks within pipelines -->
<!-- NOTE: llm-task maxTokens 800 limits sub-task scope (fast flash calls). timeout 30s prevents hangs on slow model responses. -->

```json
{
  "plugins": {
    "lobster": { "enabled": true },
    "llm-task": {
      "enabled": true,
      "maxTokens": 800,
      "timeout": 30
    }
  }
}
```
^config-plugins

---

## Cron Config

<!-- ^config-cron -->
<!-- STATUS: ✅ -->
<!-- REASON: Cron job scheduler for recurring pipeline tasks — media catchup (every 30m) and daily cleanup (2am) -->
<!-- NOTE: `maxConcurrentRuns` (not `maxConcurrent`) per OpenClaw spec. `sessionRetention: "24h"` keeps cron session logs for 24 hours. media-catchup and media-cleanup are safety nets from L3 media pipeline. -->

```json
{
  "cron": {
    "enabled": true,
    "maxConcurrentRuns": 2,
    "sessionRetention": "24h",
    "jobs": [
      {
        "name": "media-catchup",
        "cron": "*/30 * * * *",
        "kind": "lobster",
        "pipeline": "pipelines/media-catchup.lobster"
      },
      {
        "name": "media-cleanup",
        "cron": "0 2 * * *",
        "kind": "lobster",
        "pipeline": "pipelines/media-cleanup.lobster"
      }
    ]
  }
}
```
^config-cron

---

## Skills Config

<!-- ^config-skills -->
<!-- STATUS: ✅ -->
<!-- REASON: Skill registry — enables bundled skills and configures extra load dirs and installer preferences -->
<!-- NOTE: `entries` (not `installed`) is the correct field per OpenClaw skills spec. `sag` = skill-auto-generate (bundled). `gog` = GOG keyring skill (requires GOG_KEYRING_PASSWORD in .env). Skills in ~/.openclaw/skills/ auto-load without being listed here. `allowBundled` is an alternative to `entries` for whitelist-only mode. Source: .claude/skills/openclaw-debugger/references/skills-system.md -->

```json
{
  "skills": {
    "entries": {
      "sag": { "enabled": true },
      "gog": {
        "enabled": true,
        "env": { "GOG_KEYRING_PASSWORD": "${GOG_KEYRING_PASSWORD}" }
      }
    },
    "load": {
      "watch": true,
      "watchDebounceMs": 250
    },
    "install": {
      "preferBrew": true,
      "nodeManager": "npm"
    }
  }
}
```
^config-skills
