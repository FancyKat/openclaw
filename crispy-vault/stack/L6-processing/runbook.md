---
tags: [layer/processing, status/draft, type/guide]
---

# L6 Processing Runbook

> Deep-dive reference guides for processing, skill execution, and agent behavior layer. Consolidated from all L6 guide files.

---

## Agent Design


### Agent Architecture

The agent in L6 is a multi-turn reasoning system that:

1. **Receives input** from L5 (classified intent + sanitized input)
2. **Assembles context** (bootstrap, memory, history)
3. **Reasons** with the LLM (think → act → observe → repeat)
4. **Executes tools** with permission gating
5. **Responds** with formatted output for L5 validation

### Context Assembly Order

```
1. Bootstrap files (AGENTS.md, SOUL.md, TOOLS.md, etc)
2. MEMORY.md (long-term knowledge)
3. Daily logs (today + yesterday)
4. Session history (previous messages)
→ Packed into context window (respecting token limit)
```

### Tool Execution Cycle

```
LLM decides tool needed
  ↓
Agent parses tool call
  ↓
Permission check
  ↓
Execute in sandbox
  ↓
Capture output
  ↓
Add to history
  ↓
Loop again or return result
```

### Loop Termination

The agent loop exits when:
- User's text goal achieved (LLM outputs final answer)
- Max iterations reached (default: 10 iterations)
- Tool execution fails critically
- User cancels (e.g., `/cancel`)
- Context overflow (>150K tokens, triggers compaction)

---

## Button System


### Button Types

| Type | Trigger | Format | Example |
|---|---|---|---|
| **Approval Gate** | Decision gate in pipeline | [Approve] [Deny] | Git push preview |
| **Decision Tree** | Clarification needed | [Option A] [Option B] [Option C] | Which project? |
| **Quick Action** | Project context | [/git] [/deploy] [/test] | Project-specific |
| **Inline Link** | Message context | [View Details] [Learn More] | Navigation |

### UX Patterns

**Approval Flow:**
```
Crispy: "Ready to push?"
[Changes: file1.md, file2.md]
[Commits: 2]

[✅ Approve] [❌ Deny] [🔍 Preview]
```

**Decision Tree:**
```
Crispy: "Which project?"
[1️⃣ Crispy] [2️⃣ Project X] [3️⃣ Data Platform]
```

**Quick Actions (Project Context):**
```
🦊 Crispy | 📁 Crispy Stack
Quick-actions: [/git] [/brief] [/layer] [/research]
```

---

## Button UX Mockups


### Telegram Button Layout

**Single Row (up to 3 buttons):**
```
[Button 1] [Button 2] [Button 3]
```

**Stacked (3+ buttons):**
```
[Button 1] [Button 2]
[Button 3] [Button 4]
[Button 5]
```

**Approval + Preview:**
```
[✅ Approve] [❌ Deny]
[🔍 Preview diff]
```

### Button Text Guidelines

- Keep text **short** (≤15 characters)
- Use **emojis** for scannability
- Use **imperative verbs** (Approve, Review, Deploy)
- Avoid **negation** (use ✅/❌ icons instead of "Yes"/"No")

---

## Pipeline Infrastructure


### Pipeline Execution Model

```
Trigger (cron, command, webhook)
  ↓
Load args & environment
  ↓
Execute steps in order (with conditions)
  ↓
Pass JSON between steps ($step_id.stdout)
  ↓
Approval gates (resume tokens)
  ↓
Final output or error
```

### Built-in Pipeline Commands

| Command | Purpose | Example |
|---|---|---|
| `exec` | Shell commands | `exec --json 'git status'` |
| `where` | Filter JSON | `where '.status == "done"'` |
| `pick` | Select fields | `pick '.name, .age'` |
| `head` | Limit items | `head -20` |
| `map` | Transform | `map 'select(.status)'` |
| `template` | String interpolation | `template 'Hello ${name}'` |
| `approve` | User approval gate | `approve --prompt 'Continue?'` |
| `state.set` | Save state | `state.set my-key` |
| `state.get` | Load state | `state.get my-key` |
| `diff.last` | Compare to last run | `diff.last --key my-articles` |

### Error Handling in Pipelines

```yaml
steps:
  - id: risky_step
    command: exec 'might-fail.sh'
    condition: '$previous_step.exitCode == 0'  # Only run if previous succeeded
```

---

## Research Pipeline


### Research Sub-Agent Spawn

```
Main agent: "I need to research X"
  ↓
Spawn research.lobster pipeline
  ↓
Sub-agent (isolated context):
  - web_search + web_fetch
  - Summarize findings
  - Create notes.md
  - Create topic.skill
  ↓
Save to workspace/research/{topic}/
  ↓
Notify main agent
```

### Research Outputs

For each research topic:
- **notes.md** — Human-readable findings with links
- **sources.md** — All URLs and references
- **{topic}.skill** — Distilled knowledge for future use
- **_index.md** — Auto-updated topic list

### Research Depth Levels

| Depth | Time | Tokens | Output |
|---|---|---|---|
| **quick** | 30 min | ~500 | Quick summary |
| **standard** | 1 hour | ~1000 | Comprehensive summary |
| **deep** | 2 hours | ~2000 | Deep analysis with open questions |

---

## Skill Pipeline


### Skill Matching & Loading

```
User message arrives
  ↓
skill-router pipeline
  ↓
Trigger word scan (0 tokens)
  ↓
Ambiguous? → Triage model (~200 tokens)
  ↓
Match skill (confidence > 0.5)
  ↓
Load skill context into conversation
  ↓
Crispy responds with skill knowledge
```

### Skill Priority

Trigger words take priority over manual selection. Example:

```
User: "review this code"
  ↓
Trigger: "review" → engineering:code-review
  ↓
High confidence (0.9+), no triage needed
  ↓
Load skill immediately
```

### Skill Triggers

Each skill has a list of trigger phrases. When user message contains any trigger:

```yaml
engineering:code-review:
  triggers:
    - "review this code"
    - "check this PR"
    - "is this safe?"
    - "security review"
```

---

## Skills Loading


### Skill Manifest

Every skill is a Markdown file with frontmatter:

```yaml
---
name: code-review
description: Specialized code review capability
triggers: ["review", "code", "PR", "security"]
tags: [engineering, review, security]
---

# Code Review Skill

## Quick Reference
[Content...]

## When to Use
[Conditions for use...]

## Procedure
[Step-by-step process...]
```

### Skill Loading Lifecycle

1. **Detect** — skill-router identifies best match
2. **Load** — skill.md loaded into context
3. **Execute** — Crispy responds with skill knowledge
4. **Unload** — Skill context remains until session ends (can load new skill)

### Skill Context Budget

- **Small skill** (1-2 KB): Always load
- **Medium skill** (5-10 KB): Load if high confidence match
- **Large skill** (20+ KB): Load only if confidence > 0.8

---

## Skills Inventory Deep Dive


### Skill Organization

```
~/.openclaw/skills/
├── engineering/
│   ├── code-review.skill
│   ├── debug.skill
│   ├── system-design.skill
│   └── ...
├── data/
│   ├── data-exploration.skill
│   ├── sql-queries.skill
│   └── ...
├── sag/
├── gog/
├── _index.md
└── custom-topic.skill
```

### Skill Selection Heuristics

1. **Exact trigger match** → High confidence (0.9+)
2. **Partial match** → Medium confidence (0.6-0.8)
3. **No match** → No skill needed

Example:

```
User: "review this code for security issues"

Matches:
  - "review" → engineering:code-review (0.92)
  - "security" → engineering:code-review (0.85)

→ Load engineering:code-review (highest confidence)
```

### Skill Versioning

Skills can be updated from ClawHub without reinstallation:

```bash
openclaw skills update engineering:code-review
```

---

## Workspace Scanning


### Workspace Structure Awareness

Crispy scans the workspace on startup:

```
~/.openclaw/workspace/
├── AGENTS.md              ← Identity & behavior
├── SOUL.md                ← Values & principles
├── TOOLS.md               ← Tool inventory
├── MEMORY.md              ← Long-term knowledge
├── HEARTBEAT.md           ← Standing tasks
├── memory/                ← Daily logs
├── research/              ← Research findings
├── projects.json          ← Project registry
├── media/                 ← Media files (inbound/outbound)
├── .../.openclaw/workspace/
```

### Context Assembly from Workspace

When starting a session, Crispy:

1. **Reads bootstrap files** (AGENTS.md, SOUL.md, TOOLS.md, HEARTBEAT.md)
2. **Checks MEMORY.md** for long-term knowledge
3. **Loads daily logs** (today + yesterday)
4. **Scans project registry** for active project context
5. **Checks for stale research** (>7 days old)

### Workspace Health Checks

The health-check pipeline monitors:

- **Git dirty files** — Uncommitted work
- **Memory size** — MEMORY.md not growing too fast
- **Disk usage** — System has space
- **Daily log size** — Conciseness of notes

If issues found → Alert Marty via Telegram

---

## Summary

The L6 Processing layer is Crispy's reasoning and execution engine:

- **Agent loop** handles multi-turn reasoning
- **Pipelines** handle deterministic workflows
- **Skills** provide specialized knowledge
- **Tools** execute actions with permission gating
- **Project routing** keeps context aware
- **Workspace scanning** maintains situational awareness

All layers integrate through structured JSON interfaces and approval gating, ensuring safety while maximizing capability.

---

## Media Pipeline Guide


📸 **Moved →** [[stack/L3-channel/telegram/pipelines#3-media-handling]]

This pipeline is Telegram-specific and now lives in the `telegram/` subfolder.

---

## Notify Pipeline Guide


🔔 **Moved →** [[stack/L3-channel/telegram/pipelines#2-notifications]]

This pipeline is Telegram-specific and now lives in the `telegram/` subfolder.

---

**Up →** [[stack/L6-processing/_overview]]
**Back →** [[stack/_overview]]
