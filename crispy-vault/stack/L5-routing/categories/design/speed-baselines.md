---
tags: [type/reference, layer/routing, status/draft, category/design, focus/speed]
---

# Design Speed Baselines

> Latency budgets, operation breakdowns, UX red lines, and caching strategy for design workflows.

**Up →** [[stack/L5-routing/categories/design/_overview]]

---

## Latency Budgets

| Operation | Target | Notes |
|---|---|---|
| Load design hat + context injection | <50ms | Brand/style preferences pre-fetched |
| Trigger classification (wireframe vs. visual) | <100ms | Low-latency pattern match |
| Memory query (brand colors, fonts) | <200ms | Vector DB + semantic weight |
| Skill load (pptx, canvas-design) | <300ms | First-time cold load can be longer |
| Presentation deck generation | 5–8s | pptx skill latency; user expects this |
| Visual asset creation | 3–5s | canvas-design skill latency |
| Code-based art generation | 2–4s | algorithmic-art skill latency |
| Agent loop response (wireframe sketch) | 2–3s | Creative mode; includes reasoning |
| Agent loop response (review + feedback) | 1–2s | Principle-based analysis |

---

## UX Red Lines

- **Do not** delay design hat load beyond 50ms — brand memory is essential
- **Do not** stream presentation creation — users expect it as a download artifact
- **Do not** skip memory lookup for brand rules — serving generic advice when personalized memory exists breaks trust
- **Do not** timeout skill operations — cap at 10s and fail gracefully

---

## Caching Strategy

**Warm cache on hat load:**
- Brand colors (primary, secondary, accent, hex codes)
- Font preferences (headings, body, code, weights)
- Style direction keywords (minimal, bold, playful, etc.)
- WCAG accessibility standard chosen

**Per-session cache:**
- Current design project context (audience, platform, constraints)
- Latest design decisions and feedback
- Presentation structure (if in multi-turn deck creation)

---

## Testing Methodology

**Measurement points:** `message-received` → `first-token` → `complete-response`; `skill-invoke` → `skill-complete`.

**Tools:** Telegram `.date` timestamps, OpenClaw gateway logs, skill execution logs.

**Conditions:** (1) No skills, agent loop only; (2) + pptx skill; (3) + canvas-design; (4) + brand-audit pipeline.

**Sample size:** Minimum 10 messages per condition.

---

## Pipeline Impact Predictions

| Pipeline/Skill | LLM Calls | API Calls | Sync/Async | Expected Delta | Notes |
|---|---|---|---|---|---|
| `brand-audit` | 1 (main) + 1 (flash) | 1 memory R | Sync | +1.5–3s | Main model for analysis |
| `pptx` skill | 1–2 | file I/O | Async | +5–8s | Users expect deck creation time |
| `canvas-design` skill | 1 | rendering | Async | +3–5s | Canvas rendering time |
| `algorithmic-art` skill | 1 | code exec | Async | +2–4s | Code generation + execution |

---

## Speed Budget (Machine-Readable)

```json
{
  "category": "design",
  "targets": {
    "first_token_ms": 1500,
    "complete_response_ms": 5000,
    "pipeline_overhead_ms": 500
  },
  "thresholds": {
    "button_tap_ms": 500,
    "initial_response_ms": 1500,
    "multi_turn_ms": 3000,
    "complex_operation_ms": 8000,
    "hang_threshold_ms": 10000
  },
  "pipelines": {
    "brand-audit": { "latency_ms": [1500, 3000], "llm_calls": 2, "sync": true }
  },
  "skills": {
    "pptx":             { "latency_ms": [5000, 8000],  "sync": false },
    "canvas-design":    { "latency_ms": [3000, 5000],  "sync": false },
    "algorithmic-art":  { "latency_ms": [2000, 4000],  "sync": false }
  }
}
```
^speed-design
