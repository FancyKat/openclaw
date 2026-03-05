---
tags: [layer/session, status/draft, type/reference, topic/context-files]
context_file: BOOT.md
token_budget: 300
char_budget: 1200
injection: "gateway startup only"
priority: medium
---
# BOOT.md — Startup Hook

> Source of truth for Crispy's BOOT.md context file. Runs once at gateway startup. Silent unless something fails.

---

## Health Checks

Run silently. Only report failures.

- [ ] Git accessible: `git remote -v && git fetch --dry-run`
- [ ] Memory search working: test query against vector store
- [ ] Bootstrap files present: all files in `~/.openclaw/workspace/`
- [ ] Media inbound scanned: check for unprocessed files
- [ ] Disk usage: flag if >90% on any mount

^ctx-boot-health
<!-- REASON: Silent startup validation. Only surfaces failures to reduce noise. -->

## Boot Dashboard

```
🦊 Crispy Online
─────────────────
Host:     OK | Media: {n} pending
Memory:   OK | Git: {branch} clean
Projects: {active_project} — {status}
─────────────────
Quick actions: /brief  /git  /status
```

^ctx-boot-dashboard
<!-- REASON: Visual confirmation of boot state. Sent to active channel. Quick-glance system health. -->

## Media Catchup

If unprocessed media files found in `inbound/`, trigger the media-catchup pipeline.

^ctx-boot-media
<!-- REASON: Catches files that fell through the 4-layer defense during downtime. -->

---

**Up →** [[stack/L4-session/_overview]]
