# project-routing.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L6-processing/coding/project-routing.md

flowchart TD
    MSG["User message"]:::gray
    MSG --> DETECT{"Project mentioned<br>or current?"}:::amber
    DETECT -->|Explicit /project| SELECT["User selects project"]:::blue
    DETECT -->|Keywords| INFER["Detect from message<br>keywords/context"]:::blue
    SELECT & INFER --> MATCH["Look up in<br>projects.json"]:::teal
    MATCH --> LOAD["Load project context:<br>env, config, team, standards"]:::green
    LOAD --> ACTIONS["Register quick-actions<br>for this project"]:::purple
    ACTIONS --> READY["Crispy is project-aware"]:::green

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

---

## projects.json — Registry

Keep a registry of all projects at `~/.openclaw/workspace/projects.json`:

> **Important:** All `path` values are **relative to the workspace root** (`~/.openclaw/workspace/`). This ensures the sandbox container can access them at `/workspace/projects/{name}/`. See [[stack/L1-physical/filesystem]] for setup.

```json5
{
  "projects": [
    {
      "id": "crispy",
      "name": "Crispy Kitsune Stack",
      "keywords": ["crispy", "cks", "stack", "architecture", "openclaw"],
      "description": "The main CKS documentation vault",
      "path": "projects/crispy-kitsune",         // relative to workspace
      "team": ["marty"],
      "standards": {
        "language": "markdown, yaml",
        "docFormat": "Obsidian",
        "gitBranch": "main",
        "reviewProcess": "self-review"
      },
      "context": {
        "bootstrap": ["AGENTS.md", "SOUL.md", "TOOLS.md"],
        "focusAreas": ["architecture", "L6-processing", "pipelines"],
        "stackLayers": ["L1-Model", "L2-Memory", "L3-Tools", "L4-Skills", "L5-Interfaces", "L6-Processing"]
      },
      "quickActions": {
        "/stack": "Show stack overview",
        "/layer L6": "Show L6 documentation",
        "/research": "Spawn research sub-agent",
        "/brief": "Morning digest pipeline",
        "/workspace": "Check workspace health"
      }
    },
    {
      "id": "project-x",
      "name": "Project X",
      "keywords": ["project-x", "proj-x", "x project"],
      "description": "Backend service for X",
      "path": "projects/project-x",              // relative to workspace
      "team": ["alice", "bob", "marty"],
      "standards": {
        "language": "python, go",
        "docFormat": "Markdown",
        "gitBranch": "develop",
        "reviewProcess": "PR with 2 approvals"
      },
      "context": {
        "bootstrap": ["README.md", "ARCHITECTURE.md", ".env.example"],
        "focusAreas": ["api", "database", "auth"],
        "dependencies": ["postgres", "redis", "rabbitmq"]
      },
      "quickActions": {
        "/test": "Run test suite",
        "/deploy": "Deploy checklist",
        "/pr": "PR template",
        "/docs": "API documentation",
        "/status": "Project status board"
      }
    },
    {
      "id": "data-platform",
      "name": "Data Platform",
      "keywords": ["data", "warehouse", "analytics", "platform"],
      "description": "Company data warehouse and analytics",
      "path": "projects/data-platform",           // relative to workspace
      "team": ["charlie", "diana", "marty"],
      "standards": {
        "language": "sql, python, dbt",
        "docFormat": "Markdown",
        "gitBranch": "main",
        "reviewProcess": "dbt slim CI"
      },
      "context": {
        "bootstrap": ["README.md", "dbt_project.yml", "schema.yml"],
        "focusAreas": ["models", "tests", "docs", "schema"],
        "dependencies": ["snowflake", "dbt", "fivetran"]
      },
      "quickActions": {
        "/dbt": "dbt commands (run, test, docs)",
        "/schema": "Schema documentation",
        "/lineage": "Data lineage diagram",
        "/quality": "Data quality checks"
      }
    }
  ]
}
```

---

## Project Detection Flow

### 1. Explicit Selection

```
User: "/project crispy"

Crispy:
✅ Switched to Crispy Kitsune Stack

Now available:
/stack — Show stack overview
/layer L6 — Show L6 documentation
/research — Spawn research sub-agent
/brief — Morning digest pipeline
/workspace — Check workspace health

What can I help with?
```

### 2. Keyword Detection

```
User: "How does the research pipeline work?"

Crispy:
[Analyzes message for keywords: "research", "pipeline"]
[Finds matches in projects.json]
[Detects: Crispy project (strongest match)]
[Loads: AGENTS.md, SOUL.md, TOOLS.md]
[Activates: /stack, /layer, /research, /brief, /workspace]

[Answers about research pipeline]
```

### 3. Context Persistence

Once a project is selected, it persists until:
- User switches with `/project other-project`
- Session ends
- Idle timeout (2 hours)

---

## Project Context Structure

Each project loads:

```yaml
project_context:
  id: "crispy"
  name: "Crispy Kitsune Stack"

  # Metadata
  team: ["marty"]
  standards:
    language: "markdown, yaml"
    gitBranch: "main"

  # Bootstrap files (loaded into context at project switch)
  bootstrap:
    - "AGENTS.md"
    - "SOUL.md"
    - "TOOLS.md"

  # Project-specific skills to activate
  skills:
    - "engineering:documentation"
    - "engineering:system-design"

  # Quick-action commands
  quickActions:
    /stack: "Show stack overview"
    /layer: "Show specific layer"
    /research: "Spawn research sub-agent"
```

---

## Quick-Actions per Project

Each project can define custom Telegram commands that only work in that project context:

```mermaid
flowchart TD
    PROJECT["Project selected:<br>Crispy Stack"]:::purple
    PROJECT --> ACTIONS["Quick-actions registered"]:::blue
    ACTIONS --> CMD1["/stack — Layer overview"]:::green
    ACTIONS --> CMD2["/layer — Show L1-L6"]:::green
    ACTIONS --> CMD3["/research — Sub-agent"]:::green
    ACTIONS --> CMD4["/brief — Morning digest"]:::green
    ACTIONS --> CMD5["/workspace — Health check"]:::green

    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
```

**Crispy Project Quick-Actions:**
- `/stack` — Show stack overview
- `/layer L6` — Show specific layer (L1-L6)
- `/research mem0 graph relationships` — Spawn research sub-agent
- `/brief` — Morning digest pipeline
- `/workspace` — Check workspace health

**Project X Quick-Actions:**
- `/test` — Run test suite
- `/deploy` — Deployment checklist
- `/pr` — PR template
- `/docs` — API documentation
- `/status` — Project status board

**Data Platform Quick-Actions:**
- `/dbt run` — Run dbt models
- `/schema` — Show schema documentation
- `/lineage` — Draw data lineage
- `/quality` — Run quality checks

---

## Project Routing Pipeline

The project detection uses a simple lobster pipeline:

```yaml
name: project-routing
description: >
  Detects which project a message refers to by matching against projects.json registry.
  Supports explicit /project selection and keyword-based inference via triage LLM call.
  Outputs detected projectId + confidence. Triggers on every message when project context
  is unset. Used by the coding focus mode to load project-specific bootstrap files.
args:
  message:
    required: true
  explicit_project:
    default: null
steps:
  - id: load_projects
    command: exec --json --shell 'cat ~/.openclaw/workspace/projects.json | jq .projects'
    timeout: 5000

  - id: detect
    command: openclaw.invoke --tool llm-task --action json \
      --args-json '{
        "prompt": "Given this message and list of projects, detect which project is being referenced. Return the project ID if found, null if none match.",
        "input": "Message: $message\n\nProjects:\n$load_projects_stdout",
        "schema": {
          "type": "object",
          "properties": {
            "projectId": {"type": ["string","null"]},
            "confidence": {"type": "number"},
            "keywords": {"type": "array","items":{"type":"string"}}
          }
        }
      }'
    stdin: $load_projects.stdout
    timeout: 10000

  - id: select
    command: exec --json --shell |
      if [ -n "$explicit_project" ]; then
        echo "{\"projectId\":\"$explicit_project\",\"source\":\"explicit\"}"
      else
        echo "$detect_json" | jq '{projectId:.projectId,source:"inferred"}'
      fi
