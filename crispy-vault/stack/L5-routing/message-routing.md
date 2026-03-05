---
tags: [type/reference, layer/routing, status/draft]
---
# L5 — Message Routing (Decisions)

> How incoming messages are classified and routed to the right handler: the classification pipeline (trigger words → triage model → prompt builder → router), the three execution paths (Pipeline, Button, Agent), and the decision rules that determine which path each message takes.

**Up →** [[stack/L5-routing/_overview]]

---

## The Classification Pipeline

Before a message reaches the three routing paths, it passes through a four-stage classification pipeline. Each stage is cheaper and faster than the next, and most messages are resolved before reaching the expensive stages:

```mermaid
flowchart LR
    MSG["📨 Message"]:::gray
    MSG --> S1["① Trigger Words<br/>0 tokens, sub-10ms<br/>60-70% resolved here"]:::green
    S1 -->|"Resolved"| TYPE["Intent Type<br/>+ Subtype"]:::green
    S1 -->|"Ambiguous"| S2["② Triage Model<br/>~200 tokens, ~500ms<br/>Resolves 25-35% more"]:::blue
    S2 --> TYPE
    TYPE --> S3{"Skip prompt<br/>builder?"}:::amber
    S3 -->|"Pipeline/callback/<br/>high confidence"| ROUTE["④ Message Router<br/>Three Paths"]:::amber
    S3 -->|"Needs context"| S4["③ Prompt Builder<br/>~200 tokens, ~500ms<br/>Enriches for agent loop"]:::purple
    S4 -->|"Clarification needed"| CLARIFY["Ask user via buttons<br/>(no agent loop)"]:::teal
    S4 -->|"Enriched prompt"| ROUTE

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
```

| Stage | What It Does | Cost | Coverage | Doc |
|---|---|---|---|---|
| **① Trigger Words** | Regex/keyword scan → resolves intent type | 0 tokens | ~60-70% | [[#The Classification Pipeline]] |
| **② Triage Model** | Cheap LLM classifies ambiguous messages | ~200 tokens | ~25-35% | [[#The Classification Pipeline]] |
| **③ Prompt Builder** | Enriches raw message with context, file paths, approach | ~200 tokens | Agent-bound only | [[stack/L6-processing/pipelines/prompt-builder]] |
| **④ Message Router** | Routes classified intent to Pipeline / Button / Agent | 0 tokens | 100% | This document |

**Five Intent Types** (resolved by stages ① or ②):

| Type | What User Wants | Crispy's Role | Example |
|---|---|---|---|
| **ℹ️ Informational** | An answer or explanation | Answerer | "What is a lobster pipeline?" |
| **🤝 Assistance** | Guided help through a process | Facilitator | "Help me set up Discord" |
| **⚡ Action** | Something executed | Executor | "Turn on the sandbox" / "Push to git" |
| **🎨 Creative** | Ideas, design, brainstorming | Co-creator | "Let's plan the voice pipeline" |
| **🔄 Meta** | Session/context management | Navigator | "What were we working on?" |

---

## The Three Paths: Quick Reference

Every incoming message takes exactly one of three paths. The goal is to push as much traffic as possible into the fast, cheap paths and reserve the expensive path (Agent Loop) for questions that actually need thinking.

```mermaid
flowchart TD
    MSG["Message arrives"]:::gray
    MSG --> AUTH{"Authorized?"}:::amber
    AUTH -->|No| DROP["Dropped"]:::red
    AUTH -->|Yes| CLASS["Classify intent"]:::blue

    CLASS -->|"Known command<br>(/brief /email /git)"| PIPE["🟢 Pipeline Path<br>~0 LLM tokens"]:::green
    CLASS -->|"Ambiguous intent<br>(3+ interpretations)"| BTN["🟡 Button Path<br>~1 LLM call to build tree"]:::amber
    CLASS -->|"Nuanced question<br>(needs reasoning)"| AGENT["🔴 Agent Loop<br>Full LLM processing"]:::red

    PIPE --> RESULT["Response"]:::green
    BTN --> RESULT
    AGENT --> RESULT

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

### Path Summary Table

| Path | LLM Calls | Token Cost | Latency | When Used | Example |
|---|---|---|---|---|---|
| **Pipeline** | 0 (or 1 for llm-task step) | 0–800 | ~200ms | Explicit commands, button callbacks | `/brief`, `/email`, `/git`, button taps |
| **Button** | 1 (to build the decision tree) | ~500–1500 | ~1–2s | Ambiguous requests (2+ interpretations) | "Help me with X" where X is unclear |
| **Agent Loop** | 1–10+ (tool calls, reasoning loops) | 2K–50K+ | 3–30s | Nuanced questions, creative tasks, debugging | "Why is my server slow?", "Write a post about..." |

---

## Full Message Processing Pipeline

This is the complete flow from message arrival to response, with every decision point and guardrail insertion marked:

```mermaid
flowchart TD
    MSG["📨 Message arrives<br>(Telegram/Discord/webhook)"]:::gray

    subgraph G1["🛡️ Layer 1: Input Gate"]
        AUTH{"In allowlist?"}:::amber
        AUTH -->|No| DROP["🚫 Dropped"]:::red
        AUTH -->|Yes| SANITIZE["Sanitize input<br>(unicode norm, strip invisible,<br>injection pattern check)"]:::blue
        SANITIZE --> SAFE{"Injection<br>flagged?"}:::amber
        SAFE -->|Yes| LOG_BLOCK["Log + alert admin<br>(don't process)"]:::red
        SAFE -->|No| ROUTE["Route by type"]:::blue
    end

    MSG --> AUTH

    subgraph G2["🔀 Layer 2: Message Router"]
        ROUTE --> TYPE{"Message type?"}:::amber
        TYPE -->|"/command"| CMD_ROUTE["Command router"]:::green
        TYPE -->|"Button callback"| CB_ROUTE["Callback router"]:::green
        TYPE -->|"Voice"| STT["Transcribe → text"]:::teal
        TYPE -->|"File/media"| MEDIA["Media pipeline"]:::teal
        TYPE -->|"Text"| INTENT["Intent classifier"]:::blue
        STT --> INTENT
    end

    subgraph G3["⚡ Layer 3: Pipeline Path (no LLM)"]
        CMD_ROUTE --> CMD{"Which command?"}:::amber
        CMD -->|"/brief"| P_BRIEF["brief.lobster"]:::green
        CMD -->|"/email"| P_EMAIL["email.lobster"]:::green
        CMD -->|"/git"| P_GIT["git.lobster"]:::green
        CMD -->|"/pipelines"| P_LIST["List pipelines"]:::green
        CMD -->|"/new /reset"| P_RESET["Reset session"]:::green

        CB_ROUTE --> CB_VALID{"Valid callback<br>data?"}:::amber
        CB_VALID -->|No| CB_DROP["Ignore + log"]:::red
        CB_VALID -->|Yes| CB_LOOKUP["Lookup tree from<br>state (no LLM)"]:::green
        CB_LOOKUP --> CB_ACT{"Action type?"}:::amber
        CB_ACT -->|"exec"| CB_EXEC["Run command"]:::green
        CB_ACT -->|"pipeline"| CB_PIPE["Run pipeline"]:::green
        CB_ACT -->|"approve"| CB_RESUME["Resume pipeline"]:::green
        CB_ACT -->|"cascade"| CB_NEXT["Show next level"]:::green
        CB_ACT -->|"agent"| CONTEXT
    end

    subgraph G4["🧠 Layer 4: Intent Classification"]
        INTENT --> TRIAGE["triage model<br>(alias: triage — cheap)"]:::blue
        TRIAGE --> MATCH{"Known pattern?"}:::amber
        MATCH -->|"Project work<br>(matches pipeline)"| PIPE_MATCH["Route to pipeline<br>+ confirm with buttons"]:::green
        MATCH -->|"Ambiguous<br>(3+ meanings)"| BUILD_BTN["Build decision tree<br>(1 LLM call)"]:::amber
        MATCH -->|"Nuanced / creative<br>/ unknown"| CONTEXT["Full context<br>assembly"]:::purple
    end

    subgraph G5["🔮 Layer 5: Agent Loop (full LLM)"]
        CONTEXT --> BOOTSTRAP["Load bootstrap files<br>(AGENTS.md, SOUL.md, etc.)"]:::purple
        BOOTSTRAP --> MEMORY["Load MEMORY.md<br>+ session history"]:::purple
        MEMORY --> GUARDRAIL_PROMPT["🛡️ Instruction hierarchy<br>enforced in system prompt"]:::blue
        GUARDRAIL_PROMPT --> LLM["Send to primary model<br>(full reasoning)"]:::purple
        LLM --> TOOLS{"Tool needed?"}:::amber
        TOOLS -->|Yes| EXEC_TOOL["Execute tool<br>(sandboxed)"]:::blue
        EXEC_TOOL --> LLM
        TOOLS -->|No| OUTPUT["Generate response"]:::purple
    end

    subgraph G6["🛡️ Layer 6: Output Gate"]
        OUTPUT --> OUT_SCAN["Output validation<br>(secret scan, PII check)"]:::blue
        OUT_SCAN --> OUT_SAFE{"Clean?"}:::amber
        OUT_SAFE -->|No| OUT_BLOCK["Block + redact"]:::red
        OUT_SAFE -->|Yes| FORMAT["Format for channel"]:::teal
        FORMAT --> SEND["Send response"]:::green
        SEND --> PERSIST["Save to session JSONL<br>+ daily memory log"]:::gray
    end

    P_BRIEF --> FORMAT
    P_EMAIL --> FORMAT
    P_GIT --> FORMAT
    CB_EXEC --> FORMAT
    CB_PIPE --> FORMAT
    CB_RESUME --> FORMAT
    CB_NEXT --> FORMAT
    PIPE_MATCH --> FORMAT
    BUILD_BTN --> FORMAT

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
```

---

## Pipeline-First Routing Strategy

The key insight: **most messages don't need the full LLM.** If Crispy can identify the intent early and route to a pipeline, the entire interaction completes without burning reasoning tokens.

### What Routes to Pipelines (Zero-Token Path)

```mermaid
flowchart TD
    subgraph ZERO["🟢 Zero-Token Path"]
        SLASH["/brief /email /git /health<br>(explicit commands)"]:::green
        CALLBACK["Button callbacks<br>(pre-built tree lookup)"]:::green
        CRON["Cron triggers<br>(scheduled brief, health-check)"]:::green
    end

    subgraph LOW["🟡 Low-Token Path (~800 max)"]
        CLASSIFY["'Check my email'<br>→ triage model classifies<br>→ routes to email.lobster"]:::amber
        SUMMARIZE["Pipeline uses llm-task<br>for one classify/summarize step"]:::amber
    end

    subgraph FULL["🔴 Full-Token Path (2K+)"]
        NUANCE["'Why did the deploy fail?'<br>'Help me debug this'<br>'Write a post about X'"]:::red
    end

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

---

## How Project-Related Requests Get Routed

This is the specific flow for project-related requests — when the user says something like "let's work on project X" or "do something in project Y":

```mermaid
flowchart TD
    USER["'Let's work on<br>the crispy-kitsune repo'"]:::gray
    USER --> TRIAGE["Triage model classifies:<br>project_work intent"]:::blue
    TRIAGE --> HAS_PIPE{"Matching pipeline<br>exists?"}:::amber

    HAS_PIPE -->|"Yes<br>(e.g. /git for repo work)"| SUGGEST["Crispy suggests pipeline<br>via quick-action buttons"]:::green
    HAS_PIPE -->|"Partial<br>(no exact match)"| DECISION["Build decision tree<br>'What about it?'<br>🔀 Git · 🔧 Config<br>📝 Code · ❓ Ask"]:::amber
    HAS_PIPE -->|"No match"| AGENT["Full agent loop<br>(this genuinely needs thinking)"]:::red

    SUGGEST --> TAP{"User taps"}:::amber
    TAP -->|"🔀 Git"| GIT_PIPE["git.lobster runs<br>(0 LLM tokens)"]:::green
    TAP -->|"📋 Brief"| BRIEF_PIPE["brief.lobster runs<br>(~800 tokens for summarize)"]:::green

    DECISION --> TAP2{"User taps"}:::amber
    TAP2 -->|"🔀 Git"| GIT_PIPE
    TAP2 -->|"🔧 Config"| CONFIG_CHECK["Pipeline: check config<br>(deterministic)"]:::green
    TAP2 -->|"📝 Code"| CODE_REFINE["Level 2 buttons<br>'Which file?'"]:::amber
    TAP2 -->|"❓ Ask"| AGENT

    CODE_REFINE --> TAP3{"User taps"}:::amber
    TAP3 --> AGENT

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

---

## Decision Rule for Routing

Use this decision tree to determine which path a message takes:

```
IF message is a known command (/brief, /email, /git, etc.)
  → PIPELINE PATH (0 tokens)

IF message is a button callback (tree_id + option_key)
  → STATE LOOKUP (0 tokens)

IF message matches a pipeline task (project work, status check, etc.)
  → Triage + ROUTE (200 tokens)

IF message is ambiguous (3+ possible interpretations)
  → Build DECISION TREE (500-1500 tokens)

IF message needs real thinking (debugging, creative, nuanced)
  → AGENT LOOP (2K-50K+ tokens)
```

---

## Guardrail Insertion Points in Routing

Six places where guardrails intercept the message flow. Each catches a different class of problem:

```mermaid
flowchart TD
    subgraph GUARDS["🛡️ Guardrail Map"]
        G1["① Input Gate<br>Auth + sanitize + injection scan"]:::blue
        G2["② Callback Validation<br>Verify tree_id + option_key format"]:::blue
        G3["③ Intent Classification<br>Triage model flags suspicious patterns"]:::blue
        G4["④ Instruction Hierarchy<br>System prompt overrides external content"]:::amber
        G5["⑤ Output Validation<br>Secret scan, PII check, format check"]:::blue
        G6["⑥ Action Gating<br>Exec-approve, pipeline approval, HITL"]:::red
    end

    G1 --> G2 --> G3 --> G4 --> G5 --> G6

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

| # | Guardrail | Layer | Catches | Implementation |
|---|---|---|---|---|
| ① | **Input Gate** | Before any processing | Bad actors, injection payloads, invisible chars | `sanitize.lobster` pipeline |
| ② | **Callback Validation** | Button tap handler | Crafted callback_data, tree_id spoofing | Format regex in `buttons.lobster` |
| ③ | **Intent Classification** | Triage step | Suspicious requests disguised as routine | Triage model checks for red flags |
| ④ | **Instruction Hierarchy** | System prompt | External content with embedded instructions | Hardened AGENTS.md section |
| ⑤ | **Output Validation** | Before sending | Leaked secrets, PII, .env values | `validate-output.lobster` pipeline |
| ⑥ | **Action Gating** | Before exec/send | Destructive commands, unauthorized actions | Exec-approve + pipeline approval |

---

## See Also

**Execution details →** [[stack/L6-processing/message-routing]]
