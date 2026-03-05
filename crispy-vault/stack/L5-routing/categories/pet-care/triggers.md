---
tags: [type/reference, layer/routing, status/draft, category/pet-care, focus/triggers]
---

# Pet Care Triggers

> High-confidence, medium-confidence, and sub-category trigger signals for pet care intent classification.

**Up →** [[stack/L5-routing/categories/pet-care/_overview]]

---

## High Confidence (→ load hat immediately)

```
dog, cat, pet, puppy, kitten, vet, veterinarian, kibble,
walk, walkies, potty, litter box, leash, collar, harness,
groom, grooming, flea, tick, heartworm, vaccination, neuter,
spay, breed, adopt, shelter, paws, fur, coat, tail
```

---

## Medium Confidence (→ classify with context)

```
feed, feeding, treat, treats, play, toy, bed, crate,
bark, meow, scratch, bite, chew, shed, shedding,
training, sit, stay, come, heel, fetch, roll over,
anxious, anxiety, scared, aggressive, behavior, obedience,
appointment, medicine, pill, dose, schedule, weight
```

*Medium-confidence words like "training", "weight", or "schedule" need context — could be fitness (training program), cooking (ingredient weight), or pet care.*

---

## Sub-Category Signals

| Sub-Category | Additional Triggers |
|---|---|
| **health** | "vet", "sick", "limping", "not eating", "vomiting", "medication", "shot" |
| **feeding** | "food", "kibble", "wet food", "how much to feed", "treats", "diet" |
| **training** | "teach", "command", "behavior", "obedience", "crate training", "potty" |
| **grooming** | "bath", "nails", "brush", "haircut", "groomer", "matted", "shedding" |
| **supplies** | "need to buy", "running low on", "best brand of", "where to get" |
| **activity** | "walk", "play", "exercise", "dog park", "daycare", "boarding" |

^triggers-pet-care

---

## Intent Patterns

| Intent | What User Wants | Route | Example |
|---|---|---|---|
| `pet-care:health-check` | Check on a health concern | Agent loop (informational, NOT vet) | "My dog is limping after our walk" |
| `pet-care:medication` | Track or manage medications | Pipeline → medication-tracker | "When is Luna's next heartworm pill?" |
| `pet-care:vet-schedule` | Schedule or check vet appointments | Pipeline → appointment | "Luna's due for her annual checkup" |
| `pet-care:feeding-plan` | Feeding schedule or nutrition question | Agent loop (practical) | "How much should I feed a 30lb dog?" |
| `pet-care:supply-list` | Need pet supplies | Pipeline → supply-list | "I need to stock up on dog food and treats" |
| `pet-care:training-log` | Log or discuss training progress | Pipeline → training-log | "Luna learned 'leave it' today!" |
| `pet-care:training-help` | How to train a specific behavior | Agent loop (learning) | "How do I stop my dog from pulling on the leash?" |
| `pet-care:grooming-schedule` | Track grooming appointments or routines | Pipeline → grooming-schedule | "When was Luna's last nail trim?" |
| `pet-care:preference-update` | Tell Crispy about a pet or pet preference | Memory write → confirm | "Luna is a 2-year-old golden retriever, 55 lbs" |

---

**Up →** [[stack/L5-routing/categories/pet-care/_overview]]
