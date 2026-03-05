---
tags: [layer/memory, type/spec, status/draft]
---

# Audit Log

> Comprehensive record of all tool calls, approvals, denials, and errors. What did Crispy do, when, and with what result? Essential for debugging, security, and post-session review.

**Up →** [[stack/L7-memory/_overview]]

---

## Overview

The audit log is an append-only record of every action Crispy takes. Unlike memory (which is about learning), auditing is about accountability.

---

## What Gets Logged

### ✅ Always Logged

| Event | Logged As | Example |
|---|---|---|
| Tool invocation | `TOOL_CALL` | Browser opened, exec ran, web_fetch called |
| Tool result | `TOOL_RESULT` | Success/failure, return value (truncated) |
| User approval | `APPROVAL` | User confirmed download, transaction, etc |
| User denial | `DENIAL` | User rejected action |
| Error | `ERROR` | Tool failed, timeout, exception |
| Token count | `TOKENS_USED` | Input + output tokens for that turn |

### ❌ Not Logged (Privacy)

- Conversation content (too verbose)
- User messages (captured by session JSONL)
- API keys or secrets (filtered before logging)
- Browser screenshots (too large)

---

## Log Format

**Location:** `workspace/audit/YYYY-MM-DD.jsonl`

Each line is a JSON object. Append-only. One entry per event.

```json
{
  "timestamp": "2026-03-02T14:30:45.123Z",
  "event_type": "TOOL_CALL",
  "tool": "browser",
  "action": "navigate",
  "status": "started",
  "args": {
    "url": "https://docs.example.com",
    "profile": "openclaw"
  }
}

{
  "timestamp": "2026-03-02T14:31:02.456Z",
  "event_type": "TOOL_RESULT",
  "tool": "browser",
  "action": "navigate",
  "status": "success",
  "result_summary": "Loaded docs.example.com (1.2 MB, 8.4s latency)",
  "duration_ms": 8400
}

{
  "timestamp": "2026-03-02T14:31:30.000Z",
  "event_type": "APPROVAL",
  "action": "download_file",
  "resource": "JobOffer_Details.pdf",
  "user_confirmed": true,
  "note": "User confirmed download"
}

{
  "timestamp": "2026-03-02T14:32:00.000Z",
  "event_type": "TOKENS_USED",
  "turn": 42,
  "input_tokens": 3420,
  "output_tokens": 1280,
  "total_tokens": 4700,
  "model": "researcher"
}

{
  "timestamp": "2026-03-02T14:35:15.789Z",
  "event_type": "ERROR",
  "tool": "exec",
  "command": "openclaw memory search",
  "error_type": "APIError",
  "error_message": "Gemini API key invalid",
  "severity": "error"
}
```

---

## Event Types

### TOOL_CALL

```json
{
  "timestamp": "2026-03-02T14:30:45.123Z",
  "event_type": "TOOL_CALL",
  "tool": "browser",                    // "browser", "exec", "web_fetch", etc
  "action": "navigate",                 // tool-specific action
  "status": "started",
  "args": {                             // what was passed to the tool
    "url": "https://...",
    "profile": "openclaw"
  }
}
```

### TOOL_RESULT

```json
{
  "timestamp": "2026-03-02T14:31:02.456Z",
  "event_type": "TOOL_RESULT",
  "tool": "browser",
  "action": "navigate",
  "status": "success",                  // "success" | "failure" | "timeout"
  "result_summary": "Loaded page (1.2 MB, 8.4s)",
  "duration_ms": 8400,
  "exit_code": 0                        // for exec tools
}
```

### APPROVAL

```json
{
  "timestamp": "2026-03-02T14:31:30.000Z",
  "event_type": "APPROVAL",
  "action": "download_file",            // what was approved
  "resource": "JobOffer_Details.pdf",   // what it affects
  "user_confirmed": true,               // or false (rejected)
  "note": "User confirmed download"
}
```

### DENIAL

```json
{
  "timestamp": "2026-03-02T14:32:45.000Z",
  "event_type": "DENIAL",
  "action": "delete_files",
  "reason": "User declined without explanation",
  "alt_suggested": "Archive instead of delete"
}
```

### TOKENS_USED

```json
{
  "timestamp": "2026-03-02T14:32:00.000Z",
  "event_type": "TOKENS_USED",
  "turn": 42,
  "input_tokens": 3420,
  "output_tokens": 1280,
  "total_tokens": 4700,
  "model": "researcher"
}
```

### ERROR

```json
{
  "timestamp": "2026-03-02T14:35:15.789Z",
  "event_type": "ERROR",
  "tool": "exec",
  "command": "openclaw memory search",
  "error_type": "APIError",
  "error_message": "Gemini API key invalid",
  "severity": "error",                  // "warning" | "error" | "critical"
  "context": "Tried to search for 'test memory'"
}
```

---

## File Organization

```
workspace/audit/
├── 2026-03-02.jsonl      ← today's audit log (append-only)
├── 2026-03-01.jsonl      ← yesterday
├── 2026-02-28.jsonl
└── ...
```

**Retention:**
- Keep audit logs for **90 days**
- Archive older logs to `audit/archive/` if storage constrained
- Never delete (append-only by design)

---

## Config

> Config source of truth: [[stack/L7-memory/config-reference]] `^config-audit`

The audit log config block lives in `config-reference.md` per CLAUDE.md rules. Key settings: JSONL format, 90-day retention with 30-day archive rotation, logging for tool calls, approvals, errors, and token counts.

---

## How Audit Logs Feed Back into Guardrails

| Guardrail Decision | Logged As | Purpose |
|---|---|---|
| "This action is prohibited" | `DENIAL` + reason | Track what was blocked |
| "User must approve" | `APPROVAL` or `DENIAL` | Track consent |
| "This action is safe" | `TOOL_CALL` + `TOOL_RESULT` | Track what was done |
| "Action timed out" | `ERROR` + exit code | Track timeouts |

---

## Usage Examples

### Reviewing a Session

```bash
# Count all tool calls today
grep "TOOL_CALL" workspace/audit/2026-03-02.jsonl | wc -l

# Find all errors
grep "ERROR" workspace/audit/2026-03-02.jsonl | jq '.'

# Check token usage
grep "TOKENS_USED" workspace/audit/2026-03-02.jsonl | \
  jq '.total_tokens' | awk '{s+=$1} END {print "Total:", s}'

# Show all denials
grep "DENIAL" workspace/audit/2026-03-02.jsonl
```

### Security Review

```bash
# Find all tool invocations by type
grep "TOOL_CALL" workspace/audit/*.jsonl | jq '.tool' | sort | uniq -c

# Find any errors
grep "ERROR" workspace/audit/*.jsonl | jq '.error_message'

# Check for failed tools
grep "TOOL_RESULT" workspace/audit/*.jsonl | grep '"status": "failure"'
```

### Token Cost Analysis

```bash
# Calculate daily token usage
grep "TOKENS_USED" workspace/audit/2026-03-02.jsonl | \
  jq '.total_tokens' | paste -sd+ | bc

# Average tokens per turn
jq '.total_tokens' workspace/audit/2026-03-02.jsonl | \
  awk '{sum+=$1; n++} END {print "Avg tokens:", sum/n}'
```

---

## Privacy Considerations

The audit log is **safe to review** because:

- ✅ No conversation text (just tool calls)
- ✅ No personal info (just action names)
- ✅ No API keys (filtered before logging)
- ✅ No file contents (just filenames)
- ✅ No screenshot data (too large)

**What IS recorded:**
- Tool invocations and results
- User approvals/denials
- Errors and failures
- Token counts
- Timestamps and durations

---

## Compliance & Auditing

Use audit logs for:

| Purpose | Query | Benefit |
|---|---|---|
| **Security Review** | Find all denied actions | Spot attack attempts |
| **Cost Tracking** | Sum daily tokens | Monitor API spending |
| **Debugging** | Find errors by timestamp | Root cause analysis |
| **Compliance** | Show user approvals | Proof of consent |
| **Performance** | Check tool duration | Optimize slow paths |

---

## Status: 🟡 Design Phase

Not yet implemented, but configuration is ready. To enable:

1. Add `agents.defaults.auditLog` config (see above)
2. Create `workspace/audit/` directory
3. Enable in OpenClaw settings
4. Test: `openclaw doctor --audit` to verify logging works

---

## Example Daily Audit Summary

```bash
#!/bin/bash
# Generate a summary of today's audit

DATE=$(date +%Y-%m-%d)
AUDIT="workspace/audit/${DATE}.jsonl"

echo "=== Audit Summary for ${DATE} ==="
echo ""
echo "Tool Calls:"
grep "TOOL_CALL" "$AUDIT" | jq '.tool' | sort | uniq -c
echo ""
echo "Total Tokens:"
grep "TOKENS_USED" "$AUDIT" | jq '.total_tokens' | paste -sd+ | bc
echo ""
echo "Errors:"
grep "ERROR" "$AUDIT" | jq '.error_type' | sort | uniq -c
echo ""
echo "Denials:"
grep "DENIAL" "$AUDIT" | wc -l
echo ""
echo "Session Duration:"
START=$(head -1 "$AUDIT" | jq -r '.timestamp')
END=$(tail -1 "$AUDIT" | jq -r '.timestamp')
echo "From: $START"
echo "To:   $END"
```
