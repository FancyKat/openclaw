# design-brand-audit.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/design/pipelines.md

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
