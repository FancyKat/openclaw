---
tags: [type/reference, layer/routing, status/draft, category/pet-care, focus/flows]
---

# Pet Care Conversation Flows

> Example multi-turn conversation flows, channel-specific variations, and interaction patterns for pet care.

**Up →** [[stack/L5-routing/categories/pet-care/_overview]]

---

## Sequence Diagram — Telegram (Pipeline Annotated)

**Scenario:** Medication reminder → feeding log → vet appointment booking.

```mermaid
sequenceDiagram
    actor User
    participant TG as Telegram
    participant Flash as Flash (classify)
    participant L5 as L5 Router
    participant Mem as Memory
    participant AgentLoop as Agent Loop

    User->>TG: "Did Luna get her heartworm pill today?"
    TG->>Flash: classify intent
    Note right of Flash: ~150ms
    Flash-->>L5: pet-care:medication (0.89)
    Note over L5: Load pet care mode context
    L5->>Mem: recall(pets:Luna:medications)
    Note right of Mem: ~250ms — vec DB
    Mem-->>L5: Heartgard due today (monthly)
    Note over L5,Mem: ⚡ medication-tracker pipeline [FUTURE]
    L5-->>TG: "Not yet logged. Did she get it? [✅ Yes] [❌ No, remind later]"
    TG->>User: Medication check prompt

    User->>TG: tap [✅ Yes]
    TG->>L5: callback: pet-care:medication-log(Luna, Heartgard, today)
    L5->>Mem: store(Luna:meds:heartgard:2026-03-04, next_due:2026-04-04)
    L5-->>TG: "Logged! ✓ Next Heartgard due April 4."
    TG->>User: Confirmation

    User->>TG: "Add Luna's vet checkup for next Thursday"
    TG->>Flash: classify intent
    Flash-->>L5: pet-care:appointment (0.92)
    Note over L5,Mem: ⚡ appointment pipeline [FUTURE]
    L5->>Mem: recall(pets:Luna:vet:history)
    L5->>Mem: store(Luna:appointment:2026-03-12:checkup)
    L5-->>TG: "Added! Luna's checkup: Thu Mar 12. I'll remind you March 11."
    TG->>User: Appointment confirmation
```

### Speed Impact

| Step | Latency | Adds Latency? |
|---|---|---|
| Flash classify | 100–200ms | LLM call (flash) |
| Mode load | 50–100ms | Memory lookup |
| medication-tracker pipeline [FUTURE] | 300–700ms | Memory R/W — no LLM |
| appointment pipeline [FUTURE] | 300–600ms | Memory R/W — no LLM |
| Agent loop (health advice) | 1–2.5s | LLM call + context |
| **Total (medication check)** | **~400–900ms** | — |
| **Total (appointment add)** | **~400–800ms** | — |

---

## Flow 1: Medication Reminder

**Scenario:** Proactive alert that a medication is due.

```
Cron check → Heartgard due today

Crispy (Telegram): "🐾 Luna's Heartgard is due today!
Did she get it?
[✅ Yes, logged]  [⏰ Remind in 2 hours]  [❌ Already done]"

User taps: [✅ Yes, logged]

Crispy: "Got it! ✓ Heartgard logged for Luna.
Next dose: April 4, 2026 🗓️"
```

---

## Flow 2: Feeding Check

**Scenario:** User asks about feeding schedule.

```
User: "When did Luna last eat?"

Flash model → category: pet-care:feeding (confidence: 0.87)
→ Load pet care mode
→ Query memory: pets:Luna:feeding-log
→ Memory returns: "Morning feed 7:30am (chicken & rice), 2 cups"

Crispy: "Luna's last meal was this morning at 7:30am — 2 cups of
chicken & rice. She's due for her evening meal around 6pm."
```

---

## Flow 3: Training Milestone

**Scenario:** Log a training achievement.

```
User: "Luna just learned 'leave it'!"

Flash model → category: pet-care:training (confidence: 0.91)
→ Load pet care mode
→ Check memory: commands known
→ Route to: training-log pipeline (when built) OR agent loop

Crispy: "Excellent! 🎉 'Leave it' is a big one. Logged!

Known commands: sit, stay, come, shake, lie down, leave it (new!)

That's 6 commands. Ready to start working on 'place'?"
```

---

## Channel Differences

### Telegram
- Medication confirmations as inline buttons (✅ Yes / ❌ No / ⏰ Remind later)
- Feeding schedule as quick bullets with timestamps
- Appointment cards with date + reminder button

### Discord
- Vet appointment details in embeds with fields (date, vet, reason)
- Training progress as table in message
- Medication schedule as embedded list

### Email
- Monthly pet health digest (medications due, vet appointments, training progress)
- Async format — no inline buttons; link-based actions
- Full medication history as attachment

---

**Up →** [[stack/L5-routing/categories/pet-care/_overview]]
