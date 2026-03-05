# git.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L6-processing/coding/git-pipelines.md

flowchart TD
    CRISPY["🦊 Crispy"]:::purple
    CRISPY --> STATUS["git-status<br>/git"]:::blue
    CRISPY --> COMMIT["git-commit<br>/commit"]:::blue
    CRISPY --> PUSH["git-push<br>/push"]:::orange
    CRISPY --> BRANCH["git-branch<br>/branch"]:::blue
    CRISPY --> MERGE["git-merge<br>/merge"]:::orange

    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef orange fill:#fed7aa,stroke:#fb923c,color:#92400e
```

---

## 1. Git Status Pipeline

**Command:** `/git` or `openclaw pipeline run git`

**Purpose:** Quick status report of branch, dirty files, commits, remote sync.

### Flow

```mermaid
flowchart TD
    T["Trigger<br>/git"]:::gray
    T --> STATUS["git status --porcelain<br>(exec)"]:::blue
    T --> BRANCH["git branch --show-current<br>(exec)"]:::blue
    T --> LOG["git log --oneline -10<br>(exec)"]:::blue
    T --> REMOTE["git status -sb<br>(exec)"]:::blue
    STATUS & BRANCH & LOG & REMOTE --> FORMAT["Format report<br>(template)"]:::green
    FORMAT --> SEND["Send to Telegram"]:::green

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
```

### Pipeline YAML

```yaml
name: git
description: >
  Quick git status report: branch, dirty files, recent commits, and remote sync state.
  Triggers via /git Telegram command or openclaw pipeline run git. Read-only — no
  approval gate needed. Output sent directly to channel.
steps:
  - id: status
    command: exec --json --shell 'cd ~/.openclaw/workspace && git status --porcelain'
    timeout: 10000

  - id: branch
    command: exec --json --shell 'cd ~/.openclaw/workspace && git branch --show-current'
    timeout: 5000

  - id: log
    command: exec --json --shell 'cd ~/.openclaw/workspace && git log --oneline -10'
    timeout: 5000

  - id: remote_check
    command: exec --json --shell 'cd ~/.openclaw/workspace && git status -sb | head -1'
    timeout: 10000

  - id: format
    command: exec --shell |
      echo "🔀 Git Status"
      echo ""
      echo "Branch: $(echo '$branch_stdout' | tr -d '\n')"
      echo ""
      echo "Dirty files:"
      echo "$status_stdout"
      echo ""
      echo "Recent commits:"
      echo "$log_stdout"
      echo ""
      echo "Remote: $(echo '$remote_check_stdout' | tr -d '\n')"
