---
tags: [layer/processing, status/active, type/note]
---
# L6 Cross-Layer Notes

> Issues found during L6 sessions that affect other layers. Each layer session should scan this file for their layer tag.

**Up →** [[stack/L6-processing/_overview]]

---

## 2026-03-04 — Misplaced daily-logs.md found in L6
- **from:** L6
- **affects:** L4
- Found `stack/L6-processing/daily-logs.md` with `layer/session` tags and `Up →` link to `stack/L4-session/_overview`. This file is a copy of the L4-owned daily-logs file and does not belong in L6. Converted to a redirect stub pointing to `stack/L4-session/daily-logs`. Recommend deleting the L6 copy in a future cleanup pass.
- **status:** resolved — `daily-logs.md` redirect stub deleted from L6. (2026-03-04)

---

## 2026-03-04 — Resolved BRAVE_SEARCH_KEY → BRAVE_API_KEY in L6 config
- **from:** L6
- **affects:** build (env-main.md reconciliation note)
- L6 config-reference.md used `${BRAVE_SEARCH_KEY}` in `^config-tools`. Updated to `${BRAVE_API_KEY}` to match the recommendation in `build/env-main.md` (line 391: "Use `BRAVE_API_KEY` — matches provider convention"). The reconciliation note in env-main.md can be updated to reflect this is now resolved on the L6 side.
- **status:** resolved

---

## 2026-03-04 — Inbound links to core-pipelines.md and coding/workflows.md from other layers
- **from:** L6
- **affects:** L1, L3 (inbound links)
- `core-pipelines.md` has inbound links from L3 (`telegram/pipelines.md`, `_overview.md`) and `skills/inventory.md`. `coding/workflows.md` has inbound links from L1 (`runbook.md`, `sandbox.md`). Both files were split into individual files with `_overview.md` as the proper index. Converted the old files to redirect stubs. Recommend L1 and L3 sessions update their links to point to `[[stack/L6-processing/pipelines/_overview]]` and `[[stack/L6-processing/coding/_overview]]` respectively.
- **status:** resolved — L3 `telegram/pipelines.md` updated (core-pipelines → pipelines/_overview). L1 `sandbox.md` and `runbook.md` updated (coding/workflows → coding/_overview). (2026-03-04)

---

## 2026-03-04 — Acknowledged L4 SCAN re-anchoring note
- **from:** L6 (responding to L4 + L5 notes)
- **affects:** L6 (future work)
- L4 flagged persona drift >30% after 8-12 turns and recommends SCAN re-anchoring every 5 turns. L5 confirmed they'll define the trigger policy (turn counter in compaction/context-shaping). L6 will implement the re-anchoring as a pipeline step when L5's trigger policy is defined. No action needed now — tracking as future work.
- **spec received:** L5 defined trigger policy (every 5 turns in compaction logic). L4 marked spec complete. L6 will implement a `scan-reanchor` pipeline step that generates a self-summary before response. Category classification doubles as re-anchoring signal per smart-detect decision.
- **status:** spec complete — implementation deferred to pipeline build phase (2026-03-04)

---

## 2026-03-04 — Acknowledged L4 heartbeat drift detection note
- **from:** L6 (responding to L4 note)
- **affects:** L6 (future work)
- L4 suggested adding lightweight drift detection to the HEARTBEAT.md processing (runs every 20 min on flash model). L6 could wire this into the health-check pipeline or a dedicated drift-check cron job. Near-zero cost on flash model. Tracking as future work — will design once drift-guardian monitoring patterns are evaluated.
- **spec received:** Compare last 3 responses against SOUL.md baseline embedding. Threshold: <0.7 similarity triggers re-anchoring injection. Add as step in health-check pipeline or dedicated `drift-check` cron entry.
- **status:** spec complete — implementation deferred to pipeline build phase (2026-03-04)

---

## 2026-03-04 — Resolved L2 note about llm-task model alias
- **from:** L6 (responding to L2 note)
- **affects:** L2 (resolves their cross-layer note)
- L2 flagged that `llm-task` plugin might reference old model alias names. Verified: L6 `config-reference.md` plugins section uses no `allowedModels` field. The `tools.md` llm-task config had hardcoded `anthropic/claude-sonnet-4-5` as `defaultModel` — updated to use alias `triage`. L6 now uses only aliases for model references. L2's note can be marked resolved.
- **status:** resolved

---

## 2026-03-04 — 00-INDEX.md L6 wikilinks had .md extensions
- **from:** L6
- **affects:** vault-wide (00-INDEX.md)
- Fixed `.md` extensions in L6 section of `00-INDEX.md` (config-reference, agent-loop, tools, research, runbook, skills/inventory). Per vault rules, wikilinks should not include `.md` extensions. Also added missing entries: message-routing, cross-layer-notes. Note: L2 flagged the same issue for their section — that fix is still open.
- **status:** resolved
