---
tags: [channel/telegram, layer/channel, status/draft, type/reference, topic/telegram]
---
# L3 — Telegram Chat Flow

> Full Telegram message lifecycle from arrival to response, including auth checks, context loading, classification, routing, and multi-format handling.

---

## Message Arrival & Authentication

```mermaid
flowchart TD
    MSG["📱 Message arrives<br>at Telegram bot"]:::teal
    MSG --> AUTH{"User in<br>allowlist?"}:::amber
    AUTH -->|No| DROP["❌ Dropped<br>No reply sent"]:::red
    AUTH -->|Yes| TYPE{"Message type?"}:::amber

    TYPE -->|Text| PROC["▶️ Process as text"]:::green
    TYPE -->|Voice| STT["🎤 Transcribe with<br>flash model"]:::blue
    TYPE -->|Photo/File| MEDIA["📸 Media pipeline"]:::purple
    TYPE -->|Button press| CB["🔘 Callback handler"]:::purple
    TYPE -->|/command| CMD["🔧 Route to command"]:::amber

    STT --> PROC
    MEDIA --> PROC
    CB --> SKIP["🎯 Direct to<br>button pipeline"]:::purple
    CMD --> SKIP

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
```

### Allowlist Rules

> Config keys below are illustrative. Source of truth → [[stack/L3-channel/config-reference]]

```json5
{
  "telegram": {
    "dmPolicy": "allowlist",
    "allowFrom": [
      "tg:${TELEGRAM_MARTY_ID}",      // Primary user
      "tg:${TELEGRAM_WENTING_ID}"     // Secondary user
    ]
  }
}
```

If the sender's Telegram ID is not in this list, Crispy drops the message with no reply.

---

## Input Processing

### Text Messages

```mermaid
flowchart TD
    TEXT["Text message arrives"]:::teal
    TEXT --> CONTEXT["Load context"]:::green
    CONTEXT --> HIST["Fetch last 50 msgs<br>from session JSONL"]:::blue
    HIST --> CLASSIFY["Classify intent"]:::amber
    CLASSIFY --> ROUTE{"What should<br>Crispy do?"}:::amber
    ROUTE -->|"Clear intent"| LLM["Send to workhorse model<br>via agent loop"]:::green
    ROUTE -->|"Ambiguous"| BTN["Build buttons<br>decision tree"]:::purple

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
```

**Context load steps:**
1. Fetch session JSONL for current user
2. Extract last 50 messages (both user and Crispy)
3. Include daily memory log (if exists)
4. Load long-term MEMORY.md (if referenced)
5. Include any stored decision trees (from previous buttons)

### Voice Messages

```mermaid
flowchart TD
    VOICE["Voice message arrives"]:::blue
    VOICE --> DL["Download from<br>Telegram servers"]:::blue
    DL --> STT["Transcribe with<br>flash model"]:::blue
    STT --> TXT["Convert to text<br>+ confidence"]:::blue
    TXT --> CHECK{"Confidence<br>>= 85%?"}:::amber
    CHECK -->|Yes| PROC["Use transcript"]:::green
    CHECK -->|No| RETRY["Ask for<br>spoken again"]:::red
    PROC --> TEXT["▶️ Process as text"]:::teal

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
```

### Media (Photos, Documents, Files)

```mermaid
flowchart TD
    MEDIA["Photo/file arrives"]:::purple
    MEDIA --> SIZE{"Size <=<br>10 MB?"}:::amber
    SIZE -->|No| ERR["❌ File too large"]:::red
    SIZE -->|Yes| PIPE["▶️ Route to<br>media.lobster pipeline"]:::purple
    PIPE --> WHAT{"What is it?"}:::amber
    WHAT -->|"Image"| IMG["Analyze with<br>vision model"]:::blue
    WHAT -->|"Document"| DOC["Extract text"]:::blue
    WHAT -->|"Other"| SAVE["Save to workspace"]:::blue

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

---

## Custom Commands

When a message starts with `/`, it's routed to a command handler instead of the agent loop:

```mermaid
flowchart TD
    CMD{"/command?"}:::amber
    CMD -->|"/brief"| B["brief.lobster<br>Run morning briefing"]:::green
    CMD -->|"/email"| E["email.lobster<br>Email triage"]:::green
    CMD -->|"/git"| G["git.lobster<br>Git status + push"]:::green
    CMD -->|"/pipelines"| L["Built-in list<br>Show all pipelines"]:::blue
    CMD -->|"/new"| R["Reset session<br>Clear context"]:::red
    CMD -->|"/reset"| R2["Reset session"]:::red
    CMD -->|"/model coder"| S["Switch to<br>workhorse-code"]:::purple
    CMD -->|"/model default"| S2["Switch to<br>default model"]:::purple

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

### Command Config

> Authoritative config → [[stack/L3-channel/config-reference]]. Below is a summary.

```json5
{
  "telegram": {
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

## Agent Loop: Thinking & Responding

When a message makes it to the agent loop (text or transcribed voice), Crispy runs the standard decision sequence:

```mermaid
flowchart TD
    LLM["📊 Send to workhorse model<br>(with context)"]:::green
    LLM --> THINK{"Enough context<br>to act?"}:::amber
    THINK -->|Clear intent| TOOLS{"Tool<br>needed?"}:::amber
    THINK -->|Ambiguous| BTN["Build buttons<br>decision tree"]:::purple
    TOOLS -->|Yes| EXEC["Execute tool"]:::blue
    EXEC --> THINK
    TOOLS -->|No| FMT{"Response<br>format?"}:::amber

    FMT -->|Simple| TXT["Plain text<br>with HTML"]:::teal
    FMT -->|Structured| STRUCT["JSON/table"]:::teal
    FMT -->|Long| THREAD["Split into<br>threading"]:::teal
    FMT -->|Voice reply| TTS["ElevenLabs v3<br>Text-to-speech"]:::blue

    TXT & STRUCT & THREAD & TTS --> SAVE["Save to session<br>JSONL + daily log"]:::gray

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
```

### Block Streaming

Responses are streamed in blocks of 800–1200 characters to keep Telegram messages readable:

```mermaid
sequenceDiagram
    participant Crispy
    participant TG as Telegram
    participant User

    Crispy->>TG: sendMessage("🦊 [block 1: 1000 chars] ⏳ Responding...")
    TG->>User: Initial message (block 1)
    Crispy->>TG: editMessageText(+block 2: 900 chars, ⏳ Responding...)
    TG->>User: Message updated (blocks 1–2)
    Crispy->>TG: editMessageText(+block 3: 800 chars, ✅ Done)
    TG->>User: Final message (blocks 1–3, complete)
```

---

## Button Callbacks (Pre-Built Decision Trees)

When Crispy creates buttons, it builds a **pre-compiled decision tree** and stores it in Lobster state. Each button press resolves from that tree — no LLM, ~200ms response time.

```mermaid
sequenceDiagram
    participant User
    participant TG as Telegram
    participant Crispy
    participant State as Lobster State

    Note over Crispy: Creation Phase (LLM, once)
    Crispy->>State: state.set buttons:dt_XXXX
    Crispy->>TG: Send message + buttons
    TG->>User: Message + button options
    Note over User,State: ~time passes~
    Note over TG,State: Callback Phase (no LLM, ~200ms)
    User->>TG: tap button
    TG->>State: parse callback_data → resolve tree
    State-->>TG: Execute action
    TG->>User: Edit message, replace buttons
```

### Callback Data Format

```
<tree_id>:<option_key>

Examples:
dt_a1b2:yes          — tree ID "a1b2", option "yes"
dt_c3d4:fix          — tree ID "c3d4", option "fix"
dt_ap_8f3e:approve   — approval tree, "approve" option
```

---

## DM vs. Group Behavior

### Direct Messages (Full Mode)

- **Full context:** Bootstrap + memory + history
- **Voice input:** Supported, auto-transcribed
- **Buttons:** All 4 patterns (approve-deny, exec-approve, decision-tree, quick-actions)
- **Streaming:** Enabled (block streaming)
- **Response length:** No limit (can thread if needed)
- **Custom commands:** All 6 commands available

### Group Mentions (Limited Mode)

Group support is currently disabled (groups config not present). When/if enabled in the future:

```mermaid
flowchart TD
    MENTION["@Crispy in group"]:::purple
    MENTION --> ALLOW{"Group in<br>allowlist?"}:::amber
    ALLOW -->|No| DROP["Drop"]:::red
    ALLOW -->|Yes| BRIEF["Brief response<br>(no full context)"]:::blue
    BRIEF --> REACT["Add 🦊 reaction"]:::teal

    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
```

---

## Inline Button Rules

```mermaid
flowchart TD
    BTN["Crispy decides<br>to show buttons"]:::amber
    BTN --> GRID["Max 2x2 grid<br>(4 buttons)"]:::green
    GRID --> HATCH["Include escape hatch<br>(❓ Other / 💬 Ask)"]:::blue
    HATCH --> TEXT["Button text:<br>emoji + 1-2 words"]:::teal
    TEXT --> DEPTH["Max 2 levels deep<br>(Level 1 → Level 2)"]:::purple
    DEPTH --> EDIT["Edit original message<br>on callback"]:::gray

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
```

### Examples

**Good:**
- Text: "🔧 Config", "📊 Status", "💬 Ask"
- Grid: 2x2 (4 buttons max)
- Depth: Level 1 (broad category) → Level 2 (specific choice) → Work

**Bad:**
- Text: "Configure the system settings"
- Grid: 3x3 (9 buttons — unreadable)
- Depth: Level 1 → Level 2 → Level 3 → Level 4 (too deep, frustrating)

---

## Full Message Lifecycle: Example

```mermaid
sequenceDiagram
    participant User as Marty
    participant TG as Telegram
    participant Flash as Flash (transcribe)
    participant Crispy
    participant Mem as Memory

    User->>TG: Send voice message
    TG->>Flash: Download + transcribe audio
    Flash-->>Crispy: Transcript (confidence: 92%)
    Crispy->>Mem: Load context (last 50 msgs + memory)
    Mem-->>Crispy: Context loaded
    Crispy->>Crispy: Send to workhorse model (LLM)
    alt ambiguous intent
        Crispy->>Crispy: Build 4-button decision tree
        Crispy->>TG: Send message + buttons
        TG->>User: Message + button options
        User->>TG: tap button
        TG->>Crispy: callback_data resolved (~200ms)
        Crispy->>TG: Edit message, replace buttons
        Crispy->>Mem: Save to JSONL + daily log
    else clear intent
        Crispy->>Crispy: Execute action
        loop streaming blocks (800–1200 chars)
            Crispy->>TG: editMessageText(next block)
            TG->>User: Updated message
        end
        Crispy->>Mem: Save to JSONL + daily log
    end
```

---

## Config Example

```json5
{
  "telegram": {
    "enabled": true,
    "botToken": "${TELEGRAM_BOT_TOKEN}",

    // Authentication
    "dmPolicy": "allowlist",
    // groups not configured = group support disabled
    "allowFrom": [
      "tg:${TELEGRAM_MARTY_ID}",
      "tg:${TELEGRAM_WENTING_ID}"
    ],

    // Features
    "capabilities": {
      "inlineButtons": true,
      "voiceInput": true,
      "mediaHandling": true,
      "textStreaming": true
    },

    // Limits
    "historyLimit": 50,
    "mediaMaxMb": 10,
    "blockStreamingChars": 1000,
    "commandTimeout": 300,

    // Streaming
    "streaming": "partial",

    // Voice TTS (reply to voice with audio)
    "voiceReply": {
      "enabled": true,
      "provider": "elevenlabs",
      "voice": "Aria"
    },

    // Custom commands
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

## Error Handling

```mermaid
flowchart TD
    ERR["❌ Error occurs"]:::red
    ERR --> WHAT{"What kind?"}:::amber
    WHAT -->|"Transcription failed"| REPLY1["'Sorry, I didn't catch that.<br>Could you say it again?'"]:::blue
    WHAT -->|"File too large"| REPLY2["'That file is too big<br>(max 10MB). Send smaller one.'"]:::blue
    WHAT -->|"Command timeout"| REPLY3["'That took too long.<br>Try again or check logs.'"]:::blue
    WHAT -->|"LLM error"| REPLY4["'Something went wrong<br>on my end. Retry?'"]:::blue
    WHAT -->|"State error"| REPLY5["'/reset to clear state<br>or contact admin'"]:::red

    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
```

---

## Performance Targets

| Operation | Target | Notes |
|---|---|---|
| **Message arrival → auth** | < 100ms | Synchronous check |
| **Voice transcription** | 2–5s | Depends on audio length |
| **Context load** | < 500ms | 50 messages + memory from disk |
| **workhorse model round-trip** | 3–15s | Streaming response |
| **Button callback** | < 200ms | Pure state lookup, no LLM |
| **Block stream edit** | < 200ms | Each block append |

---


## Example Conversations

> Example multi-turn conversations and mockups showing all 4 button patterns in real-world scenarios.

### Conversation Flow Types

```mermaid
flowchart TD
    A["User Message"] --> B{"Flow Type"}
    B -->|Direct Command| C["/brief, /email, /git"]
    B -->|Simple Response| D["Informational Reply"]
    B -->|Approval Gate| E["Pipeline Executes<br/>Await User Approval"]
    B -->|Decision Tree| F["Multiple Options<br/>Narrow Down"]
    B -->|Voice Input| G["Transcribe → Process<br/>→ Voice Reply"]

    C --> C1["Execute Immediately<br/>Show Results"]
    D --> D1["Reply with Info<br/>No Buttons"]
    E --> E1["Show Drafts/Plan<br/>✅ Approve / ❌ Deny"]
    E1 --> E2["Execute or Cancel"]
    F --> F1["Show Options<br/>User Selects"]
    F1 --> F2["Drill Down or Execute"]
    G --> G1["Confidence Check"]
    G1 --> G2{"Confidence OK?"}
    G2 -->|Yes| G3["Process & Reply"]
    G2 -->|No| G4["Ask to Repeat"]

    style A fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    style B fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    style C fill:#dcfce7,stroke:#22c55e,color:#14532d
    style D fill:#dcfce7,stroke:#22c55e,color:#14532d
    style E fill:#fef3c7,stroke:#f59e0b,color:#78350f
    style F fill:#fef3c7,stroke:#f59e0b,color:#78350f
    style G fill:#ffe4e6,stroke:#fb7185,color:#881337
    style C1 fill:#dcfce7,stroke:#22c55e,color:#14532d
    style D1 fill:#dcfce7,stroke:#22c55e,color:#14532d
    style E1 fill:#fef3c7,stroke:#f59e0b,color:#78350f
    style E2 fill:#fef3c7,stroke:#f59e0b,color:#78350f
    style F1 fill:#fef3c7,stroke:#f59e0b,color:#78350f
    style F2 fill:#fef3c7,stroke:#f59e0b,color:#78350f
    style G1 fill:#ffe4e6,stroke:#fb7185,color:#881337
    style G2 fill:#ffe4e6,stroke:#fb7185,color:#881337
    style G3 fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    style G4 fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

### Example 1: `/brief` Command

Running the morning brief pipeline:

```
> Marty: /brief

┌─────────────────────────────────────────┐
│ 🦊 Crispy                               │
│                                         │
│ 📰 Morning Brief (Mar 2, 2026)          │
│ ⏳ Gathering info...                    │
└─────────────────────────────────────────┘

[~5 second wait]

┌─────────────────────────────────────────┐
│ 🦊 Crispy                               │
│                                         │
│ 📰 Morning Brief (Mar 2, 2026)          │
│                                         │
│ 🎯 TOP 3 ITEMS:                         │
│                                         │
│ 1. 📚 3 new articles in your briefing  │
│    • AI agent systems (HN top)         │
│    • Rust async patterns               │
│    • Postgres 16 optimizations         │
│                                         │
│ 2. 💾 Git status                       │
│    • 2 commits ahead of main           │
│    • No uncommitted changes            │
│    • Last push: 3 hours ago            │
│                                         │
│ 3. 📧 Email inbox                      │
│    • 4 unread emails                   │
│    • 1 flagged urgent                  │
│                                         │
│ ⏳ More...                              │
└─────────────────────────────────────────┘

[Block streaming continues]

┌─────────────────────────────────────────┐
│ 🦊 Crispy                               │
│                                         │
│ 📰 Morning Brief (continued)            │
│                                         │
│ 🔐 SYSTEM                               │
│    Gateway: ✅ Healthy                  │
│    Memory: 247 KB loaded               │
│    Uptime: 6h 34m                      │
│                                         │
│ 💡 WHAT'S NEXT?                         │
│    • Process emails → /email            │
│    • Check git → /git                   │
│    • Read articles → via memory search  │
│                                         │
│ ✅ Brief complete.                      │
└─────────────────────────────────────────┘
```

(Additional examples 2-8 omitted for brevity — see original conversation-flows.md for full text, photos, videos, error handling)

---

**Up →** [[stack/L3-channel/_overview]]
**Channel overview →** [[stack/L3-channel/telegram/_overview]]
**Button patterns →** [[stack/L3-channel/telegram/button-patterns]]
**Pipelines →** [[stack/L3-channel/telegram/pipelines]]
