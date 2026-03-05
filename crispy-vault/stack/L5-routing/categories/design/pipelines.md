---
tags: [type/reference, layer/routing, status/draft, category/design, focus/pipelines]
---

# Design Pipelines

> Pipeline definitions, trigger patterns, status, and capabilities for design workflows.

**Up →** [[stack/L5-routing/categories/design/_overview]]

---

## Pipeline Map

| Pipeline | Trigger | Status | What It Does |
|---|---|---|---|
| `pptx` | "presentation", "slide deck", "pitch deck" | ✅ Active | PowerPoint creation and editing via skill |
| `canvas-design` | "poster", "banner", "visual design" | ✅ Active | Visual asset creation via canvas-design skill |
| `algorithmic-art` | "generative art", "pattern", "algorithmic" | ✅ Active | Code-based generative art via skill |
| `brand-audit` | "brand check", "on brand?", "guidelines review" | 🔲 Future | Checks visual assets against stored brand guidelines |

*Design is unique among categories — it has three active skills from day one (pptx, canvas-design, algorithmic-art). Most design intents go through the agent loop with creative mode, using skills as tools.*

---

## Skill Integration Notes

Design is the most skill-heavy category. Three skills are available immediately:
- `canvas-design` — For creating visual assets (posters, banners, etc.)
- `algorithmic-art` — For generative/code-based visual art
- `pptx` — For presentations and slide decks
- `brand-guidelines` — For Anthropic-specific brand application (if relevant)

The agent should load the appropriate skill when the Focus Tree leads to a creative action.

---

## Lobster YAML Definitions

### `brand-audit`

```yaml
name: design-brand-audit
description: >
  Audits visual assets or design decisions against the user's stored brand guidelines.
  Loads brand memory (colors, fonts, style direction, accessibility standards), evaluates
  the provided asset description or design decision against the guidelines, and returns a
  structured audit report with alignment score, issues found, and recommended fixes. One
  LLM call (main model) for analysis. Target latency 1.5–3s. Falls back to agent loop
  if brand memory is empty.
args:
  asset_description:
    default: ""
steps:
  - id: load_brand
    command: exec --json --shell 'openclaw memory recall "design:brand" 2>/dev/null || echo "{}"'
  - id: check_brand_empty
    command: exec --json --shell 'echo "$load_brand_json" | jq ". == {} or . == null"'
  - id: audit
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"workhorse","prompt":"Audit this design asset against the brand guidelines. Return: {alignment_score: 0-100, issues: [{area: string, description: string, severity: \"low\"|\"medium\"|\"high\"}], recommendations: [{description: string, example: string}], summary: string}","input":{"asset":"${asset_description}","brand_guidelines":"$load_brand_json"}}'
    condition: $check_brand_empty.json == false
  - id: no_brand_fallback
    command: exec --shell 'echo "No brand guidelines found in memory. Please share your brand guidelines first and I will save them, or describe the guidelines in your message."'
    condition: $check_brand_empty.json == true
  - id: format_report
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format this brand audit report as a clear, actionable response. Show alignment score, list issues by severity (🔴 high, 🟡 medium, 🟢 low), then recommendations. Keep it professional but constructive.","input":"$audit_json"}'
    condition: $check_brand_empty.json == false
```
^pipeline-design-brand-audit
