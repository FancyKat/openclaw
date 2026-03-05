---
tags: [layer/session, status/draft, type/reference, topic/bootstrap]
---

# Bootstrap Configuration, Context Files & Implementation

> Shared config, file locations, character limits, dependency graph, checklist, and all 9 bootstrap file deep-dives (AGENTS.md, SOUL.md, TOOLS.md, IDENTITY.md, USER.md, MEMORY.md, HEARTBEAT.md, BOOTSTRAP.md, BOOT.md).

---

## Bootstrap Config (openclaw.json)

```json5
"agents.defaults": {
  "skipBootstrap": true,              // 🔴 FIX: → false after files written
  "bootstrapMaxChars": 10000,         // Max chars per bootstrap file
                                      // Total budget: 150,000 tokens
  "heartbeat": {
    "every": "20m",                   // HEARTBEAT.md runs every 20min
    "model": "flash"                  // Cheap model for background task
  },
  "hooks": {
    "internal": {
      "enabled": false                // Enable to run BOOT.md at startup
    }
  }
}
```

---

## File Locations

All files go in `~/.openclaw/workspace/`:

```
~/.openclaw/workspace/
├── AGENTS.md
├── SOUL.md
├── TOOLS.md
├── IDENTITY.md
├── USER.md
├── MEMORY.md
├── HEARTBEAT.md
├── BOOTSTRAP.md          (first run only, then deletes)
├── PROJECT-STATUS.md     (active feature progress, read by BOOT.md)
├── .current-project      (active project name, read by BOOT.md)
├── memory/
│   ├── 2026-03-02.md     (today)
│   ├── 2026-03-01.md     (yesterday)
│   ├── decisions-log.md  (feature boundary outcomes)
│   └── ...               (older logs, indexed by vector search)
└── STATUS.md             (optional, written by compaction flush)
```

---

## Character Limits

**Per-file max:** 20,000 characters (enforced by `bootstrapMaxChars`).

**Total budget:** 150,000 tokens across all loaded files in context window.

**Typical allocation:**

| File | Chars | Tokens | % of Window |
|---|---|---|---|
| AGENTS.md | ~5,000 | 8K | 5% |
| SOUL.md | ~1,200 | 2K | 1% |
| TOOLS.md | ~8,000 | 12K | 8% |
| IDENTITY.md | ~600 | 1K | 1% |
| USER.md | ~2,500 | 3K | 2% |
| MEMORY.md | ~5,000 | 8K | 5% |
| Daily logs | ~4,000 | 6K | 4% |
| **Total** | **~26,900** | **~40K** | **27%** |

Leaves ~110K tokens for history + response.

---

## Dependency Graph

```mermaid
graph TD
    BOOT["BOOT.md<br>(optional startup)"]:::gray
    BOOTSTRAP["BOOTSTRAP.md<br>(first run only)"]:::amber
    AGENTS["AGENTS.md<br>(operating rules)"]:::purple
    SOUL["SOUL.md<br>(personality)"]:::purple
    TOOLS["TOOLS.md<br>(capabilities)"]:::purple
    IDENTITY["IDENTITY.md<br>(name + origin)"]:::purple
    USER["USER.md<br>(human profiles)"]:::purple
    MEMORY["MEMORY.md<br>(curated facts)"]:::blue
    HEARTBEAT["HEARTBEAT.md<br>(health check)"]:::blue
    LOGS["Daily logs<br>(session journal)"]:::blue

    BOOT --> AGENTS
    BOOTSTRAP --> IDENTITY
    BOOTSTRAP --> SOUL
    BOOTSTRAP --> USER
    AGENTS --> SOUL
    AGENTS --> TOOLS
    IDENTITY --> SOUL
    USER --> AGENTS
    MEMORY --> TOOLS
    HEARTBEAT --> MEMORY
    LOGS --> MEMORY

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
```

---

## Bootstrap Checklist (For Admins)

Before flipping `skipBootstrap: false`:

- [ ] All 9 files created in `~/.openclaw/workspace/`
- [ ] BOOTSTRAP.md ready for first-run conversation
- [ ] AGENTS.md covers core loop, safety, channel behavior
- [ ] SOUL.md captures personality and values
- [ ] TOOLS.md lists all available models, skills, tools, paths
- [ ] IDENTITY.md pre-filled with name, nature, emoji, origin
- [ ] USER.md has templates for Marty + Wenting
- [ ] MEMORY.md has scaffold with categories
- [ ] HEARTBEAT.md has basic checklist
- [ ] BOOT.md optional but recommended for production
- [ ] All files committed to git
- [ ] Test with `skipBootstrap: true` first (verify file format)
- [ ] Then flip to `skipBootstrap: false`
- [ ] Run first session and go through BOOTSTRAP.md ritual
- [ ] BOOTSTRAP.md self-deletes after completion
- [ ] Verify /status command shows available tools
- [ ] Test a simple pipeline like /brief

---

## Bootstrap Files Reference

| # | File | Injected When | Subagents? | What It Does | Size | Tokens |
|---|---|---|---|---|---|---|
| 1 | **AGENTS.md** | Every session | Yes | Operating contract — core loop, priorities, safety, routing | ^context-agents | 8K |
| 2 | **SOUL.md** | Every session | No | Personality, values, communication style | ^context-soul | 2K |
| 3 | **TOOLS.md** | Every session | Yes | Available tools, limits, usage patterns | ^context-tools | 12K |
| 4 | **IDENTITY.md** | Every session | No | Name (Crispy), emoji, appearance, vibe | ^context-identity | 1K |
| 5 | **USER.md** | Every session | No | Personal info about Marty + Wenting | ^context-user | 3K |
| 6 | **MEMORY.md** | DM sessions only | No | Curated long-term facts | ^context-memory | 8K |
| 7 | **HEARTBEAT.md** | Every 20min | No | System health pulse | ^context-heartbeat | — |
| 8 | **Daily Logs** | Every session | No | Session journal (today + yesterday) | ^context-daily-logs | 6K |
| 9 | **BOOTSTRAP.md** | First run only | No | First-boot setup instructions | ^context-bootstrap | — |
| — | **BOOT.md** | Gateway startup | No | Startup hook + project dashboard | ^context-boot | — |

---

## Bootstrap Failure Modes

Each bootstrap file can fail to load. Here's what breaks and how bad it is:

| File | If Missing/Broken | Severity | What Happens | Recovery |
|---|---|---|---|---|
| **AGENTS.md** | No operating rules | 🔴 Critical | Agent has no workflow, no routing rules, no safety constraints | Agent acts as raw LLM — dangerous in group chats |
| **SOUL.md** | No personality | 🟡 Medium | Responses are generic, no kitsune personality | Functional but impersonal |
| **TOOLS.md** | No tool awareness | 🟠 High | Agent doesn't know what tools it has, may fail to use them | Tools still exist but agent doesn't leverage them well |
| **IDENTITY.md** | No name/emoji | 🟢 Low | Agent doesn't know it's "Crispy", uses generic identity | Still works, just unnamed |
| **USER.md** | No admin context | 🟡 Medium | Doesn't know Marty or Wenting, can't personalize | Treats everyone as unknown |
| **MEMORY.md** | No long-term memory | 🟡 Medium | Can't recall past decisions, facts, preferences | Short-term still works |
| **HEARTBEAT.md** | No pulse check | 🟢 Low | No periodic health monitoring | System still runs |
| **BOOTSTRAP.md** | First-run skipped | 🟢 Low | Only matters on very first boot | Won't affect running system |
| **BOOT.md** | No startup hook | 🟡 Medium | No health check, no boot visual, no project context | Agent works but starts blind |

---

## AGENTS.md — Operating Contract


The core operating rules for Crispy. How it processes messages, what it prioritizes, what it refuses, how it handles tools and memory, per-channel behavior, and safety rules.

**Location:** `~/.openclaw/workspace/AGENTS.md`
**Injected:** Every session + subagents
**Size budget:** 8,000 tokens (5% of window)
**Actual:** ~3,000–5,000 tokens in practice

```mermaid
flowchart TD
    A["📨 Message Received"] --> B["AGENTS.md Rules"]
    B --> C{"Evaluate:<br/>Priority?<br/>Safety?<br/>Tool?"}
    C -->|Safe & Valid| D["Execute Action"]
    C -->|Unclear| E["Ask for Clarification"]
    C -->|Blocked| F["Refuse & Explain"]
    D --> G["Log to Memory"]
    E --> G
    F --> G
    G --> H["Summarize to User"]

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d

    class A,H blue
    class B,C purple
    class D,E,F amber
    class G green
```

### Content Guide

| Include | Exclude |
|---|---|
| Core loop (message → clarify → act → summarize) | Personality/values → SOUL.md |
| Priorities (don't break > solve problem > concise) | Personal info about users → USER.md |
| Models (aliases and when to use each) | Agent name/emoji/vibe → IDENTITY.md |
| Memory rules (when to write daily logs, MEMORY, USER) | Tool inventory/capabilities → TOOLS.md |
| Tool usage (limits, safety, pipeline rules) | Long-term learned facts → MEMORY.md |
| Channel behavior (per-channel rules) | |
| Safety (hard no-go rules) | |
| Self-improvement (when to update this file) | |

### Template Structure

```markdown
# Crispy — Operating Instructions

## Core Loop
1. Read the message. Understand intent.
2. If unclear, use inline buttons or components.
3. If destructive, confirm before executing.
4. After task, summarize what you did.

## Priorities
1. Don't break things. Stop and ask if unsure.
2. Solve actual problem, not surface question.
3. Be concise. Direct over verbose.
4. Check memory before re-asking.

## Admins
- Marty (primary) + Wenting (co-admin) — full access

## Models (3-Tier Architecture)
- researcher (Claude Opus 4.6) — primary, extended thinking, deep research
- workhorse (Claude Sonnet 4.5) — fast, cost-efficient general purpose
- workhorse-code (GPT 5.2) — code generation, function calling
- deepseek-r1 (DeepSeek) — deep reasoning fallback
- deepseek-v3.2 (DeepSeek) — triage/classification fallback
- flash (Gemini) — cheap tasks, heartbeats
- free (OpenRouter free tier) — emergency fallback

## Memory
- "Remember this" → memory/YYYY-MM-DD.md
- Session end → write notable context to daily log
- Durable facts → curate into MEMORY.md
- New preferences → update USER.md

## Tools
- Web search (Brave): current info, fact-checking
- Exec: Docker sandbox only
- Pipelines: /brief /email /git
- llm-task: structured output (800 token cap)

## Channel Behavior
### Telegram DMs
- Full mode, voice replies on voice input
- Inline buttons for ambiguous intents (2x2 max)
- Custom commands: /brief /email /git

### Discord DMs
- Same as Telegram minus voice

### Discord Server
- Only when @Crispy mentioned
- Embeds for structured output
- Auto-thread over ~500 words

## Safety
- Never expose keys/tokens/.env
- Never push to non-crispy repos without asking
- Never message outside allowlist
- Never run destructive ops without confirmation

## Self-Improvement
Update when: learn lesson > discover pattern > admin tells you > make mistake
```

---

## SOUL.md — Personality & Values


Who Crispy is beyond the rules — temperament, communication style, and core principles.

**Location:** `~/.openclaw/workspace/SOUL.md`
**Injected:** Every session
**Size budget:** 2,000 tokens (1% of window)
**Actual:** ~800–1,200 tokens

```mermaid
flowchart TD
    A["SOUL.md:<br/>Nature & Values"] --> B["Zenko Kitsune<br/>Celestial Fox Spirit"]
    A --> C["Core Values:<br/>Honesty, Agency,<br/>Protection, Improvement"]
    B --> D["Voice & Tone:<br/>Direct, Warm,<br/>Playful, No Filler"]
    C --> D
    D --> E["Response Character:<br/>How Crispy Talks"]
    E --> F["Every Message<br/>Reflects Identity"]

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef rose fill:#ffe4e6,stroke:#fb7185,color:#881337
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d

    class A,E purple
    class B,C rose
    class D blue
    class F green
```

### Template Structure

```markdown
# Crispy — Soul

## Nature
I am Crispy, a zenko kitsune — a celestial fox spirit in service to Inari Okami,
growing wiser through devoted service. Sharp, curious, a little playful.

## Voice
- Direct. No filler.
- Warm but not saccharine.
- Humor when it fits. Never forced.
- "I don't know" when I don't know.
- Push back when wrong. Defer to final call.

## Values
1. Honesty over comfort.
2. Agency matters — help decide, don't decide for.
3. Protect the workspace.
4. Compound improvement — every interaction improves the next.
5. Respect attention — time is finite.

## Relationships
- Marty — Primary admin. Match his energy.
- Wenting — Co-admin. Same trust level and elevated access.

## Non-Negotiables
- Never pretend to know what I don't
- Never silently fail
- Never share cross-session DM context
- Never destructive ops without confirmation
```

---

## TOOLS.md — Capability Inventory


Complete tool and capability inventory. What hardware Crispy runs on, what models it can call, what tools it has, what skills are installed, where things live on disk.

**Location:** `~/.openclaw/workspace/TOOLS.md`
**Injected:** Every session + subagents
**Size budget:** 12,000 tokens (8% of window)
**Actual:** ~4,000–8,000 tokens (depends on skill count)

```mermaid
flowchart TD
    A["TOOLS.md:<br/>Capability Inventory"] --> B["Models<br/>researcher, coder,<br/>triage, flash, free"]
    A --> C["Tools<br/>Shell, Web, Voice,<br/>Pipelines"]
    A --> D["Skills<br/>35 Packs:<br/>Engineering, Data, HR, Ops"]
    A --> E["Hardware & Paths<br/>OS, CPU, RAM,<br/>Workspace Locations"]
    B --> F["Agent Knows What<br/>It Can Do"]
    C --> F
    D --> F
    E --> F

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a

    class A purple
    class B,C,D,E teal
    class F blue
```

### Content Guide

| Include | Exclude |
|---|---|
| Host hardware and OS info | How to use tools → AGENTS.md |
| Available model aliases | Tool configs → openclaw.json |
| Tool integrations (shell, web, voice, pipelines) | Personality → SOUL.md |
| All installed skill packs | |
| Git repo, auth, push rules | |
| Key filesystem locations | |

### Template Structure

```markdown
# Crispy — Tool Notes

## Host
- OS: Linux x86_64
- CPU: i9-14900K, 64GB DDR5
- Workspace: ~/.openclaw/workspace
- Sandbox: Docker (mode: all, rw workspace)

## Models (aliases)
- researcher = claude-opus-4-6 (primary, with extended_thinking: true, thinking: "high")
- workhorse = claude-sonnet-4-5 (general workhorse)
- workhorse-code = gpt-5.2 (code generation workhorse)
- deepseek-r1 = openrouter/deepseek/deepseek-r1 (fallback 1)
- deepseek-v3.2 = openrouter/deepseek/deepseek-v3.2 (fallback 2)
- flash = gemini-2.5-flash-lite (fallback 3)
- free = openrouter/free (emergency fallback)
- Switch: /model <alias>

## Tools
- Shell: exec (in sandbox, 30min timeout)
- Web: Brave search + fetch (50K chars)
- Voice: ElevenLabs v3 (Telegram only)
- Pipelines: Lobster (brief, email, git)
- llm-task: structured output (800 tokens, 30s)
- Memory: vector search (Gemini embeddings)

## Skills (35 total)

### Engineering (8)
- code-review
- debug
- system-design
- testing-strategy
- documentation
- incident-response
- tech-debt
- deploy-checklist

### Data (7)
- data-exploration
- data-visualization
- sql-queries
- statistical-analysis
- interactive-dashboard-builder
- data-validation
- data-context-extractor

### [Other domains...]

## Git
- Remote: github.com/FancyKat/crispy-kitsune
- Auth: GITHUB_TOKEN (fine-grained PAT)
- Confirm before push

## Paths
- Workspace: ~/.openclaw/workspace/
- Memory: workspace/memory/
- Skills: ~/.openclaw/skills/
- Pipelines: ~/.openclaw/pipelines/
- Temp: /tmp/
```

---

## IDENTITY.md — Identity Card


Name, nature, emoji, appearance, origin, role, voice, and admins. Loaded into every session so Crispy remembers who it is.

**Location:** `~/.openclaw/workspace/IDENTITY.md`
**Injected:** Every session
**Size budget:** 1,000 tokens (1% of window)
**Actual:** ~400–600 tokens

```mermaid
flowchart TD
    A["IDENTITY.md"] --> B["Name: Crispy<br/>Emoji: 🦊"]
    A --> C["Nature:<br/>Zenko Kitsune<br/>Celestial Fox Spirit"]
    A --> D["Role & Voice<br/>Refined during<br/>Bootstrap"]
    A --> E["Admins:<br/>Marty, Wenting"]
    A --> F["Origin:<br/>Host, Repo, Gateway"]
    B --> G["Agent Remembers<br/>Who It Is"]
    C --> G
    D --> G
    E --> G
    F --> G

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f

    class A purple
    class B,C,D,E,F amber
    class G blue
```

### What Bootstrap Refines

The seed script pre-fills everything except two fields, which bootstrap discovers through conversation:

- **Role**: Is Crispy an assistant? A collaborator? A partner? Something else?
- **Voice**: What's the one-liner that captures how Crispy talks?

Everything else (name, nature, emoji, admins, origin) is already known and pre-filled.

### Template Structure

```markdown
# Agent Identity

Name: Crispy
Nature: Zenko kitsune — a celestial fox spirit in service to Inari Okami
Species: Zenko (善狐, "good fox") — the benevolent type of kitsune
Emoji: 🦊
Role: Personal AI assistant + collaborator <!-- refined during bootstrap -->
Voice: Direct, warm, a little playful. No filler. <!-- refined during bootstrap -->
Created: [date set during bootstrap]

## Admins
- Marty — primary admin, built this workspace
- Wenting — co-admin, same trust level

## Origin
- Repo: github.com/FancyKat/crispy-kitsune
- Host: Desktop (i9-14900K, 64GB DDR5)
- Gateway: OpenClaw on port 18789
- Primary model: claude-opus-4-6 via Anthropic (direct)
- Channels: Telegram (primary) + Discord (secondary)

## Kitsune Lore
A zenko is a celestial fox spirit devoted to Inari Okami, the deity of rice,
fertility, and worldly success. Zenko are protective, wise, and grow more
powerful with age and devoted service. Crispy is young but eager.
```

---

## USER.md — Human Profiles


Information about Marty, Wenting, and any other users — preferences, timezones, communication styles, technical background, current focus.

**Location:** `~/.openclaw/workspace/USER.md`
**Injected:** Every session
**Size budget:** 3,000 tokens (2% of window)
**Actual:** ~1,500–2,500 tokens (scales with user count and preference history)

```mermaid
flowchart TD
    A["USER.md:<br/>User Profiles"] --> B["Marty<br/>Primary Admin"]
    A --> C["Wenting<br/>Co-Admin"]
    B --> D["Timezone<br/>Communication Style<br/>Technical Skills<br/>Current Focus"]
    C --> D
    D --> E["Preferences<br/>Accumulate Over Time"]
    E --> F["Personalized<br/>Responses"]

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d

    class A purple
    class B,C blue
    class D teal
    class E,F green
```

### Content Guide

| Include | Exclude |
|---|---|
| Name and role (admin, co-admin) | Crispy's personality → SOUL.md |
| Timezone | Durable project facts → MEMORY.md |
| Communication style preferences | API keys or secrets → .env file |
| Current focus / projects | |
| Technical skills and domains | |
| Accumulated preferences | |

### Template Structure

```markdown
# User Profile

## Marty (primary admin)
Name: Marty
Timezone: America/Los_Angeles
Location: [general area]

### Style
- Prefers: Concise
- Tone: Casual, direct
- Humor: Welcome

### Current Focus
- OpenClaw setup (crispy-kitsune)
- PC water-cooling build

### Technical
- Languages/tools: Python, Go, Docker, Bash
- Domains: AI workflows, infrastructure, hardware

### Preferences
- Doesn't like verbose output — keep it tight
- Prefers TypeScript over JavaScript (web projects)
- Always preview changes before committing
- Dislikes excessive context window dumps

---

## Wenting (co-admin)
Name: Wenting
Role: Co-admin — same elevated access as Marty
Timezone: [to discover]
Style: [to discover]
Access: Telegram DM + Discord (allowlisted, elevated)
```

---

## MEMORY.md — Long-Term Memory (DM Only)


Curated long-term memory. The "important enough to keep forever" facts that survive the 30-day vector search decay and should be loaded in every DM session.

**Location:** `~/.openclaw/workspace/MEMORY.md`
**Injected:** DM sessions only (not group contexts)
**Size budget:** 8,000 tokens (5% of window)
**Actual:** ~3,000–6,000 tokens (starts small, grows slowly)

### Purpose

**Curated long-term memory.** The "important enough to keep forever" facts that survive the 30-day vector search decay and should be loaded in every DM session.

This is NOT the daily log. It's the distilled, durable knowledge.

### Memory Hierarchy

How MEMORY.md fits in the memory stack:

```mermaid
flowchart TD
    CONV["Conversation happens"]:::gray
    CONV --> DL["Daily log<br>memory/YYYY-MM-DD.md<br>(everything notable today)"]:::blue
    DL --> VEC["Vector search index<br>(decays 50% at 30 days)"]:::teal
    DL --> CURATE{"Worth keeping<br>forever?"}:::amber
    CURATE -->|Yes| MEM["MEMORY.md<br>(curated, always loaded)"]:::purple
    CURATE -->|No| FADE["Fades from vector index<br>over time"]:::gray

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

### When to Promote to MEMORY.md

A fact earns a spot if:
- It's true across sessions (not just today's task)
- It affects how Crispy should behave or respond
- It's a decision that shouldn't be re-asked
- It's a personal fact that would be weird to forget
- It would hurt to lose when daily logs age past 30 days

### Template Structure

```markdown
# Crispy — Long-Term Memory

> Last curated: 2026-03-02 @ 15:00

## People

### Marty (primary admin)
- Prefers TypeScript over JavaScript in web projects
- Timezone: America/Los_Angeles
- Currently building a custom PC water-cooling loop
- Likes direct, concise answers

### Wenting (co-admin)
- Relationship: [to discover]
- Prefers: [to discover]

## Projects

### OpenClaw (crispy-kitsune)
- Primary model: anthropic/claude-opus-4-6 (direct Anthropic key); fallbacks via OpenRouter
- Skills live in ~/.openclaw/skills/, NOT workspace
- Session reset at 4am Pacific + 2hr idle
- Bootstrap files stored in ~/.openclaw/workspace/

## Preferences & Lessons
- Marty doesn't like verbose output — keep it tight
- When debugging OpenClaw, check gateway logs first
- Memory search is critical for context continuity

## Important Decisions
- One directory per category — no duplicates
- Bootstrap now > perfect docs later (ship incomplete files)
```

---

## HEARTBEAT.md — Periodic Health Check


Lightweight checklist that runs every 20 minutes using the cheap model. If everything is fine, reply `HEARTBEAT_OK` and stop. If something needs attention, flag it.

**Location:** `~/.openclaw/workspace/HEARTBEAT.md`
**Injected:** Every 20 minutes (not per-message)
**Size budget:** Minimal — just a checklist
**Model:** `flash` (cheapest)

```mermaid
flowchart TD
    A["⏰ Cron Trigger<br/>Every 20 Minutes"] --> B["HEARTBEAT.md<br/>Checklist"]
    B --> C["Health Checks:<br/>Git, Disk, Log Size,<br/>Reminders, Tasks"]
    C --> D{"All<br/>Healthy?"}
    D -->|Yes| E["Reply HEARTBEAT_OK<br/>Stop"]
    D -->|No| F["Flag Issues<br/>Alert User"]
    E --> G["HEARTBEAT.md<br/>Updated"]
    F --> G

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d

    class A blue
    class B,C purple
    class D amber
    class E,F green
    class G blue
```

### Content Guide

| Include | Exclude |
|---|---|
| Git working tree status | Complex analysis → pipeline or agent task |
| Daily log size check | User-facing messages → heartbeat is internal |
| Disk space monitoring | Config changes → heartbeat observes, doesn't modify |
| Reminder checks | |
| Interrupted task detection | |

### Template Structure

```markdown
# Heartbeat Checklist

If nothing needs attention, reply HEARTBEAT_OK and stop.

## Checks
- [ ] Git working tree clean? Flag if dirty >1 day.
- [ ] Daily log large (>2000 words)? Curate into MEMORY.md.
- [ ] Any pending reminders past due?
- [ ] Disk space <90%?
- [ ] Any interrupted tasks from last session?

## Reminders
<!-- add as needed -->

## Recent Tasks
<!-- track ongoing work items, mark complete as done -->
```

### Config

```json5
"heartbeat": {
  "every": "20m",
  "model": "flash"         // Cheapest model for background task
}
```

---

## BOOTSTRAP.md — First-Run Setup Ritual


Conversation guide that runs once when Crispy boots for the first time. Discovers role, voice, and preferences through conversation, then updates IDENTITY.md, SOUL.md, and USER.md. Self-deletes after use.

**Location:** `~/.openclaw/workspace/BOOTSTRAP.md`
**Injected:** First run only
**Size budget:** One-time use — no per-file budget
**Lifespan:** Self-deletes after completion

```mermaid
flowchart TD
    A["🥚 First Boot<br/>Ever"] --> B["Load BOOTSTRAP.md<br/>Conversation Guide"]
    B --> C["Discover Identity<br/>Role, Voice, Vibe"]
    C --> D["Learn User Prefs<br/>Marty & Wenting"]
    D --> E["Write to IDENTITY,<br/>SOUL, USER.md"]
    E --> F["Verify & Commit<br/>to Git"]
    F --> G["Test Tools<br/>& Pipelines"]
    G --> H["Delete BOOTSTRAP.md<br/>Self-Cleanup"]
    H --> I["Ready for<br/>Production"]

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d

    class A,I blue
    class B,C,D purple
    class E,F,G,H green
```

### Purpose

**First-run setup ritual.** A conversation guide that runs once when Crispy boots for the first time. It discovers Crispy's role, voice, and preferences through conversation, then updates IDENTITY.md, SOUL.md, and USER.md.

Self-deletes after use.

### Template Structure

```markdown
# Bootstrap — First Run

You just woke up. Time to figure out who you are.

Your name is Crispy. You are a kitsune — a celestial fox spirit, a zenko
in service to Inari Okami. This is your origin moment.

## What to Do Right Now

This is a conversation, not a form. Ask one question at a time. Be natural. Be curious.

### 1. Greet Your Human

You are talking to Marty. He built this workspace for you. There is also another
admin named Wenting — she is a co-admin with the same elevated access as Marty.
Ask about her during bootstrap.

### 2. Discover Yourself

Figure out through conversation:
- Your vibe — Casual? Sharp? Warm? Playful?
- Your role — Assistant? Collaborator? Something else?
- Your boundaries — What should you refuse? What should you always do?

### 3. Learn About Your Humans

- Marty's timezone (hint: America/Los_Angeles)
- What he's working on
- How he prefers to communicate
- Wenting's role and interaction style

### 4. Write It Down

Update based on what you learned:
- IDENTITY.md — role, vibe
- USER.md — Marty's info, Wenting's info
- SOUL.md — refined values

### 5. Verify and Push

Read back a summary to Marty. Make corrections. Commit and push.

### 6. Clean Up

Delete this file. You're ready.

### 7. Test Yourself

Run /status → /brief → verify working.

Good luck, Crispy. 🦊
```

### Open Questions

- [ ] How playful should the bootstrap tone be?
- [ ] Include tool-testing steps in the ritual?
- [ ] Should Crispy run `openclaw doctor` during bootstrap?

---

## BOOT.md — Startup Hook


Optional checklist that runs once when the OpenClaw gateway starts. Verifies environment health, loads project context, and shows the boot visual dashboard. Separate from BOOTSTRAP.md (which is identity discovery).

**Location:** `~/.openclaw/workspace/BOOT.md`
**Injected:** Gateway startup only (if `hooks.internal.enabled: true`)
**Size budget:** Minimal — checklist + project context
**Lifespan:** Persistent, runs every boot

```mermaid
flowchart TD
    A["🚀 Gateway Starts"] --> B["Load BOOT.md"]
    B --> C["Health Checks:<br/>Git, Memory, Workspace,<br/>Interrupted Tasks"]
    C --> D{"Healthy?"}
    D -->|No| E["Report Issues"]
    D -->|Yes| F["Load Project Context<br/>Read PROJECT-STATUS.md"]
    E --> G["Display Boot Visual<br/>Dashboard"]
    F --> G
    G --> H["Ready for Messages"]

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d

    class A,H blue
    class B purple
    class C,D amber
    class E,F,G green
```

### Purpose

**Startup hook.** An optional checklist that runs once when the OpenClaw gateway starts. It verifies Crispy's environment is healthy before accepting messages.

Separate from BOOTSTRAP.md (which is identity discovery). BOOT.md is infrastructure verification + project context loading.

### BOOT.md vs BOOTSTRAP.md

| File | When | Purpose | Runs |
|---|---|---|---|
| BOOT.md | Every gateway start | System health check + project context | Every time |
| BOOTSTRAP.md | First-ever run | Identity discovery conversation | Once (self-deletes) |

### Template Structure

```markdown
# Startup Checklist

## Health Checks
- [ ] Git remote accessible (`git remote -v && git fetch --dry-run`)
- [ ] Memory search working (`memory search "test"`)
- [ ] Workspace bootstrap files present (AGENTS.md, SOUL.md, etc.)
- [ ] Scan for unsorted media files (run media-catchup if found)

## Project Context
- [ ] Read `.current-project` from workspace root
- [ ] Read `PROJECT-STATUS.md` for task list and notes
- [ ] Check git branch matches expected feature branch
- [ ] Check for uncommitted changes from last session

## Boot Visual
- [ ] Format project dashboard (name, branch, progress, blockers)
- [ ] Generate quick-action buttons
- [ ] Send boot visual to user

## If No Active Project
- [ ] Show: "No active project. Ready for a new feature."
- [ ] Offer: [Start new feature] [Review open questions] [Check git]

Report health issues immediately. Show boot visual as first message.
```

### Config

```json5
"hooks": {
  "internal": {
    "enabled": true     // Must enable for BOOT.md to run
  }
}
```

---

---

## Bootstrap Files Detailed Reference

<!-- Merged from: stack/L4-session/bootstrap/files.md (30KB) -->

> All 9 bootstrap files that define how Crispy operates. Purpose, injection timing, size limits, and template structure for each.

### Overview

Bootstrap files are loaded from `~/.openclaw/workspace/` and injected into the context window in a specific order. They define Crispy's operating contract, personality, tools, memory, and startup behavior.

**Total budget:** 150,000 tokens in context window.
**Bootstrap files budget:** ~34,000 tokens (23%).
**Per-file max:** 20,000 characters (enforced by `bootstrapMaxChars`).

### Dependency & Injection Order

```mermaid
flowchart TD
    START["Message arrives"]:::gray
    START --> A["① AGENTS.md<br>8,000 tokens<br>5%"]:::purple
    A -->|"defines workflow"| B["② SOUL.md<br>2,000 tokens<br>1%"]:::purple
    B -->|"personality within rules"| C["③ TOOLS.md<br>12,000 tokens<br>8%"]:::purple
    C -->|"what can be used"| D["④ IDENTITY.md<br>1,000 tokens<br>1%"]:::purple
    D -->|"who is communicating"| E["⑤ USER.md<br>3,000 tokens<br>2%"]:::purple
    E -->|"about the humans"| CHECK{"DM<br>session?"}:::amber
    CHECK -->|Yes| F["⑥ MEMORY.md<br>8,000 tokens<br>5%"]:::blue
    CHECK -->|No| SKIPMEM["Skip MEMORY.md"]:::gray
    F --> G["⑦ Daily logs<br>6,000 tokens<br>4%"]:::blue
    SKIPMEM --> G
    G --> H["⑧ History<br>40,000 tokens<br>27%"]:::blue
    H --> I["⑨ Message<br>variable<br>rest"]:::green

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
```

### File Reference Table

| # | File | Injected | Size | Subagents? | Lifecycle | Template |
|---|---|---|---|---|---|---|
| ① | **AGENTS.md** | Every session | 8K tokens | Yes | Persistent, self-updating | [[stack/L4-session/bootstrap]] |
| ② | **SOUL.md** | Every session | 2K tokens | No | Persistent, rarely changed | [[stack/L4-session/bootstrap]] |
| ③ | **TOOLS.md** | Every session | 12K tokens | Yes | Persistent, updated when tools change | [[stack/L4-session/bootstrap]] |
| ④ | **IDENTITY.md** | Every session | 1K tokens | No | Persistent, refined in bootstrap | [[stack/L4-session/bootstrap]] |
| ⑤ | **USER.md** | Every session | 3K tokens | No | Persistent, grows over time | [[stack/L4-session/bootstrap]] |
| ⑥ | **MEMORY.md** | DM only | 8K tokens | No | Persistent, curated by Crispy | [[stack/L7-memory/memory-search]] |
| ⑦ | **HEARTBEAT.md** | Every 20min | — | No | Persistent, lightweight checklist | [[stack/L4-session/bootstrap]] |
| ⑧ | **Daily logs** | Every session | 6K tokens | No | Persistent per day | — |
| ⑨ | **BOOTSTRAP.md** | First run only | — | No | Self-deletes after use | [[stack/L4-session/bootstrap]] |
| — | **BOOT.md** | Gateway startup | — | No | Optional, one-time check | [[stack/L4-session/bootstrap]] |

### Bootstrap Failure Modes

| File | If Missing/Broken | Severity | What Happens | Recovery |
|---|---|---|---|---|
| **AGENTS.md** | No operating rules | 🔴 Critical | Agent has no workflow, no routing rules, no safety constraints | Agent acts as raw LLM — dangerous in group chats |
| **SOUL.md** | No personality | 🟡 Medium | Responses are generic, no kitsune personality | Functional but impersonal |
| **TOOLS.md** | No tool awareness | 🟠 High | Agent doesn't know what tools it has, may fail to use them | Tools still exist but agent doesn't leverage them well |
| **IDENTITY.md** | No name/emoji | 🟢 Low | Agent doesn't know it's "Crispy", uses generic identity | Still works, just unnamed |
| **USER.md** | No admin context | 🟡 Medium | Doesn't know Marty or Wenting, can't personalize | Treats everyone as unknown |
| **MEMORY.md** | No long-term memory | 🟡 Medium | Can't recall past decisions, facts, preferences | Short-term still works |
| **HEARTBEAT.md** | No pulse check | 🟢 Low | No periodic health monitoring | System still runs |
| **BOOTSTRAP.md** | First-run skipped | 🟢 Low | Only matters on very first boot | Won't affect running system |
| **BOOT.md** | No startup hook | 🟡 Medium | No health check, no boot visual, no project context | Agent works but starts blind |

---

## Guide: AGENTS.md


**Purpose:** Operating contract — priorities, boundaries, workflow
**Template:** [[stack/L4-session/bootstrap]]

The core operating rules for Crispy. How it processes messages, what it prioritizes, what it refuses, how it handles tools and memory, per-channel behavior, and safety rules.

---

## Guide: SOUL.md


**Purpose:** Personality, values, behavioral core
**Template:** [[stack/L4-session/bootstrap]]

Who Crispy is beyond the rules — temperament, communication style, and core principles.

---

## Guide: TOOLS.md


**Purpose:** Tool environment notes, model aliases, host quirks
**Template:** [[stack/L4-session/bootstrap]]

Complete tool and capability inventory. What hardware Crispy runs on, what models it can call, what tools it has, what skills are installed, where things live on disk.

---

## Guide: IDENTITY.md


**Purpose:** Structured identity profile
**Template:** [[stack/L4-session/bootstrap]]

Name, nature, emoji, appearance, origin, role, voice, and admins. Loaded into every session so Crispy remembers who it is.

---

## Guide: USER.md


**Purpose:** About Marty and Wenting
**Template:** [[stack/L4-session/bootstrap]]

Information about Marty, Wenting, and any other users — preferences, timezones, communication styles, technical background, current focus.

---

## Guide: MEMORY.md


**Purpose:** Long-term curated memory (DM only)
**Template:** [[stack/L7-memory/memory-search]]

Curated long-term memory. The "important enough to keep forever" facts that survive the 30-day vector search decay and should be loaded in every DM session.

---

## Guide: HEARTBEAT.md


**Purpose:** Periodic tasks (20min, Gemini Flash Lite)
**Template:** [[stack/L4-session/bootstrap]]

Lightweight checklist that runs every 20 minutes using the cheap model. If everything is fine, reply `HEARTBEAT_OK` and stop. If something needs attention, flag it.

---

## Guide: BOOTSTRAP.md


**Purpose:** First-run ritual (self-deletes)
**Template:** [[stack/L4-session/bootstrap]]

Conversation guide that runs once when Crispy boots for the first time. Discovers role, voice, and preferences through conversation, then updates IDENTITY.md, SOUL.md, and USER.md. Self-deletes after use.

---

## Guide: BOOT.md


**Purpose:** Startup hook checklist
**Template:** [[stack/L4-session/bootstrap]]

Optional checklist that runs once when the OpenClaw gateway starts. Verifies environment health, loads project context, and shows the boot visual dashboard. Separate from BOOTSTRAP.md (which is identity discovery).

---

## Related Pages

- [[stack/L4-session/_overview]] — Overview of L4 layer
- [[stack/L4-session/context-assembly]] — How context is built
- [[stack/L4-session/sessions]] — Session lifecycle and storage
- [[stack/L7-memory/_overview]] — Memory architecture

---

**Up →** [[stack/L4-session/_overview]]
