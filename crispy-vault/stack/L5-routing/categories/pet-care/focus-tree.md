---
tags: [type/reference, layer/routing, status/draft, category/pet-care, focus/tree]
---

# Pet Care Focus Tree

> Navigation hierarchy for pet care sub-categories, focus tree structure, and pipeline mapping.

**Up →** [[stack/L5-routing/categories/pet-care/_overview]]

---

## Focus Tree

```
🐾 Pet Care Focus (CP2 active)
├── 🏥 Health                           ← vet and medical
│   ├── 💊 Medications                 → medication-tracker pipeline
│   ├── 📅 Vet Visits                  → appointment pipeline
│   └── 🤒 Symptoms                    → agent loop (informational, NOT vet)
│
├── 🍖 Feeding                         ← food and nutrition
│   ├── 📋 Schedule                    → feeding-schedule pipeline
│   └── 🛒 Supplies                    → supply-list pipeline
│
├── 🎓 Training                        ← behavior and commands
│   ├── 📝 Log Progress                → training-log pipeline
│   └── 💡 Techniques                  → agent loop (learning)
│
└── ✂️ Grooming                        ← maintenance
    ├── 📅 Schedule                    → grooming-schedule pipeline
    └── 🛒 Supplies                    → supply-list pipeline
```

^tree-pet-care

---

**Up →** [[stack/L5-routing/categories/pet-care/_overview]]
