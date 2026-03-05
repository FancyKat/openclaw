---
tags: [layer/processing, status/draft, topic/agent-loop, type/reference]
---

# L6 — Agent Loop

> The core LLM reasoning cycle: Think → Act → Observe → Repeat until task complete or loop terminates.

---

## Universal Message Lifecycle

This is the complete flow from message arrival to response, shared across all channels (Telegram, Discord, Gmail).

### Step 1 — Input & Auth

```mermaid
flowchart TD
    TG["Telegram"]:::teal --> GATE{"Authorized?"}:::amber
    DC["Discord"]:::blue --> GATE
    GM["Gmail Hook"]:::amber --> GATE
    GATE -->|No| DROP["Dropped"]:::red
    GATE -->|Yes| CTX["Context Assembly"]:::purple

    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

### Step 2 — Context Assembly

```mermaid
flowchart TD
    BS["Load bootstrap files"]:::purple
    BS --> MEM["Load MEMORY.md<br>(DM only)"]:::purple
    MEM --> DL["Load today + yesterday log"]:::purple
    DL --> HIST["Load session history"]:::purple
    HIST --> LLM["Send to researcher<br>(primary model)"]:::green

    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
```

### Step 3 — Agent Loop

```mermaid
flowchart TD
    LLM["Send to primary/workhorse<br>(or fallback)"]:::green
    LLM --> INT{"Intent clear?"}:::amber
    INT -->|Clear| DO["Process directly"]:::green
    INT -->|Ambiguous| BTN["Build decision buttons"]:::purple
    INT -->|Tool needed| TOOL["Execute tool"]:::blue
    TOOL --> LLM

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
```

### Step 4 — Output & Persist

```mermaid
flowchart TD
    FMT{"Format for channel"}:::amber
    FMT -->|Telegram| TG_OUT["HTML + buttons"]:::teal
    FMT -->|Discord| DC_OUT["Embed + components"]:::blue
    TG_OUT --> SAVE["Session JSONL"]:::gray
    DC_OUT --> SAVE
    SAVE --> LOG["Daily memory log"]:::gray

    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
```

---

## The Agent Loop — Core Cycle

The agent loop is Crispy's main execution engine. Each iteration sends context to the LLM, receives a response, executes any tools, and observes the results.

```mermaid
flowchart TD
    START["New message arrives"]:::blue
    START --> THINK["① THINK<br>Load context + history<br>Send to LLM"]:::purple
    THINK --> RESPONSE["LLM returns:<br>reasoning + intent"]:::green
    RESPONSE --> INTENT{"What is the intent?"}:::amber
    INTENT -->|"Generate text"| TEXT["Output response<br>to channel"]:::green
    INTENT -->|"Execute tool"| TOOL["② ACT<br>Run tool with args"]:::orange
    INTENT -->|"Ask for info"| ASK["③ OBSERVE<br>Wait for user input"]:::teal
    TOOL --> OBS["Tool returns output<br>stdout, stderr, result"]:::teal
    OBS --> UPDATE["④ UPDATE CONTEXT<br>Add tool output to history"]:::blue
    UPDATE --> DECIDE{"Task complete?"}:::amber
    DECIDE -->|Yes| END["Return final response"]:::green
    DECIDE -->|No| THINK
    ASK --> WAIT["User responds"]:::teal
    WAIT --> THINK
    TEXT --> END

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef orange fill:#fed7aa,stroke:#fb923c,color:#92400e
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
```

---

## Step 1: THINK — Context Assembly

Before each LLM call, Crispy assembles context in this order:

```mermaid
flowchart TD
    START["THINK Phase begins"]:::purple
    START --> BS["Load bootstrap files<br>(AGENTS.md, SOUL.md, TOOLS.md, etc)"]:::green
    BS --> MEM["Load MEMORY.md<br>(long-term knowledge, DM only)"]:::green
    MEM --> LOG["Load daily logs<br>(today + yesterday)"]:::green
    LOG --> HIST["Load session history<br>(previous messages in this session)"]:::green
    HIST --> PACK["Pack into context window<br>respecting token limit"]:::blue
    PACK --> LLM["Send to LLM<br>(with model cascade fallback)"]:::orange

    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef orange fill:#fed7aa,stroke:#fb923c,color:#92400e
```

**Context Budget** (typical):
- Bootstrap files: 2–5K tokens
- MEMORY.md: 3–8K tokens
- Daily logs (2 days): 2–4K tokens
- Session history: 5–20K tokens (pruned if >1hr old)
- **Total loaded: 12–37K tokens**

**Token Allocation:**
- Input context: 40–50K tokens
- LLM output: 4K tokens (default)
- Safety buffer: 10K tokens
- **Total per turn: ~60K tokens from a 150K window**

---

## Step 2: ACT — Tool Execution

When the LLM returns a tool call, Crispy executes it with permission gating.

```mermaid
flowchart TD
    TOOL_REQ["LLM requests tool"]:::orange
    TOOL_REQ --> PARSE["Parse tool name + args"]:::gray
    PARSE --> CHECK{"Needs approval?"}:::amber
    CHECK -->|Yes| GATE["Check permission profile<br>(sandboxed_exec? allowed_domains?)"]:::red
    CHECK -->|No| EXEC["Execute immediately"]:::blue
    GATE -->|Approved| EXEC
    GATE -->|Blocked| DENY["Return: permission denied"]:::red
    EXEC --> RUN["Run in sandbox<br>(if applicable)"]:::blue
    RUN --> CAPTURE["Capture stdout<br>stderr, return code, result"]:::teal
    CAPTURE --> RESULT["Return to context"]:::green

    classDef orange fill:#fed7aa,stroke:#fb923c,color:#92400e
    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
```

**Tool Execution Details:**
```json5
{
  "toolName": "exec",
  "args": {
    "command": "git status",
    "workingDir": "/home/user/.openclaw/workspace"
  },
  "sandbox": {
    "profile": "sandboxed",
    "workspaceAccess": "rw",
    "networkAccess": false,
    "allowedDomains": [],
    "timeoutMs": 30000
  },
  "result": {
    "stdout": "On branch main...",
    "stderr": "",
    "exitCode": 0,
    "executionTimeMs": 245
  }
}
```

---

## Step 3: OBSERVE — Context Update

Tool output feeds back into context for the next iteration.

```mermaid
flowchart TD
    OUT["Tool execution completes<br>stdout + result"]:::teal
    OUT --> ADD["Add to message history<br>as 'tool_result' message"]:::blue
    ADD --> TOKEN["Count new tokens added<br>to context"]:::gray
    TOKEN --> CHECK{"Context still<br>under 150K?"}:::amber
    CHECK -->|Yes| NEXT["Continue"]:::green
    CHECK -->|No| PRUNE["Prune old messages<br>keep last 3"]:::orange
    PRUNE --> NEXT

    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef orange fill:#fed7aa,stroke:#fb923c,color:#92400e
```

---

## Loop Termination Conditions

The agent loop exits when any of these occur:

| Condition | What Happens | Example |
|---|---|---|
| **User text goal achieved** | LLM outputs final answer | "Your git branch is 3 commits ahead of main" |
| **Max iterations reached** | Fail-safe after N attempts | Default: 10 iterations, then error |
| **Tool execution fails (critical)** | Halt and return error | `exec` permission denied, network unreachable |
| **User cancels** | `/cancel` or timeout interrupt | Telegram user clicks stop button |
| **Context overflow** | Compaction triggered (flush + reset) | Context >150K after pruning |

**Token Consumption Example:**

```
Iteration 1:
  - Input context: 45K tokens
  - LLM response: 0.5K tokens (text) + 0.2K (tool call)
  - Total: 45.7K

Iteration 2:
  - Previous + tool result: 46K + 2K = 48K
  - LLM response: 0.8K tokens
  - Total: 48.8K

Iteration 3:
  - Previous + new tool result: 48.8K + 1.5K = 50.3K
  - LLM response: 0.6K tokens
  - Total: 50.9K

[Loop continues until goal or token budget exceeded]
```

---

## Token Consumption Per Iteration

```mermaid
flowchart LR
    START["Start iteration"]:::gray
    CTX["Input context<br>30-50K"]:::blue
    THINK["LLM processes<br>~1-2K output"]:::green
    TOOL["Tool executes<br>result: 0.5-5K"]:::orange
    STORE["Store in history<br>+1-5K"]:::teal
    END["Net addition<br>per loop: 2-10K tokens"]:::purple

    START --> CTX
    CTX --> THINK
    THINK --> TOOL
    TOOL --> STORE
    STORE --> END

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef orange fill:#fed7aa,stroke:#fb923c,color:#92400e
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

**Typical conversation:**
- Simple task (1–2 iterations): 50–80K tokens
- Complex task (3–5 iterations): 100–150K tokens
- Research task (10+ iterations): triggers memory flush at 150K

---

## Tool Calling Mechanism

When the LLM wants to execute a tool, it returns a structured request:

```json5
{
  "type": "tool_call",
  "toolName": "web_search",
  "id": "call_abc123",
  "args": {
    "query": "Mem0 vector database 2026",
    "maxResults": 10
  }
}
```

Crispy receives this and:

1. **Parse**: Extract `toolName` and `args`
2. **Check permission**: Is this tool allowed? Does it need approval?
3. **Validate args**: Does the schema match?
4. **Execute**: Run in appropriate sandbox
5. **Capture**: Collect stdout, stderr, exit code
6. **Return**: Add result to conversation history
7. **Continue**: Send back to LLM with result message

```mermaid
flowchart TD
    REQ["Tool request<br>from LLM"]:::purple
    REQ --> ROUTE{"Which tool?"}:::amber
    ROUTE -->|exec| EX["Sandboxed exec<br>(timeout: 30s)"]:::blue
    ROUTE -->|web_search| WS["Brave API<br>(rate limit: 10/min)"]:::blue
    ROUTE -->|memory_search| MS["Vector search<br>(Crispy's memory)"]:::teal
    ROUTE -->|llm-task| LLMTASK["Side-channel LLM<br>(for classification)"]:::green
    ROUTE -->|file_read| FR["Read from workspace<br>(no execution)"]:::gray
    ROUTE -->|file_write| FW["Write to workspace<br>(approval gate)"]:::orange
    EX & WS & MS & LLMTASK & FR & FW --> RETURN["Return result<br>to context"]:::green

    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef orange fill:#fed7aa,stroke:#fb923c,color:#92400e
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
```

---

## Loop Control Flow

```yaml
# Pseudocode for the agent loop
while not task_complete:
  # THINK
  context = assemble_context(bootstrap, memory, history)
  response = llm.call(context, model=cascade_pick(fallback))

  # Interpret response
  if response.type == "text_output":
    # Goal achieved
    task_complete = true
    return response.text

  elif response.type == "tool_call":
    # ACT
    tool_result = execute_tool(response.toolName, response.args)

    # OBSERVE
    history.add({role: "assistant", content: response})
    history.add({role: "tool", content: tool_result})

    # Check termination
    if should_terminate(iterations, token_count, tool_result):
      task_complete = true
      return format_error(tool_result)

  elif response.type == "ask_user":
    # Wait for input
    user_input = await user_response(timeout=60s)
    history.add({role: "user", content: user_input})

  # Safety checks
  iterations += 1
  if iterations > MAX_ITERATIONS:
    return error("Loop limit exceeded")

  if token_count(context) > 150000:
    flush_memory()
    context = fresh_context()
```

---

## Model Cascade Fallback

If the primary model fails, Crispy automatically tries the next:

```mermaid
flowchart TD
    REQ["Request to LLM"]:::gray
    REQ --> M1["① researcher"]:::green
    M1 -->|fail| M2["② workhorse"]:::blue
    M2 -->|fail| M3["③ workhorse-code"]:::orange
    M3 -->|fail| M4["④ coder"]:::amber
    M4 -->|fail| M5["⑤ triage"]:::amber
    M5 -->|fail| M6["⑥ flash"]:::teal
    M6 -->|fail| M7["⑦ free"]:::gray
    M7 -->|fail| ERR["Error: All models failed"]:::red

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef orange fill:#fed7aa,stroke:#fb923c,color:#92400e
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

**Config:** See [[stack/L6-processing/tools]] for permission profiles.
**Model aliases:** See [[stack/L2-runtime/config-reference]] for model string → alias mappings.

---

## Agent Loop State Machine

Formal state diagram showing all transitions in the Think → Act → Observe cycle, including error recovery and termination paths.

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> ContextAssembly : Message from L5

    ContextAssembly --> LLMCall : Context packed
    LLMCall --> ParseResponse : Model responds
    LLMCall --> ErrorState : All models failed

    ParseResponse --> ToolExecution : tool_call
    ParseResponse --> SendResponse : text_output
    ParseResponse --> WaitForUser : ask_user

    ToolExecution --> UpdateContext : Result captured
    UpdateContext --> CheckTermination

    CheckTermination --> LLMCall : Continue
    CheckTermination --> Compaction : Token limit hit
    CheckTermination --> SendResponse : Goal met

    Compaction --> LLMCall : Fresh context

    WaitForUser --> ContextAssembly : User responds
    WaitForUser --> SendResponse : Timeout (60s)

    SendResponse --> Persist
    Persist --> Idle

    ErrorState --> SendResponse
```

#### Agent Loop Detail

| Phase | Steps | Key Details |
|---|---|---|
| **ContextAssembly** | LoadBootstrap → LoadMemory → LoadLogs → LoadHistory → PackContext | AGENTS/SOUL/TOOLS.md first, MEMORY.md DM-only, respect token limit |
| **LLMCall** | PrimaryModel → FallbackModel → NextFallback → AllFailed | Cascade: researcher → workhorse → coder → triage → flash → free |
| **ParseResponse** | CheckType → route by type | `text_output`, `tool_call`, or `ask_user` |
| **ToolExecution** | CheckPermission → RunSandboxed → CaptureResult | Docker sandbox, network off, 30s timeout |
| **CheckTermination** | CheckGoal → CheckIterations → CheckTokens | Goal achieved, max iterations, or >150K tokens → compaction |

---

## Why This Design?

- **Modular**: Each step (think/act/observe) is independent
- **Recoverable**: Tool failure doesn't crash the loop, just returns error
- **Transparent**: Every step logged, history preserved
- **Efficient**: Context pruning keeps token usage stable
- **Safe**: Permission gating prevents unauthorized actions

---

**Up →** [[stack/L6-processing/_overview]]
**Related →** [[stack/L6-processing/tools]]
