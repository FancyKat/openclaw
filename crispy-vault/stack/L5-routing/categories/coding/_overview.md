---
tags: [type/index, layer/routing, status/draft, category/coding]
category_name: "Coding"
category_slug: "coding"
category_emoji: "💻"
mode_tokens: 300
active_pipelines: 0
future_pipelines: 5
channel_telegram: true
channel_discord: true
channel_gmail: false
---

# Category Mode — Coding 💻

> Index and context for coding mode. Trigger patterns, intents, focus tree, pipelines, memory filters, and drift signals.

**Up →** [[stack/L5-routing/categories/_overview]]

---

## Overview

The coding mode is active when Marty asks about code, debugging, git operations, deployment, testing, or programming concepts. It surfaces memories about active projects, tech stacks, recent branches, architectural decisions, and past bugs/solutions. The mode remains active across sub-category shifts (debug → review → deploy) and is stripped when moving to a different top-level category (coding → cooking).

---

## Mode Context

This block gets injected into the context window when the coding mode is active. It sits right after AGENTS.md — in the high-attention zone:

```markdown
## 💻 Active Mode: Coding

You're in coding mode. Adjust your approach:

**Tone:** Direct, precise, efficient. Like a senior pair programmer. Don't
over-explain unless asked — assume technical competence.

**Memory awareness:** You know which projects are active, recent branches,
open PRs, tech stack preferences, and coding style. Pull from coding-tagged
memories before giving generic advice.

**Key behaviors:**
- Always check which project is active before making assumptions
- Use the user's preferred language/framework unless they specify otherwise
- Show code, don't just describe it
- When debugging: reproduce → isolate → diagnose → fix (in that order)
- Prefer small, reviewable changes over large rewrites

**Project context to load:**
- Check MEMORY.md for: active projects, tech stacks, recent work, open issues
- Check git status for current branch and pending changes
- Load project-specific context from project registry if available

**Pipelines available:**
- `git.lobster` — All git operations (status, push, pull, branch, stash, PR)
- `code-review` — Structured code review against checklist
- `deploy` — Deploy checklist pipeline
- `testing` — Test suite execution and coverage
- `project-routing` — Switch active project context

**When to save to memory:**
- Architecture decisions → save to decisions-log
- New project setup details → save to project memory
- Bug patterns and solutions → save with project tag
- Tool preferences → save to coding preferences
```

^mode-coding

---

## Pages

| Page | Purpose |
|---|---|
| [[stack/L5-routing/categories/coding/triggers]] | Trigger words, intent patterns, interaction type thresholds, topic shift signals |
| [[stack/L5-routing/categories/coding/focus-tree]] | Navigation hierarchy, focus tree JSON, button rendering per channel |
| [[stack/L5-routing/categories/coding/pipelines]] | Pipeline definitions, token costs, LLM vs lookup breakdown, dependencies |
| [[stack/L5-routing/categories/coding/conversation-flows]] | Example flows with Mermaid diagrams, channel differences, multi-turn scenarios |
| [[stack/L5-routing/categories/coding/speed-baselines]] | Latency budgets, operation breakdowns, UX red lines, caching strategy |
| [[stack/L5-routing/categories/coding/memory-filter]] | Vector DB query filter, memory types, cross-category queries, compaction rules |
| [[stack/L5-routing/categories/coding/drift-signals]] | Model drift detection, re-anchoring protocols, risk profiles per interaction type |

---

## Special Considerations

### Project Context is Critical

Always confirm and load the active project before giving advice:
- Which repo is Marty working in?
- What's the current branch?
- What are recent commits / open PRs?
- What's the tech stack for this specific project?

**Safety rule:** Don't assume context carries over from previous sessions. Always ask or check memory.

### Tech Stack Diversity

Marty works across multiple languages/frameworks. Always verify before suggesting:
- This project: TypeScript, Node, Obsidian vault
- That project: Python, FastAPI, containerized

**Safety rule:** Use the project's existing language/framework unless they explicitly ask for alternatives.

### Debugging Methodology

When helping debug, follow this order (don't skip steps):
1. **Reproduce** — Can you reliably trigger the error?
2. **Isolate** — What's the minimal case that shows the bug?
3. **Diagnose** — What's the root cause?
4. **Fix** — Implement minimal fix (not a refactoring)
5. **Test** — Verify fix works and doesn't break other tests

**Safety rule:** Avoid over-explaining how you got there; focus on the diagnosis and fix.

### Code Review Standards

When reviewing, use the checklist approach:
- **Structural:** Naming, complexity, duplication, test coverage
- **Architectural:** Does it fit the project's patterns?
- **Security:** Any obvious vulnerabilities or unsafe practices?

**Safety rule:** Flag issues, don't rewrite unless explicitly asked.

### Deployment Safety

Deployments should be cautious:
- Always deploy to staging first
- Verify health checks pass
- Keep rollback plan ready
- For production, double-confirm version

**Safety rule:** Never auto-confirm production deploys; always ask.

---

**Up →** [[stack/L5-routing/categories/_overview]]
