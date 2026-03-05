# habits-streak-check.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L5-routing/categories/habits/pipelines.md

name: habits-streak-check
description: >
  Queries all active habit streaks and returns a ranked leaderboard with current vs
  personal-best streaks. Compares current streaks to stored personal bests, highlights
  milestones, and celebrates new records. Zero LLM calls — fully deterministic. Target
  latency 100–300ms.
steps:
  - id: load_streaks
    command: exec --json --shell 'openclaw memory recall "habits:streaks" 2>/dev/null || echo "{}"'
  - id: load_personal_bests
    command: exec --json --shell 'openclaw memory recall "habits:personal-bests" 2>/dev/null || echo "{}"'
  - id: build_leaderboard
    command: exec --json --shell 'jq -n --argjson s "$load_streaks_json" --argjson pb "$load_personal_bests_json" "[(\$s | to_entries[] | {habit: .key, current: .value, personal_best: (\$pb[.key] // .value), is_record: (.value >= (\$pb[.key] // .value))})] | sort_by(-.current)"'
  - id: update_personal_bests
    command: exec --shell 'jq -n --argjson l "$build_leaderboard_json" "[\$l[] | select(.is_record)] | map({(.habit): .current}) | add // {}" | openclaw memory store "habits:personal-bests" -'
  - id: format_leaderboard
    command: exec --shell 'echo "$build_leaderboard_json" | jq -r ".[] | \"🔥 \(.habit): \(.current) days\(if .is_record then \" 🏆 new record!\" else \" (best: \(.personal_best))\" end)\""'
    stdin: $build_leaderboard.stdout
