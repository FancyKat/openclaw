---
tags: [layer/memory, status/draft, type/config]
---
# L7 Config Reference — Memory Layer

> Single source of truth for L7-owned `openclaw.json` config blocks. Build script reads `^config-*` blocks from this file.

**Up →** [[stack/L7-memory/_overview]]

---

## Memory Config

<!-- ^config-memory -->
<!-- STATUS: ✅ verified (T-L7-02) — memorySearch key name confirmed, gemini-embedding-001 model string confirmed, hybrid/mmr/temporalDecay/vectorWeight/textWeight/candidateMultiplier all confirmed as real OpenClaw fields -->
<!-- REASON: Hybrid search (vector 70% + BM25 keyword 30%); Gemini embeddings for cost; MMR reranking for diversity; 30-day decay curve matches daily log rotation -->
<!-- NOTE: Merges into agents.defaults via deepMerge — L2 owns the agents wrapper. "memory" is NOT a valid top-level key. Compaction config NOT duplicated here — L2 defines agents.defaults.compaction. -->

```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": true,
        "provider": "gemini",
        "model": "gemini-embedding-001",
        "sync": { "watch": true },
        "query": {
          "hybrid": {
            "enabled": true,
            "vectorWeight": 0.7,
            "textWeight": 0.3,
            "candidateMultiplier": 4,
            "mmr": { "enabled": true, "lambda": 0.7 },
            "temporalDecay": { "enabled": true, "halfLifeDays": 30 }
          }
        },
        "cache": { "enabled": true, "maxEntries": 50000 }
      }
    }
  }
}
```
^config-memory

---

## Audit Log Config

<!-- ^config-audit -->
<!-- STATUS: ⚠️ NOT in official docs — checked https://docs.openclaw.ai/gateway/configuration-reference (2026-03-04). agents.defaults does not list auditLog. This block is a vault-designed extension that may not be supported by the current OpenClaw gateway. Keep as aspirational spec; do NOT include in dist/openclaw.json until officially supported. -->
<!-- REASON: Append-only JSONL audit trail for tool calls, approvals, denials, errors, and token usage. 90-day retention with 30-day archive trigger. -->
<!-- NOTE: Merges into agents.defaults alongside memorySearch. Full spec at [[stack/L7-memory/audit-log]]. If OpenClaw adds auditLog support, update STATUS to ✅ and include in build. -->

```json
{
  "agents": {
    "defaults": {
      "auditLog": {
        "enabled": true,
        "location": "workspace/audit/",
        "format": "jsonl",
        "retention": {
          "days": 90,
          "archiveAfter": 30
        },
        "logToolCalls": true,
        "logApprovals": true,
        "logErrors": true,
        "logTokens": true
      }
    }
  }
}
```
^config-audit
