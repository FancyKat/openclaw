---
tags: [type/reference, layer/routing, status/draft, category/habits, focus/memory]
---

# Habits: Memory Filter & Compaction

> Memory retrieval filters, retention rules, and compaction logic for habits domain.

**Up →** [[stack/L5-routing/categories/habits/_overview]]

---

## Vector DB Query Filter

```json
{
  "category": ["habits", "habits:tracking", "habits:streaks", "habits:goals"],
  "cross_category": ["fitness:workout", "cooking:meal-prep", "coding:daily"],
  "exclude_categories": ["finance:markets"],
  "boost_fields": ["habit_name", "streak_count", "consistency_rate", "habit_status"],
  "recency_weight": 0.25,
  "semantic_weight": 0.2,
  "category_weight": 0.3,
  "frequency_weight": 0.25
}
```

^filter-habits

**Rationale:** Habits memories balance frequency weight (how often something comes up) with category weight (staying in the habits domain). Recency matters for "how am I doing this week" but older patterns matter too. Cross-category with fitness, cooking, and coding because individual habits live in those domains.

---

## Memory Types to Retrieve

| Memory Type | Example | Priority | When to Load |
|---|---|---|---|
| **Active habits** | "Meditate 10 min/morning, Cook dinner 5x/week, Code 1hr/day" | Always load | Every interaction |
| **Current streaks** | "Meditation: 23 days, Cooking: 8 days, Coding: 14 days" | Always load | Every check-in, review |
| **Check-in schedule** | "Evening check-in at 9 PM, weekly review Sunday morning" | Always load | For cron routing |
| **Consistency rates** | "Meditation: 87% this month, Cooking: 71%, Coding: 92%" | Load for review intents | Weekly review, adjustment decision |
| **Habit history** | "Started cold showers Jan 15, paused Feb 20 (too cold)" | Load for adjust/new intents | When modifying or creating |
| **Pattern observations** | "I skip workouts on Mondays after late Sunday nights" | Load for review/adjust intents | Review context, relapse prevention |
| **Milestones** | "Hit 30-day meditation streak on Feb 14!" | Load for streak/review intents | Streak checks, celebrations |
| **Accountability style** | "Prefers gentle nudges, not firm reminders" | Always load | Tailor tone + recommendations |

---

## Cross-Category Integration

Individual habits are dual-tagged:
- `habits:tracking` + `fitness:workout` for "Exercise 3x/week"
- `habits:tracking` + `cooking:meal-prep` for "Cook at home 5x/week"
- `habits:tracking` + `coding:daily` for "Code for 1 hour daily"

When the user is in habits mode, pull habits memories. When they ask about cooking, pull cooking memories that also tag to habits (for context: "This connects to your 'cook daily' habit").

---

## Compaction Rules

### Preserve

- Habit definitions and their SMART criteria
- Streak milestones (7, 14, 21, 30, 60, 90, 365 days)
- Habit adjustments with reasoning (old params → new params)
- Pattern observations ("I always skip X when Y happens")
- Habits started, paused, or retired with dates and reasons
- Weekly consistency rates (for trend tracking)
- Check-in schedule changes

### Flush

- Individual daily check-in confirmations (summarize as consistency %)
- Motivational back-and-forth
- Generic habit science explanations (regeneratable)
- Repeated check-in prompts
- Detailed daily logs older than 2 weeks (preserve only trends)

### Example Compaction

**Before:**
```
Day 1: Meditated 10 min ✅
Day 2: Meditated 10 min ✅
Day 3: Meditated 10 min ✅
Day 4: Skipped (tired) ❌
Day 5: Meditated 10 min ✅
Day 6: Meditated 10 min ✅
Day 7: Meditated 10 min ✅
User asked: "Why do I skip when tired?"
Response: Here are some ways to work through fatigue...
User: "That makes sense, I'll try easier days"
```

**After compaction:**
```
Week of Feb 24: Meditation 6/7 (86%)
Pattern: Skips when tired (noted Day 4)
Adjustment proposed: Easier meditation on low-energy days
Accountability style: Gentle, pattern-focused
```

^compaction-habits

---

## Compaction Summary Prompt

Use this template when compacting habits memory segments:

```
Summarize this habits conversation segment.

Preserve exactly:
- Any new habits defined (name, frequency, cue, trigger)
- Any habit adjustments (old → new, reasoning)
- Any streak milestones reached
- Any patterns observed ("I skip X when Y")
- Any habits paused, retired, or restarted with reasoning
- Weekly consistency rates if discussed

Do NOT include:
- Individual daily check-in confirmations (just note consistency)
- Motivational conversation
- Generic habit advice or explanations
- Repeated check-in prompts

Output: max 200 tokens.
```

---

## Retention Tiers

| Tier | Data | TTL | Purpose |
|---|---|---|---|
| Hot | Active habits, current streaks, check-in schedule, accountability style | 5 minutes (refresh on checkin) | Fast access for every interaction |
| Warm | Last 7 days of check-ins, weekly consistency, pattern observations | 7 days | For daily/weekly review, trend analysis |
| Cold | Habit history (all past habits), milestone records, major adjustments | Permanent | Audit trail, relapse prevention, long-term insights |

---

## Memory Footprint Targets

- **Per active habit:** ~50 tokens (name, frequency, cue, reward, status)
- **Per streak record:** ~20 tokens (name, count, date started)
- **Per pattern observation:** ~40 tokens (pattern description, context)
- **Weekly compacted logs:** ~100 tokens (7 days compressed to 1 summary)

**Total budget for active user:** ~500 tokens (10 habits + streaks + patterns + weekly logs)

---

**Up →** [[stack/L5-routing/categories/habits/_overview]]
