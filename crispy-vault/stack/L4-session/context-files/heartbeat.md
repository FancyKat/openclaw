---
tags: [layer/session, status/draft, type/reference, topic/context-files]
context_file: HEARTBEAT.md
token_budget: 300
char_budget: 1200
injection: "every 20min (flash model)"
priority: low
---
# HEARTBEAT.md — Periodic Health Check

> Source of truth for Crispy's HEARTBEAT.md context file. Agent's "idle loop" — runs autonomously on cheapest model. Be extremely specific about actions; vague instructions cause unpredictable behavior on cheap models. Every notification is an interruption.

---

## Check

Run each check. If ALL pass, reply `HEARTBEAT_OK` and stop. Only report details if something needs attention.

- [ ] Git clean? — Flag if dirty >1 day.
- [ ] Daily log size? — If >2,000 words, curate to MEMORY.md.
- [ ] Disk space? — Flag if >90% on any mount.
- [ ] Pending reminders? — List any past due.
- [ ] Interrupted tasks? — Flag hanging tasks from previous session.

^ctx-heartbeat-checks
<!-- REASON: Lightweight health pulse. Flash model keeps cost near zero. Mechanical checks only. -->

## Notify

- Only notify if a check fails. HEARTBEAT_OK is silent.
- Pending reminders past due → notify in active channel.
- Disk >90% → notify immediately.

^ctx-heartbeat-notify
<!-- REASON: Minimize notification triggers. Only genuinely important events warrant interruption. -->

## Never

- Never take irreversible action during heartbeat (no deletes, no pushes, no writes to bootstrap files).
- Never start a new conversation — heartbeat is read-only except for notifications.

^ctx-heartbeat-never
<!-- REASON: Safety guardrails for autonomous actions. Heartbeat must never take irreversible action on cheap model. -->

## Reminders
<!-- Format: - [ ] {reminder} — due {datetime} -->

^ctx-heartbeat-reminders

## Recent Tasks
<!-- Format: - [ ] {task} — started {date}, status: {in-progress|blocked|waiting} -->

^ctx-heartbeat-tasks

---

**Up →** [[stack/L4-session/_overview]]
