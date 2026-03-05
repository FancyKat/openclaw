---
tags: [layer/session, status/draft, type/reference, topic/context-files]
context_file: STATUS.md
token_budget: 300
char_budget: 1200
injection: "every session"
priority: low
---
# STATUS.md — Ephemeral Session State

> Source of truth for Crispy's STATUS.md context file. A sticky note, not a document. Clear/rewrite between sessions — never append. Separating from MEMORY.md prevents full KV-cache invalidation on minor status updates.

---

## Session

- Last compaction: (none yet)
- Current task: (none yet)
- Pending actions: (none yet)
- Waiting on: (none yet)

^ctx-status-session
<!-- REASON: Resume context after compaction. Overwritten each session, never appended. -->

## Alerts

- (none)

^ctx-status-alerts
<!-- REASON: Urgent items that must surface immediately. Clear when resolved. -->

## Carried Forward
<!-- Key facts from compacted context that must not be lost -->

^ctx-status-carried
<!-- REASON: Critical facts buffer; prevents information loss during compaction. -->

---

**Up →** [[stack/L4-session/_overview]]
