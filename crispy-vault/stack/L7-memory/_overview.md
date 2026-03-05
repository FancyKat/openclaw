---
tags: [layer/memory, status/draft, type/index]
layer_name: "Memory"
layer_number: 7
layer_slug: "L7-memory"
config_blocks: ["^config-memory", "^config-audit"]
file_count: 11
status_summary: "draft"

# ── VERSION TRACKING (managed by build/build.sh) ──
version_major: 0
version_minor: 0
version_patch: 5
version_full: "0.0.5"
version_changes: 6
version_last_build: 13
version_notes: "Initial — daily logs, memory search, Mem0, SQLite documented"
---

# L7 — Memory Layer

> What Crispy remembers between sessions. Daily logs, curated MEMORY.md, Mem0 vector memory, SQLite structured storage, and memory search. This is the persistence layer — no OSI equivalent, because networks don't need to remember.

**OSI parallel:** None — this is agent-specific. Networks are stateless; agents are not.

## Contents

- [[#Memory Systems]]
- [[#Write Triggers]]
- [[#Read Flow]]
- [[#Memory Decay]]
- [[#Pages in This Layer]]
- [[#Layer Boundary]]
- [[#Diagrams]]
  - [[#What's at This Layer]] · `flowchart`
  - [[#The 4 Memory Methods]] · `flowchart`
  - [[#How They Layer Together]] · `flowchart`
  - [[#Session Lifecycle]] · `flowchart`
  - [[#Setup Priority]] · `flowchart`
  - [[#Write Triggers]] · `flowchart`
  - [[#Read Flow]] · `flowchart`
  - [[#Audit Log — Tool Call Flow]] · `flowchart`
  - [[#How Audit Logs Feed Back into Guardrails]] · `flowchart`
  - [[#When to Use SQLite vs Other Methods]] · `flowchart`
  - [[#How SQLite Works]] · `flowchart`
  - [[#Memory Storage Schema (ER Diagram)]] · `erDiagram`
  - [[#Memory Decay Timeline]] · `timeline`
- [[#L7 File Review (Live)]]

---

## Memory Systems

Four complementary memory systems, each serving a different purpose:

| System | Storage | Query Method | Best For | Status |
|---|---|---|---|---|
| **Daily Logs** | `memory/YYYY-MM-DD.md` files | File read, memory_search | Session summaries, daily activity | ✅ Configured |
| **MEMORY.md** | Single curated file | Injected into context (DMs) | Durable facts, preferences, lessons | ✅ Configured |
| **Memory Search** | Built-in OpenClaw tool | `memory_search` tool call | Finding past conversations | ✅ Configured |
| **Mem0** | Vector database (plugin) | Semantic similarity search | "Remember when we..." style recall | 🟡 Ready |
| **SQLite** | `.db` file | SQL queries | Structured data, analytics | ⏳ Planned |

---

## Write Triggers

When does Crispy write to memory?

See [[stack/L7-memory/daily-logs]] for details on daily log structure and write triggers.

---

## Read Flow

When Crispy needs past context:

See the diagrams below for the complete read flow sequence.

---

## Memory Decay

Not all memories are equally important. Over time:

| Time | What Persists | What Fades |
|---|---|---|
| **Today** | Full daily log in context | — |
| **Yesterday** | Full daily log in context | — |
| **This week** | Searchable via memory_search | Exact wording |
| **This month** | Key facts in MEMORY.md | Session details |
| **Older** | Only what's in MEMORY.md or Mem0 | Daily logs archived |

---

## Pages in This Layer

| Page | Covers |
|---|---|
| [[stack/L7-memory/daily-logs]] | Daily log structure, write triggers |
| [[stack/L7-memory/memory-md]] | MEMORY.md curation rules |
| [[stack/L7-memory/memory-search]] | Built-in search, query patterns |
| [[stack/L7-memory/audit-log]] | Guardrail log format, review process |
| [[stack/L7-memory/sqlite]] | Structured data, SQL queries |
| [[stack/L7-memory/decisions-log]] | Architectural decisions |
| [[stack/L7-memory/open-questions]] | Unresolved questions |
| [[stack/L7-memory/CHANGELOG]] | Layer changelog — all L7 changes by date |
| [[stack/L7-memory/cross-layer-notes]] | Cross-layer notes from L7 sessions |

---

## Layer Boundary

**L7 receives from L6:** Write requests (save to daily log, update MEMORY.md) and read requests (memory_search, check facts).

**L7 provides to L4:** Persistent data that gets loaded into context at session start (MEMORY.md, daily logs).

**If L7 breaks:** Crispy has amnesia. Each session starts fresh with no history. Check file permissions, memory paths, search index.

---

## Diagrams

### What's at This Layer

```mermaid
flowchart TD
    L7["L7 — Memory"]:::purple
    L7 --> DAILY["Daily Logs<br>memory/YYYY-MM-DD.md<br>Written at session end + compaction"]:::blue
    L7 --> CURATED["MEMORY.md<br>Durable facts true<br>across all sessions"]:::purple
    L7 --> SEARCH["Memory Search<br>Built-in query tool<br>Search past context"]:::blue
    L7 --> MEM0["Mem0 Plugin<br>Vector memory<br>Semantic recall"]:::amber
    L7 --> SQLITE["SQLite<br>Structured queries<br>Analytics, patterns"]:::green
    L7 --> AUDIT["Audit Log<br>guardrail.log<br>Security decisions"]:::red

    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

### The 4 Memory Methods

```mermaid
flowchart TD
    M1["① Structured Folders<br>Markdown files in workspace/"]:::green
    M2["② Memory Search<br>Built-in vector + BM25"]:::teal
    M3["③ Mem0 Plugin<br>Auto-capture + auto-recall"]:::purple
    M4["④ SQLite Database<br>Structured data + exact queries"]:::blue

    M1 ---|"transparent<br>manual"| M2
    M2 ---|"semantic<br>built-in"| M3
    M3 ---|"automatic<br>plugin"| M4

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
```

### How They Layer Together

```mermaid
flowchart TD
    CTX["Context Window<br>(what Crispy sees right now)"]:::amber

    CTX --> F["① Folders<br>Bootstrap files loaded<br>at session start"]:::green
    CTX --> MS["② Memory Search<br>Semantic recall<br>on demand"]:::teal
    CTX --> M0["③ Mem0<br>Auto-recall injects<br>relevant memories"]:::purple
    CTX --> DB["④ SQLite<br>Exact queries on<br>structured data"]:::blue

    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
```

### Session Lifecycle

```mermaid
flowchart TD
    NEW["New session<br>(or daily reset @ 4am)"]:::green
    NEW --> LOAD["Load bootstrap + MEMORY.md<br>+ today + yesterday logs"]:::blue
    LOAD --> CHAT["Conversation"]:::gray
    CHAT --> PRUNE{"Old messages<br>> 1hr?"}:::amber
    PRUNE -->|Yes| TTL["Prune, keep last 3"]:::amber
    PRUNE -->|No| CHAT
    TTL --> OVF{"Context<br>overflowing?"}:::amber
    OVF -->|Yes| FLUSH["Flush → Compact"]:::amber
    OVF -->|No| CHAT
    FLUSH --> CHAT

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
```

### Setup Priority

```mermaid
flowchart TD
    P1["① Folders — ✅ done"]:::green
    P2["② Memory Search — ✅ done<br>just verify Gemini key"]:::green
    P3["③ Mem0 — next<br>install plugin + API key"]:::amber
    P4["④ SQLite — later<br>when structured data needed"]:::gray
    P1 --> P2 --> P3 --> P4

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
```

### Write Triggers

When does Crispy write to memory?

```mermaid
flowchart TD
    TRIGGER["Memory Write Triggers"]:::gray
    TRIGGER --> T1["'Remember this'<br>→ daily log"]:::blue
    TRIGGER --> T2["Session end<br>→ daily log"]:::blue
    TRIGGER --> T3["Compaction<br>→ daily log (flush first)"]:::amber
    TRIGGER --> T4["Durable fact learned<br>→ MEMORY.md"]:::purple
    TRIGGER --> T5["New preference<br>→ USER.md"]:::purple
    TRIGGER --> T6["Lesson learned<br>→ AGENTS.md (self-update)"]:::green
    TRIGGER --> T7["Guardrail decision<br>→ guardrail.log"]:::red

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

### Read Flow

When Crispy needs past context:

```mermaid
flowchart TD
    NEED["Need past info"]:::gray
    NEED --> CHECK_MEM["1. Check MEMORY.md<br>(already in context for DMs)"]:::purple
    CHECK_MEM --> FOUND1{"Found?"}:::amber
    FOUND1 -->|Yes| USE["Use it"]:::green
    FOUND1 -->|No| SEARCH["2. memory_search tool<br>(query past sessions)"]:::blue
    SEARCH --> FOUND2{"Found?"}:::amber
    FOUND2 -->|Yes| USE
    FOUND2 -->|No| DAILY_CHECK["3. Check today/yesterday<br>daily logs (in context)"]:::blue
    DAILY_CHECK --> FOUND3{"Found?"}:::amber
    FOUND3 -->|Yes| USE
    FOUND3 -->|No| ASK["4. Ask the user"]:::gray

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
```

### Audit Log — Tool Call Flow

```mermaid
flowchart TD
    CALL["Tool call<br>(browser, exec, web_fetch)"]:::blue
    CALL --> LOG["Log to audit file"]:::green
    LOG --> RECORD["Timestamp, tool,<br>input, result, tokens"]:::purple

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

### How Audit Logs Feed Back into Guardrails

```mermaid
flowchart TD
    CALL["Crispy attempts action"]:::blue
    CALL --> CHECK["Guardrail check<br>Is this allowed?"]:::amber
    CHECK -->|"No"| DENY["Deny + log DENIAL"]:::red
    CHECK -->|"Yes, needs approval"| ASK["Ask user<br>Log APPROVAL"]:::yellow
    CHECK -->|"Yes, auto-allowed"| DO["Execute<br>Log TOOL_CALL"]:::green
    DENY & ASK & DO --> LOG["All recorded in<br>audit/YYYY-MM-DD.jsonl"]:::purple

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef yellow fill:#fef08a,stroke:#eab308,color:#713f12
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

### When to Use SQLite vs Other Methods

```mermaid
flowchart TD
    Q{"What kind of<br>data?"}:::amber
    Q -->|"Preferences<br>decisions"| M123["Use Methods 1–3<br>Folders + vectors<br>+ Mem0"]:::green
    Q -->|"APIs, schemas"| SQL["Use SQLite"]:::blue
    Q -->|"Product catalogs"| SQL
    Q -->|"Structured lists<br>with fields"| SQL
    Q -->|"Data needing<br>exact queries"| SQL

    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
```

### How SQLite Works

```mermaid
flowchart TD
    NEED["Crispy needs<br>structured storage"]:::teal
    NEED --> CREATE["Creates .db file<br>defines schema with SQL"]:::blue
    CREATE --> POP["Populates rows<br>INSERT statements"]:::blue
    POP --> QUERY["Later: exact SQL queries<br>SELECT WHERE, JOIN, etc"]:::green
    QUERY --> ANS["Returns precise results"]:::green

    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
```

### Memory Storage Schema (ER Diagram)

How the five storage entities relate. Each entity maps to a physical file or index in the workspace.

```mermaid
erDiagram
    SESSION ||--o{ DAILY_LOG : "flushes to"
    SESSION ||--o{ AUDIT_EVENT : "produces"
    DAILY_LOG ||--o{ MEMORY_ENTRY : "auto-indexed into"
    MEMORY_MD ||--o{ MEMORY_ENTRY : "indexed into (no decay)"
    DAILY_LOG }o--|| MEMORY_MD : "heartbeat promotes"

    SESSION {
        string session_id PK
        datetime started_at
        datetime ended_at
        string agent_id FK
        string channel
        int message_count
        int token_total
        string jsonl_path
    }

    DAILY_LOG {
        date log_date PK
        string file_path
        string agent_id FK
        int entry_count
        string categories
        datetime last_write
    }

    MEMORY_ENTRY {
        string entry_id PK
        vector embedding
        string content
        string source
        string category
        string subcategory
        string session_id FK
        string_array tags
        datetime timestamp
        datetime decay_anchor
        float vector_score
        float bm25_score
    }

    MEMORY_MD {
        string section PK
        string content
        string source_type
        datetime last_updated
        datetime last_accessed
        int access_count
    }

    AUDIT_EVENT {
        string event_id PK
        string session_id FK
        datetime timestamp
        string event_type
        string tool_name
        string input_summary
        string result
        string decision
    }
```

| Entity | Physical Storage | Retention | Query Method |
|---|---|---|---|
| **SESSION** | `sessions/YYYY-MM-DD.jsonl` | 90 days | File read |
| **DAILY_LOG** | `memory/YYYY-MM-DD.md` | Permanent (older archived) | File read + vector search |
| **MEMORY_ENTRY** | Embedding index (Gemini vectors) | 50K max, 30-day decay | `memory_search` tool |
| **MEMORY_MD** | `workspace/MEMORY.md` | Permanent (audit at 180d) | Loaded into context |
| **AUDIT_EVENT** | `audit/YYYY-MM-DD.jsonl` | 90 days | File read |

### Memory Decay Timeline

How memory relevance fades over time. MEMORY.md entries are exempt — they persist at full strength until manually archived.

```mermaid
timeline
    title Memory Decay (30-day half-life)
    section Day 0
        100% relevance
    section Day 7
        87% relevance
    section Day 30
        50% — half-life reached
    section Day 60
        25% — fading
    section Day 90
        12.5% — rarely surfaces
    section Day 180+
        Archive threshold
```

| Age | Score | What Happens |
|---|---|---|
| Day 0 | 100% | New memory indexed, vector + BM25 at full weight, daily log in active context |
| Day 7 | 87% | Still very accessible, daily log searchable |
| Day 30 | 50% | Half-life reached, heartbeat may promote to MEMORY.md |
| Day 60 | 25% | Only strong semantic matches surface |
| Day 90 | 12.5% | Rarely surfaces, session JSONL eligible for cleanup |
| Day 180+ | Archive | Daily logs archived, MEMORY.md entries audited |

> **MEMORY.md entries are exempt from decay** — they persist at full score until manually archived.

---

## L7 File Review (Live)

```dataview
TABLE WITHOUT ID
  file.link AS "File",
  choice(contains(file.frontmatter.tags, "status/finalized"), "✅",
    choice(contains(file.frontmatter.tags, "status/review"), "🔍",
      choice(contains(file.frontmatter.tags, "status/planned"), "⏳", "📝"))) AS "Status",
  choice(contains(file.frontmatter.tags, "type/guide"), "Guide", "Core") AS "Type",
  dateformat(file.mtime, "yyyy-MM-dd") AS "Last Modified"
FROM "stack/L7-memory"
WHERE file.name != "_overview"
SORT choice(contains(file.frontmatter.tags, "type/guide"), "Z", "A") ASC, file.name ASC
```

> **Key Decision: SSD as Vector Database** — The 870 EVO (1TB SATA SSD) can host a dedicated Qdrant vector DB for all of L7's memory search needs. See [[stack/L1-physical/hardware#priority-3--ssd-vector-database-free-just-needs-setup]] for setup instructions.

**Legend:** ✅ Finalized · 🔍 Review · 📝 Draft · ⏳ Planned

---

**Up →** [[stack/_overview]]
