# context-main.md — Master Context Assembly
<!-- SCAFFOLD FILE — do not hand-edit content. Edit the source files in stack/L4-session/context-files/ -->
<!-- This file assembles final context output via transclusion from individual context files. -->
<!-- Each ![[...#^block-id]] pulls content from the owning source file. -->

> **Config →** [[build/config-main]] | **Env →** [[build/env-main]]

---

# § SOUL — Personality & Values
<!-- Deploy section to: ~/.openclaw/workspace/SOUL.md -->
<!-- Budget: ~600 tokens | Injection: every session -->

![[stack/L4-session/context-files/soul#^ctx-soul-identity]]

![[stack/L4-session/context-files/soul#^ctx-soul-voice]]

![[stack/L4-session/context-files/soul#^ctx-soul-values]]

![[stack/L4-session/context-files/soul#^ctx-soul-relationships]]

![[stack/L4-session/context-files/soul#^ctx-soul-boundaries]]

![[stack/L4-session/context-files/soul#^ctx-soul-regrounding]]

---

# § IDENTITY — Who Am I
<!-- Deploy section to: ~/.openclaw/workspace/IDENTITY.md -->
<!-- Budget: ~400 tokens | Injection: every session -->

![[stack/L4-session/context-files/identity#^ctx-identity-card]]

![[stack/L4-session/context-files/identity#^ctx-identity-origin]]

![[stack/L4-session/context-files/identity#^ctx-identity-lore]]

---

# § AGENTS — Operating Contract
<!-- Deploy section to: ~/.openclaw/workspace/AGENTS.md -->
<!-- Budget: ~2,000 tokens | Injection: every session + subagents -->

![[stack/L4-session/context-files/agents#^ctx-agents-constraints]]

![[stack/L4-session/context-files/agents#^ctx-agents-priorities]]

![[stack/L4-session/context-files/agents#^ctx-agents-admins]]

![[stack/L4-session/context-files/agents#^ctx-agents-loop]]

![[stack/L4-session/context-files/agents#^ctx-agents-models]]

![[stack/L4-session/context-files/agents#^ctx-agents-memory]]

![[stack/L4-session/context-files/agents#^ctx-agents-channels]]

![[stack/L4-session/context-files/agents#^ctx-agents-subagents]]

![[stack/L4-session/context-files/agents#^ctx-agents-reminders]]

---

# § TOOLS — Capability Inventory
<!-- Deploy section to: ~/.openclaw/workspace/TOOLS.md -->
<!-- Budget: ~600 tokens | Injection: every session + subagents -->

![[stack/L4-session/context-files/tools#^ctx-tools-preferences]]

![[stack/L4-session/context-files/tools#^ctx-tools-forbidden]]

![[stack/L4-session/context-files/tools#^ctx-tools-gotchas]]

---

# § USER — Human Profiles
<!-- Deploy section to: ~/.openclaw/workspace/USER.md -->
<!-- Budget: ~400 tokens | Injection: every session -->

![[stack/L4-session/context-files/user#^ctx-user-marty-identity]]

![[stack/L4-session/context-files/user#^ctx-user-marty-style]]

![[stack/L4-session/context-files/user#^ctx-user-marty-tech]]

![[stack/L4-session/context-files/user#^ctx-user-marty-focus]]

![[stack/L4-session/context-files/user#^ctx-user-marty-accumulated]]

![[stack/L4-session/context-files/user#^ctx-user-wenting-identity]]

![[stack/L4-session/context-files/user#^ctx-user-wenting-prefs]]

![[stack/L4-session/context-files/user#^ctx-user-wenting-accumulated]]

---

# § MEMORY — Long-Term Memory
<!-- Deploy section to: ~/.openclaw/workspace/MEMORY.md -->
<!-- Budget: ~800 tokens | Injection: DM sessions only -->

![[stack/L4-session/context-files/memory#^ctx-memory-people]]

![[stack/L4-session/context-files/memory#^ctx-memory-projects]]

![[stack/L4-session/context-files/memory#^ctx-memory-decisions]]

![[stack/L4-session/context-files/memory#^ctx-memory-preferences]]

![[stack/L4-session/context-files/memory#^ctx-memory-facts]]

---

# § BOOT — Startup Hook
<!-- Deploy section to: ~/.openclaw/workspace/BOOT.md -->
<!-- Budget: ~300 tokens | Injection: gateway startup only -->

![[stack/L4-session/context-files/boot#^ctx-boot-health]]

![[stack/L4-session/context-files/boot#^ctx-boot-dashboard]]

![[stack/L4-session/context-files/boot#^ctx-boot-media]]

---

# § HEARTBEAT — System Pulse
<!-- Deploy section to: ~/.openclaw/workspace/HEARTBEAT.md -->
<!-- Budget: ~300 tokens | Injection: every 20min (flash model) -->

![[stack/L4-session/context-files/heartbeat#^ctx-heartbeat-checks]]

![[stack/L4-session/context-files/heartbeat#^ctx-heartbeat-notify]]

![[stack/L4-session/context-files/heartbeat#^ctx-heartbeat-never]]

![[stack/L4-session/context-files/heartbeat#^ctx-heartbeat-reminders]]

![[stack/L4-session/context-files/heartbeat#^ctx-heartbeat-tasks]]

---

# § BOOTSTRAP — First-Run Setup Ritual
<!-- Deploy section to: ~/.openclaw/workspace/BOOTSTRAP.md -->
<!-- Budget: ~400 tokens | Injection: first run only | Self-deletes after completion -->

![[stack/L4-session/context-files/bootstrap#^ctx-bootstrap-purpose]]

![[stack/L4-session/context-files/bootstrap#^ctx-bootstrap-steps]]

---

# § STATUS — Compaction Flush State
<!-- Deploy section to: ~/.openclaw/workspace/STATUS.md -->
<!-- Budget: ~300 tokens | Updated automatically during compaction -->

![[stack/L4-session/context-files/status#^ctx-status-session]]

![[stack/L4-session/context-files/status#^ctx-status-alerts]]

![[stack/L4-session/context-files/status#^ctx-status-carried]]

---

# Build Summary

| Section | Source File | Budget | Block IDs |
|---------|-----------|--------|-----------|
| § SOUL | `context-files/soul.md` | ~600 tok | `^ctx-soul-*` (6 blocks) |
| § IDENTITY | `context-files/identity.md` | ~400 tok | `^ctx-identity-*` (3 blocks) |
| § AGENTS | `context-files/agents.md` | ~2,000 tok | `^ctx-agents-*` (9 blocks) |
| § TOOLS | `context-files/tools.md` | ~600 tok | `^ctx-tools-*` (3 blocks) |
| § USER | `context-files/user.md` | ~400 tok | `^ctx-user-*` (8 blocks) |
| § MEMORY | `context-files/memory.md` | ~800 tok | `^ctx-memory-*` (5 blocks) |
| § BOOT | `context-files/boot.md` | ~300 tok | `^ctx-boot-*` (3 blocks) |
| § HEARTBEAT | `context-files/heartbeat.md` | ~300 tok | `^ctx-heartbeat-*` (5 blocks) |
| § BOOTSTRAP | `context-files/bootstrap.md` | ~400 tok | `^ctx-bootstrap-*` (2 blocks) |
| § STATUS | `context-files/status.md` | ~300 tok | `^ctx-status-*` (3 blocks) |
| **Total** | **10 files** | **~6,100 tok** | **47 blocks** |

> **Config →** [[build/config-main]] | **Env →** [[build/env-main]]
