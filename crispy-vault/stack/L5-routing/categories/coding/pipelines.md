---
tags: [type/reference, layer/routing, status/draft, category/coding, focus/pipelines]
---

# Coding Category — Pipelines

> Pipeline definitions, token costs, LLM vs lookup breakdown, schemas, and deployment status.

**Up →** [[stack/L5-routing/categories/coding/_overview]]

---

## Pipeline Map

| Pipeline | Trigger | Status | What It Does |
|---|---|---|---|
| `git.lobster` | "/git", "push", "commit", "branch" | ✅ Designed | Git operations (status, push, pull, PR, branch, stash) |
| `code-review` | "/review", "review this", "check this PR" | ✅ Designed | Structured review against quality checklist |
| `deploy` | "/deploy", "ship it", "release" | ✅ Designed | Deploy checklist with environment verification |
| `testing` | "/test", "run tests", "coverage" | ✅ Designed | Test execution, coverage reporting, test generation |
| `project-routing` | "switch to X", "work on Y" | ✅ Designed | Project registry lookup, context switch |

*Coding has the most mature pipeline infrastructure — most common operations can be handled without the full agent loop.*

---

## git.lobster Pipeline

**Tokens:** ~200 per operation (lookup only, no LLM unless user asks interpretation)

**Operation Breakdown:**
- `status` — File diff parsing, branch name extraction (100 tokens)
- `push` — Validation + execution + confirmation (150 tokens)
- `pull` — Conflict detection, merge strategy suggestion (200 tokens)
- `commit` — Message validation, tree diff (180 tokens)
- `branch` — Name validation, existence check (80 tokens)
- `stash` — Stack trace parsing, recovery metadata (150 tokens)
- `pr` — GitHub API call, metadata parsing (250 tokens)

**Schema:**
```json
{
  "operation": "push|pull|commit|branch|stash|pr",
  "context": "working_directory, active_branch, remote_name",
  "args": "operation_specific_params",
  "confirmation_required": "true|false",
  "rollback_available": "true|false"
}
```

---

## code-review Pipeline

**Tokens:** 2K–4K per review (checklist lookup + selective LLM)

**Breakdown:**
- Load checklist from memory (200 tokens)
- Apply structural checks (linting, complexity, duplication) (500 tokens)
- LLM review pass if needed (1500 tokens)
- Generate report (300 tokens)

**Schema:**
```json
{
  "diff_or_pr": "file_content|pr_url",
  "checklist": ["naming", "performance", "security", "test-coverage"],
  "severity_threshold": "error|warning|info",
  "output_format": "brief|detailed|summary"
}
```

---

## deploy Pipeline

**Tokens:** 500–1K per deploy (mostly lookup + validation)

**Breakdown:**
- Environment validation (200 tokens)
- Health check (150 tokens)
- Deployment execution (or instructions) (300 tokens)
- Rollback plan generation (200 tokens)

**Schema:**
```json
{
  "environment": "staging|production",
  "version_or_branch": "commit_sha|branch_name",
  "dry_run": true,
  "rollback_available": true,
  "health_checks": ["url_path", "endpoint", "status_code"]
}
```

---

## testing Pipeline

**Tokens:** 500–2K per execution (depends on test suite size)

**Breakdown:**
- Test discovery (200 tokens)
- Execution output parsing (300–1K tokens)
- Coverage report generation (200 tokens)
- Failure analysis (if needed) (500 tokens)

**Schema:**
```json
{
  "command": "npm test|pytest|cargo test",
  "filters": "pattern_to_run|suite_name",
  "report_type": "summary|detailed|coverage",
  "generate_if_missing": true
}
```

---

## project-routing Pipeline

**Tokens:** 200–500 per switch (memory lookup + context switch)

**Breakdown:**
- Project registry lookup (100 tokens)
- Context assembly (tech stack, branches, recent work) (300 tokens)
- Memory preload (100 tokens)

**Schema:**
```json
{
  "project_name_or_alias": "string",
  "context_depth": "minimal|full",
  "load_branches": true,
  "load_recent_work": true
}
```

---

## Pipeline Dependencies & Ordering

```
User Input
  ↓
Triage (trigger + intent classification)
  ↓
[Coding Hat Loaded]
  ↓
  ├─→ Is intent a pipeline trigger?
  │   ├─→ YES: Route to pipeline (git.lobster, code-review, deploy, testing, project-routing)
  │   │   └─→ Execute, return result
  │   └─→ NO: Fall through to agent loop
  │
  └─→ Agent Loop (for debug, write-code, explain, setup)
      └─→ Uses full context + coding hat
```

---

## LLM vs Lookup Decision Tree

For each coding intent, the routing layer decides:

| Intent | Primary Route | Fallback |
|---|---|---|
| `coding:git-op` | Pipeline (lookup) | Agent if user asks why/explanation |
| `coding:debug` | Agent loop | Pipeline if diagnostics available |
| `coding:write-code` | Agent loop | Pipeline for boilerplate/templates |
| `coding:review` | Pipeline (checklist) | Agent if architectural review needed |
| `coding:deploy` | Pipeline (checklist) | Agent if deployment strategy unclear |
| `coding:test` | Pipeline (execution) | Agent if test generation needed |
| `coding:explain` | Agent loop | Pipeline for API/doc lookup |
| `coding:setup` | Agent loop + Pipeline | Pipeline for common tool setup |
| `coding:project-switch` | Pipeline (lookup) | Agent if context assembly fails |

---

## Future Pipelines (In Planning)

- `linter-formatter` — Run eslint/prettier, auto-format or suggest fixes
- `dependency-upgrade` — Check for outdated packages, assess breaking changes
- `security-audit` — Run OWASP checks, dependency vulnerability scan
- `performance-profiler` — Identify bottlenecks in code or build
- `doc-generator` — Create README, API docs, or JSDoc from codebase

---

**Up →** [[stack/L5-routing/categories/coding/_overview]]
