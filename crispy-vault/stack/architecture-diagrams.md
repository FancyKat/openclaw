---
tags: [type/reference, status/draft]
---
# Architecture Diagrams

> Visual diagrams covering memory lifecycle, background agents, system overview, and multi-bot architecture. Uses Mermaid diagram types beyond flowcharts: state, gantt, class, mindmap.

**Up →** [[stack/_overview]]

---

## Memory Lifecycle (State Diagram)

How a piece of information moves from initial capture through short-term to long-term storage. Compaction and heartbeat are the primary promotion triggers.

```mermaid
stateDiagram-v2
    [*] --> SessionContext: User message arrives

    SessionContext --> DailyLog: Session end / compaction flush
    SessionContext --> MEMORY_MD: Explicit "remember this"

    DailyLog --> VectorIndex: Auto-indexed (Gemini embeddings)
    DailyLog --> MEMORY_MD: Heartbeat promotes durable fact

    VectorIndex --> Retrieved: Query matches (score >= threshold)
    VectorIndex --> Decayed: Score < 0.1 (age > 90 days)

    Retrieved --> SessionContext: Injected into active context

    MEMORY_MD --> SessionContext: Loaded at session start (DM only)
    MEMORY_MD --> Archive: Monthly audit (>180d, unused)

    Decayed --> [*]: Functionally forgotten
    Archive --> [*]: Moved to memory/archive/

    note right of SessionContext
        Short-term: active conversation
        Token budget: up to ~100K
    end note

    note right of DailyLog
        Medium-term: today + yesterday loaded
        Older days searchable via vectors
    end note

    note right of MEMORY_MD
        Long-term: curated, permanent
        Max ~50KB before archiving
    end note

    note right of VectorIndex
        Decay: 0.5^(age_days / 30)
        30d = 50%, 60d = 25%, 90d = 12.5%
    end note
```

---

## Background Agent Schedule (Gantt)

What Crispy does when nobody is talking to it — and during active conversations. All background tasks use the flash model (cheapest inference).

```mermaid
gantt
    title Background Agent Schedule (24h)
    dateFormat HH:mm
    axisFormat %H:%M

    section Continuous
    Heartbeat check        :active, h1, 00:00, 24h
    Category classify      :active, c1, 00:00, 24h
    Compaction             :crit, co, 00:00, 24h

    section Scheduled
    Media catchup          :done, mc, 00:00, 24h
    Health check           :done, hc, 00:00, 24h
    Media cleanup          :milestone, m1, 02:00, 15min
    Daily brief            :milestone, b1, 08:00, 10min

    section Session
    Daily reset            :crit, r1, 04:00, 5min
    Idle timeout           :active, it, 00:00, 24h
```

### Schedule Summary

| Task | Schedule | Model | Cost | Purpose |
|------|----------|-------|------|---------|
| Heartbeat | Every 20 min (active session) | flash | ~100 tokens | Git dirty, disk, daily log size, pending reminders |
| Category classify | Per message (async) | flash | ~100 tokens | Tag messages with category:subcategory |
| Compaction | Context > ~120K tokens | flash | ~200 tokens/group | Per-category-segment summarization |
| Media catchup | */30 * * * * | — | 0 (pipeline) | Safety net for missed inbound processing |
| Health check | 0 * * * * | flash | ~100 tokens | Git, memory folder, disk, daily log checks |
| Media cleanup | 0 2 * * * | — | 0 (pipeline) | Archive 30d media, delete 90d archived |
| Daily brief | 0 8 * * * (PT) | flash | ~800 tokens | RSS, weather, git status, inbox summary |
| Daily reset | 4am PT | — | 0 | Clear context, save session JSONL |
| Idle timeout | After 2hr silence | — | 0 | Write checkpoint, close session |

---

## Four Memory Types (Class Diagram)

The 4 complementary storage methods. Each serves a different query pattern and persistence need.

```mermaid
classDiagram
    class StructuredFolders {
        +path: ~/.openclaw/workspace/
        +format: Markdown (.md)
        +persistence: Permanent
        +loaded: Every session (bootstrap)
        +files: MEMORY.md, daily logs, SOUL.md
        +write(fact)
        +curate(section)
    }

    class MemorySearch {
        +provider: Gemini
        +model: gemini-embedding-001
        +dimensions: 768
        +vectorWeight: 0.7
        +textWeight: 0.3 (BM25)
        +halfLifeDays: 30
        +maxCache: 50000 entries
        +search(query, filters)
        +index(content, metadata)
    }

    class Mem0Plugin {
        +provider: app.mem0.ai
        +mode: Auto-capture
        +trigger: Passive (background)
        +status: Ready (not yet active)
        +autoRecall(context)
        +autoCapture(conversation)
    }

    class SQLiteDB {
        +path: workspace/data/*.db
        +format: Relational (SQL)
        +persistence: Permanent
        +databases: endpoints, tasks, changelog, index
        +query(sql)
        +insert(table, row)
        +createTable(schema)
    }

    StructuredFolders --> MemorySearch : daily logs indexed into vectors
    StructuredFolders --> Mem0Plugin : MEMORY.md supplements auto-capture
    MemorySearch <.. Mem0Plugin : semantic overlap (both use embeddings)
    SQLiteDB ..> MemorySearch : structured data kept separate
    StructuredFolders ..> SQLiteDB : could migrate structured facts
```

### When to Use Each

| Method | Best For | Query Style | Example |
|--------|----------|-------------|---------|
| Folders (MEMORY.md) | Durable facts, preferences, people | Loaded automatically | "Marty prefers dark mode" |
| Memory Search | Past conversations, contextual recall | Semantic + keyword | "What chicken recipe did we discuss?" |
| Mem0 | Passive auto-capture, implicit memory | Automatic injection | System remembers without being told |
| SQLite | Structured data, exact lookups | SQL queries | "List all API endpoints with rate limits" |

---

## Full System Overview (Mindmap)

The complete Crispy Kitsune architecture at a glance — all 7 layers and their key subsystems.

```mermaid
mindmap
    root((Crispy Kitsune))
        L1 Physical
            Hardware
                i9-14900K
                64GB DDR5
                GTX 1060
            Docker Sandbox
                Isolated execution
                No network by default
            Gateway
                Port 18789
                Loopback only
            Hooks
                media-sort
                Gmail webhook
        L2 Runtime
            Model Cascade
                researcher (primary)
                workhorse (coding)
                workhorse-code (GPT)
                flash (background)
                4 fallbacks
            Config
                openclaw.json
                .env secrets
            Session Defaults
                Heartbeat 20m
                Compaction flash
                Reset 4am + 2hr idle
        L3 Channels
            Telegram (primary)
                DM allowlist
                Inline buttons
                Voice/media
            Discord (planned)
                Multi-bot council
                Guild-scoped
                Role-based agents
            Gmail (webhook)
                Inbound processing
                Not a full channel
        L4 Session
            Bootstrap Files
                AGENTS
                SOUL
                IDENTITY
                TOOLS
                USER
                MEMORY
                HEARTBEAT
                STATUS
                BOOT
            Context Assembly
                Ordered injection
                Attention curve
            Compaction
                Per-category-segment
                Flash model
        L5 Routing
            Intent Classification
                Trigger words
                Triage model
                Prompt builder
            3 Execution Paths
                Pipeline (0 tokens)
                Button tree (~1.5K)
                Agent loop (2K-50K+)
            7 Focus Categories
                Cooking
                Coding
                Finance
                Fitness
                Pet Care
                Design
                Habits
            Guardrails
                Input gate
                Output validation
                Action gating
        L6 Processing
            Agent Loop
                Think-Act-Observe
                Tool calls
                Model fallback
            Pipelines (Lobster)
                brief
                email
                git
                health-check
                media
                26 category pipelines
            Skills (54+)
                Platform skills
                Claude Code skills
            Coding Workflows
                git, code-review
                deploy, testing
        L7 Memory
            Daily Logs
                Today + yesterday loaded
                Older searchable
            MEMORY.md
                Curated long-term
                People, projects, prefs
            Memory Search
                Gemini vectors
                Hybrid 70/30
                30-day decay
            Mem0 (planned)
                Auto-capture
            SQLite (planned)
                Structured data
            Audit Log
                JSONL append-only
                90-day retention
```

---

## Multi-Bot Architecture (Class Diagram)

How multiple agents bind to multiple channel instances with isolated workspaces.

```mermaid
classDiagram
    class Agent {
        +id: string
        +workspace: path
        +heartbeat: HeartbeatConfig
        +model: ModelConfig
    }

    class Channel {
        +type: telegram | discord
        +instance: string
        +token: env_var
        +policy: allowlist | pairing
    }

    class Binding {
        +agentId: string
        +channel: string
        +guildId?: string
        +roles?: string[]
    }

    class Workspace {
        +path: string
        +SOUL_MD: shared or custom
        +AGENTS_MD: role-specific
        +USER_MD: per-user
        +MEMORY_MD: isolated
        +daily_logs/: isolated
    }

    class HeartbeatConfig {
        +every: string
        +target: last | none
        +directPolicy: allow | suppress
    }

    Agent "1" --> "1" Workspace : owns
    Agent "1" --> "0..1" HeartbeatConfig : configures
    Binding "1" --> "1" Agent : routes to
    Binding "1" --> "1" Channel : listens on
    Channel "1" --> "0..*" Binding : serves

```

### Default Configuration (Starter)

```
Agents:
  crispy          → workspace/          → telegram    (Marty)
  crispy-wenting  → workspace-wenting/  → telegram1   (Wenting)
  crispy          → workspace/          → discord     (main guild)

Scaling to multi-bot Discord:
  discord-bot-1   → workspace-discord-1/ → discord1   (trading channel)
  discord-bot-2   → workspace-discord-2/ → discord2   (coding channel)
  discord-bot-3   → workspace-discord-3/ → discord3   (general channel)
```

---

## See Also

- [[stack/L7-memory/_overview]] — Memory layer detail (ER diagram, decay timeline)
- [[stack/L7-memory/memory-search]] — Search scoring pipeline
- [[stack/L6-processing/_overview]] — Processing layer (cron schedule)
- [[stack/L6-processing/agent-loop]] — Agent loop state machine
- [[stack/L5-routing/conversation-flows]] — Conversation lifecycle + progress bar
- [[stack/L5-routing/message-routing]] — Three routing paths
- [[stack/_overview]] — Config cascade diagram

---

**Up →** [[stack/_overview]]
