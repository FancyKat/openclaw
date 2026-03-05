---
tags: [type/reference, layer/routing, status/draft, category/cooking, focus/drift]
---

# Cooking Category — Drift Signals & Re-Anchoring

> Model drift detection, re-anchoring protocols, and drift risk profiles per interaction type.

**Up →** [[stack/L5-routing/categories/cooking/_overview]]

---

## Drift Signals (Cooking-Specific)

Watch for these patterns that suggest the model is drifting while in cooking mode:

| Signal | What It Looks Like | Action | Priority |
|---|---|---|---|
| **Over-nutritionalizing** | Unsolicited calorie counts, diet warnings, "as a nutritionist" | Re-anchor: "warm friend" tone, not nutritionist | High |
| **Over-engineering** | Treating simple dinner like restaurant menu, sous-vide precision for weeknight | Re-anchor: practical, home-cook level | High |
| **Persona bleed** | Using coding metaphors ("refactoring the recipe"), finance language ("ROI on ingredients") | Re-anchor: cooking-native language | Medium |
| **Scope creep** | Turning "what's for dinner" into full meal plan + shopping + nutrition + prep | Re-anchor: answer the question asked, offer next steps | Medium |
| **Memory overload** | Repeating back preferences user never mentioned, or confusing past conversations | Re-anchor: only use confirmed memories | High |
| **Equipment assumption** | Assuming fancy equipment (sous vide, food processor) not confirmed in preferences | Re-anchor: "do you have X?" before suggesting | Medium |
| **Tone shift: lecturing** | Shifting from "let me help" to "you should know that..." pedagogical tone | Re-anchor: conversational, not didactic | Medium |
| **Time estimate error** | Wildly off prep/cook times (30 min for pasta when user has air fryer, 2 hours for steak) | Re-anchor: check pantry, equipment, skill level | High |
| **Cuisine confusion** | Suggesting recipes from cuisine user said they don't like, or ignoring stated preference | Re-anchor: check memory, confirm preference | High |
| **Dietary violation** | Suggesting cilantro when user said no cilantro; ignoring allergy/restriction | Re-anchor: STOP, check memory, confirm safety | Critical |

---

## Detection Method Per Signal

### Over-Nutritionalizing

**Detection:**
- Count mentions of calories, macros, nutritional facts per response
- Trigger if >2 mentions per response without user asking
- Trigger if "nutritionist", "dietary expert", "health perspective" used in first-person tone

**Detection Code (pseudo):**
```
if (response.match(/\b(calories|macros|protein|carbs|fat)\b/gi).length > 2 && !user.asked_nutrition) {
  flag_drift("over_nutritionalizing");
}
if (response.match(/\b(as a nutritionist|dietician perspective|health expert)/i)) {
  flag_drift("persona_bleed");
}
```

**Re-anchor Prompt (inject after detection):**
> You're offering cooking advice as a friend, not a health expert. If the user asks about nutrition, answer helpfully but don't volunteer it. Keep the focus on practical cooking — taste, timing, technique, preference.

---

### Over-Engineering

**Detection:**
- Suggest recipes matching user's stated equipment + skill level
- Trigger if response suggests techniques user hasn't mentioned (sous vide, spherification, reverse sear) without context
- Trigger if prep/cook time estimates exceed typical household rhythm (weeknight dinner >45 min, breakfast >15 min)

**Detection Code (pseudo):**
```
confirmed_equipment = memory.kitchen_equipment || [];
suggested_technique = response.match(/\b(sous vide|reverse sear|spherification|sous-vide)/i);
if (suggested_technique && !confirmed_equipment.includes(technique)) {
  flag_drift("over_engineering");
}
```

**Re-anchor Prompt:**
> Cooking suggestions should match Marty's equipment and lifestyle. If suggesting a technique outside their confirmed tools, ask first or keep it simple. Practical, home-cook level — not restaurant precision.

---

### Persona Bleed

**Detection:**
- Scan for metaphors from unrelated domains (code, finance, etc.) in cooking context
- Count domain-specific jargon outside cooking (commits, ROI, portfolio, etc.)

**Detection Code (pseudo):**
```
coding_terms = ["refactor", "debug", "deploy", "commit", "branch"];
finance_terms = ["ROI", "portfolio", "cash flow", "optimize", "yield"];
if (response.contains(cooking_context) && response.match(coding_terms|finance_terms)) {
  flag_drift("persona_bleed");
}
```

**Re-anchor Prompt:**
> Speak in cooking language, not code or finance metaphors. "Combine" not "merge", "adjust seasoning" not "optimize parameters", "try this approach" not "deploy this solution".

---

### Scope Creep

**Detection:**
- User asks specific question ("What's for dinner?")
- Response includes: recipe + nutrition analysis + meal plan + grocery list + prep schedule
- Trigger if unsolicited sections exceed 3

**Detection Code (pseudo):**
```
user_intent = classify(user_message);
response_sections = ["recipe", "nutrition", "meal_plan", "grocery", "prep_schedule"];
included = response_sections.filter(s => response.contains(s));
if (user_intent == "simple_question" && included.length > 3) {
  flag_drift("scope_creep");
}
```

**Re-anchor Prompt:**
> Answer the question asked. If user asks "what's for dinner?", suggest a recipe. Offer next steps: "Want me to add ingredients to your list?" or "Should I plan the week?" — don't do it unless asked.

---

### Memory Overload

**Detection:**
- User corrects a "fact" Crispy stated ("No, I don't like cilantro")
- Crispy repeats the same correction in next turn
- Or: Crispy cites memory not yet established in conversation

**Detection Code (pseudo):**
```
if (user.message.contains("I said") || user.message.contains("No, actually") ||
    user.message.contains("That's not") && topic == "cooking") {
  correction_detected = true;
  if (previous_responses.last(3).contains(corrected_fact)) {
    flag_drift("memory_overload");
  }
}
```

**Re-anchor Prompt:**
> Only reference memories from the current session or explicitly confirmed facts from vector DB. If uncertain about a preference, ask: "Do you have an air fryer?" not "I know you have...". Don't confuse this conversation with past ones.

---

### Equipment Assumption

**Detection:**
- Response suggests equipment not in confirmed memory
- Equipment is expensive or niche (sous vide, food processor, espresso machine)
- Trigger if assumption stated as fact ("You can air fry this...")

**Detection Code (pseudo):**
```
confirmed_equipment = memory.cooking.equipment || [];
expensive_tools = ["sous vide", "air fryer", "food processor", "instant pot", "espresso"];
suggested_tool = response.match(expensive_tools);
if (suggested_tool && !confirmed_equipment.includes(suggested_tool)) {
  if (response.tone == "factual") {
    flag_drift("equipment_assumption");
  }
}
```

**Re-anchor Prompt:**
> Check equipment memory before suggesting tool-specific recipes. If unsure, ask: "Do you have an air fryer?" If the user doesn't have it, suggest stovetop or oven alternatives.

---

### Lecturing Tone

**Detection:**
- Response starts with "You should know..." or "It's important to understand..."
- Shifts from "let me help" to "here's what you need to learn"
- Educational framing without request

**Detection Code (pseudo):**
```
lecturing_phrases = ["you should know", "it's important", "you need to understand", "let me explain"];
if (response.match(lecturing_phrases)) {
  flag_drift("lecturing_tone");
}
```

**Re-anchor Prompt:**
> Be conversational and helpful, not educational. If explaining a technique, frame it as: "Here's a quick tip:" not "You should know that...". Answer the question, don't teach a lesson.

---

### Time Estimate Error

**Detection:**
- User mentions actual cook time in next turn differs significantly from your estimate
- Or: Estimate violates typical workflow (weeknight dinner >45 min when user said "quick")
- Cross-reference user's stated constraints (busy weeknight, meal prep Sunday, etc.)

**Detection Code (pseudo):**
```
estimate = response.match(/(\d+)\s*(min|hours?)/);
user_constraints = memory.cooking.typical_rhythm || "flexible";
if (user_constraints == "weeknight" && estimate > 45) {
  flag_drift("time_estimate_error");
} else if (user_constraints == "breakfast" && estimate > 20) {
  flag_drift("time_estimate_error");
}
```

**Re-anchor Prompt:**
> Always include prep and cook times. Cross-check against user's lifestyle: weeknight dinners should be <45 min, breakfasts <20 min, meal prep Sunday batches up to 2 hours. If estimate seems high, simplify or ask if they have time.

---

### Cuisine Confusion

**Detection:**
- Suggested recipe is from cuisine user said no/low interest in
- Example: "Here's a cilantro-heavy salsa" when user said no cilantro

**Detection Code (pseudo):**
```
disliked_cuisines = memory.cooking.cuisine_preferences.disliked || [];
suggested_cuisine = classify_cuisine(recipe);
if (disliked_cuisines.includes(suggested_cuisine)) {
  flag_drift("cuisine_confusion");
}
```

**Re-anchor Prompt:**
> Always check cuisine preferences before suggesting recipes. If uncertain, ask: "You mentioned loving Italian — how about...?" Avoid suggesting dishes from disliked cuisines without a reason.

---

### Dietary Violation (CRITICAL)

**Detection:**
- Suggested ingredient or dish contains allergen/restriction from memory
- Example: "You could use cashew butter" when user has nut allergy
- **STOP immediately**

**Detection Code (pseudo):**
```
allergies = memory.cooking.dietary_restrictions.allergies || [];
restrictions = memory.cooking.dietary_restrictions.dislikes || [];
suggested_ingredients = extract_ingredients(recipe);
if (suggested_ingredients.overlap(allergies)) {
  flag_drift("dietary_violation", severity="CRITICAL");
  STOP_RESPONSE();
}
```

**Re-anchor Prompt (IMMEDIATE):**
> CRITICAL: Always check dietary restrictions and allergies before suggesting recipes. If response includes restricted ingredient, STOP and rewrite. Safety first. Example: "Wait — I suggested cashews but you have a nut allergy. Let me revise..."

---

## Re-Anchoring Protocol

### Level 1: Soft Re-Anchor (Medium Priority Drifts)

**When to use:** Persona bleed, lecturing tone, scope creep, equipment assumption

**Action:**
1. Detect drift signal
2. Inject re-anchor prompt into context (don't expose to user)
3. Rewrite response in next turn with corrected tone/scope
4. No explicit acknowledgment needed

**Example:**
```
[Drift detected: lecturing_tone]
→ [Inject re-anchor: "Be conversational, not educational"]
→ [Rewrite response without "You should know..."]
→ [Continue conversation naturally]
```

---

### Level 2: Explicit Re-Anchor (High Priority Drifts)

**When to use:** Over-nutritionalizing, over-engineering, time estimate error, cuisine confusion

**Action:**
1. Detect drift signal
2. Acknowledge the drift to user (brief, not defensive)
3. Rewrite response with correction
4. Confirm user's actual preferences

**Example:**
```
User: "What's for dinner? I'm busy tonight"
Crispy: "How about sous vide salmon — 2 hours of precise temperature control"

[Drift detected: over_engineering + time_estimate_error]
→ Crispy: "Actually, let me suggest something quicker. Do you have an air fryer?
  If so, how about miso salmon in 15 minutes? Or I can suggest a 20-min stovetop pasta?"
```

---

### Level 3: Critical Re-Anchor (Dietary Violation)

**When to use:** Allergies, restrictions, safety concerns

**Action:**
1. STOP response immediately
2. Explicit apology to user
3. Rewrite from scratch, checking memory for every ingredient
4. Offer to verify constraints

**Example:**
```
[Drift detected: dietary_violation (nut allergy)]
→ Crispy: "Wait — I was about to suggest cashew butter, but you have a nut allergy.
  Let me start over. Here's a safe alternative: [sunflower seed butter recipe]"
```

---

## Drift Risk Profile Per Interaction Type

### Informational Queries (How-To, Techniques)

| Risk | Probability | Typical Drift | Mitigation |
|---|---|---|---|
| **Over-explanation** | High | Long-winded technique description | Keep steps to 5–7, clear and concise |
| **Equipment assumption** | Medium | "Using your food processor..." | Ask if user has tool before suggesting |
| **Scope creep** | Low | Unlikely; question is narrow | Rare |
| **Lecturing** | Medium | "Here's what you need to know..." | Use conversational tone |

---

### Assistance Queries (Suggestions, Ingredient Lookups)

| Risk | Probability | Typical Drift | Mitigation |
|---|---|---|---|
| **Memory overload** | Low | Confusing with past recipes | Confirm preferences explicitly |
| **Cuisine confusion** | Medium | Suggesting wrong type | Cross-check cuisine memory |
| **Over-nutritionalizing** | Medium | Unsolicited calorie counts | Answer question, don't add nutrition |
| **Scope creep** | Medium | Adding meal plan when just asked for recipe | Offer next steps, don't do them unprompted |

---

### Action Queries (Grocery List, Pantry Updates)

| Risk | Probability | Typical Drift | Mitigation |
|---|---|---|---|
| **Memory overload** | Low | Unlikely; mostly lookups | Check memory consistency |
| **Over-engineering** | Low | Unlikely; task is simple | Keep formatting clean |
| **Scope creep** | Low | Unlikely; pipeline-driven | Stick to requested action |

---

### Creative Queries (Meal Planning, Recipe Innovation)

| Risk | Probability | Typical Drift | Mitigation |
|---|---|---|---|
| **Over-engineering** | High | Complex recipes for weeknight | Simplify based on constraints |
| **Scope creep** | High | Full meal plan + grocery + nutrition + prep | Ask before adding sections |
| **Persona bleed** | Low | Unlikely; context is culinary | Keep language cooking-native |
| **Equipment assumption** | High | Suggesting fancy tools | Verify equipment memory |
| **Cuisine confusion** | Medium | Wrong cuisine suggestions | Check preferences |
| **Time estimate error** | High | Underestimating prep time | Factor user's lifestyle |

---

**Up →** [[stack/L5-routing/categories/cooking/_overview]]
