---
tags: [layer/runtime, status/draft, topic/operations, type/guide]
---
# L2 — Operations Runbook

> Hands-on procedures for managing the OpenClaw gateway, model routing, and session operations.

---

## Gateway Operations

Hands-on commands for starting, stopping, and managing the OpenClaw gateway.

### Management Commands

```bash
# Start
openclaw start

# Stop
openclaw stop

# Health check
curl http://localhost:18789/health

# Config validation
openclaw doctor

# Auto-fix common issues
openclaw doctor --fix

# View logs
openclaw logs

# Reload config (no restart)
openclaw reload
```

---

### Startup Failure Checklist

| Step | Symptom | Fix |
|---|---|---|
| Load .env | "Missing env var" | Check `OPENCLAW_GATEWAY_TOKEN` exists |
| Parse config | "Invalid JSON" | `openclaw doctor --fix` |
| Start gateway | "Port in use" | `lsof -i :18789` then kill stale process |
| Connect channels | "Bad token" | Check `TELEGRAM_BOT_TOKEN` in .env |
| Load pipelines | "File not found" | Create missing `.lobster` files |

---

### Quick Commands

| Command | When |
|---|---|
| `openclaw gateway start` | Start Crispy |
| `openclaw gateway stop` | Stop |
| `openclaw gateway restart` | After config changes |
| `openclaw gateway logs` | Debug |
| `openclaw doctor --fix` | First aid |
| `openclaw status` | Quick health |

---

## Model Auth & Switching

Hands-on setup and testing for LLM authentication and model routing.

### Auth Setup

#### Anthropic (API Key)

```bash
# Verify ANTHROPIC_API_KEY is set in .env
echo $ANTHROPIC_API_KEY

# Test connectivity
openclaw models status | grep anthropic
```

#### OpenAI (API Key)

```bash
# Verify OPENAI_API_KEY is set in .env
echo $OPENAI_API_KEY

# Test connectivity
openclaw models status | grep openai
```

#### OpenRouter (API Key)

```bash
# Verify OPENROUTER_API_KEY is set in .env
echo $OPENROUTER_API_KEY

# Test connectivity
openclaw models status | grep openrouter
```

#### Google Gemini (API Key)

```bash
# Verify GEMINI_API_KEY is set in .env
echo $GEMINI_API_KEY

# Test connectivity
openclaw models status | grep gemini
```

---

### Testing Models

```bash
# List all configured models
openclaw models list

# Test primary model
openclaw models test --model researcher

# Test fallback chain
openclaw models test --fallback

# Check model status
openclaw models status
```

---

### Switching Models in Chat

Use aliases in Telegram:

```bash
/model researcher  # Switch to primary (Claude Opus 4.6)
/model coder       # Switch to DeepSeek R1 (deep reasoning)
/model triage      # Switch to DeepSeek (classification)
/model flash       # Switch to Gemini Flash (fast/cheap)
/model free        # Switch to OpenRouter free tier (emergency)
```

---

## Known Issues

### Fallback Reset on Config Reload (OpenClaw #29564)

User-configured model fallbacks in `openclaw.json` can be silently overridden or reset after gateway restarts, config reloads, or version updates. Root cause: `applyModelDefaults()` in OpenClaw's `src/config/defaults.ts` runs on every config load and can inject default model aliases back into the runtime config.

**Workaround:** After any `openclaw reload` or gateway restart, verify fallbacks are intact:

```bash
openclaw models fallbacks
# Should show your configured chain, not OpenClaw defaults
```

If fallbacks were reset, restart the gateway (not just reload) to force a clean config parse.

**Tracking:** [github.com/openclaw/openclaw/issues/29564](https://github.com/openclaw/openclaw/issues/29564)

---

**Related →** [[stack/L2-runtime/config-reference]] · [[stack/L2-runtime/env]] · [[stack/L2-runtime/gateway]] · [[stack/L2-runtime/models]]
**Up →** [[stack/L2-runtime/_overview]]
