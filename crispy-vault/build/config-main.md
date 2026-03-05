# config-main.md — openclaw.json Assembly Blueprint
<!-- This file documents the assembly order for openclaw.json -->
<!-- Each section references its source layer's config-reference.md -->
<!-- The build script reads ^config-* blocks from layer files directly -->
<!-- JSON5 format: supports comments, trailing commas, unquoted keys -->

> **Status key:** 🔲 = TODO | ⚠️ = needs refinement | ✅ = confirmed
> **Context →** [[build/context-main]] | **Env →** [[build/env-main]]

---

## Assembly Order

The build script (`build/scripts/build-config.js`) scans `stack/*/config-reference.md` files for `^config-*` blocks and assembles them in this order:

| # | Section | Owner | Block ID | Status |
|---|---------|-------|----------|--------|
| 1 | Gateway | L1-Physical | `^config-gateway` | ✅ |
| 2 | Agents | L2-Runtime | `^config-agents` | ✅ |
| 3 | Channels | L3-Channel | `^config-channels` | ⚠️ |
| 4 | Tools | L6-Processing | `^config-tools` | ✅ |
| 5 | Memory | L7-Memory | `^config-memory` | ✅ |
| 5b | Audit Log | L7-Memory | `^config-audit` | ⚠️ |
| 6 | Hooks | L1-Physical | `^config-hooks` | ✅ |
| 7 | Plugins | L6-Processing | `^config-plugins` | ✅ |
| 8 | Cron | L6-Processing | `^config-cron` | ✅ |
| 9 | Skills | L6-Processing | `^config-skills` | ✅ |

---

## §1 — Gateway ← L1-Physical

![[stack/L1-physical/config-reference#Gateway Config]]

---

## §2 — Agents (+ Models) ← L2-Runtime

![[stack/L2-runtime/config-reference#Agents Config]]

---

## §3 — Channels ← L3-Channel

![[stack/L3-channel/config-reference#Channel Config]]

---

## §4 — Tools ← L6-Processing

![[stack/L6-processing/config-reference#Tools Config]]

---

## §5 — Memory ← L7-Memory

![[stack/L7-memory/config-reference#Memory Config]]

---

## §5b — Audit Log ← L7-Memory

![[stack/L7-memory/config-reference#Audit Log Config]]

---

## §6 — Hooks ← L1-Physical

![[stack/L1-physical/config-reference#Hooks Config]]

---

## §7 — Plugins ← L6-Processing

![[stack/L6-processing/config-reference#Plugins Config]]

---

## §8 — Cron ← L6-Processing

![[stack/L6-processing/config-reference#Cron Config]]

---

## §9 — Skills ← L6-Processing

![[stack/L6-processing/config-reference#Skills Config]]

---

## Build Notes

- **No ^config-* blocks in this file** — all config lives in layer `config-reference.md` files
- The build script ignores Obsidian transclusions — it reads layer files directly
- In Obsidian, this file renders the full config via transclusion for review
- **Property order in output:** gateway → agents → channels → tools → memory → hooks → plugins → cron → skills
- **Env vars:** All secrets use `${VAR_NAME}` syntax, resolved at Gateway load time

> **Context →** [[build/context-main]] | **Env →** [[build/env-main]]
