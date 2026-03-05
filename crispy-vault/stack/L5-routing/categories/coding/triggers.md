---
tags: [type/reference, layer/routing, status/draft, category/coding, focus/triggers]
---

# Coding Category — Trigger Words & Intent Patterns

> Flash classifier triggers and intent sub-classification rules for coding mode. Interaction type thresholds and topic shift signals.

**Up →** [[stack/L5-routing/categories/coding/_overview]]

---

## Trigger Words

These are matched by the flash model classifier and the triage trigger-word scan (stage ①):

### High Confidence (→ load hat immediately)
```
code, coding, programming, debug, debugging, git, github, commit,
push, pull, merge, branch, deploy, pipeline, CI/CD, test, testing,
function, class, module, API, endpoint, server, database, query,
bug, error, exception, stack trace, dockerfile, container, npm, pip
```

### Medium Confidence (→ classify with context)
```
build, run, install, package, config, setup, fix, refactor,
update, version, release, lint, format, type, variable, loop,
compile, import, export, dependency, library, framework
```

*Medium-confidence words need surrounding context. "Build" alone could be deployment, compilation, or even non-technical. The flash model uses the last 3 messages to disambiguate.*

### Sub-Category Signals

| Sub-Category | Additional Triggers |
|---|---|
| **project** | project name mentions, "work on", "the repo", "codebase" |
| **debugging** | "not working", "error", "broken", "failing", "why is", stack traces |
| **tools** | "install", "set up", "configure", "which library", tool names |
| **review** | "review this", "look at this", "is this right", "PR", "diff" |
| **deploy** | "deploy", "ship", "release", "production", "staging" |
| **learning** | "how does X work", "explain", "what's the difference between" |

---

## Intent Patterns

When the coding hat is on, the triage model sub-classifies into these intents:

| Intent | What User Wants | Route | Example |
|---|---|---|---|
| `coding:git-op` | A git operation | Pipeline → git.lobster | "Push the latest changes" |
| `coding:debug` | Find and fix a bug | Agent loop (reasoning) | "Why is the build failing?" |
| `coding:write-code` | Write or modify code | Agent loop (creative) | "Add a retry handler to the API client" |
| `coding:review` | Review code or a PR | Pipeline → code-review | "Review the last commit" |
| `coding:deploy` | Deploy or release | Pipeline → deploy | "Deploy to staging" |
| `coding:test` | Write or run tests | Pipeline → testing | "Run the test suite" |
| `coding:explain` | Understand code or concepts | Agent loop (informational) | "How does the middleware chain work?" |
| `coding:setup` | Install or configure tools | Agent loop + pipeline | "Set up ESLint for this project" |
| `coding:project-switch` | Change active project context | Pipeline → project-routing | "Switch to the crispy-kitsune repo" |

---

## Interaction Type Thresholds

Token budgets and context length thresholds for routing decisions:

^triggers-coding

| Interaction Type | Token Range | Use Case | Hat State |
|---|---|---|---|
| **Informational** | 2K–8K tokens | "How does X work?", architecture questions, concept explanations | Hat always on |
| **Assistance** | 5K–20K tokens | Code reviews, debugging help, implementation guidance | Hat on, memory preloaded |
| **Action** | 0–1K tokens | Pipeline triggers (git, deploy, test) | Hat on, fast-path |
| **Creative** | 8K–25K tokens | New features, refactoring, architecture design | Hat on, full context |
| **Meta** | 200–1K tokens | Preference setting, hat state changes, project switching | Hat on or off depending on intent |

### Coding Distribution

- **Action-heavy:** Git operations, test runs, deployments (45% of interactions)
- **Assistance-heavy:** Debugging, code review, implementation help (35% of interactions)
- **Informational:** Architecture, concepts, best practices (15% of interactions)
- **Creative:** Feature design, refactoring proposals (4% of interactions)
- **Meta:** Project switching, tool setup (1% of interactions)

---

## Topic Shift Signals

### Signals In (Entering Coding)

- **High confidence triggers** (section above) + context from last 2 messages
- **Sub-category signal** in message + coding hat already partially loaded
- **Soft shift:** "While we're at it, can you..." from non-coding mode → add to hat, don't swap

Examples:
- "While we're at it, what's the git status?" (soft)
- "Actually, let me focus on fixing this bug first" (soft)

### Signals Out (Leaving Coding)

- **Absence of coding words** for 2+ turns after hat loaded
- **Explicit category trigger** from another domain (cooking, fitness, finance, etc.)
- **Question scope** changes to non-code domain
- **Hard shift:** Save compaction summary, flush hat, load new hat

Examples:
- "Let's talk about something else — what's for dinner?" (hard)
- "OK, moving on to my workout plan" (hard)
- "So about that recipe you mentioned..." (hard)

### Re-Entry Rules

- If user returns to coding within same session, reload hat (don't resume old context)
- If coding was a soft shift, restore full hat context
- If coding was a hard shift, load fresh hat

---

**Up →** [[stack/L5-routing/categories/coding/_overview]]
