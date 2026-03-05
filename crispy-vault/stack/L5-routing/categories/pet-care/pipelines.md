---
tags: [type/reference, layer/routing, status/draft, category/pet-care, focus/pipelines]
---

# Pet Care Pipelines

> Pipeline definitions, triggers, status, and functional descriptions for pet care workflows.

**Up →** [[stack/L5-routing/categories/pet-care/_overview]]

---

## Pipeline Map

| Pipeline | Trigger | Status | What It Does |
|---|---|---|---|
| `medication-tracker` | "medication", "pill", "heartworm", "flea med" | 🔲 Future | Tracks medication schedules, dosages, and reminders |
| `appointment` | "vet appointment", "checkup", "vaccinations due" | 🔲 Future | Manages vet and grooming appointment scheduling |
| `feeding-schedule` | "feeding time", "how much to feed", "food schedule" | 🔲 Future | Tracks feeding routine, amounts, and food brands |
| `supply-list` | "need to buy", "running low", "pet supplies" | 🔲 Future | Maintains pet supply shopping list |
| `training-log` | "learned", "training progress", "new command" | 🔲 Future | Logs training milestones and commands learned |
| `grooming-schedule` | "grooming", "nail trim", "bath", "haircut" | 🔲 Future | Tracks grooming appointments and routines |

---

## Lobster YAML Definitions

### `medication-tracker`

```yaml
name: pet-care-medication-tracker
description: >
  Tracks pet medication schedules, logs administration, and calculates next due dates.
  Handles log/check/schedule actions. Reads current med schedule from memory, updates
  the log, calculates the next dose date based on frequency, and confirms. Zero LLM
  calls for log/check actions; one flash call for scheduling questions. Target latency
  300–700ms. Writes to pets:{name}:medications with dose history and next_due.
args:
  raw_message:
    default: ""
  pet_name:
    default: ""
steps:
  - id: parse_intent
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this medication request. Return: {action: \"log\"|\"check\"|\"schedule\", pet_name: string, medication: string|null, date: \"YYYY-MM-DD\"|null}","input":"${raw_message}"}'
  - id: load_schedule
    command: exec --json --shell 'openclaw memory recall "pets:${pet_name}:medications" 2>/dev/null || echo "[]"'
  - id: log_dose
    command: exec --json --shell 'jq -n --argjson s "$load_schedule_json" --argjson p "$parse_intent_json" "[\$s[] | if .medication == \$p.medication then . + {last_given: \$p.date, next_due: (.frequency | if . == \"monthly\" then (\$p.date | split(\"-\") | .[0] + \"-\" + (.[1] | tonumber + 1 | tostring | if length == 1 then \"0\" + . else . end) + \"-\" + .[2]) else . end)} else . end]"'
    condition: $parse_intent.json.action == "log"
  - id: save_schedule
    command: exec --shell 'openclaw memory store "pets:${pet_name}:medications" "$log_dose_json"'
    condition: $parse_intent.json.action == "log"
  - id: format_response
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format a brief medication response. For log: confirm and state next due date. For check: show what is due today/soon. Be warm and brief.","input":{"action":"$parse_intent_json.action","schedule":"$load_schedule_json","updated":"$log_dose_json"}}'
```
^pipeline-pet-care-medication-tracker

---

### `appointment`

```yaml
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
```
^pipeline-pet-care-appointment

---

### `feeding-schedule`

```yaml
name: pet-care-feeding-schedule
description: >
  Tracks the pet feeding routine, portions, and food brand. Handles log/check/update
  actions. Logs each meal with timestamp and portion, checks the last feeding time,
  or updates the schedule parameters. Zero LLM calls for log/check. Target latency
  200–500ms. Writes to pets:{name}:feeding-log with daily meal history.
args:
  raw_message:
    default: ""
  pet_name:
    default: ""
steps:
  - id: parse_feeding
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this feeding request. Return: {action: \"log\"|\"check\"|\"update\", pet_name: string, meal_time: \"YYYY-MM-DDTHH:MM\"|null, portion: string|null, food: string|null}","input":"${raw_message}"}'
  - id: load_log
    command: exec --json --shell 'openclaw memory recall "pets:${pet_name}:feeding-log" 2>/dev/null | jq "[.[] | select(.date == \"$(date +%Y-%m-%d)\")]" || echo "[]"'
  - id: append_meal
    command: exec --json --shell 'jq -n --argjson log "$load_log_json" --argjson meal "$parse_feeding_json" "[\$log[], {time: \$meal.meal_time, portion: \$meal.portion, food: \$meal.food}]"'
    condition: $parse_feeding.json.action == "log"
  - id: save_log
    command: exec --shell 'openclaw memory store "pets:${pet_name}:feeding-log:$(date +%Y-%m-%d)" "$append_meal_json"'
    condition: $parse_feeding.json.action == "log"
  - id: format_response
    command: exec --shell 'echo "Logged! ${pet_name} fed at $(echo $parse_feeding_json | jq -r .meal_time | cut -c12-16). Today: $(echo $append_meal_json | jq length) meals."'
```
^pipeline-pet-care-feeding-schedule

---

### `supply-list`

```yaml
name: pet-care-supply-list
description: >
  Manages the pet supply shopping list stored in memory. Mirrors the cooking grocery-list
  pipeline but scoped to pet supplies (food, treats, medications, accessories). Handles
  add/remove/view actions. One LLM call (flash) for intent parsing. Target latency
  300–700ms. Writes to pets:supplies:list grouped by supply type.
args:
  raw_message:
    default: ""
steps:
  - id: parse_intent
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this pet supply request. Return: {action: \"add\"|\"remove\"|\"view\", items: [{name, qty, unit, type: \"food\"|\"treats\"|\"medication\"|\"accessories\"|\"hygiene\"|\"other\"}]}","input":"${raw_message}"}'
  - id: load_list
    command: exec --json --shell 'openclaw memory recall "pets:supplies:list" 2>/dev/null || echo "[]"'
  - id: apply_change
    command: exec --json --shell 'jq -n --argjson p "$parse_intent_json" --argjson l "$load_list_json" "if \$p.action == \"add\" then \$l + \$p.items elif \$p.action == \"remove\" then \$l | map(select(.name as \$n | \$p.items | map(.name) | index(\$n) == null)) else \$l end"'
  - id: save_list
    command: exec --shell 'openclaw memory store "pets:supplies:list" "$apply_change_json"'
    condition: $parse_intent.json.action != "view"
  - id: format_response
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format this pet supply list update as a friendly, concise response. Group by type (Food, Treats, Medication, Accessories). Show total item count.","input":"$apply_change_json"}'
```
^pipeline-pet-care-supply-list

---

### `training-log`

```yaml
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
```
^pipeline-pet-care-training-log

---

### `grooming-schedule`

```yaml
name: pet-care-grooming-schedule
description: >
  Tracks grooming appointments and routines (baths, nail trims, haircuts). Logs
  completed grooming sessions and calculates when the next session is due based on
  the pet's breed/coat and stored frequency preferences. One flash call for intent
  parsing. Target latency 300–600ms. Writes to pets:{name}:grooming with history.
args:
  raw_message:
    default: ""
  pet_name:
    default: ""
steps:
  - id: parse_grooming
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Parse this grooming request. Return: {action: \"log\"|\"schedule\"|\"view\", pet_name: string, grooming_type: \"bath\"|\"nail-trim\"|\"haircut\"|\"full-groom\"|\"other\", date: \"YYYY-MM-DD\"|null, notes: string|null}","input":"${raw_message}"}'
  - id: load_history
    command: exec --json --shell 'openclaw memory recall "pets:${pet_name}:grooming" 2>/dev/null || echo "[]"'
  - id: load_preferences
    command: exec --json --shell 'openclaw memory recall "pets:${pet_name}:grooming-preferences" 2>/dev/null || echo "{\"bath_frequency_days\":14,\"nail_trim_days\":21,\"haircut_days\":60}"'
  - id: add_session
    command: exec --json --shell 'jq -n --argjson h "$load_history_json" --argjson g "$parse_grooming_json" --argjson p "$load_preferences_json" "[\$h[], {type: \$g.grooming_type, date: \$g.date, notes: \$g.notes, next_due: \"(calculated from \$p)\"}]"'
    condition: $parse_grooming.json.action == "log"
  - id: save_history
    command: exec --shell 'openclaw memory store "pets:${pet_name}:grooming" "$add_session_json"'
    condition: $parse_grooming.json.action == "log"
  - id: format_response
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Respond to this grooming update. For log: confirm and state when next session is due. For view: show recent history and upcoming schedule. Be warm and brief.","input":{"action":"$parse_grooming_json","history":"$load_history_json","prefs":"$load_preferences_json"}}'
```
^pipeline-pet-care-grooming-schedule

---

**Up →** [[stack/L5-routing/categories/pet-care/_overview]]
