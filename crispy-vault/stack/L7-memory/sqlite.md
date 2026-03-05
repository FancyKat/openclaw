---
tags: [layer/memory, type/spec, status/planned]
---

# SQLite

> For dense structured data that needs exact queries. When markdown and vectors aren't enough. Portable `.db` files survives session resets. Method ④ in the memory stack.

**Up →** [[stack/L7-memory/_overview]]

---

## Status: ⏳ Not Yet Used

No setup needed — OpenClaw can natively read/write SQLite via the `exec` tool. Just create a `.db` file when the need arises.

---

## When to Use SQLite vs Other Methods

| Good for SQLite | Better as Markdown/Vectors |
|---|---|
| API endpoint registry (method, auth, rate limit) | "Marty prefers TypeScript" |
| Project task tracker with status/priority fields | "We decided to use Codex as primary" |
| Configuration change log with timestamps | Daily conversation summaries |
| Contact list with structured fields | Free-form notes and decisions |
| Endpoint catalog with test scripts | Cross-session patterns |

---

## How It Works

SQLite is a file-based relational database. Crispy can:

1. **Create** a schema (define tables with columns)
2. **Insert** rows of data
3. **Query** with SQL (SELECT WHERE, JOIN, etc.)
4. **Update** existing rows
5. **Delete** old records

All stored in a single `.db` file that persists across sessions.

---

## Use Cases

### Use Case 1: API Endpoint Registry

Track all endpoints, methods, auth, rate limits:

```sql
-- Create
CREATE TABLE endpoints (
  path TEXT PRIMARY KEY,
  method TEXT,
  auth_required BOOLEAN,
  rate_limit TEXT,
  description TEXT,
  last_tested DATE
);

-- Insert
INSERT INTO endpoints VALUES (
  '/users/{id}', 'GET', true, '100/min', 'Get user by ID', '2026-03-01'
);

-- Query: "Show all POST endpoints that need auth"
SELECT path, description FROM endpoints
WHERE method = 'POST' AND auth_required = 1;
```

### Use Case 2: Project Task Tracker

Track tasks with status, assignee, priority:

```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY,
  title TEXT,
  status TEXT,        -- 'todo', 'in-progress', 'done'
  priority TEXT,      -- 'low', 'medium', 'high'
  assignee TEXT,
  due_date DATE,
  created_at DATE
);

-- Query: "Show high-priority tasks due this week"
SELECT title, assignee FROM tasks
WHERE priority = 'high' AND due_date BETWEEN date('now') AND date('now', '+7 days');
```

### Use Case 3: Configuration Change Log

Track when configs changed and why:

```sql
CREATE TABLE config_log (
  id INTEGER PRIMARY KEY,
  key TEXT,
  old_value TEXT,
  new_value TEXT,
  changed_by TEXT,
  reason TEXT,
  timestamp DATETIME
);

-- Query: "Show all changes to model.fallbacks"
SELECT * FROM config_log WHERE key = 'model.fallbacks' ORDER BY timestamp DESC;
```

### Use Case 4: Documentation Index

Link docs to projects, tags, status:

```sql
CREATE TABLE docs (
  id INTEGER PRIMARY KEY,
  title TEXT,
  project TEXT,       -- 'OpenClaw', 'Crispy', etc
  path TEXT,
  tags TEXT,          -- comma-separated
  status TEXT,        -- 'draft', 'published', 'archived'
  last_updated DATE
);

-- Query: "Show all OpenClaw docs marked as draft"
SELECT title, path FROM docs
WHERE project = 'OpenClaw' AND status = 'draft';
```

---

## File Location

Keep `.db` files in `workspace/data/` so they're backed up with the rest of workspace:

```
workspace/
├── data/
│   ├── endpoints.db        ← API registry
│   ├── tasks.db            ← Project tracker
│   ├── changelog.db        ← Config history
│   └── index.db            ← Documentation index
├── memory/
├── AGENTS.md
└── ...
```

---

## Config

No special config needed. SQLite works through the `exec` tool:

```json5
// [[stack/L2-runtime/config-reference]] §7 — Tools
"tools": {
  "profile": "full"   // exec tool is available
}

// [[stack/L2-runtime/config-reference]] §3e — Sandbox
"agents.defaults.sandbox": {
  "workspaceAccess": "rw"   // can create .db files in workspace/data/
}
```

---

## How Crispy Uses It

### Create a Database

```bash
sqlite3 workspace/data/endpoints.db "
CREATE TABLE endpoints (
  path TEXT PRIMARY KEY,
  method TEXT,
  auth_required BOOLEAN,
  rate_limit TEXT,
  description TEXT,
  last_tested DATE
);
"
```

### Insert Data

```bash
sqlite3 workspace/data/endpoints.db "
INSERT INTO endpoints VALUES (
  '/api/users/{id}',
  'GET',
  1,
  '100 per minute',
  'Retrieve user by ID',
  '2026-03-01'
);
"
```

### Query Data

```bash
sqlite3 workspace/data/endpoints.db "
SELECT * FROM endpoints WHERE auth_required = 1;
"
```

### From Crispy's Perspective

```
User: "Create an endpoint tracker for OpenClaw API"

Crispy:
1. Asks clarification: "Which endpoints should we track?"
2. Designs schema with user
3. Creates database: sqlite3 workspace/data/endpoints.db "CREATE TABLE ..."
4. Populates it with known endpoints
5. Saves queries for future use (in TOOLS.md or comments)

User: "Find all endpoints with rate limiting"

Crispy:
1. Runs: sqlite3 workspace/data/endpoints.db "SELECT * FROM endpoints WHERE rate_limit IS NOT NULL"
2. Returns formatted results
```

---

## Common Queries

```sql
-- Count rows
SELECT COUNT(*) FROM endpoints;

-- Filter by value
SELECT * FROM endpoints WHERE method = 'POST';

-- Sort results
SELECT * FROM tasks ORDER BY due_date ASC;

-- Join two tables (if data is normalized)
SELECT e.path, t.title FROM endpoints e
JOIN tasks t ON e.id = t.endpoint_id
WHERE e.method = 'POST';

-- Aggregate (find patterns)
SELECT method, COUNT(*) as count FROM endpoints GROUP BY method;

-- Range query
SELECT * FROM config_log
WHERE timestamp BETWEEN '2026-03-01' AND '2026-03-02';
```

---

## Strengths & Weaknesses

| Strength | Weakness |
|---|---|
| Exact queries on structured data | Overkill for preferences/decisions |
| Portable (single .db file) | Requires Crispy to design schema first |
| Survives session resets forever | Not semantic — can't find "similar" results |
| SQL is universal | Adds schema design complexity |
| No external dependency | Needs `exec` tool access |
| Can normalize data (no duplication) | Requires JOIN queries for related data |

---

## Backup & Version Control

Since `.db` files are binary, they won't diff well in Git:

```bash
# Add to .gitignore if using version control
echo "workspace/data/*.db" >> .gitignore

# OR: Export as SQL for version control
sqlite3 workspace/data/endpoints.db ".dump" > workspace/data/endpoints-export.sql
git add workspace/data/endpoints-export.sql
```

**Recommendation:** Keep `.db` files in workspace (synced to GitHub as binary blobs), and export `.sql` dumps only if schema changes need review.

---

## Setup Steps (When Ready)

When you identify a need for structured data:

- [ ] Decide what data to track (APIs, tasks, logs, etc.)
- [ ] Design schema (what fields, what types?)
- [ ] Create `workspace/data/` directory if not exists
- [ ] Have Crispy design and create the schema
- [ ] Test with a few sample rows
- [ ] Write helper queries to `.sql` files for reference
- [ ] Add to workspace awareness scanner (so it's checked in daily scans)
- [ ] Document usage in TOOLS.md or a reference guide

---

## Example Workflow

```
User: "I want to catalog all the endpoints in the OpenClaw API"

Crispy:
1. "I'll create an endpoint tracker for you. Let me ask a few questions:
   - Should we include deprecated endpoints?
   - Do we need to track test scripts or examples?
   - Should I track response schema too?"

2. After getting answers, creates:
   $ sqlite3 workspace/data/endpoints.db "CREATE TABLE endpoints (...)"

3. Populates from docs:
   $ sqlite3 workspace/data/endpoints.db "INSERT INTO endpoints VALUES (...)"

4. Provides query examples:
   - Show all endpoints needing authentication
   - List endpoints by rate limit
   - Find endpoints added in last month

User: "Which endpoints can I call without authentication?"

Crispy:
$ sqlite3 workspace/data/endpoints.db "SELECT path, method FROM endpoints WHERE auth_required = 0"

Returns:
/health (GET)
/status (GET)
/docs (GET)
```

---

## Advanced: Triggers & Views

For very important catalogs, add triggers and views:

```sql
-- Automatically update 'last_modified' timestamp
CREATE TRIGGER endpoints_update AFTER UPDATE ON endpoints
BEGIN
  UPDATE endpoints SET last_modified = CURRENT_TIMESTAMP WHERE rowid = NEW.rowid;
END;

-- View: All endpoints that need testing
CREATE VIEW endpoints_untested AS
SELECT path, method FROM endpoints
WHERE last_tested IS NULL OR last_tested < date('now', '-30 days');

-- Then query the view
SELECT * FROM endpoints_untested;
```

---

## When to Move Data to SQLite

| Signal | Action |
|---|---|
| Data has 3+ fields | Consider SQLite |
| Queries get complex | Definitely use SQLite |
| Need to track relationships | Use SQLite + JOINs |
| Data > 1000 rows | Use SQLite for performance |
| Updates need to be atomic | Use SQLite for transactions |
