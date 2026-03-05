---
tags: [layer/physical, status/review, type/reference, topic/config]
---
# L1 Config Reference — Physical Layer

> Single source of truth for L1-owned openclaw.json config blocks. Build script reads `^config-*` blocks from this file.

**Up →** [[stack/L1-physical/_overview]]

**Owner:** L1-Physical | **Produces:** `gateway`, `hooks` sections of openclaw.json

---

## Gateway Config

<!-- ^config-gateway -->
<!-- STATUS: ✅ -->
<!-- REASON: Gateway is the single Node.js process. loopback + token = secure local-only access. -->
<!-- NOTE: Port and bind values sourced from L1 _overview.md frontmatter properties. -->

```json
{
  "gateway": {
    "port": 18789,
    "bind": "loopback",
    "mode": "local",
    "auth": {
      "mode": "token",
      "token": "${OPENCLAW_GATEWAY_TOKEN}"
    }
  }
}
```
^config-gateway

| Key | Value | Source |
|-----|-------|--------|
| port | `= [[stack/L1-physical/_overview]].network_gateway_port` | L1 |
| bind | `= [[stack/L1-physical/_overview]].network_gateway_bind` | L1 |
| mode | `= [[stack/L1-physical/_overview]].network_gateway_mode` | L1 |
| auth.mode | `= [[stack/L1-physical/_overview]].network_gateway_auth_mode` | L1 |

---

## Hooks Config

<!-- ^config-hooks -->
<!-- STATUS: ⚠️ -->
<!-- REASON: Combined webhook + event hooks. Webhooks route inbound HTTP (Gmail) to agents. Event hooks fire at gateway level before agent session — media-sort is the zero-token primary sorter. -->
<!-- NOTE: Per OpenClaw spec: mappings = webhook routing, entries = event-driven hooks. OPENCLAW_HOOKS_TOKEN is optional until Gmail integration goes live. -->

```json
{
  "hooks": {
    "enabled": true,
    "token": "${OPENCLAW_HOOKS_TOKEN}",
    "path": "/hooks",
    "mappings": [
      {
        "match": { "path": "gmail" },
        "action": "agent",
        "agentId": "crispy",
        "deliver": true
      }
    ],
    "entries": {
      "media-sort": {
        "kind": "lobster",
        "pipeline": "pipelines/media-sort.lobster",
        "on": "message.inbound",
        "condition": "message.hasAttachment"
      }
    }
  }
}
```
^config-hooks

| Key | Value | Source |
|-----|-------|--------|
| token | `${OPENCLAW_HOOKS_TOKEN}` | .env (optional until Gmail) |
| path | `/hooks` | OpenClaw default |
| entries.media-sort.kind | `lobster` | Zero-token deterministic pipeline |
| entries.media-sort.on | `message.inbound` | Gateway-level event trigger |
| entries.media-sort.condition | `message.hasAttachment` | Only processes media messages |
