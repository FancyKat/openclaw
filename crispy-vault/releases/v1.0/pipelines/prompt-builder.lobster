# prompt-builder.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L6-processing/pipelines/prompt-builder.md

flowchart LR
    subgraph WITHOUT["Without Prompt Builder"]
        RAW["'fix the config'"]:::gray
        RAW --> LLM1["Full LLM burns<br/>~2000 tokens on<br/>context gathering"]:::red
        LLM1 --> WORK1["Then does the<br/>actual work<br/>(~3000 tokens)"]:::red
    end

    subgraph WITH["With Prompt Builder"]
        RAW2["'fix the config'"]:::gray
        RAW2 --> PB["Prompt Builder<br/>~200 tokens (cheap model)<br/>adds context + file paths"]:::blue
        PB --> LLM2["Full LLM starts<br/>with rich context<br/>(~1500 tokens saved)"]:::green
    end

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
```

## How It Works

The prompt builder takes three inputs and produces one output:

```mermaid
flowchart TD
    subgraph INPUTS["Inputs"]
        MSG["Raw user message<br/>'fix the config'"]:::gray
        ENV["Intent envelope<br/>(from intent-finder)<br/>type: action, subtype: debug"]:::blue
        CTX["Session context<br/>(recent messages,<br/>active project, errors)"]:::purple
    end

    subgraph BUILDER["Prompt Builder"]
        RESOLVE["① Resolve ambiguities<br/>'config' → openclaw.json"]:::blue
        INJECT["② Inject file paths<br/>~/.openclaw/openclaw.json<br/>+ recent error logs"]:::blue
        FRAME["③ Frame the task<br/>'Debug the openclaw.json<br/>config. Recent error: ...'"]:::blue
        SUGGEST["④ Suggest approach<br/>'Run openclaw doctor first,<br/>then check the models section'"]:::blue
    end

    subgraph OUTPUT["Output"]
        PROMPT["Enriched prompt<br/>ready for the LLM"]:::green
    end

    MSG --> RESOLVE
    ENV --> RESOLVE
    CTX --> RESOLVE
    RESOLVE --> INJECT --> FRAME --> SUGGEST --> PROMPT

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
```

## The Four Enrichment Steps

### ① Resolve Ambiguities

Map vague references to specific entities using project knowledge:

| Raw Reference | Resolved To | How |
|---|---|---|
| "the config" | `~/.openclaw/openclaw.json` | Intent = debug + "config" keyword → most likely openclaw.json |
| "the bot" | Telegram bot (Crispy) | Active channel = Telegram, context = bot setup |
| "the error" | Last error from session history | Check recent messages for error patterns |
| "the API" | User profile API (from MEMORY.md) | Recent planning session was about user profiles |
| "the project" | crispy-kitsune repo | Active project from session context |
| "that thing we discussed" | Guardrails output validator | L7 memory search for recent discussion topics |

**Resolution strategy:**
- Check `context_hints` from the intent envelope
- Search last 5 messages in session for related nouns
- Check MEMORY.md for recent project/topic references
- If still ambiguous → don't guess, add a clarification prompt

### ② Inject File Paths

Based on the resolved entities, inject relevant file paths so the LLM knows where to look:

```yaml
# Example: "fix the config" → inject these paths
files:
  primary:
    - "~/.openclaw/openclaw.json"      # The main config file
  related:
    - "~/.openclaw/.env"                # Environment variables
    - "workspace/AGENTS.md"             # Agent bootstrap (references config)
  recent_errors:
    - "Last error (2 min ago): 'Invalid model alias: old-workhorse'"
  diagnostic:
    - "Run: openclaw doctor"            # Suggested diagnostic command
```

## Pipeline YAML

```yaml
name: prompt-builder
description: >
  Context enrichment pipeline. Takes raw user message and intent envelope, resolves
  vague references to specific files/entities using session context and memory, injects
  relevant file paths and recent errors, and frames the task with a suggested approach.
  Saves ~1500 tokens per agent turn by pre-computing context gathering. Runs between
  intent classification and agent loop for action and assistance intents.
args:
  message:
    required: true
    description: "Raw user message"
  intent:
    default: "{}"
    description: "Intent envelope JSON from intent-finder"
steps:
  - id: recall_context
    command: exec --json --shell |
      openclaw memory recall "session:recent-context" 2>/dev/null | \
      jq '{active_project: .project, recent_files: .files[-5:], recent_errors: .errors[-3:]}' \
      2>/dev/null || echo '{"active_project":null,"recent_files":[],"recent_errors":[]}'
    timeout: 5000

  - id: resolve
    command: openclaw.invoke --tool llm-task --action json \
      --args-json '{
        "model": "flash",
        "maxTokens": 400,
        "prompt": "Resolve vague references in this message to specific files/entities. Message: \"$message\". Intent: $intent. Context: $recall_context_stdout. Return JSON: {resolved_entities: {term: file_or_entity}, primary_files: [string], suggested_approach: string, clarification_needed: bool, clarification_question: string|null}",
        "schema": {"type":"object","properties":{"resolved_entities":{"type":"object"},"primary_files":{"type":"array"},"suggested_approach":{"type":"string"},"clarification_needed":{"type":"boolean"},"clarification_question":{"type":["string","null"]}}}
      }'
    timeout: 15000

  - id: build_prompt
    command: exec --shell |
      python3 -c "
import json, sys
msg = '''$message'''
resolved = json.loads('''$resolve_stdout''')
intent = json.loads('''$intent''' or '{}')
files = resolved.get('primary_files', [])
approach = resolved.get('suggested_approach', '')
files_str = '\n'.join(f'  - {f}' for f in files) if files else '  (none identified)'
print(f'''Task: {msg}

Intent: {intent.get(\"class\", \"unknown\")} / {intent.get(\"subtype\", \"\")}

Relevant files:
{files_str}

Suggested approach: {approach}''')
"
