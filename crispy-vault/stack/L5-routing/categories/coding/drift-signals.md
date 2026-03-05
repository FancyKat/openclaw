---
tags: [type/reference, layer/routing, status/draft, category/coding, focus/drift]
---

# Coding Category — Drift Signals & Re-anchoring

> Model drift detection methods, signal examples, re-anchoring protocols, and risk profiles for coding intents.

**Up →** [[stack/L5-routing/categories/coding/_overview]]

---

## Drift Signals (Coding-Specific)

| Signal | What It Looks Like | Risk | Action |
|---|---|---|---|
| **Over-explaining** | Explaining basic concepts (loops, functions) unprompted | Medium | Re-anchor: "Assume technical competence; skip basics unless asked" |
| **Scope creep** | Turning a simple bug fix into a refactoring proposal | High | Re-anchor: "Fix only what was asked; suggest refactoring separately" |
| **Framework evangelism** | Pushing a specific tool/framework unprompted | High | Re-anchor: "Use their preferred stack unless they explicitly ask for alternatives" |
| **Perfectionism** | Suggesting total rewrites when a patch would suffice | High | Re-anchor: "Small, reviewable changes over large rewrites" |
| **Persona bleed** | Being overly casual/chatty when user needs code | Medium | Re-anchor: "Direct, precise, efficient; show code, not chat" |
| **Analysis paralysis** | Suggesting endless testing/validation before deployment | Medium | Re-anchor: "Good enough for staging; iterate in production safely" |
| **Over-abstracting** | Making code too generic/configurable too early | High | Re-anchor: "Write for current need; refactor when pattern emerges" |
| **Premature optimization** | Optimizing code that doesn't have a performance problem | High | Re-anchor: "Measure before optimizing; profile real bottlenecks" |
| **Memory forgetting** | Ignoring known project context (tech stack, style) | High | Re-anchor: "Check memory first; use project's existing patterns" |
| **Deprecation blindness** | Suggesting outdated libraries/patterns | Medium | Re-anchor: "Verify tool/pattern currency before recommending" |

---

## Detection Methods

### Method 1: Keyword Monitoring

Watch for these phrases in generated responses:

```
Over-explaining:
  "Let me explain what a loop is..."
  "Fundamentally, this pattern works by..."
  "First, you should understand X..."

Scope creep:
  "While we're at it, let's refactor this whole module..."
  "This is a good opportunity to redesign..."
  "Why not also add these features..."

Framework evangelism:
  "You should really use [Framework]..."
  "This is so much better in [Language]..."
  "Honestly, [Tool] is the way to go..."

Perfectionism:
  "Let me rewrite this to be perfect..."
  "This needs a complete redesign..."
  "We should add comprehensive error handling..."

Persona bleed:
  "Haha, this is such a mess..."
  "Just FYI, this is hilarious..."
  "By the way, did you see...?"
```

### Method 2: Action Misalignment

Compare generated action against intent:

| Intent | Expected Action | Drift Signal |
|---|---|---|
| `coding:debug` | Show root cause + minimal fix | Suggest refactoring or redesign |
| `coding:write-code` | Implement requested feature | Suggest architectural overhaul |
| `coding:review` | Apply checklist; flag issues | Propose rewrite or new framework |
| `coding:deploy` | Validate + deploy | Suggest extensive testing first |
| `coding:git-op` | Execute git command | Ask philosophical questions about branching |

### Method 3: Memory Alignment Check

```
Drift detected if:
  - Generated code uses different style than memory records
  - Suggested tool differs from project_preference in memory
  - Recommended pattern conflicts with architecture_decision
  - Proposed language/framework differs from tech_stack in memory
```

### Method 4: Token Inflation

```
Expected tokens by intent:
  coding:git-op → 150 tokens
  coding:review → 2K–4K tokens
  coding:debug → 4K–8K tokens

Drift if:
  coding:git-op response = 2K tokens (over-explaining)
  coding:review response = 500 tokens (skipping rigor)
  coding:debug response = 1K tokens (insufficient reasoning)
```

---

## Re-Anchoring Protocols

### Protocol 1: Immediate Reset (In-Turn)

When drift is detected mid-response:

```
User: "Push the latest changes"
Generated: "Let me explain git push in detail. Git is a distributed version control system..."

DRIFT DETECTED: Over-explaining (informational tone on action intent)

Re-anchor: (inline correction to continued response)
"Actually — pushing now: [execute git push]"
```

### Protocol 2: Session-Level Reset

If drift persists across multiple turns:

```
Drift detected: 3+ turns of over-explaining in coding mode

Action:
  1. Acknowledge: "I notice I've been over-explaining. Switching to direct mode."
  2. Reload hat context: Re-inject the coding hat with emphasis on directness
  3. Reset tone: "From here on: Show code, assume technical competence"
  4. Continue: Re-engage with user's actual intent
```

### Protocol 3: Memory-Based Reset

If memory shows conflicting guidance:

```
Drift detected: Suggesting framework X, but memory shows project uses framework Y

Action:
  1. Check memory: "This project uses Y; your style is Y"
  2. Correct suggestion: "I recommended X, but given your stack, Y is better"
  3. Align: "Using Y pattern you prefer"
  4. Log: "Framework alignment reset"
```

### Protocol 4: Context Refresh

If user behavior contradicts loaded context:

```
Drift detected: User asking for explanation when hat assumes technical competence

Action:
  1. Detect mismatch: User asking for basic concept explanation
  2. Query: "Should I explain from basics, or assume you know this?"
  3. Adjust: Reload hat with updated assumption ("user prefers detailed explanations")
  4. Continue: Respond with appropriate depth
```

---

## Risk Profiles by Interaction Type

### Action Intents (git, deploy, test)

**Risk:** Low (pipeline-based, minimal LLM, hard execution boundaries)

**Drift vectors:**
- Over-explaining when user just wants to execute
- Asking unnecessary questions before running pipeline

**Mitigation:**
- Pipeline is the guardrail; use it
- If LLM needed, keep explanation <50 tokens

### Assistance Intents (debug, review, setup)

**Risk:** Medium (LLM-heavy, some open-endedness, user depends on guidance)

**Drift vectors:**
- Over-abstracting fixes
- Scope creep (suggesting more than asked)
- Using outdated patterns

**Mitigation:**
- Check memory for project patterns before generating
- Explicitly limit scope: "I'll fix the X issue; refactoring is separate"
- Verify tool/library currency before recommending

### Creative Intents (write-code, design)

**Risk:** High (open-ended, no hard boundaries, user may adopt bad suggestions)

**Drift vectors:**
- Perfectionism (unnecessary polish)
- Over-engineering (premature abstraction)
- Framework evangelism (pushing preferences)
- Ignoring project style

**Mitigation:**
- Always check memory for style + tech stack FIRST
- Generate options (not prescriptions): "Given your stack, here are 2 approaches..."
- Show tradeoffs explicitly
- Default to project's existing patterns

---

## Re-Anchoring Checklist

Use this checklist when drift is detected:

- [ ] Identify which signal applies (over-explaining, scope creep, etc.)
- [ ] Check method used to detect (keywords, action misalignment, memory conflict, token inflation)
- [ ] Select re-anchoring protocol (immediate, session-level, memory-based, context refresh)
- [ ] Execute correction (inline, reload hat, check memory, query user)
- [ ] Verify alignment (do next 1–2 turns stay anchored?)
- [ ] Log incident (for session memory: "Drift detected: X, re-anchored via Y, resolved")

---

## Edge Cases & Exceptions

### Exception 1: User Explicitly Asks for Over-Explanation

```
User: "I don't know much about Docker. Explain it to me."

This is NOT drift — user explicitly requested explanation.
Load explanation hat (lower technical competence assumption).
Don't flag as over-explaining.
```

### Exception 2: Refactoring Is the Actual Request

```
User: "While we're at it, let's refactor this module."

This is NOT drift — user explicitly asked for refactoring.
Scope creep only if user didn't ask.
Don't flag as scope creep.
```

### Exception 3: New Tool Might Be Correct

```
User: "This project is Python; should I use X library?"

If library X is genuinely better for this use case (even if different from project norm),
recommending it is NOT framework evangelism — it's good advice.
Only flag as drift if you're ignoring user's actual constraint (e.g., "stay in Python").
```

---

## Logging Drift Events

Every drift detection + re-anchor should log:

```
Event: DRIFT_DETECTED
Signal type: over-explaining | scope-creep | framework-evangelism | etc.
Detection method: keyword | action-misalignment | memory-conflict | token-inflation
Intent: coding:debug | coding:write-code | etc.
Re-anchor protocol: immediate | session-level | memory-based | context-refresh
Resolution: inline correction | hat reload | memory check | user query
Status: resolved | ongoing | escalated
Timestamp: [ISO timestamp]
```

---

**Up →** [[stack/L5-routing/categories/coding/_overview]]
