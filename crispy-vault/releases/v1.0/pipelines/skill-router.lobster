# skill-router.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L6-processing/pipelines/skill-router.md

flowchart TD
    MSG["User message"]:::gray
    MSG --> LIST["Load skills inventory<br>from TOOLS.md"]:::blue
    LIST --> CLASSIFY["Classify intent<br>llm-task, triage model"]:::amber
    CLASSIFY --> MATCH{"Skill match<br>confidence > 0.5?"}:::amber
    MATCH -->|Yes| LOAD["Return skill name<br>+ confidence score"]:::green
    MATCH -->|No| DEFAULT["No skill needed<br>use AGENTS.md rules"]:::blue

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
```

## When It Fires

The skill router runs when Crispy is about to respond, if:
- User message might benefit from a skill
- Multiple skills could apply (pick best one)
- Need to decide if a skill is needed at all

## Skill Trigger Map

Quick reference for the router's classification:

| Intent Pattern | Best Skill | Confidence |
|---|---|---|
| **Code/Review** | | |
| "review this code", "check this PR" | `engineering:code-review` | High |
| "is this safe?", "security review" | `engineering:code-review` | High |
| **Debug/Fix** | | |
| "help me debug", "this isn't working" | `engineering:debug` | High |
| "find the bug", "what's wrong" | `engineering:debug` | High |
| **Design** | | |
| "design a system for", "how should we architect" | `engineering:system-design` | High |
| "API design", "service architecture" | `engineering:system-design` | High |
| **Testing** | | |
| "how should we test", "write tests for" | `engineering:testing-strategy` | High |
| "test plan", "coverage report" | `engineering:testing-strategy` | High |
| **Documentation** | | |
| "write docs for", "create a README" | `engineering:documentation` | High |
| "write a runbook", "API docs" | `engineering:documentation` | High |
| **Incidents** | | |
| "production is down", "we have an incident" | `engineering:incident-response` | High |
| "SEV1", "critical issue", "postmortem" | `engineering:incident-response` | High |
| **Tech Debt** | | |
| "tech debt audit", "what should we refactor" | `engineering:tech-debt` | High |
| "code health", "cleanup needed" | `engineering:tech-debt` | Medium |
| **Deploy** | | |
| "ready to deploy?", "pre-deploy check" | `engineering:deploy-checklist` | High |
| **Data Analysis** | | |
| "explore this dataset", "what's in this CSV?" | `data:data-exploration` | High |
| "profile this data", "data quality" | `data:data-exploration` | High |
| **Visualization** | | |
| "make a chart", "visualize this" | `data:data-visualization` | High |
| "create a graph", "plot this" | `data:data-visualization` | High |
| **SQL/Queries** | | |
| "write a query", "optimize this SQL" | `data:sql-queries` | High |
| "translate this query" | `data:sql-queries` | High |
| **Statistics** | | |
| "is this significant?", "run a t-test" | `data:statistical-analysis` | High |
| "find correlations", "hypothesis test" | `data:statistical-analysis` | High |
| **Dashboards** | | |
| "build a dashboard", "create a report" | `data:interactive-dashboard-builder` | High |
| "interactive charts" | `data:interactive-dashboard-builder` | Medium |
| **Data QA** | | |
| "QA this analysis", "check for errors" | `data:data-validation` | High |
| "validate the data" | `data:data-validation` | High |
| **Gaming** | | |
| "Steam", "my games" | `sag` | High |
| "GOG", "game library" | `gog` | High |
| **No Skill** | | |
| General conversation | None | N/A |
| Simple questions | None | N/A |
| Ambiguous ("help me") | None | Low |

## Confidence Threshold

The router uses a **0.5 confidence threshold**. This prevents:

- **False positives**: Using a skill that doesn't apply
- **Over-specialization**: Avoiding generic conversation

## Token Cost

The skill router is optimized for cost:

- Uses **triage model** (cheapest, fast)
- Runs only when needed
- Minimal context (just message + skill list)
- Quick decision (< 5 second response time)

**Cost per route:** ~0.05¢

## Config

Add to `openclaw.json`:

```json5
{
  "skillRouter": {
    "enabled": true,
    "confidenceThreshold": 0.5,
    "model": "triage",
    "timeout": 15000
  }
}
```

## Pipeline YAML

```yaml
name: skill-router
description: >
  Intent-to-skill classification pipeline. Loads available skill list from TOOLS.md,
  classifies user message with triage LLM at 0.5 confidence threshold to prevent false
  positives, and returns the best matching skill name. Returns null when no skill meets
  threshold — falls back to base AGENTS.md behavior. Optimized for low cost: triage
  model only, ~0.05¢ per route.
args:
  message:
    required: true
    description: "Raw user message to classify"
steps:
  - id: load_skills
    command: exec --json --shell |
      grep -o '"[a-z][a-z-]*:[a-z][a-z-]*"' ~/.openclaw/workspace/TOOLS.md 2>/dev/null | \
      sort -u | tr -d '"' | \
      jq -Rn '[inputs]'
    timeout: 5000

  - id: classify
    command: openclaw.invoke --tool llm-task --action json \
      --args-json '{
        "model": "triage",
        "maxTokens": 100,
        "prompt": "Match this message to the best skill from the list. Only match if confidence >= 0.5. Message: \"$message\". Available skills: $load_skills_stdout. Return JSON: {skill: string|null, confidence: number, reason: string}",
        "schema": {
          "type": "object",
          "properties": {
            "skill": {"type": ["string","null"]},
            "confidence": {"type": "number"},
            "reason": {"type": "string"}
          }
        }
      }'
    timeout: 10000

  - id: result
    command: exec --json --shell |
      python3 -c "
import json
r = json.loads('''$classify_stdout''')
if r['confidence'] >= 0.5 and r['skill']:
  print(json.dumps({'skill': r['skill'], 'confidence': r['confidence']}))
else:
  print(json.dumps({'skill': None, 'confidence': r['confidence']}))
"
