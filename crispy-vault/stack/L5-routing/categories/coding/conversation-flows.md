---
tags: [type/reference, layer/routing, status/draft, category/coding, focus/flows]
---

# Coding Category — Conversation Flows

> Example flows with Mermaid diagrams, channel differences, and multi-turn scenarios for coding intents.

**Up →** [[stack/L5-routing/categories/coding/_overview]]

---

## Sequence Diagram — Telegram (Pipeline Annotated)

**Scenario:** Git push with confirmation gate → code review pipeline.

```mermaid
sequenceDiagram
    actor User
    participant TG as Telegram
    participant Flash as Flash (classify)
    participant L5 as L5 Router
    participant Mem as Memory
    participant AgentLoop as Agent Loop

    User->>TG: "Push the latest changes"
    TG->>Flash: classify intent
    Note right of Flash: ~150ms
    Flash-->>L5: coding:git-push (0.96)
    Note over L5: Load coding mode context
    L5->>Mem: recall(project:current, git:config)
    Note right of Mem: ~200ms — project context
    Note over L5,AgentLoop: ⚡ git.lobster pipeline (active)
    L5->>AgentLoop: run git.lobster(action=push)
    AgentLoop->>AgentLoop: git status → git push origin/main
    Note right of AgentLoop: approval gate required
    AgentLoop-->>TG: "Push 3 commits to main?\n- Fix auth bug\n- Add tests\n- Update docs\n[✅ Push] [❌ Cancel]"
    TG->>User: Confirmation prompt

    User->>TG: tap [✅ Push]
    TG->>AgentLoop: resume(token, approve=true)
    AgentLoop->>AgentLoop: execute git push
    AgentLoop-->>TG: "✅ Pushed! 3 commits → origin/main"
    TG->>User: Success + [🔍 Code Review] button

    User->>TG: tap [🔍 Code Review]
    TG->>L5: callback: coding:code-review
    Note over L5,AgentLoop: ⚡ code-review.lobster pipeline (active)
    L5->>AgentLoop: run code-review.lobster(target=HEAD~3)
    Note right of AgentLoop: ~3–5s — LLM analysis
    AgentLoop-->>TG: Code review results (issues, suggestions)
    TG->>User: Review report
```

### Speed Impact

| Step | Latency | Adds Latency? |
|---|---|---|
| Flash classify | 100–200ms | LLM call (flash) |
| Mode load | 150–300ms | Project context from memory |
| git.lobster pipeline | 800ms–2s | git exec + approval gate |
| code-review.lobster pipeline | 3–5s | LLM analysis |
| Agent loop (explain/debug) | 1.5–3s | LLM reasoning + code context |
| **Total (git push with approval)** | **~1–2.5s** | — |
| **Total (code review)** | **~3.5–5.5s** | — |

---

## Git Operation Flow

**Trigger:** "Push the latest changes"

```mermaid
graph TD
    A["User: Push the latest changes"] --> B{Git Hat Active?}
    B -->|No| C["Load Coding Hat"]
    C --> D["Route to git.lobster pipeline"]
    B -->|Yes| D
    D --> E["Get git status"]
    E --> F{Changes to push?}
    F -->|No| G["Respond: Nothing to push"]
    F -->|Yes| H["Confirm: Push branch main to origin"]
    H --> I{User confirms?}
    I -->|Yes| J["Execute git push"]
    J --> K["Report: Success, commit count, new refs"]
    I -->|No| L["Cancel operation"]
```

**Token cost:** ~150 tokens (lookup + confirmation)

---

## Debugging Flow

**Trigger:** "Why is the build failing?"

```mermaid
graph TD
    A["User: Why is the build failing?"] --> B["Load Coding Hat"]
    B --> C["Agent Loop: Full Context"]
    C --> D["Classify: coding:debug intent"]
    D --> E["Request: Build output/error logs"]
    E --> F{Logs provided?}
    F -->|No| G["Ask: Run build again, paste output"]
    F -->|Yes| H["Parse error trace"]
    H --> I["Isolate: Root cause"]
    I --> J["Suggest fix"]
    J --> K{User confirms understanding?}
    K -->|Yes| L["Save diagnosis to memory"]
    K -->|No| M["Ask follow-up clarification"]
    M --> J
```

**Token cost:** 3K–8K tokens (reasoning + diagnosis)

---

## Code Review Flow

**Trigger:** "Review this commit"

```mermaid
graph TD
    A["User: Review this commit"] --> B["Load Coding Hat"]
    B --> C["Route to code-review pipeline"]
    C --> D["Get diff from git"]
    D --> E["Apply structural checklist"]
    E --> F{Issues found?}
    F -->|No| G["Load architectural checklist"]
    G --> H{Architecture OK?}
    H -->|Yes| I["Report: All checks passed"]
    H -->|No| J["Flag: Architecture concerns"]
    F -->|Yes| K["Flag: Issues + suggestions"]
    J --> L["Generate report"]
    K --> L
    L --> M["Save review to memory"]
```

**Token cost:** 2K–4K tokens (checklist lookup + review)

---

## Deploy Flow

**Trigger:** "Deploy to staging"

```mermaid
graph TD
    A["User: Deploy to staging"] --> B["Load Coding Hat"]
    B --> C["Route to deploy pipeline"]
    C --> D["Verify environment: staging"]
    D --> E["Check health: target healthy?"]
    E -->|Unhealthy| F["Stop: Env not ready"]
    E -->|Healthy| G["Confirm: Deploy commit XXX to staging"]
    G --> H{User confirms?}
    H -->|Yes| I["Execute deployment"]
    I --> J["Poll health checks"]
    J --> K{Health OK?}
    K -->|Yes| L["Report: Success"]
    K -->|No| M["Alert: Failed deployment, rollback?"]
    L --> N["Save deployment record to memory"]
    M --> N
    H -->|No| O["Cancel"]
```

**Token cost:** ~800 tokens (validation + execution)

---

## Code Writing Flow

**Trigger:** "Add a retry handler to the API client"

```mermaid
graph TD
    A["User: Add a retry handler"] --> B["Load Coding Hat"]
    B --> C["Agent Loop: Full Context"]
    C --> D["Check memory: Tech stack, style, patterns"]
    D --> E["Ask: Exponential backoff? Max retries?"]
    E --> F["Generate implementation"]
    F --> G["Show code + explanation"]
    G --> H{User satisfied?}
    H -->|No| I["Iterate on feedback"]
    I --> G
    H -->|Yes| J["User applies changes"]
    J --> K["Save pattern + decision to memory"]
```

**Token cost:** 5K–15K tokens (creative + interactive)

---

## Project Switch Flow

**Trigger:** "Switch to the infra project"

```mermaid
graph TD
    A["User: Switch to infra"] --> B["Load Coding Hat"]
    B --> C["Route to project-routing pipeline"]
    C --> D["Lookup project registry: infra"]
    D --> E{Project found?}
    E -->|No| F["Ask: Project name or alias?"]
    F --> D
    E -->|Yes| G["Load context: tech stack, branches"]
    G --> H["Assemble memory: recent work, decisions"]
    H --> I["Set active project: infra"]
    I --> J["Report: Ready for infra work"]
    J --> K["Save project switch to memory"]
```

**Token cost:** ~400 tokens (lookup + context assembly)

---

## Topic Shift: Coding → Cooking

**Trigger:** In middle of debugging session, "What's for dinner?"

```mermaid
graph TD
    A["In coding session..."] --> B["User: What's for dinner?"]
    B --> C{Cooking trigger detected?}
    C -->|Yes| D["Classify: Soft shift or hard shift?"]
    D -->|Soft| E["Keep coding hat, add cooking hat overlay"]
    D -->|Hard| F["Compact coding context → memory"]
    F --> G["Flush coding hat"]
    G --> H["Load cooking hat"]
    H --> I["Agent Loop: Cooking context"]
    I --> J["Answer dinner question"]
    J --> K{User returns to coding?}
    K -->|Yes| L["Restore coding hat context"]
    K -->|No| M["Continue in cooking mode"]
```

---

## Error Recovery Flow

**Trigger:** Pipeline fails with "Permission denied" on git push

```mermaid
graph TD
    A["git.lobster pipeline: push fails"] --> B["Catch: Permission denied"]
    B --> C["Check: SSH keys, auth, branch protection"]
    C --> D{Root cause identified?}
    D -->|SSH key missing| E["Suggest: Load SSH key"]
    D -->|Branch protected| F["Suggest: Create PR instead"]
    D -->|Unknown| G["Fall back to Agent Loop"]
    E --> H["User takes action"]
    H --> I["Retry push"]
    F --> I
    G --> I
```

**Token cost:** 500–1K tokens (diagnostics + fallback)

---

## Multi-Turn: Debugging → Code Review → Deploy

**Full session example:**

1. **Turn 1 (Debug):** User: "Why is the test failing?"
   - Agent loop, diagnose, fix
   - Token cost: 4K

2. **Turn 2 (Review):** User: "Review my fix"
   - Pipeline: code-review
   - Token cost: 2K

3. **Turn 3 (Deploy):** User: "Deploy to staging"
   - Pipeline: deploy
   - Token cost: 800

**Total session cost:** ~6.8K tokens

All three intents stay within the coding hat context. Memory accumulates decisions and patterns across turns.

---

## Channel Differences

### Telegram Flow

Buttons guide the flow:
- User clicks "🐛 Debug" → System shows debug checklist → User selects "Read Error" → Proceeds

### Discord Flow

Slash commands:
- `/debug read-error` → System reads provided error → Proceeds

### Gmail Flow

Linear conversation:
- User sends email with error → System replies with questions → Back-and-forth resolution

---

**Up →** [[stack/L5-routing/categories/coding/_overview]]
