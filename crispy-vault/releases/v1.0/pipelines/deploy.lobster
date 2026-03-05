# deploy.lobster — Auto-assembled from vault on 2026-03-04
# Source: stack/L6-processing/coding/deploy.md

flowchart TD
    CHECK["Deploy checklist<br>engineering:deploy-checklist skill"]:::purple
    CHECK --> STAGES["Check staging"]:::blue
    CHECK --> TESTS["Run tests"]:::blue
    CHECK --> DOCS["Verify docs"]:::blue
    CHECK --> CONFIG["Check config"]:::blue
    STAGES & TESTS & DOCS & CONFIG --> GATE["Approval gate"]:::red
    GATE -->|Approved| DEPLOY["Deploy to prod"]:::green
    GATE -->|Blocked| BLOCK["Fix issues first"]:::orange

    classDef purple fill:#ede9fe,stroke:#8b5cf6,color:#3b0764
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef orange fill:#fed7aa,stroke:#fb923c,color:#92400e
```

---

## Pre-Deployment Checklist

The `deploy-checklist` skill verifies:

| Check | Why | Status |
|---|---|---|
| **All tests pass** | Code works | Auto |
| **Staging deployment succeeds** | Safe to promote | Auto |
| **No breaking migrations** | Database safe | Manual |
| **Docs updated** | Team informed | Manual |
| **Config correct** | No env mismatches | Manual |
| **Rollback plan** | Can recover | Manual |
| **On-call notified** | Someone watching | Manual |

---

## Staging vs Production

### Staging Deployment

```mermaid
flowchart TD
    CODE["Code ready"]:::blue
    CODE --> STAGE["Deploy to staging<br>(non-critical environment)"]:::blue
    STAGE --> TEST["Test in staging<br>smoke tests + manual verification"]:::orange
    TEST --> OK{"Staging<br>OK?"}:::amber
    OK -->|No| REVERT["Revert staging"]:::red
    OK -->|Yes| PROD["Ready for production"]:::green

    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef orange fill:#fed7aa,stroke:#fb923c,color:#92400e
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
```

### Production Deployment

```mermaid
flowchart TD
    READY["Approved for production"]:::green
    READY --> BACKUP["Backup production"]:::blue
    BACKUP --> DEPLOY["Deploy to prod<br>(blue-green or canary)"]:::green
    DEPLOY --> MONITOR["Monitor metrics<br>(error rate, latency, etc)"]:::orange
    MONITOR --> OK{"Metrics<br>OK?"}:::amber
    OK -->|No| ROLLBACK["Execute rollback"]:::red
    OK -->|Yes| SUCCESS["✅ Deployment complete"]:::green

    classDef green fill:#dcfce7,stroke:#22c55e,color:#14532d
    classDef blue fill:#dbeafe,stroke:#3b82f6,color:#1e3a5f
    classDef orange fill:#fed7aa,stroke:#fb923c,color:#92400e
    classDef amber fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef red fill:#fee2e2,stroke:#ef4444,color:#7f1d1d
```

---

## Rollback Procedures

If production deployment has issues, rollback is automated:

```
⚠️ High error rate detected (5% → 15%)

Initiating rollback...

🔙 Rolling back to previous version
[Monitoring rollback progress...]

✅ Rollback complete
- Error rate: 5% (restored)
- Latency: normal
- All systems OK

Next steps:
1. Analyze what went wrong
2. Fix the issue locally
3. Re-deploy when ready
```

---

## Deployment Skill

Trigger with: "ready to deploy?", "pre-deploy check"

The skill:
- Runs pre-flight checks
- Verifies staging environment
- Confirms approval for production
- Monitors deployment metrics
- Initiates rollback if needed

---

## Config

Production deployment requires:
- Approval from authorized user
- All tests passing
- Staging verification passed
- Config correct for target environment
- Rollback plan in place

```
Pre-deployment checklist
- Staging deployment verified
- Tests passing
- Docs updated
- Config correct
- Rollback plan ready
- On-call notified
```

## Pipeline YAML

```yaml
name: deploy
description: >
  Deployment checklist and gated execution pipeline. Verifies staging health, runs test
  suite, checks config validity, then presents a human approval gate before executing
  deployment. Supports staging and production targets. Monitors post-deploy metrics and
  initiates rollback on error spike. Triggers via "deploy to staging/prod" or /deploy.
args:
  environment:
    default: "staging"
    description: "Target environment: staging or production"
  run_tests:
    default: "true"
steps:
  - id: check_staging
    command: exec --json --shell |
      curl -sf --max-time 10 "${STAGING_HEALTH_URL:-http://localhost:8080/health}" \
        && echo '{"healthy":true}' || echo '{"healthy":false}'
    timeout: 15000

  - id: run_tests
    command: exec --json --shell |
      cd ~/.openclaw/workspace
      if command -v pytest &>/dev/null; then pytest --tb=short -q 2>&1 | tail -5
      elif [ -f "package.json" ]; then npm test 2>&1 | tail -5
      else echo "No test runner found"; fi
    timeout: 120000
    condition: '$run_tests == "true"'

  - id: preflight
    command: openclaw.invoke --tool llm-task --action json \
      --args-json '{
        "model": "flash",
        "prompt": "Evaluate deploy readiness. Staging health: $check_staging_stdout. Test results: $run_tests_stdout. Return JSON: {ready: bool, blockers: [string], warnings: [string]}",
        "schema": {"type":"object","properties":{"ready":{"type":"boolean"},"blockers":{"type":"array"},"warnings":{"type":"array"}}}
      }'
    timeout: 15000

  - id: show_checklist
    command: exec --shell |
      echo "🚀 Deploy to $environment"
      echo ""
      echo "Staging: $(echo '$check_staging_json' | jq -r 'if .healthy then "✅ healthy" else "❌ unhealthy" end')"
      echo "Tests: $run_tests_stdout"
      echo ""
      echo "Preflight: $(echo '$preflight_json' | jq -r 'if .ready then "✅ ready" else "❌ blockers: \(.blockers | join(", "))" end')"

  - id: approve
    command: approve --preview-from-stdin --prompt "Proceed with deployment to $environment?"
    stdin: $show_checklist.stdout
    approval: required

  - id: deploy_exec
    command: exec --shell |
      echo "Deploying to $environment..."
      if [ "$environment" = "production" ]; then
        echo "⚠️  Production deployment — monitoring for 5 minutes post-deploy"
      fi
      echo "✅ Deployment initiated (integrate your deploy command here)"
    condition: $approve.approved
    timeout: 300000
