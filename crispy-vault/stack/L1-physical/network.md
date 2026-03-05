---
tags: [layer/physical, status/review, type/reference, topic/network]
---
# L1 — Network

> Network topology — what ports are open, what connects where, and how traffic flows in and out.
> **Properties live in [[stack/L1-physical/_overview]].** This file provides context and explanations.

---

## Outbound Connections (Crispy → Internet)

```mermaid
flowchart TD
    GW["Gateway :18789"]:::green
    GW -->|HTTPS| TG["Telegram Bot API"]:::teal
    GW -->|WSS| DC["Discord Gateway"]:::blue
    GW -->|HTTPS| OAI["OpenAI (Codex)"]:::green
    GW -->|HTTPS| OR["OpenRouter<br>(Opus, DeepSeek, Gemini)"]:::blue
    GW -->|HTTPS| BRAVE["Brave Search API"]:::amber
    GW -->|HTTPS| GEM["Google Gemini<br>(embeddings)"]:::teal
    GW -->|HTTPS| E11["ElevenLabs (TTS)"]:::purple

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

---

## Inbound Connections (Internet → Desktop)

```mermaid
flowchart TD
    GM_HOOK["Gmail Webhook"]:::amber -->|HTTPS| GW["Gateway :18789"]:::green
    TS["Tailscale (remote admin)"]:::teal -->|WireGuard| SHELL["Desktop SSH"]:::gray

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
```

---

## Connection Table

| Direction | Protocol | Destination | Auth Method | CKS Layer |
|---|---|---|---|---|
| Outbound | HTTPS | Telegram Bot API | Bot token | L3 — Channel |
| Outbound | WSS | Discord Gateway | Bot token | L3 — Channel |
| Outbound | HTTPS | OpenAI (Codex) | OAuth (auto-refresh) | L6 — Processing |
| Outbound | HTTPS | OpenRouter | API key | L6 — Processing |
| Outbound | HTTPS | Google Gemini | API key | L6 — Processing |
| Outbound | HTTPS | Brave Search | API key | L6 — Processing |
| Outbound | HTTPS | ElevenLabs | API key | L3 — Channel |
| Outbound | HTTPS | GitHub API | Fine-grained PAT | L6 — Processing |
| Inbound | HTTPS | Gmail webhooks | Hooks token | L3 — Channel |
| Inbound | WireGuard | Tailscale (admin) | Device auth | L1 — Physical |

---

## Port Configuration

| Port | Binding | Purpose | Exposed? |
|---|---|---|---|
| **`= [[_overview]].network_gateway_port`** | `= [[_overview]].network_gateway_bind` (localhost only) | OpenClaw gateway | No (local only) |
| **11434** | `localhost` | Ollama (if running) | No |
| **6333** | `localhost` | Qdrant (if running) | No |
| **7474/7687** | `localhost` | Neo4j (if running) | No |

**No ports are exposed to the public internet.** Telegram and Discord use outbound connections (long-polling / WebSocket). Gmail webhooks need a tunnel (Tailscale or ngrok).

---

## Security Posture

```mermaid
flowchart TD
    INTERNET["Internet"]:::gray
    INTERNET -->|"No direct inbound<br>(except via tunnel)"| FW["Firewall / Router"]:::red
    FW -->|"Tailscale only"| DESKTOP["Desktop"]:::green
    DESKTOP -->|"Loopback only"| GW["Gateway :18789"]:::blue

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
```

Key security features:
- Gateway binds to `= [[_overview]].network_gateway_bind` — no external access without tunnel
- All model API calls use HTTPS (encrypted in transit)
- Channel tokens stored in .env (never in config)
- Tailscale provides encrypted remote access without exposing ports

---

## Verification Commands

```bash
# Is the gateway listening?
ss -tlnp | grep 18789

# Can you reach it locally?
curl http://localhost:18789/health

# Check outbound connectivity
curl -I https://api.telegram.org
curl -I https://api.openai.com

# Check Tailscale
tailscale status

# DNS resolution
dig api.telegram.org
```

---

**Up →** [[stack/L1-physical/_overview]]
