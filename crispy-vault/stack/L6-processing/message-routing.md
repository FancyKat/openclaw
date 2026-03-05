---
tags: [type/reference, layer/processing, status/draft]
---
# L6 — Message Routing (Execution)

> How different types of interactions flow through the Crispy Kitsune Stack after routing decisions are made: each situation has its own flowchart showing the exact path a message takes, which layers are involved, latency, and token costs. This is a visual reference for understanding what actually happens when you send a voice note, when Crispy needs to make a plan, when you share an image, and in 7 other common interaction types.

**Up →** [[stack/L6-processing/_overview]]

---

## Pipeline Chaining: Buttons to Gates

When a button tap triggers a pipeline, that pipeline can itself contain approval gates. This creates a natural guardrail chain:

```mermaid
flowchart LR
    TAP["User taps<br>🔀 Git"]:::gray
    TAP --> PIPE["git.lobster<br>runs"]:::green
    PIPE --> STATUS["Shows status<br>(deterministic)"]:::green
    STATUS --> QA2["Quick-actions:<br>🚀 Push · 📋 Diff<br>🔄 Pull · ❓ Ask"]:::blue
    QA2 -->|"🚀 Push"| EA["Exec-approve<br>pattern kicks in"]:::amber
    EA --> GATE["🛡️ Approval gate<br>(human confirms)"]:::red
    GATE -->|"✅"| EXEC["git push<br>(sandboxed)"]:::green
    GATE -->|"❌"| CANCEL["Cancelled"]:::red

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

Notice: The entire chain from "work on crispy" → git status → push → approval used **zero full LLM reasoning calls**. The only LLM work was the triage classification and button tree build.

---

## Full Message Lifecycle: Situational Flowcharts

How different types of interactions flow through the Crispy Kitsune Stack. Each situation has its own flowchart showing the exact path a message takes, which layers are involved, and where decisions happen.

This document is a **visual reference** — use it to understand the full journey for each situation, then drill into the layer docs for implementation details.

---

### Why This Document Exists

The [[stack/_overview]] shows how the 7 layers connect. The [[stack/L5-routing/message-routing]] shows the three routing paths and classification decisions. But neither shows what actually happens in **real situations** — what does the stack do when you send a voice note? When Crispy needs to make a plan? When you share an image?

This document maps each situation end-to-end so you can:
1. See which layers light up for each interaction type
2. Identify bottlenecks and latency sources
3. Plan what to build first based on which situations you use most

---

### Situation Map

```mermaid
flowchart TD
    subgraph SIMPLE["⚡ Simple (Pipeline Path)"]
        S1["Text command<br>/brief /email /git"]:::green
        S2["Button tap<br>(callback)"]:::green
        S3["Scheduled task<br>(cron heartbeat)"]:::green
    end

    subgraph MEDIA["📎 Media"]
        M1["Voice message<br>(STT → text → TTS)"]:::teal
        M2["Image received<br>(describe / OCR)"]:::teal
        M3["Video received<br>(thumbnail + describe)"]:::teal
        M4["Document received<br>(parse + summarize)"]:::teal
    end

    subgraph THINKING["🧠 Thinking"]
        T1["Planning session<br>(multi-turn collaborative)"]:::purple
        T2["Decision making<br>(options → choice)"]:::purple
        T3["Research request<br>(search → synthesize)"]:::purple
        T4["Debugging<br>(diagnose → fix)"]:::purple
    end

    subgraph OUTBOUND["📤 Outbound"]
        O1["Generate image"]:::amber
        O2["Generate voice reply"]:::amber
        O3["Send notification"]:::amber
        O4["Push to GitHub"]:::amber
    end

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
```

---

### 1. Text Command (`/brief`)

**Situation:** User sends `/brief` in Telegram.
**Path:** Pipeline (0 LLM tokens for routing)
**Layers touched:** L1 → L2 → L3 → L5 → L6 → L3 → L1

```mermaid
flowchart LR
    USER["👤 /brief"]:::gray
    USER --> L3_IN["L3: Telegram receives<br>identifies as /command"]:::teal
    L3_IN --> L5["L5: Command router<br>(no triage needed)"]:::amber
    L5 --> L6["L6: brief.lobster runs<br>• read workspace state<br>• llm-task: summarize<br>• format output"]:::red
    L6 --> L3_OUT["L3: Format as Telegram HTML<br>+ quick-action buttons"]:::teal
    L3_OUT --> DONE["👤 Sees daily brief"]:::gray

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

**Latency:** ~1–3s (mostly the llm-task summarize step)
**Token cost:** ~500–800 (single summarize call)
**Memory impact:** Brief logged to daily log (L7)

---

### 2. Button Tap (Callback)

**Situation:** User taps a button from a previous message (e.g., "🔀 Git" from a decision tree).
**Path:** Pipeline (0 LLM tokens)
**Layers touched:** L3 → L5 → L6 → L3

```mermaid
flowchart LR
    TAP["👤 Taps 🔀 Git"]:::gray
    TAP --> L3["L3: Telegram callback<br>data: tree_123:git"]:::teal
    L3 --> L5["L5: Validate callback format<br>Lookup tree state"]:::amber
    L5 --> L6["L6: Execute mapped action<br>git.lobster runs"]:::red
    L6 --> L3_OUT["L3: Send result<br>+ new quick-actions"]:::teal
    L3_OUT --> DONE["👤 Sees git status"]:::gray

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

**Latency:** ~200ms–1s (no LLM call, pure state lookup + pipeline)
**Token cost:** 0 (deterministic)
**Key insight:** Button trees are pre-computed — the tap just looks up which action to run

---

### 3. Voice Message Received

**Situation:** User sends a voice note in Telegram.
**Path:** Media → STT → Agent Loop → TTS → Voice reply
**Layers touched:** L1 → L3 → L6 (STT) → L5 → L6 (Agent) → L6 (TTS) → L3 → L1

```mermaid
flowchart TD
    VOICE["🎤 Voice message<br>(Telegram .ogg)"]:::gray

    subgraph INBOUND["📥 Inbound Processing"]
        L3_IN["L3: Telegram receives .ogg<br>Save to media/inbound/"]:::teal
        STT["L6: STT pipeline<br>Whisper / Deepgram<br>→ transcribed text"]:::red
    end

    subgraph PROCESS["🧠 Processing"]
        L5["L5: Route transcribed text<br>(same as any text message)"]:::amber
        DECIDE{"Pipeline or<br>Agent Loop?"}:::amber
        PIPE["L6: Pipeline path"]:::green
        AGENT["L6: Agent Loop<br>(full reasoning)"]:::purple
    end

    subgraph OUTBOUND["📤 Outbound"]
        TTS["L6: TTS pipeline<br>ElevenLabs / Google<br>→ .ogg voice reply"]:::red
        L3_OUT["L3: Send voice message<br>+ text fallback"]:::teal
    end

    VOICE --> L3_IN --> STT --> L5
    L5 --> DECIDE
    DECIDE -->|"Known command"| PIPE
    DECIDE -->|"Needs thinking"| AGENT
    PIPE --> TTS
    AGENT --> TTS
    TTS --> L3_OUT
    L3_OUT --> DONE["👤 Hears voice reply"]:::gray

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

**Latency target:** <3s total (STT ~500ms + processing + TTS ~500ms)
**Token cost:** Varies — depends on whether text routes to pipeline or agent
**Files involved:** `media/inbound/telegram-YYYYMMDD-{hash}.ogg` → `media/outbound/telegram-YYYYMMDD-{hash}.ogg`

---

### 4. Image Received

**Situation:** User sends a photo in Telegram (screenshot, whiteboard, receipt, etc.).
**Path:** Media → Vision → Agent Loop
**Layers touched:** L1 → L3 → L6 (Vision) → L5 → L6 (Agent) → L3

```mermaid
flowchart TD
    IMG["📷 Image sent<br>(Telegram photo)"]:::gray

    subgraph INBOUND["📥 Inbound"]
        L3_IN["L3: Telegram receives photo<br>Download + save to<br>media/inbound/"]:::teal
        VISION["L6: Vision model<br>• Describe image<br>• OCR if text present<br>• Extract key info"]:::red
    end

    subgraph CONTEXT["🧠 Context Decision"]
        L5["L5: Route based on<br>caption + image description"]:::amber
        HAS_CAPTION{"Has caption<br>with intent?"}:::amber
        NO_CAP["Crispy asks:<br>'What would you like me<br>to do with this?'<br>+ quick-action buttons"]:::blue
        YES_CAP["Route caption<br>as text message"]:::green
    end

    subgraph ACTIONS["Possible Actions"]
        A1["📝 Summarize / describe"]:::purple
        A2["🔍 OCR → extract text"]:::purple
        A3["📊 Analyze chart / data"]:::purple
        A4["🎨 Edit / transform"]:::purple
        A5["💾 Save to workspace"]:::purple
    end

    IMG --> L3_IN --> VISION --> L5
    L5 --> HAS_CAPTION
    HAS_CAPTION -->|No| NO_CAP
    HAS_CAPTION -->|Yes| YES_CAP
    YES_CAP --> A1
    NO_CAP -->|"User taps"| A1

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

**Key decision:** If the user sends a photo with no caption, Crispy shouldn't guess — it should ask via buttons ("Describe this? OCR? Analyze? Save?"). If there's a caption like "what does this error mean?", route normally.

**Token cost:** ~1000–2000 for vision description + agent processing
**File:** `media/inbound/telegram-YYYYMMDD-{hash}.jpg`

---

### 5. Video Received

**Situation:** User sends a video clip.
**Path:** Media → Thumbnail + Metadata → Agent
**Layers touched:** L1 → L3 → L6 (Media) → L5 → L6 (Agent) → L3

```mermaid
flowchart TD
    VID["🎥 Video sent"]:::gray

    subgraph INBOUND["📥 Inbound"]
        L3_IN["L3: Download video<br>Save to media/inbound/"]:::teal
        THUMB["L6: Media pipeline<br>• Extract thumbnail<br>• Get duration/size<br>• Check limits"]:::red
        SIZE{"Under size<br>limit?"}:::amber
    end

    subgraph PROCESS["🧠 Process"]
        VISION["L6: Vision on thumbnail<br>+ caption context"]:::purple
        AGENT["L6: Agent processes<br>based on intent"]:::purple
    end

    subgraph OVERSIZE["⚠️ Too Large"]
        WARN["L3: 'Video is {size}MB.<br>I can analyze the thumbnail<br>or a shorter clip.'"]:::amber
    end

    VID --> L3_IN --> THUMB --> SIZE
    SIZE -->|Yes| VISION --> AGENT
    SIZE -->|No| WARN
    AGENT --> REPLY["L3: Send response"]:::teal

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

**Size limits:** Telegram max 20MB download, Discord 25MB. Videos above limit get thumbnail-only processing.
**Key insight:** We don't do full video transcription yet — we extract a representative thumbnail and use vision on that, plus any caption the user provides.

---

### 6. Planning Session (Multi-Turn Collaborative)

**Situation:** User says "Let's plan out the API for the new feature" — starts a back-and-forth planning session.
**Path:** Agent Loop (multi-turn, high token usage)
**Layers touched:** L5 → L6 → L7 (repeated)

```mermaid
flowchart TD
    START["👤 'Let's plan the API<br>for user profiles'"]:::gray

    subgraph TURN1["Turn 1: Scope"]
        T1_CLASS["L5: Classify → agent_loop<br>(creative/planning intent)"]:::amber
        T1_CTX["L4: Load context<br>+ project memory"]:::blue
        T1_LLM["L6: Agent thinks<br>• Reads existing code<br>• Proposes structure"]:::purple
        T1_OUT["Crispy: 'Here's what I'm thinking:<br>3 endpoints, REST, here's the shape...<br>What do you think about auth?'"]:::gray
    end

    subgraph TURN2["Turn 2: Refine"]
        T2_IN["👤 'Use JWT, and add<br>a /me endpoint too'"]:::gray
        T2_LLM["L6: Agent refines plan<br>• Incorporates feedback<br>• Updates proposal"]:::purple
        T2_OUT["Crispy: 'Updated plan with JWT +<br>/me endpoint. Want me to<br>write this up as a spec?'"]:::gray
    end

    subgraph TURN3["Turn 3: Commit"]
        T3_IN["👤 'Yes, save it'"]:::gray
        T3_LLM["L6: Agent writes spec<br>to workspace"]:::purple
        T3_MEM["L7: Save to daily log<br>'Planned user profile API<br>with Marty — JWT + 4 endpoints'"]:::blue
        T3_OUT["Crispy: 'Saved to workspace/<br>research/api-spec.md ✅'"]:::gray
    end

    START --> T1_CLASS --> T1_CTX --> T1_LLM --> T1_OUT
    T1_OUT --> T2_IN --> T2_LLM --> T2_OUT
    T2_OUT --> T3_IN --> T3_LLM --> T3_MEM --> T3_OUT

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

**Token cost:** 5K–30K+ across the session (context grows each turn)
**Memory impact:** Heavy — planning decisions should be logged to L7 daily log with key decisions highlighted
**Compaction risk:** Long planning sessions may trigger L4 compaction — important decisions could be lost if not explicitly saved

---

### 7. Decision Making (Options → Choice)

**Situation:** User needs help choosing between options — "Should we use PostgreSQL or MongoDB for this?"
**Path:** Agent Loop → structured comparison → user decides

```mermaid
flowchart TD
    ASK["👤 'PostgreSQL or MongoDB<br>for the user service?'"]:::gray

    subgraph ANALYZE["🧠 Analysis"]
        CLASS["L5: Classify → agent_loop<br>(decision/comparison intent)"]:::amber
        CTX["L4: Load context<br>+ existing architecture notes"]:::blue
        LLM["L6: Agent analyzes<br>• Pros/cons for each<br>• Considers existing stack<br>• Checks memory for past decisions"]:::purple
    end

    subgraph PRESENT["📊 Structured Output"]
        COMPARE["Crispy presents comparison:<br>| Factor | Postgres | Mongo |<br>+ recommendation + rationale"]:::gray
        BUTTONS["L3: Quick-action buttons<br>🐘 PostgreSQL<br>🍃 MongoDB<br>❓ Need more info"]:::teal
    end

    subgraph DECIDE["✅ Decision Captured"]
        CHOICE["👤 Taps 🐘 PostgreSQL"]:::gray
        LOG["L7: Log decision<br>'Chose PostgreSQL for user service<br>— relational data, existing expertise'"]:::blue
        CONFIRM["Crispy: 'Logged. Want me to<br>set up the schema?'"]:::gray
    end

    ASK --> CLASS --> CTX --> LLM
    LLM --> COMPARE --> BUTTONS
    BUTTONS --> CHOICE --> LOG --> CONFIRM

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

**Key insight:** Decision-making should always end with a **logged decision** in L7. Crispy should proactively ask "Want me to log this decision?" if the user picks an option.
**Token cost:** 2K–5K (single analysis turn + structured output)

---

### 8. Research Request

**Situation:** User says "Research the best TTS providers for our voice pipeline."
**Path:** Agent Loop with tool calls (web search, file writes)

```mermaid
flowchart TD
    REQ["👤 'Research best TTS<br>providers for voice pipeline'"]:::gray

    subgraph PLAN["🧠 Plan"]
        CLASS["L5: Classify → agent_loop<br>(research intent)"]:::amber
        CTX["L4: Load context<br>+ voice-pipeline notes"]:::blue
        PLAN_LLM["L6: Agent plans research<br>• Define criteria<br>• List providers to check"]:::purple
    end

    subgraph EXECUTE["🔍 Execute"]
        SEARCH["L6: Tool → web search<br>(Brave API)"]:::red
        COMPARE["L6: Agent synthesizes<br>• Compares providers<br>• Prices, quality, latency"]:::purple
        WRITE["L6: Tool → exec<br>Write to workspace/<br>research/tts-comparison.md"]:::red
    end

    subgraph OUTPUT["📤 Output"]
        SUMMARY["L3: Send summary +<br>link to full doc"]:::teal
        MEM["L7: Log to daily log<br>'Researched TTS: ElevenLabs<br>recommended for quality'"]:::blue
    end

    REQ --> CLASS --> CTX --> PLAN_LLM
    PLAN_LLM --> SEARCH --> COMPARE --> WRITE
    WRITE --> SUMMARY --> MEM

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

**Token cost:** 10K–50K+ (multiple search calls, synthesis, file writing)
**Output:** Research doc saved to `workspace/research/` + summary in chat
**Memory impact:** Key findings logged to L7 daily log

---

### 9. Send Notification (Outbound)

**Situation:** Crispy proactively sends a notification (e.g., cron-triggered health check alert).
**Path:** Pipeline (scheduled trigger, no user message)

```mermaid
flowchart LR
    CRON["⏰ Cron trigger<br>(every 20min)"]:::gray
    CRON --> L6["L6: health-check.lobster<br>• Check gateway status<br>• Check API keys<br>• Check disk space"]:::red
    L6 --> RESULT{"All healthy?"}:::amber
    RESULT -->|Yes| SKIP["No message sent<br>(silent success)"]:::green
    RESULT -->|No| ALERT["L6: Build alert message<br>with details"]:::red
    ALERT --> L3["L3: Send to Telegram<br>admin chat"]:::teal
    L3 --> MEM["L7: Log health event"]:::blue

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
```

**Latency:** ~1–2s (all deterministic checks)
**Token cost:** 0 (pipeline only, no LLM)
**Key insight:** Silent on success, alert on failure — don't spam the admin

---

### 10. Push to GitHub (Exec-Approve)

**Situation:** User asks Crispy to push code changes.
**Path:** Agent Loop → Exec-Approve guardrail → Sandboxed execution

```mermaid
flowchart TD
    REQ["👤 'Push the changes<br>to main'"]:::gray

    subgraph PROCESS["🧠 Process"]
        CLASS["L5: Classify → agent_loop"]:::amber
        AGENT["L6: Agent prepares<br>git add + commit + push"]:::purple
    end

    subgraph GUARDRAIL["🛡️ Exec-Approve Gate"]
        PREVIEW["L6: Show preview<br/>git add, commit, push"]:::blue
        BUTTONS["L3: Approval buttons<br>✅ Approve · ❌ Deny"]:::teal
        WAIT["Waiting for human..."]:::gray
    end

    subgraph EXECUTE["⚡ Execute"]
        EXEC["L1: Docker sandbox<br>runs git commands"]:::green
        RESULT["L3: Send result<br>'Pushed 3 commits to main ✅'"]:::teal
        MEM["L7: Log action<br>'Pushed to main — 3 commits'"]:::blue
    end

    subgraph DENIED["❌ Denied"]
        CANCEL["L3: 'Push cancelled.'"]:::red
    end

    REQ --> CLASS --> AGENT
    AGENT --> PREVIEW --> BUTTONS --> WAIT
    WAIT -->|"✅"| EXEC --> RESULT --> MEM
    WAIT -->|"❌"| CANCEL

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

**Key insight:** Destructive or irreversible actions (push, delete, deploy) always go through exec-approve. The user sees exactly what will run before approving.

---

## Latency & Cost Summary

| Situation | Typical Latency | Token Cost | Path |
|---|---|---|---|
| Text command (`/brief`) | 1–3s | ~500–800 | Pipeline |
| Button tap | 200ms–1s | 0 | Pipeline (state lookup) |
| Voice message | 2–5s | 500–5K+ | STT → Route → TTS |
| Image received | 2–4s | 1K–2K | Vision → Agent |
| Video received | 3–6s | 1K–2K | Thumbnail → Vision |
| Planning session | 5–30s/turn | 5K–30K+ | Agent Loop (multi-turn) |
| Decision making | 3–10s | 2K–5K | Agent Loop |
| Research request | 10–60s | 10K–50K+ | Agent Loop + tools |
| Notification (cron) | 1–2s | 0 | Pipeline |
| Git push (exec-approve) | 3–15s | 2K–5K | Agent + guardrail |

---

## See Also

**Routing decisions →** [[stack/L5-routing/message-routing]]
