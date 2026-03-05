# fitness-program-generator.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/fitness/pipelines.md

name: fitness-program-generator
description: >
  Designs a multi-week training program using the agent loop with memory of the user's
  goals, experience, equipment, and injury history. Spawns an agent session for complex
  creative composition with periodization logic. Requires approval before saving. Three
  agent turns: structure → detail → finalize. Target latency 10–20s (complex composition).
args:
  raw_message:
    default: ""
steps:
  - id: parse_params
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Extract program design parameters: {goal, duration_weeks, frequency_per_week, equipment: [], experience_level: beginner|intermediate|advanced, injuries: string|null}","input":"${raw_message}"}'
  - id: load_context
    command: exec --json --shell 'openclaw memory recall "fitness:goals" 2>/dev/null; openclaw memory recall "fitness:workout-log" 2>/dev/null | jq "[.[-10:]]"'
  - id: generate_program
    command: openclaw.invoke --tool sessions_spawn --action run --args-json '{"prompt":"Design a ${parse_params_json.duration_weeks}-week training program. Use periodization (progressive overload, deload weeks). Include: weekly structure, exercise selection, rep/set schemes, progression logic, and coaching notes. Account for experience level and any injuries.","context":"$load_context_json","model":"workhorse"}'
    timeout: 45000
  - id: review
    command: approve --preview-from-stdin --prompt 'Review this training program before saving to memory.'
    stdin: $generate_program.stdout
    approval: required
  - id: save_program
    command: exec --shell 'openclaw memory store "fitness:program:current" "$generate_program_json"'
    condition: $review.approved
