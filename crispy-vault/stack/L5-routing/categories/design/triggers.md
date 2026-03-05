---
tags: [type/reference, layer/routing, status/draft, category/design, focus/triggers]
---

# Design Triggers

> Trigger words, intent patterns, sub-category signals, and confidence levels for the design hat.

**Up →** [[stack/L5-routing/categories/design/_overview]]

---

## Trigger Words

### High Confidence (→ load hat immediately)
```
design, UI, UX, wireframe, mockup, prototype, layout,
typography, font, color palette, hex code, RGB, brand,
logo, icon, illustration, figma, sketch, photoshop,
responsive, mobile design, desktop design, component,
presentation, slide deck, pitch deck, infographic
```

### Medium Confidence (→ classify with context)
```
style, visual, aesthetic, clean, minimal, modern, flat,
spacing, padding, margin, grid, alignment, hierarchy,
contrast, whitespace, dark mode, light mode, theme,
template, asset, export, resolution, vector, raster,
pixel, SVG, PNG, banner, header, card, button, form,
accessibility, a11y, WCAG, color blind, screen reader
```

*Medium-confidence words like "style", "template", or "button" need context — could be coding (CSS button), Telegram (inline button), or design.*

---

## Sub-Category Signals

| Sub-Category | Additional Triggers |
|---|---|
| **ui-ux** | "interface", "user flow", "wireframe", "prototype", "usability", "interaction" |
| **graphic** | "image", "graphic", "banner", "poster", "social media post", "thumbnail" |
| **presentation** | "slides", "deck", "presentation", "pitch", "keynote", "powerpoint" |
| **brand** | "brand", "logo", "identity", "guidelines", "color scheme", "brand voice" |
| **review** | "does this look good", "feedback on", "review the design", "what do you think" |

---

## Intent Patterns

| Intent | What User Wants | Route | Example |
|---|---|---|---|
| `design:wireframe` | Create a wireframe or layout sketch | Agent loop (creative) | "Wireframe a settings page for the app" |
| `design:visual-design` | Create or refine visual design | Agent loop (creative) | "Design a hero section with a gradient background" |
| `design:review` | Get feedback on a design | Agent loop + code-review | "Does this layout feel balanced?" |
| `design:create-graphic` | Create a static visual asset | Agent loop (creative, tool-assisted) | "Make a social media banner for our launch" |
| `design:edit-graphic` | Modify an existing graphic | Agent loop (tool-assisted) | "Can you resize this for Instagram?" |
| `design:new-deck` | Create a presentation | Pipeline → pptx | "Build a pitch deck for our product" |
| `design:edit-deck` | Modify an existing presentation | Pipeline → pptx | "Update the Q3 slides with new numbers" |
| `design:brand-guide` | Create or reference brand guidelines | Agent loop (reference) | "What are our brand colors again?" |
| `design:brand-asset` | Create a brand-related asset | Agent loop (creative) | "Make a logo concept for the project" |
| `design:learn` | Understand a design concept | Agent loop (informational) | "What's the difference between UX and UI?" |
| `design:preference-update` | Tell Crispy a design preference | Memory write → confirm | "I prefer minimal, clean designs with lots of whitespace" |

^triggers-design
