---
tags: [type/reference, layer/routing, status/draft, category/pet-care, focus/memory]
---

# Pet Care Memory Filter

> Vector DB query filter, memory types to retrieve, cross-category patterns, and compaction rules.

**Up →** [[stack/L5-routing/categories/pet-care/_overview]]

---

## Memory Filter Configuration

```json
{
  "category": ["pet-care", "pet-care:health", "pet-care:feeding", "pet-care:training", "pet-care:grooming"],
  "cross_category": ["cooking:grocery"],
  "exclude_categories": ["coding", "finance:markets"],
  "boost_fields": ["pet_name", "medication_name", "vet_name", "breed"],
  "recency_weight": 0.2,
  "semantic_weight": 0.3,
  "category_weight": 0.3,
  "frequency_weight": 0.2
}
```

^filter-pet-care

*Pet care memories are more stable than trading but less static than cooking preferences. Health history and medication schedules are always relevant. Cross-category with cooking:grocery for pet food supply overlap.*

---

## Memory Types to Retrieve

| Memory Type | Example | Priority |
|---|---|---|
| **Pet profiles** | "Luna: golden retriever, 2 years, 55 lbs, spayed" | Always load |
| **Current medications** | "Heartgard Plus, monthly, 1st of each month" | Always load |
| **Allergies/sensitivities** | "Chicken allergy — grain-free salmon kibble only" | Always load |
| **Vet info** | "Dr. Park at Riverside Vet, last visit Feb 15 for annual" | Load for health intents |
| **Feeding routine** | "2 cups morning, 2 cups evening, Blue Buffalo salmon" | Load for feeding intents |
| **Training progress** | "Knows: sit, down, stay, shake. Working on: recall, leave it" | Load for training intents |
| **Health history** | "Ear infection March 2025, treated with Otibiotic" | Load for health intents |
| **Weight history** | "Jan: 52 lbs, Feb: 54 lbs, Mar: 55 lbs" | Load for health/feeding intents |

---

## Compaction Rules

### Preserve
- Pet profile updates (weight changes, age milestones)
- Medication changes (new, stopped, dosage adjusted)
- Vet visit outcomes (diagnosis, treatment, follow-up needed)
- Training milestones (new commands learned, behavioral breakthroughs)
- Health incidents (symptoms, duration, resolution)
- Allergy or sensitivity discoveries
- Feeding routine changes

### Flush
- Routine daily walk updates (unless something notable happened)
- Repeated feeding schedule confirmations
- Generic pet care advice already known
- Supply list items already purchased
- Routine grooming confirmations (just the schedule matters)

### Compaction Summary Prompt (pet-care-specific)

```
Summarize this pet care conversation segment.

Preserve exactly:
- Any health concerns mentioned (symptoms, severity, outcome)
- Any medication changes (new, stopped, dosage)
- Any vet visit information (date, findings, follow-up)
- Any training milestones or behavioral observations
- Any feeding or dietary changes
- Any new pet information or profile updates

Do NOT include:
- Routine daily updates with no changes
- Generic pet care advice
- Supply items already purchased
- Repeated schedule confirmations

Output: max 200 tokens.
```

^compaction-pet-care

---

**Up →** [[stack/L5-routing/categories/pet-care/_overview]]
