---
tags: [layer/physical, type/note, status/active]
---
# L1 — Physical Changelog

> All changes to this layer. Each session adds a dated entry.

**Up →** [[stack/L1-physical/_overview]]

---

## 2026-03-04 — Block format standardization + cross-layer notes cleanup

### Changed
- `config-reference.md` — Reformatted `^config-gateway` and `^config-hooks` to COMMENT → BLOCK → ID pattern. Removed inline `//` comments from JSON. Moved metadata comments before code fence. Pure JSON in code fences. (T-L1-01)
- `cross-layer-notes.md` — Deleted all 3 resolved notes (all were marked resolved 2026-03-04). File now contains only frontmatter, heading, description, and Up link.

---

## 2026-03-04 — Cleanup pass (session-prompt re-audit)

### Removed
- `_overview.md.bak` — Leftover backup file from previous edit session. Deleted.

### Changed
- `sandbox.md` — Fixed broken link: `coding/workflows` → `coding/_overview` (file was split)
- `runbook.md` — Fixed 2 broken links: `coding/workflows` → `coding/_overview`

### Verified
- Config blocks `^config-gateway` and `^config-hooks` properly tagged and registered in `build/config-main.md`
- All wikilinks use full paths for repeated filenames
- `00-INDEX.md` L1 section clean — no `.md` extensions in wikilinks
- Cross-layer note (`.md` extensions in 00-INDEX.md) confirmed resolved for L1–L7 sections
- File count: 9 files (config-reference, hardware, sandbox, filesystem, media, network, runbook, CHANGELOG, cross-layer-notes) — updated from 10 after removing .bak

---

## 2026-03-04 — Full layer audit (session-prompt Phase 2–5)

### Removed
- `l1-skill-reference.md` — Redundant; all content already covered by hardware.md, sandbox.md, network.md, media.md, runbook.md, config-reference.md. Deleted per session-prompt instructions.

### Changed
- `_overview.md` — Removed l1-skill-reference from Pages table. Added `layer_name`, `layer_number`, `layer_slug`, `config_blocks`, `file_count`, `status_summary` frontmatter properties per CLAUDE.md § Frontmatter Properties.
- `filesystem.md` — Updated directory listing: replaced l1-skill-reference.md entry with CHANGELOG.md entry.

### Added
- `CHANGELOG.md` — This file. Layer changelog created per session-prompt Phase 3 template.

### Cross-Layer Effects
- `00-INDEX.md` — Removed link to deleted l1-skill-reference.md.
- L1 cross-layer note (2026-03-04, .md extensions in 00-INDEX.md) still open — L2–L7 entries need fixing during their audits.
