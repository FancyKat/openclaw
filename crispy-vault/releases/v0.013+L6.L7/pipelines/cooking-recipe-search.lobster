# cooking-recipe-search.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/cooking/pipelines.md

{
  "query": "salmon air fryer",
  "filters": {
    "cuisine": ["Japanese", "Asian"],
    "dietary_restrictions": ["no_cilantro"]
  },
  "limit": 3
}
```

**Output Schema:**
```json
{
  "recipes": [
    {
      "name": "Miso-Glazed Air Fryer Salmon",
      "rating": 4.5,
      "prep_time": "5 min",
      "cook_time": "15 min",
      "key_ingredients": ["salmon fillet", "miso paste", "sesame oil"],
      "memory_ref": "recipe:20250215:salmon_miso"
    }
  ]
}
```

**Dependencies:** Vector DB, memory service

### Lobster YAML

```yaml
name: cooking-recipe-search
description: >
  Searches Crispy's saved recipe memory by ingredient, cuisine, or name. Extracts
  the search query using the flash model, runs a semantic vector search against saved
  recipes, re-ranks results by user preferences and past ratings, then returns top 3
  recipe cards. Two LLM calls (flash for query extraction, main for re-ranking).
  Target latency 500ms–1.2s.
args:
  raw_message:
    default: ""
steps:
  - id: extract_query
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"flash","prompt":"Extract the recipe search intent. Return: {\"query\":\"string\",\"cuisine\":[\"strings\"],\"dietary_restrictions\":[\"strings\"],\"keywords\":[\"strings\"]}","input":"${raw_message}"}'
  - id: vector_search
    command: openclaw.invoke --tool web_fetch --action post --args-json '{"url":"memory://vector/search","body":{"collection":"recipes","query":"$extract_query_json.query","limit":10}}'
  - id: rerank
    command: openclaw.invoke --tool llm-task --action json --args-json '{"model":"workhorse","prompt":"Re-rank these recipes based on the user query and preferences. Consider dietary restrictions, cuisine preferences, and past ratings. Return top 3 as [{name, rating, prep_time, cook_time, key_ingredients, memory_ref}].","input":{"query":"$extract_query_json","results":"$vector_search_json"}}'
    stdin: $vector_search.stdout
  - id: format_cards
    command: openclaw.invoke --tool llm-task --action text --args-json '{"model":"flash","prompt":"Format these recipe results as a warm, scannable response. Show recipe name, rating, prep+cook time, and top 3 ingredients per recipe.","input":"$rerank_json"}'
    stdin: $rerank.stdout
