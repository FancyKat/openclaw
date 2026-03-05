# pipeline-main.md — Pipeline Assembly Blueprint
<!-- SCAFFOLD FILE — do not hand-edit content. Edit the source files in stack/L6-processing/pipelines/ and stack/L5-routing/categories/ -->
<!-- This file registers all Lobster pipeline definitions for the build system. -->
<!-- Each ![[...#^block-id]] pulls pipeline content from the owning source file. -->
<!-- Deploy target: ~/.openclaw/pipelines/ -->

> **Config →** [[build/config-main]] | **Context →** [[build/context-main]] | **Env →** [[build/env-main]] | **Focus →** [[build/focus-main]]

---

## Assembly Order

The build script (`build/scripts/build-config.js`) reads `^pipeline-*` blocks from layer files and assembles them as `.lobster` files in `dist/pipelines/`.

| # | Pipeline | Owner | Block ID | Deploy As | Status |
|---|----------|-------|----------|-----------|--------|
| 1 | Daily Brief | L6-Processing | `^pipeline-brief` | `brief.lobster` | 🔲 |
| 2 | Email Triage | L6-Processing | `^pipeline-email` | `email.lobster` | 🔲 |
| 3 | Health Check | L6-Processing | `^pipeline-health-check` | `health-check.lobster` | 🔲 |
| 4 | Skill Router | L6-Processing | `^pipeline-skill-router` | `skill-router.lobster` | 🔲 |
| 5 | Intent Finder | L6-Processing | `^pipeline-intent-finder` | `intent-finder.lobster` | 🔲 |
| 6 | Prompt Builder | L6-Processing | `^pipeline-prompt-builder` | `prompt-builder.lobster` | 🔲 |
| 7 | Media Sort | L6-Processing | `^pipeline-media` | `media-sort.lobster` | 🔲 |

### Coding Pipelines

| # | Pipeline | Owner | Block ID | Deploy As | Status |
|---|----------|-------|----------|-----------|--------|
| 8 | Git Pipelines | L6-Processing | `^pipeline-git` | `git.lobster` | 🔲 |
| 9 | Code Review | L6-Processing | `^pipeline-code-review` | `code-review.lobster` | 🔲 |
| 10 | Deploy | L6-Processing | `^pipeline-deploy` | `deploy.lobster` | 🔲 |
| 11 | Testing | L6-Processing | `^pipeline-testing` | `testing.lobster` | 🔲 |
| 12 | Project Routing | L6-Processing | `^pipeline-project-routing` | `project-routing.lobster` | 🔲 |

---

## §1 — Daily Brief ← L6-Processing

![[stack/L6-processing/pipelines/brief#^pipeline-brief]]

---

## §2 — Email Triage ← L6-Processing

![[stack/L6-processing/pipelines/email#^pipeline-email]]

---

## §3 — Health Check ← L6-Processing

![[stack/L6-processing/pipelines/health-check#^pipeline-health-check]]

---

## §4 — Skill Router ← L6-Processing

![[stack/L6-processing/pipelines/skill-router#^pipeline-skill-router]]

---

## §5 — Intent Finder ← L6-Processing

![[stack/L6-processing/pipelines/intent-finder#^pipeline-intent-finder]]

---

## §6 — Prompt Builder ← L6-Processing

![[stack/L6-processing/pipelines/prompt-builder#^pipeline-prompt-builder]]

---

## §7 — Media Sort ← L6-Processing

![[stack/L6-processing/pipelines/media#^pipeline-media]]

---

## §8 — Git Pipelines ← L6-Processing/Coding

![[stack/L6-processing/coding/git-pipelines#^pipeline-git]]

---

## §9 — Code Review ← L6-Processing/Coding

![[stack/L6-processing/coding/code-review#^pipeline-code-review]]

---

## §10 — Deploy ← L6-Processing/Coding

![[stack/L6-processing/coding/deploy#^pipeline-deploy]]

---

## §11 — Testing ← L6-Processing/Coding

![[stack/L6-processing/coding/testing#^pipeline-testing]]

---

## §12 — Project Routing ← L6-Processing/Coding

![[stack/L6-processing/coding/project-routing#^pipeline-project-routing]]

---

### L5 Category Pipelines

| # | Pipeline | Owner | Block ID | Deploy As | Status |
|---|----------|-------|----------|-----------|--------|
| 13 | Grocery List | L5-routing/cooking | `^pipeline-cooking-grocery-list` | `cooking-grocery-list.lobster` | 🔲 |
| 14 | Recipe Search | L5-routing/cooking | `^pipeline-cooking-recipe-search` | `cooking-recipe-search.lobster` | 🔲 |
| 15 | Meal Plan | L5-routing/cooking | `^pipeline-cooking-meal-plan` | `cooking-meal-plan.lobster` | 🔲 |
| 16 | Pantry Check | L5-routing/cooking | `^pipeline-cooking-pantry-check` | `cooking-pantry-check.lobster` | 🔲 |
| 17 | Market Brief | L5-routing/finance | `^pipeline-finance-market-brief` | `finance-market-brief.lobster` | 🔲 |
| 18 | Position Check | L5-routing/finance | `^pipeline-finance-position-check` | `finance-position-check.lobster` | 🔲 |
| 19 | Backtest | L5-routing/finance | `^pipeline-finance-backtest` | `finance-backtest.lobster` | 🔲 |
| 20 | Watchlist | L5-routing/finance | `^pipeline-finance-watchlist` | `finance-watchlist.lobster` | 🔲 |
| 21 | Budget Review | L5-routing/finance | `^pipeline-finance-budget-review` | `finance-budget-review.lobster` | 🔲 |
| 22 | Expense Tracker | L5-routing/finance | `^pipeline-finance-expense-tracker` | `finance-expense-tracker.lobster` | 🔲 |
| 23 | Workout Log | L5-routing/fitness | `^pipeline-fitness-workout-log` | `fitness-workout-log.lobster` | 🔲 |
| 24 | Progress Check | L5-routing/fitness | `^pipeline-fitness-progress-check` | `fitness-progress-check.lobster` | 🔲 |
| 25 | Program Generator | L5-routing/fitness | `^pipeline-fitness-program-generator` | `fitness-program-generator.lobster` | 🔲 |
| 26 | Rest Day Check | L5-routing/fitness | `^pipeline-fitness-rest-day-check` | `fitness-rest-day-check.lobster` | 🔲 |
| 27 | Habit Check-in | L5-routing/habits | `^pipeline-habits-habit-checkin` | `habits-habit-checkin.lobster` | 🔲 |
| 28 | Habit Review | L5-routing/habits | `^pipeline-habits-habit-review` | `habits-habit-review.lobster` | 🔲 |
| 29 | Streak Check | L5-routing/habits | `^pipeline-habits-streak-check` | `habits-streak-check.lobster` | 🔲 |
| 30 | Habit Update | L5-routing/habits | `^pipeline-habits-habit-update` | `habits-habit-update.lobster` | 🔲 |
| 31 | Habit Reminder | L5-routing/habits | `^pipeline-habits-habit-reminder` | `habits-habit-reminder.lobster` | 🔲 |
| 32 | Medication Tracker | L5-routing/pet-care | `^pipeline-pet-care-medication-tracker` | `pet-care-medication-tracker.lobster` | 🔲 |
| 33 | Appointment | L5-routing/pet-care | `^pipeline-pet-care-appointment` | `pet-care-appointment.lobster` | 🔲 |
| 34 | Feeding Schedule | L5-routing/pet-care | `^pipeline-pet-care-feeding-schedule` | `pet-care-feeding-schedule.lobster` | 🔲 |
| 35 | Supply List | L5-routing/pet-care | `^pipeline-pet-care-supply-list` | `pet-care-supply-list.lobster` | 🔲 |
| 36 | Training Log | L5-routing/pet-care | `^pipeline-pet-care-training-log` | `pet-care-training-log.lobster` | 🔲 |
| 37 | Grooming Schedule | L5-routing/pet-care | `^pipeline-pet-care-grooming-schedule` | `pet-care-grooming-schedule.lobster` | 🔲 |
| 38 | Brand Audit | L5-routing/design | `^pipeline-design-brand-audit` | `design-brand-audit.lobster` | 🔲 |

---

## §13–38 — L5 Category Pipelines ← L5-Routing

![[stack/L5-routing/categories/cooking/pipelines#^pipeline-cooking-grocery-list]]
![[stack/L5-routing/categories/cooking/pipelines#^pipeline-cooking-recipe-search]]
![[stack/L5-routing/categories/cooking/pipelines#^pipeline-cooking-meal-plan]]
![[stack/L5-routing/categories/cooking/pipelines#^pipeline-cooking-pantry-check]]
![[stack/L5-routing/categories/finance/pipelines#^pipeline-finance-market-brief]]
![[stack/L5-routing/categories/finance/pipelines#^pipeline-finance-position-check]]
![[stack/L5-routing/categories/finance/pipelines#^pipeline-finance-backtest]]
![[stack/L5-routing/categories/finance/pipelines#^pipeline-finance-watchlist]]
![[stack/L5-routing/categories/finance/pipelines#^pipeline-finance-budget-review]]
![[stack/L5-routing/categories/finance/pipelines#^pipeline-finance-expense-tracker]]
![[stack/L5-routing/categories/fitness/pipelines#^pipeline-fitness-workout-log]]
![[stack/L5-routing/categories/fitness/pipelines#^pipeline-fitness-progress-check]]
![[stack/L5-routing/categories/fitness/pipelines#^pipeline-fitness-program-generator]]
![[stack/L5-routing/categories/fitness/pipelines#^pipeline-fitness-rest-day-check]]
![[stack/L5-routing/categories/habits/pipelines#^pipeline-habits-habit-checkin]]
![[stack/L5-routing/categories/habits/pipelines#^pipeline-habits-habit-review]]
![[stack/L5-routing/categories/habits/pipelines#^pipeline-habits-streak-check]]
![[stack/L5-routing/categories/habits/pipelines#^pipeline-habits-habit-update]]
![[stack/L5-routing/categories/habits/pipelines#^pipeline-habits-habit-reminder]]
![[stack/L5-routing/categories/pet-care/pipelines#^pipeline-pet-care-medication-tracker]]
![[stack/L5-routing/categories/pet-care/pipelines#^pipeline-pet-care-appointment]]
![[stack/L5-routing/categories/pet-care/pipelines#^pipeline-pet-care-feeding-schedule]]
![[stack/L5-routing/categories/pet-care/pipelines#^pipeline-pet-care-supply-list]]
![[stack/L5-routing/categories/pet-care/pipelines#^pipeline-pet-care-training-log]]
![[stack/L5-routing/categories/pet-care/pipelines#^pipeline-pet-care-grooming-schedule]]
![[stack/L5-routing/categories/design/pipelines#^pipeline-design-brand-audit]]

---

## Build Notes

- **No `^pipeline-*` blocks in this file** — all pipeline definitions live in layer files
- The build script reads this scaffold to discover which blocks to extract (manifest-based)
- In Obsidian, this file renders the full pipeline inventory via transclusion for review
- **Deploy target:** `dist/pipelines/` → copies to `~/.openclaw/pipelines/` at install
- **Block ID convention:** `^pipeline-{name}` on the code fence containing Lobster YAML
- Worker sessions are responsible for adding `^pipeline-*` block IDs to L6 pipeline files

> **Config →** [[build/config-main]] | **Context →** [[build/context-main]] | **Env →** [[build/env-main]] | **Focus →** [[build/focus-main]]
