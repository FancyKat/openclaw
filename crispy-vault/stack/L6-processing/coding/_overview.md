---
tags: [layer/processing, status/draft, type/index]
---
# Coding Workflows

> Everything development-related: git pipelines, code review, deploy checklists, testing strategies, and project-aware routing. The goal is to make as much of the dev workflow deterministic (pipeline-driven) as possible, with LLM reasoning only for code analysis and creative tasks.

---

## Overview

```mermaid
flowchart TD
    CODE["Coding Workflows"]:::amber
    CODE --> GIT["Git Operations<br>Status, push, pull, PR, branch"]:::green
    CODE --> REVIEW["Code Review<br>PR review, diff analysis,<br>security + performance"]:::blue
    CODE --> DEPLOY["Deploy<br>Pre-deploy checklist,<br>environment verification"]:::red
    CODE --> TEST["Testing<br>Test strategy, coverage,<br>test runner pipeline"]:::purple
    CODE --> PROJECT["Project Routing<br>Detect project → switch repo<br>→ load context → quick-actions"]:::amber

    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

---

## Design Principles

- **Pipeline-first:** Push as much of the dev workflow into deterministic Lobster pipelines (0 LLM tokens) as possible
- **LLM for analysis only:** Code review, test suggestion, and creative tasks use the full agent loop
- **Approval gates:** Destructive operations (push, deploy, delete branch) always require user confirmation
- **Project-aware:** Context switching loads the right repo, branch, and quick-actions automatically

See the individual files below for full specs, pipeline YAML, and flowcharts.

---

## Pages in This Folder

| Page | Covers |
|---|---|
| [[stack/L6-processing/coding/git-pipelines]] | All git Lobster pipeline designs (status, push, pull, PR, branch) |
| [[stack/L6-processing/coding/code-review]] | Review workflow, skill integration, output format |
| [[stack/L6-processing/coding/deploy]] | Deploy checklist pipeline, environment verification |
| [[stack/L6-processing/coding/testing]] | Test strategy, coverage pipeline, test generation |
| [[stack/L6-processing/coding/project-routing]] | Project registry, routing logic, context switching |

---

**Up →** [[stack/L6-processing/_overview]]
**Back →** [[stack/_overview]]
