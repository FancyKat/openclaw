---
tags: [type/dashboard, status/draft]
---

# Version Dashboard

Live version information and status tracking for the Crispy Kitsune project.

## Layer Versions (Live)

```dataview
TABLE version_full AS Version, version_changes AS Changes, version_last_build AS "Last Build", version_notes AS Notes
FROM "stack"
WHERE contains(file.name, "_overview")
SORT file.folder ASC
```

## File Status by Layer

```dataview
TABLE
  choice(
    contains(file.frontmatter.tags, "status/finalized"),
    "✅",
    choice(
      contains(file.frontmatter.tags, "status/review"),
      "🔍",
      choice(
        contains(file.frontmatter.tags, "status/planned"),
        "⏳",
        choice(
          contains(file.frontmatter.tags, "status/draft"),
          "📝",
          "❓"
        )
      )
    )
  ) AS Status,
  file.mtime AS "Last Modified"
FROM "stack"
WHERE file.name != "_overview"
SORT file.folder ASC, file.name ASC
```

## Recently Modified (Last 7 Days)

```dataview
TABLE
  file.folder AS Layer,
  file.mtime AS "Modified"
FROM "stack"
WHERE file.name != "_overview" AND file.mtime >= date(now) - dur(7 days)
SORT file.mtime DESC
```

## Quick Links

- [[CHANGELOG]]
- [[versions.json]]
- [[build/README]]
- [[00-INDEX]]
