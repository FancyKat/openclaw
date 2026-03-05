---
tags: [layer/physical, status/draft, type/index]
layer_name: "Physical"
layer_number: 1
layer_slug: "L1-physical"
config_blocks: ["^config-gateway", "^config-hooks"]
file_count: 9
status_summary: "draft"

# ── HARDWARE: CPU ──
hardware_cpu_model: "Intel Core i9-14900K"
hardware_cpu_model_reason: "High-core-count consumer CPU; Raptor Lake Refresh; 24C/32T for multi-agent orchestration"
hardware_cpu_cores: "24C/32T (8P + 16E)"
hardware_cpu_cores_reason: "8 performance + 16 efficiency cores; sufficient for gateway + Docker + embedding"
hardware_cpu_status: "DEGRADED — Channel A IMC failure"
hardware_cpu_status_reason: "Known batch defect in 14900K; memory controller channel A non-functional; RMA pending"

# ── HARDWARE: MOTHERBOARD ──
hardware_motherboard: "ASUS Z790 GAMING WIFI7"
hardware_motherboard_reason: "Z790 chipset for i9-14900K; 4x DDR5, PCIe 5.0 x16, WiFi 7, 3x M.2 slots"

# ── HARDWARE: MEMORY ──
hardware_ram_model: "Corsair Dominator Titanium 64GB DDR5-6600"
hardware_ram_model_reason: "High-speed DDR5 for future LLM inference headroom; 2x32GB kit"
hardware_ram_capacity: "64GB"
hardware_ram_capacity_reason: "Comfortable for gateway + Docker services + OS (~32GB used, ~32GB free)"
hardware_ram_status: "Single-channel (~38 GB/s)"
hardware_ram_status_reason: "CPU IMC channel A failure forces both sticks into channel B; halves bandwidth"

# ── HARDWARE: GPU ──
hardware_gpu_model: "EVGA GeForce GTX 1060 6GB"
hardware_gpu_model_reason: "Pascal placeholder; no tensor cores; inadequate for local LLM inference"
hardware_gpu_vram: "6GB GDDR5"
hardware_gpu_vram_reason: "7B quantized models need 4-6GB leaving no headroom; Ollama falls back to CPU"
hardware_gpu_status: "Placeholder — no local LLM inference"
hardware_gpu_status_reason: "Upgrade planned to RTX 5080 (16GB) or 5090 (32GB) for local inference"

# ── HARDWARE: STORAGE ──
hardware_nvme_model: "Samsung 990 PRO"
hardware_nvme_model_reason: "PCIe 4.0 NVMe; 7,450 MB/s read; primary OS + workspace + media drive"
hardware_nvme_capacity: "1TB"
hardware_nvme_capacity_reason: "OS ~50GB + workspace ~20GB + Docker ~10GB + media ~20GB = ~900GB free"
hardware_nvme_interface: "PCIe 4.0 x4"
hardware_nvme_interface_reason: "Native Z790 slot; no PCIe bottleneck for gateway or media I/O"
hardware_nvme_role: "OS + primary workload"
hardware_nvme_role_reason: "All workspace, media, pipelines, skills live here; fast random I/O for gateway"

hardware_sata_model: "Samsung 870 EVO"
hardware_sata_model_reason: "Reliable SATA SSD for vector DB; sequential read sufficient for similarity search"
hardware_sata_capacity: "1TB"
hardware_sata_capacity_reason: "Qdrant embeddings projected ~200GB; ample room for growth"
hardware_sata_interface: "SATA III"
hardware_sata_interface_reason: "560 MB/s read; vector query bottleneck is embedding model, not disk"
hardware_sata_role: "Qdrant Vector DB"
hardware_sata_role_reason: "Dedicated drive isolates vector I/O from OS; prevents disk contention"

# ── HARDWARE: POWER ──
hardware_psu_model: "Corsair RM1000e"
hardware_psu_model_reason: "ATX 3.1, 12V-2x6 connector ready for RTX 50-series; 80+ Gold efficiency"
hardware_psu_wattage: "1000W"
hardware_psu_wattage_reason: "Current draw ~400W; overspecced to support future RTX 5080/5090 upgrade"

# ── HARDWARE: OS ──
hardware_os: "Ubuntu 24.04 LTS"
hardware_os_reason: "5-year LTS support; native Docker, systemd; standard for server workloads"

# ── NETWORK: GATEWAY ──
network_gateway_port: 18789
network_gateway_port_reason: "Default OpenClaw port; avoids conflict with SSH (22), HTTP (80/443), common services"
network_gateway_bind: "loopback"
network_gateway_bind_reason: "Security: no remote access without tunnel (Tailscale/ngrok/SSH forward)"
network_gateway_mode: "local"
network_gateway_mode_reason: "Single-user local deployment; all agent connections are localhost"
network_gateway_auth_mode: "token"
network_gateway_auth_mode_reason: "Requires OPENCLAW_GATEWAY_TOKEN in .env; prevents unauthorized local access"

# ── SANDBOX: DOCKER ──
sandbox_mode: "all"
sandbox_mode_reason: "Maximum isolation; every exec command runs inside Docker regardless of session type"
sandbox_scope: "session"
sandbox_scope_reason: "Fresh container per conversation; prevents state pollution between sessions"
sandbox_workspace_access: "rw"
sandbox_workspace_access_reason: "Sub-agents need read-write to workspace for git, project work, memory writes"
sandbox_docker_enabled: true
sandbox_docker_enabled_reason: "Docker required for exec isolation; host must have daemon running"
sandbox_docker_readonly_root: true
sandbox_docker_readonly_root_reason: "Immutable container root; prevents system file writes; limits blast radius"
sandbox_docker_image: "openclaw-sandbox:bookworm-slim"
sandbox_docker_image_reason: "Default OpenClaw sandbox image; Debian Bookworm slim base with dev tools pre-installed"
sandbox_docker_network: "bridge"
sandbox_docker_network_reason: "Bridge allows outbound network (git clone, API calls, pip install) while isolating"
sandbox_docker_memory: "2g"
sandbox_docker_memory_reason: "2GB per container; sufficient for Node.js/Python tasks; hardware has 64GB headroom"
sandbox_docker_cpus: 2
sandbox_docker_cpus_reason: "2 CPUs per container; i9-14900K has 24C/32T so plenty of headroom for parallel sessions"

# ── MEDIA: STORAGE ──
media_base_path: "~/.openclaw/workspace/media"
media_base_path_reason: "Under workspace for sandbox rw access; organized into inbound/outbound/cache/archive"
media_max_file_size_mb: 2000
media_max_file_size_mb_reason: "Telegram/Discord file limits allow up to 2GB; handles video without blocking"
media_keep_sizes: "large"
media_keep_sizes_reason: "Telegram sends 3 photo sizes; store only large to save disk (~60% reduction)"
media_cache_24h: true
media_cache_24h_reason: "CDN downloads cached 24h; prevents re-download of same media within a day"
media_metadata_format: "json"
media_metadata_format_reason: "Sidecar .metadata.json files; queryable with jq; integrates with pipelines"
media_archive_retention_days: 90
media_archive_retention_days_reason: "90 days balances recall ability with storage; archive ~5-15GB at steady state"
media_cleanup_schedule: "0 2 * * *"
media_cleanup_schedule_reason: "Daily 2am (low-activity window); moves >30d to archive, deletes >90d from archive"

# ── MEDIA: HOOKS ──
media_hook_kind: "lobster"
media_hook_kind_reason: "Deterministic Lobster pipeline; zero token cost; runs before agent sees the message"
media_hook_pipeline: "pipelines/media-sort.lobster"
media_hook_pipeline_reason: "Entry point for all inbound media; identifies channel + type, sorts to organized path"
media_hook_trigger: "message.inbound"
media_hook_trigger_reason: "Fires on every inbound message event at gateway level"
media_hook_condition: "message.hasAttachment"
media_hook_condition_reason: "Only processes messages with media attachments; skips text-only messages"

# ── AGGREGATION METADATA ──
aggregation_source_count: 5
aggregation_source_count_reason: "Consolidated from: hardware, network, sandbox, media (storage + inbound flow)"
aggregation_last_updated: "2026-03-02"

# ── VERSION TRACKING (managed by build/build.sh) ──
version_major: 0
version_minor: 0
version_patch: 6
version_full: "0.0.6"
version_changes: 8
version_last_build: 12
version_notes: "Sandbox fields aligned with OpenClaw docs, hooks merged, stale refs fixed, restart runbook added"
---

# L1 — Physical Layer

> What exists on the machine. Hardware, containers, filesystem, and network. If you can touch it (or SSH into it), it lives here.
> **This file is the single source of truth for all L1 properties.** Other L1 files reference these values via Dataview inline queries.

**OSI parallel:** Physical + Data Link — the raw infrastructure that everything else sits on top of.

## Contents

- [[#Diagrams]]
  - [[#What's at This Layer]] · `flowchart`
  - [[#Docker Sandbox]] · `flowchart`
  - [[#Hardware — Marty's Desktop]] · `flowchart`
  - [[#Filesystem Layout]] · `flowchart`
  - [[#Sandbox Model]] · `flowchart`
- [[#Hardware]]
- [[#Network]]
  - [[#Gateway — The Core Process]] · `flowchart`
  - [[#Outbound API Connections]] · `flowchart`
  - [[#Inbound Connections (Webhooks & Admin)]] · `flowchart`
  - [[#Startup Sequence]] · `flowchart`
- [[#Network Configuration]]
- [[#Media Storage]]
- [[#System Topology]]
- [[#Pages in This Layer]]
- [[#Property Schema Reference]]
- [[#Layer Boundary]]
- [[#L1 File Review (Live)]]

---

## Diagrams

### What's at This Layer

```mermaid
flowchart TD
    L1["L1 — Physical"]:::gray
    L1 --> HW["Hardware<br>i9-14900K · 64GB DDR5<br>GTX 1060 6GB"]:::blue
    L1 --> DOCKER["Docker<br>Sandbox for exec commands<br>Read-write workspace only"]:::green
    L1 --> FS["Filesystem<br>~/.openclaw/ directory tree<br>workspace, pipelines, skills"]:::blue
    L1 --> NET["Network<br>Port 18789 (gateway)<br>Outbound: APIs, Telegram, Discord"]:::teal
    L1 --> MEDIA["Media Storage<br>inbound/ · outbound/<br>cache/ · archive/"]:::orange

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef orange fill:#fff7ed,stroke:#f97316,color:#7c2d12
```

---

## Hardware

> Deep dive → [[stack/L1-physical/hardware]]

| Component | Spec | Notes |
|-----------|------|-------|
| **CPU** | `= this.hardware_cpu_model` (`= this.hardware_cpu_cores`) | ⚠️ `= this.hardware_cpu_status` |
| **RAM** | `= this.hardware_ram_capacity` `= this.hardware_ram_model` | ⚠️ `= this.hardware_ram_status` |
| **GPU** | `= this.hardware_gpu_model` | `= this.hardware_gpu_status` |
| **NVMe** | `= this.hardware_nvme_capacity` `= this.hardware_nvme_model` | `= this.hardware_nvme_role` |
| **SATA** | `= this.hardware_sata_capacity` `= this.hardware_sata_model` | `= this.hardware_sata_role` |
| **OS** | `= this.hardware_os` | Always-on, 24/7 |

This machine is an **inference client**, not an inference server. All LLM calls go to external APIs (OpenAI, Anthropic, DeepSeek, Google). The GPU is unused for AI work.

---

## Docker Sandbox

All `exec` commands run inside a Docker container with restricted access:

### Docker Sandbox

```mermaid
flowchart LR
    HOST["Host OS"]:::gray
    HOST --> DOCKER["Docker Container<br>(OpenClaw runtime)"]:::green
    DOCKER --> WS["~/.openclaw/workspace/<br>(read-write)"]:::blue
    DOCKER --> PIPE["~/.openclaw/pipelines/<br>(read-only)"]:::blue
    DOCKER -->|"❌ No access"| SYS["System files,<br>other user data"]:::red

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

| Key | Value | Why |
|-----|-------|-----|
| Mode | `= this.sandbox_mode` | `= this.sandbox_mode_reason` |
| Scope | `= this.sandbox_scope` | `= this.sandbox_scope_reason` |
| Workspace | `= this.sandbox_workspace_access` | `= this.sandbox_workspace_access_reason` |
| Docker | `= this.sandbox_docker_enabled` | `= this.sandbox_docker_enabled_reason` |
| Image | `= this.sandbox_docker_image` | `= this.sandbox_docker_image_reason` |
| Read-only root | `= this.sandbox_docker_readonly_root` | `= this.sandbox_docker_readonly_root_reason` |
| Network | `= this.sandbox_docker_network` | `= this.sandbox_docker_network_reason` |
| Memory | `= this.sandbox_docker_memory` | `= this.sandbox_docker_memory_reason` |
| CPUs | `= this.sandbox_docker_cpus` | `= this.sandbox_docker_cpus_reason` |

**Key constraint:** Exec can only write to the workspace directory. This is the first guardrail — L1 limits blast radius before any other layer gets involved.

---

### Hardware — Marty's Desktop

```mermaid
flowchart TD
    PC["🖥️ Desktop Build<br>i9-14900K · 64GB DDR5<br>Linux x86_64"]:::green
    PC --> GW["OpenClaw Gateway<br>localhost:18789"]:::blue
    PC --> FS["Local Filesystem<br>~/.openclaw/"]:::gray
    PC --> NET["Network<br>Tailscale / LAN"]:::teal

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
```

### Filesystem Layout

```mermaid
flowchart TD
    HOME["~/.openclaw/"]:::gray
    HOME --> CFG["openclaw.json + .env"]:::blue
    HOME --> WS["workspace/"]:::purple
    HOME --> PIPE["pipelines/ · skills/"]:::green
    HOME --> OTHER["sessions/ · agents/"]:::gray

    WS --> BOOT["Bootstrap files (10)<br>AGENTS, SOUL, TOOLS, etc."]:::purple
    WS --> MEM["memory/<br>daily logs"]:::purple
    WS --> MEDIA["media/<br>inbound · outbound · archive"]:::orange
    WS --> PROJ["projects/<br>git repos (sandbox rw)"]:::teal

    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef orange fill:#fff7ed,stroke:#f97316,color:#7c2d12
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
```

Notice how the filesystem is shared across layers — the Physical layer provides the storage, but each file is **owned by** the layer that reads/writes it.

---

### Sandbox Model

```mermaid
flowchart TD
    CRISPY["Crispy agent"]:::purple
    CRISPY --> EXEC["exec tool<br>(sandboxed)"]:::amber
    CRISPY --> WS["workspace/<br>rw access"]:::green
    CRISPY --> DOCK["Docker containers<br>(if available)"]:::blue
    CRISPY -.- NOHOME["❌ No access to ~/<br>or system files"]:::red

    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

## Network

### Gateway — The Core Process

```mermaid
flowchart TD
    GW["OpenClaw Gateway<br>localhost:18789"]:::blue
    GW --> AUTH["Token auth<br>$OPENCLAW_GATEWAY_TOKEN"]:::red
    GW --> BIND["bind: loopback<br>local-only access"]:::green
    GW --> MODE["mode: local<br>single-user"]:::green

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

### Outbound API Connections

```mermaid
flowchart TD
    TG["Telegram API<br>(outbound HTTPS)"]:::teal
    DC["Discord API<br>(outbound WSS)"]:::blue
    OR["OpenRouter<br>(outbound HTTPS)"]:::blue
    OAI["OpenAI Codex<br>(outbound HTTPS)"]:::green
    GEM["Google Gemini<br>(outbound HTTPS)"]:::teal

    GW["Gateway :18789<br>(loopback only)"]:::gray

    GW --> TG
    GW --> DC
    GW --> OR
    GW --> OAI
    GW --> GEM

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
```

### Inbound Connections (Webhooks & Admin)

```mermaid
flowchart TD
    HK["Gmail Webhook<br>(inbound HTTPS)"]:::amber
    TS["Tailscale<br>(remote SSH / admin)"]:::teal

    HK --> GW["Gateway :18789"]:::gray
    TS --> PC["Desktop shell"]:::green

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
    classDef gray fill:#f3f4f6,stroke:#9ca3af,color:#1f2937
```

### Startup Sequence

```mermaid
flowchart TD
    S1["Load .env"]:::red
    S2["Parse openclaw.json"]:::blue
    S3["Validate config<br>(openclaw doctor)"]:::blue
    S4["Start gateway :18789"]:::green
    S5["Connect channels<br>(Telegram poll, Discord WSS)"]:::teal
    S6["Ready for messages"]:::green
    S1 --> S2 --> S3 --> S4 --> S5 --> S6

    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef teal fill:#ccfbf1,stroke:#14b8a6,color:#134e4a
```

## Network Configuration

| Key | Value | Why |
|-----|-------|-----|
| Port | `= this.network_gateway_port` | `= this.network_gateway_port_reason` |
| Bind | `= this.network_gateway_bind` | `= this.network_gateway_bind_reason` |
| Mode | `= this.network_gateway_mode` | `= this.network_gateway_mode_reason` |
| Auth | `= this.network_gateway_auth_mode` | `= this.network_gateway_auth_mode_reason` |

| Direction | Port/Protocol | Purpose | Layer Owner |
|---|---|---|---|
| **Inbound** | TCP `= this.network_gateway_port` | Gateway API | L2 — Runtime |
| **Outbound** | HTTPS | OpenAI, Anthropic, DeepSeek, Google APIs | L6 — Processing |
| **Outbound** | HTTPS | Telegram Bot API | L3 — Channel |
| **Outbound** | HTTPS/WSS | Discord Gateway + REST API | L3 — Channel |
| **Outbound** | HTTPS | Brave Search API | L6 — Processing |
| **Inbound** | Webhook (optional) | Gmail push notifications | L3 — Channel |

---

## Media Storage

| Key | Value | Why |
|-----|-------|-----|
| Base path | `= this.media_base_path` | `= this.media_base_path_reason` |
| Max file size | `= this.media_max_file_size_mb` MB | `= this.media_max_file_size_mb_reason` |
| Keep sizes | `= this.media_keep_sizes` | `= this.media_keep_sizes_reason` |
| Cache 24h | `= this.media_cache_24h` | `= this.media_cache_24h_reason` |
| Metadata | `= this.media_metadata_format` | `= this.media_metadata_format_reason` |
| Archive retention | `= this.media_archive_retention_days` days | `= this.media_archive_retention_days_reason` |
| Cleanup schedule | `= this.media_cleanup_schedule` | `= this.media_cleanup_schedule_reason` |

### Media Hook (Primary Sorter)

| Key | Value | Why |
|-----|-------|-----|
| Kind | `= this.media_hook_kind` | `= this.media_hook_kind_reason` |
| Pipeline | `= this.media_hook_pipeline` | `= this.media_hook_pipeline_reason` |
| Trigger | `= this.media_hook_trigger` | `= this.media_hook_trigger_reason` |
| Condition | `= this.media_hook_condition` | `= this.media_hook_condition_reason` |

---

## System Topology

> What runs where. For setup steps, see [[stack/L1-physical/runbook]].

The gateway is the single process — if it's down, everything is down. No ports are exposed to the public internet; Telegram/Discord use outbound connections, Gmail hooks need a tunnel.

| Subsystem | Deep Dive | Key Facts |
|-----------|-----------|-----------|
| Hardware | [[stack/L1-physical/hardware]] | i9-14900K (⚠️ degraded), 64GB DDR5, GTX 1060 placeholder |
| Network | [[stack/L1-physical/network]] | Port 18789 loopback, token auth, Tailscale for remote |
| Sandbox | [[stack/L1-physical/sandbox]] | Docker mode `all`, session scope, read-only root |
| Filesystem | [[stack/L1-physical/filesystem]] | `~/.openclaw/` runtime tree + planning vault |
| Media | [[stack/L1-physical/media]] | 4-layer defense: hook → AGENTS.md → BOOT.md → cron |
| Config blocks | [[stack/L1-physical/config-reference]] | `^config-gateway` + `^config-hooks` for openclaw.json |

---

## Pages in This Layer

| Page | Covers |
|---|---|
| [[stack/L1-physical/config-reference]] | `^config-gateway` + `^config-hooks` blocks for openclaw.json |
| [[stack/L1-physical/hardware]] | CPU, RAM, GPU specs, machine capabilities |
| [[stack/L1-physical/sandbox]] | Docker sandbox, full field reference, modes and scopes |
| [[stack/L1-physical/filesystem]] | Full directory layout — runtime + vault |
| [[stack/L1-physical/media]] | Media inbound/outbound/cache/archive structure + 4-layer defense |
| [[stack/L1-physical/network]] | Port 18789, inbound/outbound routing, API access |
| [[stack/L1-physical/runbook]] | Hardware verification, workspace/sandbox setup, media maintenance |
| [[stack/L1-physical/CHANGELOG]] | Layer changelog — all L1 changes by date |
| [[stack/L1-physical/cross-layer-notes]] | Cross-layer notes from L1 audit sessions |

---

## Property Schema Reference

All L1 properties live in this file's frontmatter. Other L1 files reference them via `= [[_overview]].property_name`. Property names follow `{subsystem}_{concept}` naming.

| Group | Prefix | Count | From |
|-------|--------|-------|------|
| CPU | `hardware_cpu_*` | 3 | hardware.md |
| Motherboard | `hardware_motherboard` | 1 | hardware.md |
| Memory | `hardware_ram_*` | 3 | hardware.md |
| GPU | `hardware_gpu_*` | 3 | hardware.md |
| NVMe storage | `hardware_nvme_*` | 4 | hardware.md |
| SATA storage | `hardware_sata_*` | 4 | hardware.md |
| Power | `hardware_psu_*` | 2 | hardware.md |
| OS | `hardware_os` | 1 | hardware.md |
| Gateway | `network_gateway_*` | 4 | network.md |
| Sandbox | `sandbox_*` | 9 | sandbox.md |
| Media storage | `media_*` (not hook) | 7 | media.md |
| Media hooks | `media_hook_*` | 4 | media.md |

---

## Layer Boundary

**L1 provides to L2:** A running machine with Docker, network access, and a filesystem.

**L1 does NOT care about:** What's in the config files, which models are configured, or what messages say. It just provides the infrastructure.

**If L1 breaks:** Nothing works. Docker down = no gateway. Disk full = no memory writes. Network down = no API calls.

---

## L1 File Review (Live)

```dataview
TABLE WITHOUT ID
  file.link AS "File",
  choice(contains(file.frontmatter.tags, "status/finalized"), "✅",
    choice(contains(file.frontmatter.tags, "status/review"), "🔍",
      choice(contains(file.frontmatter.tags, "status/planned"), "⏳", "📝"))) AS "Status",
  choice(contains(file.frontmatter.tags, "type/guide"), "Guide", "Core") AS "Type",
  dateformat(file.mtime, "yyyy-MM-dd") AS "Last Modified"
FROM "stack/L1-physical"
WHERE file.name != "_overview"
SORT choice(contains(file.frontmatter.tags, "type/guide"), "Z", "A") ASC, file.name ASC
```

**Legend:** ✅ Finalized · 🔍 Review (content solid, verify against live) · 📝 Draft (needs work) · ⏳ Planned (skeleton only)

---

**Up -->** [[stack/L2-runtime/_overview]]
**Back -->** [[stack/_overview]]
