---
tags: [type/reference, layer/routing, status/draft, category/coding, focus/speed]
---

# Coding Category — Speed Baselines

> Latency budgets, operation breakdowns, UX red lines, and caching strategy for coding operations.

**Up →** [[stack/L5-routing/categories/coding/_overview]]

---

## Latency Budgets by Intent

| Intent | Target Latency | Red Line | Notes |
|---|---|---|---|
| `coding:git-op` | <1s | 3s | Must feel instant; cached when possible |
| `coding:debug` | 5–15s | 30s | Reasoning-heavy; user expects thinking time |
| `coding:write-code` | 8–20s | 45s | Creative; incremental display OK |
| `coding:review` | 3–8s | 15s | Checklist-based; mostly lookup |
| `coding:deploy` | 5–15s | 60s | Includes health checks; long latency acceptable |
| `coding:test` | 5–30s | 120s | Execution-dependent; can be very long |
| `coding:explain` | 3–10s | 20s | Informational; should be quick |
| `coding:setup` | 10–30s | 60s | Multi-step; user expects work |
| `coding:project-switch` | <1s | 3s | Must feel instant |

---

## Operation Breakdown

### git.lobster Pipeline

```
git status
├── Read filesystem (cached) → 50ms
├── Parse .git tree → 100ms
├── Extract branch name → 20ms
└── Total: ~170ms → Display instantly

git push
├── Validate branch exists → 100ms
├── Confirm with user → 500ms (user input)
├── Execute git push → 1–5s (network dependent)
├── Parse output → 100ms
└── Total: 1–5.5s (mostly network)

git pull
├── Check for conflicts → 200ms
├── Execute git pull → 1–3s (network)
├── Merge strategy suggest (if needed) → 500ms
└── Total: 1–3.5s

git pr
├── Parse diff → 200ms
├── Call GitHub API → 1–2s (network)
├── Format response → 100ms
└── Total: 1–2.3s
```

### code-review Pipeline

```
Apply structural checks
├── Load checklist → 100ms (cached)
├── Lint analysis (eslint/ruff) → 300–1000ms
├── Complexity metrics → 200ms
└── Subtotal: 600–1300ms

Architectural review (if needed)
├── LLM analysis pass → 2–4s (LLM dependent)
└── Subtotal: 2–4s

Generate report
├── Format markdown → 100ms
└── Subtotal: 100ms

Total: 700ms–5.4s
```

### deploy Pipeline

```
Validate environment
├── Check AWS/Heroku status → 500ms (API call)
├── Verify credentials → 100ms
└── Subtotal: 600ms

Health check
├── Poll endpoint → 200ms per attempt (retry up to 3x)
└── Subtotal: 200–600ms

Confirm + execute
├── Wait for user input → 5–30s (user dependent)
├── Deploy execution → 2–10s (platform dependent)
└── Subtotal: 7–40s

Total: 7.8–41.2s (user input dominates)
```

### testing Pipeline

```
Test discovery
├── Find test files → 100ms
├── Parse test names → 200ms
└── Subtotal: 300ms

Execution
├── Run test suite → 5s–2m (suite size dependent)
└── Subtotal: 5–120s

Coverage analysis
├── Parse coverage data → 200ms
├── Generate report → 300ms
└── Subtotal: 500ms

Total: 5.8s–120.8s
```

---

## UX Red Lines

These thresholds trigger different UX responses:

| Latency | Response |
|---|---|
| < 100ms | Instant feedback (no loading indicator needed) |
| 100ms–1s | Show spinner; keep smooth |
| 1–3s | Show spinner + estimated wait time |
| 3–10s | Show progress bar + "thinking..." message |
| 10–30s | Show multi-step progress (e.g., "Running tests...", "Compiling...") |
| 30+ seconds | Offer to run in background; provide polling mechanism |

---

## Caching Strategy

### Level 1: Filesystem Cache (Pipeline Results)

```
cache git status
├── TTL: 5 seconds
├── Invalidated by: file modification, git command
└── Use: Quick repeated checks

cache project registry
├── TTL: 1 hour
├── Invalidated by: manual refresh, context change
└── Use: Project-switch pipeline

cache lint/complexity results
├── TTL: 10 minutes
├── Invalidated by: file change, manual refresh
└── Use: code-review pipeline
```

### Level 2: Memory Cache (User Context)

```
cache active project
├── TTL: session duration
├── Invalidated by: project-switch
└── Use: All operations (avoid lookup cost)

cache recent branches
├── TTL: 15 minutes
├── Invalidated by: git pull/push
└── Use: branch completion in git.lobster

cache coding style + preferences
├── TTL: session duration
├── Invalidated by: memory write
└── Use: code generation, review guidance
```

### Level 3: Vector DB (Long-term Memory)

```
cache code patterns + solutions
├── TTL: permanent
├── Invalidated by: memory write/compaction
└── Use: setup, refactoring, learning flows

cache architecture decisions
├── TTL: permanent
├── Invalidated by: decision log update
└── Use: code review, design discussions

cache bug patterns + root causes
├── TTL: permanent
├── Invalidated by: compaction
└── Use: debugging flow
```

---

## Operation Latency Table

---

## Testing Methodology

**Measurement points:** `message-received` → `first-token` → `complete-response`; `pipeline-trigger` → `pipeline-complete` (Lobster trace).

**Tools:** Telegram `.date` timestamps, OpenClaw gateway logs, Lobster execution trace, `auditLog` JSONL (`coding:*` events).

**Conditions:** (1) Agent loop only (explain/debug), cold cache; (2) Agent loop, warm cache; (3) + git pipeline; (4) + code-review pipeline; (5) Full pipeline stack.

**Sample size:** Minimum 10 messages per condition.

---

## Pipeline Impact Predictions

| Pipeline | LLM Calls | Exec Calls | Sync/Async | Expected Delta | Notes |
|---|---|---|---|---|---|
| `git.lobster` | 0 | 2–5 git cmds | Sync (approval gate) | +800ms–2s | Approval adds ~1–2s UI wait |
| `code-review.lobster` | 2–3 (main) | 1 git diff | Sync | +3–5s | Main model — complex analysis |
| `deploy.lobster` | 1 (flash) | 3–5 cmds | Sync (approval gate) | +2–4s | Pre-flight checks + approval |
| `testing.lobster` | 1 (flash) | test runner | Async | +2–10s | Test suite time-dependent |
| `project-routing.lobster` | 1 (flash) | 0 | Sync | +200–500ms | Classification only |

---

## Speed Budget (Machine-Readable)

```json
{
  "category": "coding",
  "targets": {
    "first_token_ms": 1500,
    "complete_response_ms": 5000,
    "pipeline_overhead_ms": 500
  },
  "thresholds": {
    "button_tap_ms": 500,
    "initial_response_ms": 1500,
    "multi_turn_ms": 3000,
    "complex_operation_ms": 8000,
    "hang_threshold_ms": 10000
  },
  "pipelines": {
    "git":             { "latency_ms": [800,  2000], "llm_calls": 0, "sync": true },
    "code-review":     { "latency_ms": [3000, 5000], "llm_calls": 3, "sync": true },
    "deploy":          { "latency_ms": [2000, 4000], "llm_calls": 1, "sync": true },
    "testing":         { "latency_ms": [2000, 10000], "llm_calls": 1, "sync": false },
    "project-routing": { "latency_ms": [200,  500],  "llm_calls": 1, "sync": true }
  }
}
```
^speed-coding

| Operation | Typical | 95th % | Notes |
|---|---|---|---|
| git status | 150ms | 300ms | Cached filesystem read |
| git push | 2s | 5s | Network dependent |
| git pull | 2.5s | 6s | Conflict check adds latency |
| git branch | 400ms | 800ms | List all branches |
| git commit | 800ms | 1.2s | Message validation included |
| lint check | 500ms | 1.5s | Depends on file count |
| code review (structural) | 1.2s | 3s | Checklist only |
| code review (architectural) | 4s | 8s | Includes LLM pass |
| test suite run | 15s | 45s | Highly variable by project |
| deploy (staging) | 8s | 20s | Includes health check |
| deploy (production) | 12s | 30s | Extra confirmation steps |
| project switch | 300ms | 1s | Memory load + registry lookup |

---

## Performance Optimization Tips

1. **Eager loading:** Preload project context when user loads coding hat
2. **Pagination:** For long diffs/logs, paginate instead of loading all
3. **Background work:** Offer to run long operations (tests, deploys) in background
4. **Incremental display:** Show partial results as they arrive (e.g., test output streaming)
5. **Caching:** Always check cache before calling external APIs
6. **Compression:** For large diffs/logs, offer summary + expandable detail

---

**Up →** [[stack/L5-routing/categories/coding/_overview]]
