---
tags: [layer/session, status/active, type/note]
---
# L4 Cross-Layer Notes

> Issues found during L4 sessions that affect other layers. Each layer session should scan this file for their layer tag.

**Up →** [[stack/L4-session/_overview]]

---

## 2026-03-04 — SCAN re-anchoring needed in agent loop
- **from:** L4
- **affects:** L5, L6
- Drift-guardian research shows persona consistency degrades >30% after 8-12 dialogue turns. Recommend implementing SCAN re-anchoring: every 5 turns, have the agent generate tokens summarizing its own role before responding. This creates active attention links to the system prompt. This is a middleware/routing concern (L5) or a processing pipeline step (L6) — not L4's job to implement, but L4 flags it because context injection order alone isn't enough for long conversations.
- **spec defined:** L5 owns the trigger (turn counter in compaction logic, every 5 turns). L6 implements the pipeline step (self-summary generation before response). Smart-detect category persistence means each session re-classifies anyway, so SCAN doubles as category confirmation.
- **status:** spec complete — implementation tracked in L5/L6 (2026-03-04)

## 2026-03-04 — Heartbeat as lightweight drift detection opportunity
- **from:** L4
- **affects:** L6
- HEARTBEAT.md runs every 20 minutes on the flash model. This is a natural place to add a lightweight drift check: compare the last few responses against the persona baseline using embedding similarity (drift-guardian's monitoring stack). Cost is near zero on the flash model. L6 owns the processing pipeline that could wire this up.
- **spec defined:** Add an embedding similarity check to the health-check pipeline or a dedicated `drift-check` cron entry. Compare last 3 responses against SOUL.md baseline embedding. Threshold: <0.7 similarity triggers a re-anchoring injection. Uses flash model, cost ~0 tokens.
- **status:** spec complete — implementation tracked in L6 (2026-03-04)
