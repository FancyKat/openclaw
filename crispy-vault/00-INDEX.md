---
tags: [status/draft, type/index]
---
# Crispy Kitsune — Vault Index

> The planning vault for the Crispy Kitsune OpenClaw AI agent.

---

## Quick Links

| What | Where |
|------|-------|
| **Project Rules (CLAUDE.md)** | [[CLAUDE]] |
| **Build & Install** | [[build/README.md]] |
| **Version Dashboard** | [[build/version-dashboard]] |
| **System architecture** | [[stack/_overview]] |
| **Architecture diagrams** | [[architecture-diagrams]] |
| **Open questions** | [[stack/L7-memory/open-questions]] |
| **Decisions log** | [[stack/L7-memory/decisions-log]] |
| **Changelog** | [[CHANGELOG]] |

---

## Build & Install

Everything you need before Crispy's first boot.

- [[build/README.md]] — 7-phase install guide
- [[build/.env.example]] — Annotated environment variable template
- [[build/config-main]] — Config assembly scaffold (`^config-*` → `dist/openclaw.json`)
- [[build/context-main]] — Context assembly scaffold (`^ctx-*` → `dist/context-files/`)
- [[build/env-main]] — Env vars scaffold (`^env-*` → `dist/.env`)
- [[build/pipeline-main]] — Pipeline assembly scaffold (`^pipeline-*` → `dist/pipelines/`)
- [[build/focus-main]] — Focus mode assembly scaffold (L5 category blocks → `dist/focus/`)
- [[build/version-dashboard]] — Live version tracking (Dataview)

---

## CKS Stack (Crispy Kitsune Stack)

The 7-layer architecture model. Start at [[stack/_overview]].

- [[architecture-diagrams]] — Mermaid diagrams: memory lifecycle, background agents, memory types, system mindmap, multi-bot architecture

---

### L1 — Physical

Hardware, Docker, filesystem, network.

- [[stack/L1-physical/_overview]] — Layer overview
- [[stack/L1-physical/config-reference]] — Config reference (gateway, hooks)
- [[stack/L1-physical/hardware]] — CPU, RAM, GPU specs + hardware setup guide
- [[stack/L1-physical/sandbox]] — Docker, isolation, and sandbox setup
- [[stack/L1-physical/filesystem]] — Full directory layout (runtime + vault) + workspace guide
- [[stack/L1-physical/media]] — Media storage, inbound flow, and media guide
- [[stack/L1-physical/network]] — Network topology
- [[stack/L1-physical/runbook]] — L1 operations runbook
- [[stack/L1-physical/CHANGELOG]] — L1 layer changelog
- [[stack/L1-physical/cross-layer-notes]] — Cross-layer notes from L1 sessions

---

### L2 — Runtime

How messages get in and out — gateway, config, .env, auth.

- [[stack/L2-runtime/_overview]] — Layer overview
- [[stack/L2-runtime/config-reference]] — Config reference (agents, models, sandbox)
- [[stack/L2-runtime/gateway]] — OpenClaw gateway
- [[stack/L2-runtime/env]] — Environment variables + key acquisition guide
- [[stack/L2-runtime/models]] — Model configuration + task routing
- [[stack/L2-runtime/runbook]] — Runtime operations runbook (gateway ops, config audit, model auth)
- [[stack/L2-runtime/CHANGELOG]] — L2 layer changelog
- [[stack/L2-runtime/cross-layer-notes]] — Cross-layer notes from L2 sessions

---

### L3 — Channel

Where messages arrive/depart — Telegram, Discord, Gmail, Voice.

- [[stack/L3-channel/_overview]] — Layer overview + integration map
- [[stack/L3-channel/config-reference]] — Config reference (channels)
- [[stack/L3-channel/CHANGELOG]] — L3 layer changelog
- [[stack/L3-channel/cross-layer-notes]] — Cross-layer notes from L3
- ~~decision-trees~~ → moved to L5 (see [[stack/L5-routing/decision-trees]])
- [[stack/L3-channel/voice-pipeline]] — STT → agent → TTS (all channels) + voice guide

**Telegram:**
- [[stack/L3-channel/telegram/_overview]] — Telegram overview
- [[stack/L3-channel/telegram/chat-flow]] — Chat flow patterns + conversation flows
- [[stack/L3-channel/telegram/button-patterns]] — Button UI patterns
- [[stack/L3-channel/telegram/pipelines]] — All Telegram pipelines (approve/deny, exec, decision-tree, quick-actions, notify, media)
- [[stack/L3-channel/telegram/media-handling]] — Telegram media (voice, photo, video, docs)
- [[stack/L3-channel/telegram/runbook]] — Telegram setup + operations guide

**Discord:**
- [[stack/L3-channel/discord/_overview]] — Discord overview
- [[stack/L3-channel/discord/chat-flow]] — Discord chat flow + components + media handling
- [[stack/L3-channel/discord/runbook]] — Discord setup + operations guide

**Gmail:**
- [[stack/L3-channel/gmail/_overview]] — Gmail overview
- [[stack/L3-channel/gmail/email-triage]] — Email triage, webhook flow, privacy/security
- [[stack/L3-channel/gmail/runbook]] — Gmail setup + operations guide

---

### L4 — Session

What Crispy knows right now — context, bootstrap, hooks, compaction.

- [[stack/L4-session/_overview]] — Layer overview
- [[stack/L4-session/context-assembly]] — Context assembly process
- [[stack/L4-session/sessions]] — Session management, compaction, templates, and coding lifecycle
- [[stack/L4-session/bootstrap]] — Bootstrap config, dependency graph, checklist (legacy deep-dive)
- [[stack/L4-session/daily-logs]] — Daily log system
- [[stack/L4-session/CHANGELOG]] — L4 layer changelog
- [[stack/L4-session/cross-layer-notes]] — Cross-layer notes from L4 sessions
- [[stack/L4-session/config-reference]] — Context file block registry (^ctx-* blocks, assembly order, token budgets)

**Context File Sources** → [[stack/L4-session/_overview]]
- [[stack/L4-session/context-files/agents]] — AGENTS.md source
- [[stack/L4-session/context-files/soul]] — SOUL.md source
- [[stack/L4-session/context-files/identity]] — IDENTITY.md source
- [[stack/L4-session/context-files/tools]] — TOOLS.md source
- [[stack/L4-session/context-files/user]] — USER.md source
- [[stack/L4-session/context-files/memory]] — MEMORY.md source
- [[stack/L4-session/context-files/heartbeat]] — HEARTBEAT.md source
- [[stack/L4-session/context-files/status]] — STATUS.md source
- [[stack/L4-session/context-files/boot]] — BOOT.md source
- [[stack/L4-session/context-files/bootstrap]] — BOOTSTRAP.md source

---

### L5 — Routing (Context Intelligence)

Where context meets intent — intent classification, context shaping, compaction, memory filtering, guardrails.

- [[stack/L5-routing/_overview]] — Layer overview (context shaping, compaction, memory filtering, mode detection)
- [[stack/L5-routing/message-routing]] — Classification pipeline, three routing paths, intent taxonomy, guardrail insertion points
- [[stack/L5-routing/decision-trees]] — Decision tree generic routing pattern (moved from L3)
- [[stack/L5-routing/conversation-flows]] — Conversation category classification, category-aware compaction, filtered memory retrieval, drift prevention
- [[stack/L5-routing/guardrails]] — Guardrails framework, input sanitization, output validation
- [[stack/L5-routing/CHANGELOG]] — L5 layer changelog
- [[stack/L5-routing/cross-layer-notes]] — Cross-layer notes from L5 sessions

**Conversation Categories (Focus Modes)** → [[stack/L5-routing/categories/_overview]]

*Cooking:*
- [[stack/L5-routing/categories/cooking/_overview]] — Cooking focus: recipes, grocery, meal prep, nutrition
- [[stack/L5-routing/categories/cooking/triggers]] — Trigger words and patterns
- [[stack/L5-routing/categories/cooking/focus-tree]] — Decision tree for cooking sub-intents
- [[stack/L5-routing/categories/cooking/pipelines]] — Pipeline definitions (future)
- [[stack/L5-routing/categories/cooking/conversation-flows]] — Conversation flow patterns + compaction
- [[stack/L5-routing/categories/cooking/speed-baselines]] — Speed and token baselines
- [[stack/L5-routing/categories/cooking/memory-filter]] — Memory filter rules
- [[stack/L5-routing/categories/cooking/drift-signals]] — Drift detection signals

*Coding:*
- [[stack/L5-routing/categories/coding/_overview]] — Coding focus: projects, debugging, tools, review, deploy
- [[stack/L5-routing/categories/coding/triggers]] — Trigger words and patterns
- [[stack/L5-routing/categories/coding/focus-tree]] — Decision tree for coding sub-intents
- [[stack/L5-routing/categories/coding/pipelines]] — Pipeline definitions (future)
- [[stack/L5-routing/categories/coding/conversation-flows]] — Conversation flow patterns + compaction
- [[stack/L5-routing/categories/coding/speed-baselines]] — Speed and token baselines
- [[stack/L5-routing/categories/coding/memory-filter]] — Memory filter rules
- [[stack/L5-routing/categories/coding/drift-signals]] — Drift detection signals

*Finance:*
- [[stack/L5-routing/categories/finance/_overview]] — Finance focus: markets, budgeting, investing, planning
- [[stack/L5-routing/categories/finance/triggers]] — Trigger words and patterns
- [[stack/L5-routing/categories/finance/focus-tree]] — Decision tree for finance sub-intents
- [[stack/L5-routing/categories/finance/pipelines]] — Pipeline definitions (future)
- [[stack/L5-routing/categories/finance/conversation-flows]] — Conversation flow patterns + compaction
- [[stack/L5-routing/categories/finance/speed-baselines]] — Speed and token baselines
- [[stack/L5-routing/categories/finance/memory-filter]] — Memory filter rules
- [[stack/L5-routing/categories/finance/drift-signals]] — Drift detection signals

*Fitness:*
- [[stack/L5-routing/categories/fitness/_overview]] — Fitness focus: workouts, tracking, recovery, goals, programs
- [[stack/L5-routing/categories/fitness/triggers]] — Trigger words and patterns
- [[stack/L5-routing/categories/fitness/focus-tree]] — Decision tree for fitness sub-intents
- [[stack/L5-routing/categories/fitness/pipelines]] — Pipeline definitions (future)
- [[stack/L5-routing/categories/fitness/conversation-flows]] — Conversation flow patterns + compaction
- [[stack/L5-routing/categories/fitness/speed-baselines]] — Speed and token baselines
- [[stack/L5-routing/categories/fitness/memory-filter]] — Memory filter rules
- [[stack/L5-routing/categories/fitness/drift-signals]] — Drift detection signals

*Pet Care:*
- [[stack/L5-routing/categories/pet-care/_overview]] — Pet Care focus: health, feeding, training, grooming
- [[stack/L5-routing/categories/pet-care/triggers]] — Trigger words and patterns
- [[stack/L5-routing/categories/pet-care/focus-tree]] — Decision tree for pet-care sub-intents
- [[stack/L5-routing/categories/pet-care/pipelines]] — Pipeline definitions (future)
- [[stack/L5-routing/categories/pet-care/conversation-flows]] — Conversation flow patterns + compaction
- [[stack/L5-routing/categories/pet-care/speed-baselines]] — Speed and token baselines
- [[stack/L5-routing/categories/pet-care/memory-filter]] — Memory filter rules
- [[stack/L5-routing/categories/pet-care/drift-signals]] — Drift detection signals

*Design:*
- [[stack/L5-routing/categories/design/_overview]] — Design focus: UI/UX, graphic, presentations, brand
- [[stack/L5-routing/categories/design/triggers]] — Trigger words and patterns
- [[stack/L5-routing/categories/design/focus-tree]] — Decision tree for design sub-intents
- [[stack/L5-routing/categories/design/pipelines]] — Pipeline definitions (future)
- [[stack/L5-routing/categories/design/conversation-flows]] — Conversation flow patterns + compaction
- [[stack/L5-routing/categories/design/speed-baselines]] — Speed and token baselines
- [[stack/L5-routing/categories/design/memory-filter]] — Memory filter rules
- [[stack/L5-routing/categories/design/drift-signals]] — Drift detection signals

*Habits:*
- [[stack/L5-routing/categories/habits/_overview]] — Habits focus: tracking, streaks, new habits, adjustments
- [[stack/L5-routing/categories/habits/triggers]] — Trigger words and patterns
- [[stack/L5-routing/categories/habits/focus-tree]] — Decision tree for habits sub-intents
- [[stack/L5-routing/categories/habits/pipelines]] — Pipeline definitions (future)
- [[stack/L5-routing/categories/habits/conversation-flows]] — Conversation flow patterns + compaction
- [[stack/L5-routing/categories/habits/speed-baselines]] — Speed and token baselines
- [[stack/L5-routing/categories/habits/memory-filter]] — Memory filter rules
- [[stack/L5-routing/categories/habits/drift-signals]] — Drift detection signals

---

### L6 — Processing

How Crispy does the work — LLM reasoning, tools, skills, pipelines.

- [[stack/L6-processing/_overview]] — Layer overview
- [[stack/L6-processing/config-reference]] — Config reference (tools, plugins, cron, skills)
- [[stack/L6-processing/agent-loop]] — Agent loop design
- [[stack/L6-processing/tools]] — Tool system (Lobster, llm-task, CDP)
- [[stack/L6-processing/research]] — Research pipeline
- [[stack/L6-processing/message-routing]] — Execution flowcharts for interaction types
- [[stack/L6-processing/runbook]] — L6 operations runbook
- [[stack/L6-processing/CHANGELOG]] — L6 layer changelog
- [[stack/L6-processing/cross-layer-notes]] — Cross-layer notes from L6 sessions

**Coding:**
- [[stack/L6-processing/coding/_overview]] — Coding overview
- [[stack/L6-processing/coding/git-pipelines]] — Git operations (status, push, pull, PR, branch, stash)
- [[stack/L6-processing/coding/code-review]] — Code review workflow, skill integration
- [[stack/L6-processing/coding/deploy]] — Deploy checklist pipeline, environment verification
- [[stack/L6-processing/coding/testing]] — Test strategy, coverage pipeline, test generation
- [[stack/L6-processing/coding/project-routing]] — Project registry, routing logic, context switching

**Pipelines:**
- [[stack/L6-processing/pipelines/_overview]] — Pipelines overview
- [[stack/L6-processing/pipelines/brief]] — Daily brief pipeline (RSS, weather, git, inbox)
- [[stack/L6-processing/pipelines/email]] — Email triage pipeline (classify, summarize, flag)
- [[stack/L6-processing/pipelines/health-check]] — System heartbeat (git, memory, uptime)
- [[stack/L6-processing/pipelines/skill-router]] — Skill matching and selection
- [[stack/L6-processing/pipelines/intent-finder]] — Two-layer intent classification
- [[stack/L6-processing/pipelines/prompt-builder]] — Context enrichment before agent loop
- [[stack/L6-processing/pipelines/media]] — Media processing, cleanup, and media-sort pipelines

**Skills:**
- [[stack/L6-processing/skills/_overview]] — Skills overview
- [[stack/L6-processing/skills/inventory]] — Full skills inventory (all skill packs, authoring, config, custom skills)

---

### L7 — Memory

What Crispy remembers between sessions — daily logs, MEMORY.md, Mem0, SQLite, vector search.

- [[stack/L7-memory/_overview]] — Layer overview
- [[stack/L7-memory/config-reference]] — Config reference (memory)
- [[stack/L7-memory/decisions-log]] — Log of architectural decisions made for Crispy
- [[stack/L7-memory/open-questions]] — Open questions still being resolved
- [[stack/L7-memory/daily-logs]] — Daily log system
- [[stack/L7-memory/memory-md]] — MEMORY.md file design
- [[stack/L7-memory/memory-search]] — Vector search, query patterns
- [[stack/L7-memory/audit-log]] — Guardrail audit log format, event types, review process
- [[stack/L7-memory/sqlite]] — Structured data storage, SQL queries, future planning
- [[stack/L7-memory/CHANGELOG]] — L7 layer changelog
- [[stack/L7-memory/cross-layer-notes]] — Cross-layer notes from L7 sessions

---

## Vault Dashboard (Live)

### Status Overview

```dataview
TABLE WITHOUT ID
  Status as "Status",
  length(rows) as "Files"
FROM "stack" OR "build"
FLATTEN file.frontmatter.tags AS tag
WHERE startswith(tag, "status/")
GROUP BY replace(tag, "status/", "") AS Status
SORT length(rows) DESC
```

### Recently Modified

```dataview
TABLE file.mtime AS "Modified"
FROM "stack" OR "build"
SORT file.mtime DESC
LIMIT 10
```

### Files Needing Work (status/draft)

```dataview
TABLE file.folder AS "Layer", length(file.name) AS "Name Length"
FROM "stack"
FLATTEN file.frontmatter.tags AS tag
WHERE tag = "status/draft"
SORT file.folder ASC
```

---
