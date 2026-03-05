---
tags: [type/reference, layer/routing, status/draft, category/coding, focus/memory]
---

# Coding Category — Memory Filter & Compaction

> Vector DB filter configuration, memory types to retrieve, cross-category queries, and compaction rules for coding context.

**Up →** [[stack/L5-routing/categories/coding/_overview]]

---

## Vector DB Query Filter

^filter-coding

```json
{
  "category": ["coding", "coding:project", "coding:debugging", "coding:tools", "coding:review"],
  "exclude_categories": ["cooking", "social"],
  "boost_fields": ["project_name", "tech_stack", "recent_errors"],
  "recency_weight": 0.3,
  "semantic_weight": 0.3,
  "category_weight": 0.2,
  "frequency_weight": 0.2
}
```

**Explanation:**
- `category`: Retrieve memories tagged with coding or its sub-categories
- `exclude_categories`: Skip non-coding memories (cooking, social, fitness, etc.)
- `boost_fields`: Prioritize memories that mention projects, tech stacks, or errors (context-critical)
- Weights: Recency + semantic relevance equally important (0.3 each), then category match (0.2), then frequency (0.2)

---

## Memory Types to Retrieve

| Memory Type | Example | Priority | Retrieval Strategy |
|---|---|---|---|
| **Active project context** | "crispy-kitsune: Obsidian vault, Node.js build, L5 audit in progress" | Always load | Query: active_project + project_name |
| **Recent work** | "Last commit: audit(L5), working branch: main, pending: PR#42" | Always load | Query: recent_activity + project_name |
| **Architecture decisions** | "Chose transclusion over inline content for context-main.md — reasoning: performance + readability" | Load if relevant project | Query: architecture + project_name |
| **Bug patterns** | "Sharp build errors on macOS → use SHARP_IGNORE_GLOBAL_LIBVIPS=1; Windows path issues → use forward slashes in .env" | Load if debugging | Query: bug_pattern + error_type |
| **Tool preferences** | "Prefers VS Code + ESLint + Prettier, avoids Prettier semicolons" | Load for setup/config | Query: tool_preference + intent |
| **Tech stack** | "This project: TypeScript, Node 22, Obsidian vault; other projects: Python 3.11, Docker" | Always load for active project | Query: tech_stack + project_name |
| **Code patterns** | "Pattern: Use optional chaining before property access; pattern: Batch operations in loops for performance" | Load for code review/writing | Query: code_pattern + language |
| **Performance notes** | "This endpoint is slow on large datasets — add pagination; database queries need indexing" | Load if optimization/debug | Query: performance + component_name |

---

## Cross-Category Queries

Coding can query memories from other categories in specific scenarios:

| Scenario | Query | Example |
|---|---|---|
| Setup for fitness app | `category: [coding, fitness] + tag: api_integration` | "Pull fitness data — which endpoints does the fitness category mention?" |
| Finance dashboard update | `category: [coding, finance] + tag: data_model` | "Refresh the dashboard — what does the finance category say about structure?" |
| Cooking site refactor | `category: [coding, cooking]` | "Update recipe database schema — what fields does the cooking category track?" |
| Testing deployment | `category: [coding] + project_name: any` | "Run tests across all projects" |

---

## Memory Write Rules

When coding mode is active, these memories should be saved immediately:

| Trigger | What to Save | Metadata |
|---|---|---|
| **Successful debug** | Diagnosis (symptom → root cause → fix) | `tag: bug_pattern`, `project_name`, `error_type`, `language` |
| **Architecture decision** | Decision + reasoning | `tag: architecture`, `project_name`, `date_decided` |
| **New code pattern** | Pattern description + code example | `tag: code_pattern`, `language`, `use_case` |
| **Tool setup** | Tool + config details | `tag: tool_preference`, `project_name`, `status: active` |
| **Performance insight** | Component + bottleneck + fix | `tag: performance`, `project_name`, `impact: high/medium/low` |
| **Project context change** | New branch, tech stack update, PR opened | `tag: recent_activity`, `project_name`, `timestamp` |
| **Refactoring decision** | What changed, why, outcome | `tag: refactoring`, `project_name`, `scope: small/medium/large` |

---

## Memory Retrieval by Intent

### Intent: `coding:debug`

```
Retrieve:
  1. Bug patterns (error_type = user_error)
  2. Recent activity in active project
  3. Tech stack for active project
  4. Recent failures/stack traces
Boost: Recency (find the most recent similar bug)
```

### Intent: `coding:write-code`

```
Retrieve:
  1. Code patterns (language = active_language)
  2. Tech stack preferences
  3. Architecture decisions (project_name = active)
  4. Code style notes
Boost: Semantic match (find similar patterns)
```

### Intent: `coding:review`

```
Retrieve:
  1. Code patterns (relevant language/framework)
  2. Architecture decisions
  3. Recent reviews (to maintain consistency)
  4. Project-specific style guide
Boost: Semantic + frequency (most common patterns)
```

### Intent: `coding:deploy`

```
Retrieve:
  1. Deployment history (project_name = active)
  2. Environment configuration
  3. Rollback notes (if they exist)
Boost: Recency (latest successful deploy)
```

### Intent: `coding:setup`

```
Retrieve:
  1. Tool preferences
  2. Installation notes from past setups
  3. Environment configuration
Boost: Frequency (most-used tools)
```

---

## Compaction Rules

^compaction-coding

### Preserve

- **Architecture decisions** and the reasoning behind them
- **Bug diagnoses** (symptom → root cause → fix mapping)
- **Code patterns** and solutions that might recur
- **Project state snapshots** (branch, open PRs, blocked items, tech stack)
- **Tool/config decisions** and why they were chosen
- **Performance insights** (bottlenecks, optimizations)
- **Failed attempts** (learning: what didn't work and why)

### Flush

- **Step-by-step debugging transcripts** (preserve only the diagnosis + root cause, not the conversation)
- **Code output that's already committed** (don't preserve git diffs after merge)
- **Generic explanations of well-known concepts** ("What is a closure?" level detail)
- **Build/test output logs** (preserve only failures and the fixes, discard success logs)
- **Temporary branch notes** (after merge, flush branch-specific context)
- **Solved issues** (once fixed and committed, move to "bug patterns" summary, flush transcript)
- **Tool version notes** (if version is outdated, flush; keep only active versions)

### Compaction Triggers

| Condition | Action |
|---|---|
| **Memory exceeds 50K tokens** | Compact oldest entries; preserve only patterns and decisions |
| **Project archived** | Move to archive section; flush recent activity |
| **Bug pattern solved multiple times** | Consolidate into single pattern entry with frequency note |
| **Tool/version becomes obsolete** | Flush old version notes; keep only active tool info |
| **Session ends after deep coding** | Consolidate session's learning into reusable patterns |

### Compaction Example

**Before compaction (verbose):**
```
Turn 1: User asked why tests were failing
  → Opened test output
  → Found import error on line 42
  → Checked package.json
  → Saw lodash was in devDependencies
  → Moved to dependencies
  → Tests passed
Turn 2: User asked to review the fix
  → Suggested adding import test
  → User agreed and implemented
Turn 3: User deployed successfully
```

**After compaction (pattern):**
```
Bug pattern: Import error from devDependencies
├── Symptom: Test failure with "module not found"
├── Root cause: Dependency in devDependencies when should be in dependencies
├── Fix: Move package to dependencies section
├── Frequency: 2 occurrences
├── Project: crispy-kitsune
└── Last occurrence: 2026-03-04
```

---

## Memory Lifespan by Type

| Memory Type | Keep | Compaction | Archive |
|---|---|---|---|
| **Architecture decision** | Permanent | Consolidate related decisions | Never |
| **Bug pattern** | Permanent | Consolidate duplicates | Keep summary in archive |
| **Code pattern** | Permanent | Consolidate by language | Never |
| **Tool preference** | Permanent (active tool) | Flush outdated versions | Keep old versions in archive |
| **Project context** | While project active | Flush after project ends | Archive for future reference |
| **Recent activity** | 30 days | Consolidate into "last known state" | Archive older activity |
| **Performance insight** | Permanent | Consolidate similar insights | Never |
| **Debugging transcript** | 1 session | Compress to pattern + diagnosis | Flush |
| **Build/test logs** | 1 session | Keep only failures | Flush successful logs |

---

**Up →** [[stack/L5-routing/categories/coding/_overview]]
