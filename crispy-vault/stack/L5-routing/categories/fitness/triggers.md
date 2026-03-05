---
tags: [type/reference, layer/routing, status/draft, category/fitness, focus/triggers]
---

# Fitness Triggers

> High-confidence, medium-confidence, and sub-category trigger words for fitness intent detection. Intent patterns route to appropriate handler (agent loop or pipeline).

**Up →** [[stack/L5-routing/categories/fitness/_overview]]

---

## High Confidence (→ load hat immediately)

```
workout, exercise, gym, lift, lifting, run, running, cardio,
stretching, yoga, reps, sets, PR, personal record, squat, bench,
deadlift, pushup, pullup, plank, HIIT, rest day, recovery,
muscle, strength, endurance, flexibility, mobility, warm up,
cool down, training, gains
```

---

## Medium Confidence (→ classify with context)

```
weight, heavy, light, form, routine, split, program, progress,
volume, intensity, heart rate, steps, miles, pace, zone,
soreness, injury, pain, rest, sleep, hydration, foam roll,
band, dumbbell, barbell, kettlebell, treadmill, bike
```

*Medium-confidence words like "weight" or "heavy" need context — could be cooking (heavy cream), trading (portfolio weight), or fitness.*

---

## Sub-Category Signals

| Sub-Category | Additional Triggers |
|---|---|
| **workout** | "what should I do today", "leg day", "upper body", "push/pull", workout names |
| **tracking** | "how much did I", "my PR", "progress", "this week's numbers", "log this" |
| **nutrition** | "protein", "pre-workout", "post-workout", "macros for", "bulking", "cutting" |
| **recovery** | "sore", "rest day", "stretching", "mobility", "sleep quality", "deload" |
| **goals** | "I want to", "my goal is", "by summer", "in 3 months", "get stronger" |
| **learning** | "how to", "proper form", "what's the difference", "should I", "is it okay to" |

---

## Intent Patterns

| Intent | What User Wants | Route | Example |
|---|---|---|---|
| `fitness:workout-plan` | A workout for today or a period | Agent loop (creative) | "What should I do for legs today?" |
| `fitness:log-workout` | Record what they did | Pipeline → workout-log | "I did 5x5 squats at 185" |
| `fitness:check-progress` | See trends or history | Pipeline → progress-check | "How's my bench trending?" |
| `fitness:nutrition-check` | Fitness-specific nutrition question | Agent loop (with cooking hat awareness) | "How much protein should I eat after lifting?" |
| `fitness:recovery-advice` | Recovery or injury question | Agent loop (informational) | "I'm really sore from yesterday, should I still train?" |
| `fitness:form-check` | How to do an exercise properly | Agent loop (informational) | "What's the proper form for Romanian deadlifts?" |
| `fitness:goal-set` | Set or review a fitness goal | Agent loop + planning framework | "I want to bench 225 by June" |
| `fitness:program-design` | Design a multi-week training program | Agent loop (complex + planning) | "Build me a 4-day push/pull/legs split" |
| `fitness:preference-update` | Tell Crispy a fitness preference | Memory write → confirm | "I work out Monday, Wednesday, Friday" / "I don't like running" |

^triggers-fitness
