# intent-finder.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L6-processing/pipelines/intent-finder.md

flowchart TD
    MSG["Raw user message"]:::gray

    subgraph LAYER1["Layer 1: Trigger Word Scan (0 tokens)"]
        TW["Pattern match against<br/>trigger word registry"]:::green
        TW_RESULT{"Clear match?"}:::amber
    end

    subgraph LAYER2["Layer 2: Triage Model (~200 tokens)"]
        TRIAGE["DeepSeek v3.2<br/>classify intent + confidence"]:::blue
    end

    subgraph OUTPUT["Structured Output"]
        RESULT["Intent envelope:<br/>type, class, subtype,<br/>confidence, context hints"]:::purple
    end

    MSG --> TW --> TW_RESULT
    TW_RESULT -->|"Yes (60-70%)"| OUTPUT
    TW_RESULT -->|"No / ambiguous"| TRIAGE
    TRIAGE --> OUTPUT
    OUTPUT --> NEXT["→ prompt-builder.lobster<br/>or → message router"]:::amber

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
```

## The Intent Envelope

Every message that passes through the intent finder gets an "intent envelope" — a structured JSON object that downstream pipelines consume:

```json5
{
  // Level 1: What kind of ask (from trigger words or triage)
  "type": "action",              // informational | assistance | action | creative | meta

  // Level 2: Specific intent (from triage model, null if trigger-only)
  "class": "project_work",      // command | project_work | status_check | etc.

  // Sub-type for action intents
  "subtype": "debug",           // toggle | execute | modify | research | debug | null

  // Confidence in the classification
  "confidence": 0.85,

  // Where the classification came from
  "source": "trigger_words",    // trigger_words | triage_model | fallback

  // Extracted entities
  "project_name": "crispy-kitsune",
  "urgency": "normal",          // low | normal | high

  // Keywords/entities for prompt builder
  "context_hints": ["config", "sandbox", "docker"],

  // Should we skip routing and go straight to agent loop?
  "escalate_to_agent": false
}
```

## Pipeline YAML

```yaml
name: intent-finder
description: >
  Two-layer intent classification pipeline. Layer 1 scans for trigger words against
  L5 registry (0 tokens, <10ms) — resolves ~60-70% of messages instantly. Layer 2
  calls triage LLM (~200 tokens, ~500ms) for ambiguous messages. Outputs a structured
  intent envelope (type, class, subtype, confidence, context_hints) consumed by
  prompt-builder and message router.
args:
  message:
    required: true
    description: "Raw user message to classify"
steps:
  - id: trigger_scan
    command: exec --json --shell |
      python3 -c "
import json, re, sys
msg = '''$message'''.lower()
# Load trigger words from L5 routing layer
try:
  import subprocess
  triggers_raw = subprocess.run(
    ['openclaw', 'focus', 'triggers', '--all', '--format', 'json'],
    capture_output=True, text=True
  ).stdout
  triggers = json.loads(triggers_raw or '{}')
except:
  triggers = {}
matched = None
confidence = 0.0
for category, words in triggers.items():
  for word in (words if isinstance(words, list) else []):
    if word.lower() in msg:
      matched = category
      confidence = 0.95
      break
  if matched: break
print(json.dumps({'matched': matched, 'confidence': confidence, 'source': 'trigger_words'}))
"
    timeout: 1000

  - id: triage_classify
    command: openclaw.invoke --tool llm-task --action json \
      --args-json '{
        "model": "triage",
        "maxTokens": 150,
        "prompt": "Classify this message intent. Message: \"$message\". Return JSON with: type (informational|assistance|action|creative|meta), class (command|project_work|status_check|question|conversation), subtype (debug|execute|modify|research|toggle|null), confidence (0-1), urgency (low|normal|high), context_hints (array of keywords), escalate_to_agent (bool).",
        "schema": {"type":"object","properties":{"type":{"type":"string"},"class":{"type":"string"},"subtype":{"type":["string","null"]},"confidence":{"type":"number"},"urgency":{"type":"string"},"context_hints":{"type":"array"},"escalate_to_agent":{"type":"boolean"}}}
      }'
    condition: 'not $trigger_scan_json.matched'
    timeout: 10000

  - id: envelope
    command: exec --json --shell |
      python3 -c "
import json
trigger = json.loads('''$trigger_scan_stdout''')
if trigger['matched']:
  result = {'type': 'action', 'class': trigger['matched'], 'subtype': None,
            'confidence': trigger['confidence'], 'source': 'trigger_words',
            'urgency': 'normal', 'context_hints': [], 'escalate_to_agent': False}
else:
  result = json.loads('''$triage_classify_stdout''')
  result['source'] = 'triage_model'
print(json.dumps(result))
"
