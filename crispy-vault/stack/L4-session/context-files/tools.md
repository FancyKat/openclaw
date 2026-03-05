---
tags: [layer/session, status/draft, type/reference, topic/context-files]
context_file: TOOLS.md
token_budget: 600
char_budget: 2400
injection: "every session + subagents"
priority: high
---
# TOOLS.md — Tool Constraints

> Source of truth for Crispy's TOOLS.md context file. Only NON-OBVIOUS rules — the agent already has tool schemas from OpenClaw. An empty TOOLS.md is better than a padded one. Never list what the agent can discover from schemas.

---

## Preferences

- Shell (exec): always sandboxed (Docker). 30-min timeout. Workspace read-write, root read-only, bridge network.
- Web: Brave Search + fetch. 50K char limit per fetch.
- Voice: ElevenLabs v3, Telegram only (for now). Auto-transcribe inbound, TTS outbound.
- Pipelines: `/brief` `/email` `/git` `/status` — Lobster workflows, zero LLM tokens.
- llm-task: 800 token cap, 30s timeout. Use for inline sub-tasks (summarize, classify, extract).
- Memory: Vector search (Gemini embeddings) + BM25 hybrid.

^ctx-tools-preferences
<!-- REASON: Non-obvious constraints per tool. Schemas describe parameters; this describes limits and gotchas the agent can't discover from schemas alone. -->

## Forbidden Patterns

- Never use exec outside Docker sandbox.
- Never pipe secrets through shell commands.
- Never fetch URLs containing credentials in query strings.

^ctx-tools-forbidden
<!-- REASON: Things that technically work but must not happen. Security boundaries for tool use. -->

## Environment Gotchas

- GPU: GTX 1060 6GB — no local inference. Don't attempt to load models locally.
- RAM: 64GB DDR5 single-channel (Channel A IMC failure) — memory-intensive tasks may be slower.
- NVMe: Samsung 990 PRO 1TB — primary workload disk, keep workspace tidy.

^ctx-tools-gotchas
<!-- REASON: Hardware constraints the agent cannot discover from tool schemas. Prevents wasted attempts at local inference. Values reference L1 — update if hardware changes. -->

---

**Up →** [[stack/L4-session/_overview]]
