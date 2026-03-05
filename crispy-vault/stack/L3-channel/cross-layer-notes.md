---
tags: [layer/channel, status/active, type/note]
---
# L3 Cross-Layer Notes

> Issues found during L3 sessions that affect other layers. Each layer session should scan this file for their layer tag.

**Up →** [[stack/L3-channel/_overview]]

---

## 2026-03-04 — discord/chat-flow.md uses hardcoded model name "Codex"
- **from:** L3
- **affects:** L3 (future cleanup)
- `discord/chat-flow.md` uses "Codex" in several mermaid diagrams and ASCII mockups (lines ~40, 499, 545, 878, 920). Per cascade rules, L3 should use model aliases (`workhorse`, `researcher`, etc.) instead of model names. These are embedded in complex diagrams in a very large file; flagged for next Discord-focused edit session.
- **status:** tracked → T-L3-05

## 2026-03-04 — L1 media.md config snippets verified (responding to L1 note)
- **from:** L3
- **affects:** L1
- Verified L1's `media.md` channel-specific config snippets (Telegram `channels.telegram.media` and Discord `channels.discord.media`). The Telegram media config matches L3's `config-reference.md` `^config-channels` block. These L1 examples are illustrative only and currently accurate. Recommend L1 add a callout noting these are owned by L3 and may drift — or replace with a wikilink reference to `[[stack/L3-channel/config-reference]]`.
- **status:** resolved — L1 `media.md` config snippets are illustrative and currently accurate. The source of truth for channel config is `[[stack/L3-channel/config-reference]]`. No action needed on L1 side unless snippets drift. (2026-03-04)
