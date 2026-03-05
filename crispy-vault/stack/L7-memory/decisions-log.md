---
tags: [layer/memory, type/planning, topic/audit, status/draft]
---
# 📋 Decisions Log

> Choices made and why.

### Agent: Crispy (kitsune/fox spirit)
> Pre-decided. Skip naming, get to personality.

### Model architecture: researcher + 2 workhorses + 4 fallbacks
> **Researcher:** `researcher` alias — extended thinking, high. Global primary for deep research. See [[stack/L2-runtime/config-reference]] for model strings.
> **Workhorse (general):** `workhorse` alias — crispy default agent model. See [[stack/L2-runtime/config-reference]] for model strings.
> **Workhorse (code):** `openai/gpt-5.2` (alias: workhorse-code) — crispy-code agent model.
> **Fallbacks:** coder (deepseek-r1) → triage (deepseek-v3.2) → flash (gemini) → free (auto).
> Auth: Anthropic direct (researcher + workhorse), OpenAI direct (workhorse-code), OpenRouter (fallbacks).
> Changed from single primary Codex → single primary Opus → researcher + workhorses architecture (2026-03-03).

### Channels: Telegram (primary) + Discord (secondary)
> Telegram for mobile/voice/buttons. Discord for dev/embeds/commands. Discord bot will be set up — moved from "planned" to "ready to implement." (2026-03-02)

### Auth: Anthropic (researcher + workhorse) + OpenAI (workhorse-code) + OpenRouter (fallbacks) + Gemini (embeddings)
> Three providers for models, one for embeddings. Anthropic direct for researcher + general workhorse. OpenAI direct for code workhorse. OpenRouter for fallback cascade. Gemini for memory embeddings. (2026-03-03).

### Plugins: Lobster + llm-task (both enabled)
> Lobster for workflows. llm-task for structured outputs in pipelines.

### Custom Telegram commands: /brief /email /git /pipelines
> Already registered with BotFather. Pipeline files still needed.

### Gmail hooks: enabled (fancykatbase@gmail.com)
> Webhook at /hooks/gmail. PubSub renewal every 12hrs.

### Sandbox: Docker, mode "all", rw workspace access
> Maximum isolation. Main agent can break out via elevated mode.

### Memory: hybrid search, 30-day decay, auto-journal on compaction
> 70% vector + 30% text. Flush writes checkpoint before context trim.

### Session reset: daily @ 4am Pacific + 2hr idle timeout
> Clean slate each day plus idle-based reset. /new and /reset for manual. `idleTimeout: "2h"` added to session.reset config. (2026-03-02)

### Two admins: Marty (primary admin) + Wenting (co-admin)
> Both are admins with elevated access. Both on Telegram DM, both on Discord when enabled. Marty handles config/infra decisions. (2026-03-02)

### Hardware: Desktop build (NOT Raspberry Pi)
> i9-14900K, 64GB DDR5, GTX 1060. Source of truth: [[stack/L1-physical/hardware]].
> All vault references updated from Pi 5 to desktop. (2026-03-02)

### File locations: one directory per category
> Skills → `~/.openclaw/skills/` (both ClawHub + custom). Pipelines → `~/.openclaw/pipelines/`. Workspace only holds bootstrap + memory + research + inbox. No `workspace/skills/` or `workspace/pipelines/`. (2026-03-02)

### Mem0: ready to implement (not future)
> Moved from "planned" to "ready to implement." Env example updated with `MEM0_API_KEY`. Hardware has plenty of resources for self-hosted (Qdrant, Neo4j, Ollama embeddings). See [[stack/L7-memory/memory-search]] and [[stack/L1-physical/hardware]]. (2026-03-02)

### Sessions: per-user by default
> `session.dmScope: "per-channel-peer"` gives Marty and Wenting separate isolated sessions automatically. No custom config needed. (2026-03-02)

### Messages + TTS: §12 in CONFIG.md
> Message formatting (4096 char split, ack reaction, debounce, group mention patterns) and ElevenLabs v3 TTS. Voice responses are Telegram-only for now. ElevenLabs keys added to env tiers. (2026-03-02)

### Category persistence: smart detect (re-classify first message)
> No timer, no carry-over state. Each session starts neutral; the flash classifier re-detects category from the user's first message. If it matches the previous category, seamless continuation. If not, clean switch. Avoids stale context and presumptuous greetings. (2026-03-04)

### Compaction: per-category-segment
> When context fills up, group messages by category within the session, then summarize each group separately. Preserves domain nuance — a cooking segment and a coding segment in the same session get independent summaries, not one blended summary. (2026-03-04)

### Cross-category messages: dual-tag
> Messages that span categories (e.g., "I built a meal planner app") get tagged under both categories. Retrievable from either hat's memory filter. More storage, but richer recall. (2026-03-04)

### Kitsune personality: moderate (5-6/10)
> Clear kitsune identity with regular fox personality. Not subtle hints, not overwhelming character. The fox is visible but doesn't dominate over helpfulness. Cultural flavor: modern with light Japanese folklore touches. (2026-03-04)

### Telegram buttons: standard 3×2 grid
> Max 3 buttons per row, 2 rows (6 buttons visible). Decision tree max depth: 4 levels. Button timeout: 60 seconds. Trigger threshold: >2 possible interpretations. (2026-03-04)

---

**Open questions →** [[open-questions]]
**Up →** [[stack/L7-memory/_overview]]
