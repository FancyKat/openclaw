---
tags: [layer/runtime, status/draft, topic/gateway, type/reference]
---
# L2 — Gateway

> The OpenClaw gateway — the single process that everything runs through. Port 18789, loopback binding, token auth.

**Operations guide →** [[stack/L2-runtime/runbook]]

---

## Overview

The gateway is the **core process** of the entire stack. Every message, every tool call, every model request flows through it. If the gateway is down, nothing works.

```mermaid
flowchart TD
    GW["OpenClaw Gateway<br>localhost:18789"]:::green
    GW --> AUTH["Token auth<br>$OPENCLAW_GATEWAY_TOKEN"]:::red
    GW --> BIND["Binding: loopback<br>(local connections only)"]:::green
    GW --> MODE["Mode: local<br>(single-user)"]:::green
    GW --> HEALTH["Health: GET /health<br>(returns 200 if up)"]:::blue

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
```

---

## Config

```json5
// openclaw.json → gateway section
"gateway": {
  "port": 18789,
  "bind": "loopback",     // Only local connections
  "mode": "local",         // Single-user mode
  "auth": {
    "mode": "token",
    "token": "${OPENCLAW_GATEWAY_TOKEN}"
  }
}
```

---

## Startup Sequence

```mermaid
flowchart TD
    S1["openclaw start"]:::gray
    S1 --> S2["Load .env"]:::red
    S2 --> S3["Parse openclaw.json"]:::blue
    S3 --> S4{"Config valid?"}:::amber
    S4 -->|No| FAIL["Startup failed<br>Run: openclaw doctor"]:::red
    S4 -->|Yes| S5["Initialize model<br>connections"]:::green
    S5 --> S6["Connect channels<br>(Telegram, Discord)"]:::teal
    S6 --> S7["Load pipeline<br>definitions"]:::blue
    S7 --> S8["Load skill<br>manifests"]:::blue
    S8 --> READY["Gateway ready<br>on :18789"]:::green

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
```

---

**Operations guide →** [[stack/L2-runtime/runbook]]
**Up →** [[stack/L2-runtime/_overview]]
