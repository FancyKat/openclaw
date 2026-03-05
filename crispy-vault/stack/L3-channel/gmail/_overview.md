---
tags: [layer/channel, channel/gmail, status/draft, type/index]
channel_name: Gmail
channel_slug: gmail
channel_role: info-gathering
interaction_model: "inbound-only"
session_type: none
focus_modes: false
status_connection: planned
---
# Gmail Channel

> Gmail is triggered via webhook only (not DM mode). When emails arrive, Crispy processes them and routes them to appropriate pipelines.

## Architectural Role

Gmail is the **information gathering** channel. No interactive sessions — incoming email triggers category-aware memory writes (recipe newsletter -> cooking memory, market update -> finance memory). Data is ready for retrieval when the relevant hat loads on Telegram. Outbound email requires safeguards and explicit user approval.

---

## What It Is

Gmail integration is **read-only webhook** — Crispy doesn't send emails directly via Gmail API. Instead:

1. Emails arrive via Google Cloud Pub/Sub webhook
2. Crispy receives the webhook, fetches the full email via Gmail API
3. Extracts metadata (from, subject, body) and classifies urgency
4. Routes to downstream pipelines (email triage, alert notification, etc.)
5. May send replies via the email.lobster pipeline (with approval)

```mermaid
flowchart TD
    GMAIL["📧 Email arrives<br>in Gmail inbox"]:::teal
    GMAIL --> WEBHOOK["Google Cloud Pub/Sub<br>Push notification"]:::blue
    WEBHOOK --> CRISPY["Crispy receives<br>webhook + decodes"]:::green
    CRISPY --> FETCH["Fetch full email<br>via Gmail API"]:::blue
    FETCH --> PARSE["Parse email metadata<br>subject, from, body"]:::blue
    PARSE --> CLASSIFY["Classify urgency<br>& category"]:::amber
    CLASSIFY --> ROUTE{"Route to:"}:::amber
    ROUTE -->|"Urgent"| URGENT["email.lobster<br>with urgent flag"]:::purple
    ROUTE -->|"Normal"| NORMAL["email.lobster<br>normal processing"]:::purple
    ROUTE -->|"Alert"| ALERT["notify.lobster<br>send Telegram DM"]:::purple

    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

---

## How It Fits in CKS Stack

```mermaid
flowchart TD
    L3["L3 — Channel<br>Gmail webhook receiver"]:::teal
    L3 --> L5["L5 — Routing<br>Route email to appropriate handler"]:::amber
    L5 --> L6A["L6a — Triage Pipeline<br>Classify & draft responses"]:::green
    L5 --> L6B["L6b — Alert Pipeline<br>Send urgent notifications"]:::purple
    L5 --> L6C["L6c — Approval Pipeline<br>Get user approval for replies"]:::blue

    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
```

---

## Channel Behavior

| Aspect | Gmail |
|---|---|
| **Mode** | Webhook only |
| **Trigger** | Incoming email |
| **User input** | Email content (subject, body) |
| **Response** | Draft reply (optional, needs approval) |
| **Status** | ⏳ Planned |

---

## Pages

| Page | Covers |
|---|---|
| [[stack/L3-channel/gmail/email-triage]] | Triage flow, classification rules, webhook architecture, privacy & security |
| [[stack/L3-channel/gmail/runbook]] | Setup guide, pipeline config, notification rules, debugging |

---

## Status

**Current:** ⏳ Planned
**Next steps:**
- [ ] Google Cloud Pub/Sub integration
- [ ] Service account setup
- [ ] email.lobster pipeline creation
- [ ] Email classification rules
- [ ] Notification routing

---

**Up →** [[stack/L3-channel/_overview]]
**Telegram →** [[stack/L3-channel/telegram/_overview]]
**Discord →** [[stack/L3-channel/discord/_overview]]
