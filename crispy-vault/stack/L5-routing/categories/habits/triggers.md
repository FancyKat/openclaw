---
tags: [type/reference, layer/routing, status/draft, category/habits, focus/triggers]
---

# Habits: Trigger Patterns

> High-confidence triggers that activate habits mode, medium-confidence classification signals, and sub-category routing.

**Up →** [[stack/L5-routing/categories/habits/_overview]]

---

## High Confidence Triggers

These words/phrases route immediately to habits mode without context:

```
habit, habits, streak, routine, daily routine, morning routine,
check in, check-in, accountability, consistency, tracking,
did I, have I been, how many days, on track, off track,
habit tracker, new habit, break a habit, build a habit
```

^triggers-habits

---

## Medium Confidence Triggers

These require context — could be habits, fitness, cooking, or coding:

```
every day, daily, weekly, routine, schedule, remember to,
forgot to, skip, skipped, missed, consecutive, progress,
goal, discipline, commitment, system, pattern, trigger,
cue, reward, stack, habit stack, atomic, tiny habit,
journal, log, record, track, how am I doing
```

**Context clues:**
- "daily routine" + time mention (morning/evening) → habits
- "daily" + "workout/meal/code" → that domain
- "forgot to" + specific action → habits (tracking)
- "progress" + numbers/streaks → habits

---

## Sub-Category Routing

| Sub-Category | Trigger Phrases | Intent Tag |
|---|---|---|
| **tracking** | "check in", "did I", "today's habits", "log my habits", "mark as done" | `habits:check-in` |
| **review** | "how am I doing", "streak", "this week", "progress report", "consistency" | `habits:daily-review`, `habits:weekly-review` |
| **new** | "start a new habit", "I want to", "add a habit", "build", "begin" | `habits:new-habit` |
| **adjust** | "change", "modify", "too hard", "too easy", "pause", "scale up" | `habits:adjust-habit`, `habits:pause-habit` |
| **learn** | "how to build habits", "habit science", "why do I keep", "motivation" | `habits:learn` |

---

## Intent Patterns & Routing

| Intent | What User Wants | Route | Example |
|---|---|---|---|
| `habits:check-in` | Log today's habit completion | Pipeline → habit-checkin | "Morning check-in — I meditated and journaled" |
| `habits:custom-log` | Log something that doesn't fit standard check-in | Agent loop (flexible) | "I've been reading for 20 minutes every night" |
| `habits:daily-review` | See today's habit status | Pipeline → habit-review | "How'd I do today?" |
| `habits:weekly-review` | See this week's habit trends | Pipeline → habit-review | "How was my week?" |
| `habits:streak-check` | Check current streaks | Pipeline → streak-check | "What are my longest streaks right now?" |
| `habits:new-habit` | Define and start a new habit | Agent loop + SMART+ | "I want to start meditating every morning" |
| `habits:adjust-habit` | Modify an existing habit | Pipeline → habit-update | "The 30-minute meditation is too long, can we try 10?" |
| `habits:pause-habit` | Temporarily pause a habit | Pipeline → habit-update | "Pause the gym habit while I'm traveling" |
| `habits:learn` | Understand habit science or strategy | Agent loop (informational) | "Why is it so hard to stick with new habits?" |
| `habits:preference-update` | Tell Crispy about habit preferences | Memory write → confirm | "I want check-ins at 9 PM every night" |

---

**Up →** [[stack/L5-routing/categories/habits/_overview]]
