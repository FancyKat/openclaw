# pet-care-appointment.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/pet-care/pipelines.md

name: pet-care-appointment
description: >
  Manages vet and grooming appointments. Handles add/view/remind actions. Parses the
  appointment details, stores in memory with a reminder flag, and confirms. Sets a
  reminder for 24 hours before the appointment via memory tag. Zero LLM calls for
  add/view; one flash call for natural language parsing. Target latency 300–600ms.
args:
  raw_message:
    default: ""
  pet_name:
    default: ""
steps:
  - id: parse_appointment
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this appointment request. Return: {action: \"add\"|\"view\"|\"cancel\", pet_name: string, type: \"vet\"|\"grooming\"|\"other\", date: \"YYYY-MM-DD\", time: \"HH:MM\"|null, notes: string|null}","input":"${raw_message}"}'
  - id: load_appointments
    command: exec --json --shell 'openclaw memory recall "pets:${pet_name}:appointments" 2>/dev/null || echo "[]"'
  - id: add_appointment
    command: exec --json --shell 'jq -n --argjson appts "$load_appointments_json" --argjson new "$parse_appointment_json" "[\$appts[], (\$new + {id: \"apt-$(date +%s)\", reminder_set: true})]"'
    condition: $parse_appointment.json.action == "add"
  - id: save_appointments
    command: exec --shell 'openclaw memory store "pets:${pet_name}:appointments" "$add_appointment_json"'
    condition: $parse_appointment.json.action == "add"
  - id: format_response
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Confirm this appointment action. For add: state date, type, and that a reminder will be sent the day before. Be brief and warm.","input":{"action":"$parse_appointment_json.action","appointment":"$parse_appointment_json","all_appointments":"$load_appointments_json"}}'
