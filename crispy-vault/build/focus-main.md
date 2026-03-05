# focus-main.md — Focus Mode Assembly Blueprint
<!-- SCAFFOLD FILE — do not hand-edit content. Edit the source files in stack/L5-routing/categories/ -->
<!-- This file registers all Focus Mode block IDs for the build system. -->
<!-- Each ![[...#^block-id]] pulls focus content from L5 category source files. -->
<!-- Deploy target: ~/.openclaw/workspace/focus/{category}/ -->

> **Config →** [[build/config-main]] | **Context →** [[build/context-main]] | **Env →** [[build/env-main]] | **Pipeline →** [[build/pipeline-main]]

---

## Architecture

Focus Mode uses a two-checkpoint system (see [[stack/L5-routing/categories/_overview]]):

```
CP1: Base role (SOUL + AGENTS + IDENTITY) — always loaded
CP2: Base + focus mode + domain memories — loaded when category activates
```

Per-category files deploy to `~/.openclaw/workspace/focus/{category}/` with this structure:

| File | Format | Block Pattern | Purpose |
|------|--------|---------------|---------|
| `mode.md` | Markdown | `^mode-{slug}` | Sub-role context injection (loaded at CP2) |
| `tree.json` | JSON | `^tree-{slug}` | Focus Tree — inline button navigation (zero-token, session state) |
| `triggers.json` | JSON | `^triggers-{slug}` | Trigger words and classification thresholds |
| `filter.json` | JSON | `^filter-{slug}` | Vector DB query filters and weights for memory retrieval |
| `compaction.md` | Markdown | `^compaction-{slug}` | Compaction summary prompt for context pruning |
| `speed.json` | JSON | `^speed-{slug}` | Latency baselines and token budgets |

---

## Assembly Order

The build script reads `^mode-*`, `^tree-*`, `^triggers-*`, `^filter-*`, `^compaction-*`, `^speed-*` blocks from L5 category files and deploys them as individual files per category.

### Categories

| # | Category | Slug | Source Directory | Status |
|---|----------|------|-----------------|--------|
| 1 | Cooking | `cooking` | `stack/L5-routing/categories/cooking/` | ✅ blocks tagged |
| 2 | Coding | `coding` | `stack/L5-routing/categories/coding/` | ✅ blocks tagged |
| 3 | Finance | `finance` | `stack/L5-routing/categories/finance/` | ✅ blocks tagged |
| 4 | Fitness | `fitness` | `stack/L5-routing/categories/fitness/` | ✅ blocks tagged |
| 5 | Habits | `habits` | `stack/L5-routing/categories/habits/` | ✅ blocks tagged |
| 6 | Pet Care | `pet-care` | `stack/L5-routing/categories/pet-care/` | ✅ blocks tagged |
| 7 | Design | `design` | `stack/L5-routing/categories/design/` | ✅ blocks tagged |

---

## § Cooking

<!-- Deploy to: ~/.openclaw/workspace/focus/cooking/ -->

### Hat (mode.md)
![[stack/L5-routing/categories/cooking/_overview#^mode-cooking]]

### Tree (tree.json)
![[stack/L5-routing/categories/cooking/focus-tree#^tree-cooking]]

### Triggers (triggers.json)
![[stack/L5-routing/categories/cooking/triggers#^triggers-cooking]]

### Filter (filter.json)
![[stack/L5-routing/categories/cooking/memory-filter#^filter-cooking]]

### Compaction (compaction.md)
![[stack/L5-routing/categories/cooking/memory-filter#^compaction-cooking]]

### Speed (speed.json)
![[stack/L5-routing/categories/cooking/speed-baselines#^speed-cooking]]

---

## § Coding

<!-- Deploy to: ~/.openclaw/workspace/focus/coding/ -->

### Hat (mode.md)
![[stack/L5-routing/categories/coding/_overview#^mode-coding]]

### Tree (tree.json)
![[stack/L5-routing/categories/coding/focus-tree#^tree-coding]]

### Triggers (triggers.json)
![[stack/L5-routing/categories/coding/triggers#^triggers-coding]]

### Filter (filter.json)
![[stack/L5-routing/categories/coding/memory-filter#^filter-coding]]

### Compaction (compaction.md)
![[stack/L5-routing/categories/coding/memory-filter#^compaction-coding]]

### Speed (speed.json)
![[stack/L5-routing/categories/coding/speed-baselines#^speed-coding]]

---

## § Finance

<!-- Deploy to: ~/.openclaw/workspace/focus/finance/ -->

### Hat (mode.md)
![[stack/L5-routing/categories/finance/_overview#^mode-finance]]

### Tree (tree.json)
![[stack/L5-routing/categories/finance/focus-tree#^tree-finance]]

### Triggers (triggers.json)
![[stack/L5-routing/categories/finance/triggers#^triggers-finance]]

### Filter (filter.json)
![[stack/L5-routing/categories/finance/memory-filter#^filter-finance]]

### Compaction (compaction.md)
![[stack/L5-routing/categories/finance/memory-filter#^compaction-finance]]

### Speed (speed.json)
![[stack/L5-routing/categories/finance/speed-baselines#^speed-finance]]

---

## § Fitness

<!-- Deploy to: ~/.openclaw/workspace/focus/fitness/ -->

### Hat (mode.md)
![[stack/L5-routing/categories/fitness/_overview#^mode-fitness]]

### Tree (tree.json)
![[stack/L5-routing/categories/fitness/focus-tree#^tree-fitness]]

### Triggers (triggers.json)
![[stack/L5-routing/categories/fitness/triggers#^triggers-fitness]]

### Filter (filter.json)
![[stack/L5-routing/categories/fitness/memory-filter#^filter-fitness]]

### Compaction (compaction.md)
![[stack/L5-routing/categories/fitness/memory-filter#^compaction-fitness]]

### Speed (speed.json)
![[stack/L5-routing/categories/fitness/speed-baselines#^speed-fitness]]

---

## § Habits

<!-- Deploy to: ~/.openclaw/workspace/focus/habits/ -->

### Hat (mode.md)
![[stack/L5-routing/categories/habits/_overview#^mode-habits]]

### Tree (tree.json)
![[stack/L5-routing/categories/habits/focus-tree#^tree-habits]]

### Triggers (triggers.json)
![[stack/L5-routing/categories/habits/triggers#^triggers-habits]]

### Filter (filter.json)
![[stack/L5-routing/categories/habits/memory-filter#^filter-habits]]

### Compaction (compaction.md)
![[stack/L5-routing/categories/habits/memory-filter#^compaction-habits]]

### Speed (speed.json)
![[stack/L5-routing/categories/habits/speed-baselines#^speed-habits]]

---

## § Pet Care

<!-- Deploy to: ~/.openclaw/workspace/focus/pet-care/ -->

### Hat (mode.md)
![[stack/L5-routing/categories/pet-care/_overview#^mode-pet-care]]

### Tree (tree.json)
![[stack/L5-routing/categories/pet-care/focus-tree#^tree-pet-care]]

### Triggers (triggers.json)
![[stack/L5-routing/categories/pet-care/triggers#^triggers-pet-care]]

### Filter (filter.json)
![[stack/L5-routing/categories/pet-care/memory-filter#^filter-pet-care]]

### Compaction (compaction.md)
![[stack/L5-routing/categories/pet-care/memory-filter#^compaction-pet-care]]

### Speed (speed.json)
![[stack/L5-routing/categories/pet-care/speed-baselines#^speed-pet-care]]

---

## § Design

<!-- Deploy to: ~/.openclaw/workspace/focus/design/ -->

### Hat (mode.md)
![[stack/L5-routing/categories/design/_overview#^mode-design]]

### Tree (tree.json)
![[stack/L5-routing/categories/design/focus-tree#^tree-design]]

### Triggers (triggers.json)
![[stack/L5-routing/categories/design/triggers#^triggers-design]]

### Filter (filter.json)
![[stack/L5-routing/categories/design/memory-filter#^filter-design]]

### Compaction (compaction.md)
![[stack/L5-routing/categories/design/memory-filter#^compaction-design]]

### Speed (speed.json)
![[stack/L5-routing/categories/design/speed-baselines#^speed-design]]

---

## Build Summary

| Category | Block IDs | Deploy Target | Files |
|----------|-----------|---------------|-------|
| Cooking | `^mode-cooking`, `^tree-cooking`, `^triggers-cooking`, `^filter-cooking`, `^compaction-cooking`, `^speed-cooking` | `focus/cooking/` | 6 |
| Coding | `^mode-coding`, `^tree-coding`, `^triggers-coding`, `^filter-coding`, `^compaction-coding`, `^speed-coding` | `focus/coding/` | 6 |
| Finance | `^mode-finance`, `^tree-finance`, `^triggers-finance`, `^filter-finance`, `^compaction-finance`, `^speed-finance` | `focus/finance/` | 6 |
| Fitness | `^mode-fitness`, `^tree-fitness`, `^triggers-fitness`, `^filter-fitness`, `^compaction-fitness`, `^speed-fitness` | `focus/fitness/` | 6 |
| Habits | `^mode-habits`, `^tree-habits`, `^triggers-habits`, `^filter-habits`, `^compaction-habits`, `^speed-habits` | `focus/habits/` | 6 |
| Pet Care | `^mode-pet-care`, `^tree-pet-care`, `^triggers-pet-care`, `^filter-pet-care`, `^compaction-pet-care`, `^speed-pet-care` | `focus/pet-care/` | 6 |
| Design | `^mode-design`, `^tree-design`, `^triggers-design`, `^filter-design`, `^compaction-design`, `^speed-design` | `focus/design/` | 6 |
| **Total** | **42 blocks** | **7 directories** | **42 files** |

---

## Build Notes

- **No focus blocks in this file** — all focus content lives in L5 category files
- The build script reads this scaffold to discover which blocks to extract (manifest-based)
- In Obsidian, this file renders the full focus inventory via transclusion for review
- **Format mapping:** `^mode-*` and `^compaction-*` → markdown files; `^tree-*`, `^triggers-*`, `^filter-*`, `^speed-*` → JSON files
- **Token budget at CP2:** ~3,400–3,800 tokens (~2% of 200K context window)
- Focus Trees are zero-token — stored in session state as JSON, rendered as L3 inline buttons
- Vector metadata from tree navigation paths trains the classifier over time

> **Config →** [[build/config-main]] | **Context →** [[build/context-main]] | **Env →** [[build/env-main]] | **Pipeline →** [[build/pipeline-main]]
