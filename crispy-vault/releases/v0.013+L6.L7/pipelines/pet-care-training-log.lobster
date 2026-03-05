# pet-care-training-log.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/pet-care/pipelines.md

name: pet-care-training-log
description: >
  Logs training milestones, commands learned, and session notes. Stores structured
  training history with command name, mastery level, and date achieved. Provides
  a commands inventory on request. Zero LLM calls for log/view; one flash call for
  session note summarization. Target latency 200–500ms.
args:
  raw_message:
    default: ""
  pet_name:
    default: ""
steps:
  - id: parse_training
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this training update. Return: {action: \"log\"|\"view\", pet_name: string, command: string|null, mastery: \"learning\"|\"practicing\"|\"mastered\"|null, session_notes: string|null}","input":"${raw_message}"}'
  - id: load_history
    command: exec --json --shell 'openclaw memory recall "pets:${pet_name}:training" 2>/dev/null || echo "[]"'
  - id: add_entry
    command: exec --json --shell 'jq -n --argjson h "$load_history_json" --argjson e "$parse_training_json" "[\$h[], {command: \$e.command, mastery: \$e.mastery, date: \"$(date +%Y-%m-%d)\", notes: \$e.session_notes}] | unique_by(.command + .date)"'
    condition: $parse_training.json.action == "log"
  - id: save_history
    command: exec --shell 'openclaw memory store "pets:${pet_name}:training" "$add_entry_json"'
    condition: $parse_training.json.action == "log"
  - id: format_response
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Respond to this training log update. Celebrate the milestone! Show the full list of known commands with mastery level emoji (🌱 learning, ✏️ practicing, ✅ mastered). Suggest the next command to work on.","input":{"new_entry":"$parse_training_json","history":"$add_entry_json"}}'
