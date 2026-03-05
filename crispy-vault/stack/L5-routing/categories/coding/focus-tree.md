---
tags: [type/reference, layer/routing, status/draft, category/coding, focus/tree]
---

# Coding Category — Focus Tree

> Navigation hierarchy and focus tree JSON with callback convention. Telegram button rendering example and tree structure.

**Up →** [[stack/L5-routing/categories/coding/_overview]]

---

## Focus Tree ASCII Representation

```
Coding 💻
├── Git Operations (git.lobster)
│   ├── Status
│   ├── Push
│   ├── Pull
│   ├── Branch (create/delete/list)
│   ├── Commit
│   ├── Stash (save/pop/list)
│   └── PR (open/review/merge)
├── Debugging (agent loop)
│   ├── Read error
│   ├── Reproduce
│   ├── Isolate
│   └── Fix & test
├── Write Code (agent loop)
│   ├── New feature
│   ├── Modify existing
│   ├── Refactor
│   └── Optimize
├── Code Review (code-review pipeline)
│   ├── Checklist review
│   ├── Architecture feedback
│   └── Security check
├── Deploy (deploy pipeline)
│   ├── To staging
│   ├── To production
│   └── Rollback
├── Testing (testing pipeline)
│   ├── Run suite
│   ├── Coverage report
│   └── Generate tests
├── Learning (agent loop)
│   ├── Concept explanation
│   ├── Architecture walk-through
│   └── Pattern examples
├── Project Setup (agent loop + pipeline)
│   ├── Tool install
│   ├── Configuration
│   └── Environment setup
└── Project Switch (project-routing)
    └── Select active repo
```

---

## Focus Tree JSON

```json
{
  "tree_id": "coding",
  "tree_name": "Coding Hat Focus Tree",
  "emoji": "💻",
  "callback_prefix": "coding",
  "nodes": [
    {
      "id": "git-ops",
      "label": "Git Operations",
      "callback": "coding:git-ops",
      "pipeline": "git.lobster",
      "children": [
        {"id": "git-status", "label": "Status", "callback": "coding:git:status"},
        {"id": "git-push", "label": "Push", "callback": "coding:git:push"},
        {"id": "git-pull", "label": "Pull", "callback": "coding:git:pull"},
        {"id": "git-branch", "label": "Branch", "callback": "coding:git:branch"},
        {"id": "git-commit", "label": "Commit", "callback": "coding:git:commit"},
        {"id": "git-stash", "label": "Stash", "callback": "coding:git:stash"},
        {"id": "git-pr", "label": "PR", "callback": "coding:git:pr"}
      ]
    },
    {
      "id": "debug",
      "label": "Debugging",
      "callback": "coding:debug",
      "agent_loop": true,
      "children": [
        {"id": "debug-read", "label": "Read Error", "callback": "coding:debug:read"},
        {"id": "debug-reproduce", "label": "Reproduce", "callback": "coding:debug:reproduce"},
        {"id": "debug-isolate", "label": "Isolate", "callback": "coding:debug:isolate"},
        {"id": "debug-fix", "label": "Fix & Test", "callback": "coding:debug:fix"}
      ]
    },
    {
      "id": "write-code",
      "label": "Write Code",
      "callback": "coding:write-code",
      "agent_loop": true,
      "children": [
        {"id": "code-new", "label": "New Feature", "callback": "coding:write:new"},
        {"id": "code-modify", "label": "Modify", "callback": "coding:write:modify"},
        {"id": "code-refactor", "label": "Refactor", "callback": "coding:write:refactor"},
        {"id": "code-optimize", "label": "Optimize", "callback": "coding:write:optimize"}
      ]
    },
    {
      "id": "review",
      "label": "Code Review",
      "callback": "coding:review",
      "pipeline": "code-review",
      "children": [
        {"id": "review-checklist", "label": "Checklist", "callback": "coding:review:checklist"},
        {"id": "review-arch", "label": "Architecture", "callback": "coding:review:arch"},
        {"id": "review-security", "label": "Security", "callback": "coding:review:security"}
      ]
    },
    {
      "id": "deploy",
      "label": "Deploy",
      "callback": "coding:deploy",
      "pipeline": "deploy",
      "children": [
        {"id": "deploy-staging", "label": "Staging", "callback": "coding:deploy:staging"},
        {"id": "deploy-prod", "label": "Production", "callback": "coding:deploy:prod"},
        {"id": "deploy-rollback", "label": "Rollback", "callback": "coding:deploy:rollback"}
      ]
    },
    {
      "id": "testing",
      "label": "Testing",
      "callback": "coding:test",
      "pipeline": "testing",
      "children": [
        {"id": "test-run", "label": "Run Suite", "callback": "coding:test:run"},
        {"id": "test-coverage", "label": "Coverage", "callback": "coding:test:coverage"},
        {"id": "test-generate", "label": "Generate", "callback": "coding:test:generate"}
      ]
    },
    {
      "id": "learning",
      "label": "Learning",
      "callback": "coding:explain",
      "agent_loop": true,
      "children": [
        {"id": "learn-concept", "label": "Concept", "callback": "coding:explain:concept"},
        {"id": "learn-arch", "label": "Architecture", "callback": "coding:explain:arch"},
        {"id": "learn-pattern", "label": "Pattern", "callback": "coding:explain:pattern"}
      ]
    },
    {
      "id": "setup",
      "label": "Project Setup",
      "callback": "coding:setup",
      "agent_loop": true,
      "children": [
        {"id": "setup-install", "label": "Install", "callback": "coding:setup:install"},
        {"id": "setup-config", "label": "Configure", "callback": "coding:setup:config"},
        {"id": "setup-env", "label": "Environment", "callback": "coding:setup:env"}
      ]
    },
    {
      "id": "project-switch",
      "label": "Project Switch",
      "callback": "coding:project-switch",
      "pipeline": "project-routing",
      "children": []
    }
  ]
}
```

^tree-coding

---

## Telegram Button Rendering

When coding mode is active in Telegram, the bot renders a keyboard with these buttons:

**Row 1:**
- `🔀 Git Ops` (callback: `coding:git-ops`)
- `🐛 Debug` (callback: `coding:debug`)

**Row 2:**
- `✏️ Write Code` (callback: `coding:write-code`)
- `👀 Review` (callback: `coding:review`)

**Row 3:**
- `🚀 Deploy` (callback: `coding:deploy`)
- `✅ Test` (callback: `coding:test`)

**Row 4:**
- `📚 Learning` (callback: `coding:explain`)
- `⚙️ Setup` (callback: `coding:setup`)

**Row 5:**
- `📁 Project Switch` (callback: `coding:project-switch`)

Each button tap triggers the callback, which either loads a submenu (if children exist) or executes the intent directly.

---

## Discord Slash Commands

Coding mode in Discord maps to these slash commands:

```
/git [status|push|pull|branch|commit|stash|pr]
/debug [read-error|reproduce|isolate|fix]
/code [new|modify|refactor|optimize]
/review [checklist|arch|security]
/deploy [staging|prod|rollback]
/test [run|coverage|generate]
/explain [concept|arch|pattern]
/setup [install|config|env]
/project switch
```

Each slash command can include context-specific options (e.g., `/git push --branch main`).

---

**Up →** [[stack/L5-routing/categories/coding/_overview]]
