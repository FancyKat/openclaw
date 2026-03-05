---
tags: [channel/gmail, layer/channel, status/draft, type/runbook]
---

# Gmail Runbook

> Step-by-step implementation guides for Gmail webhook integration: setup, email triage pipeline, notification rules, and debugging.

---

## Gmail Setup Guide


Configure Gmail to send webhooks when emails arrive, and authenticate Crispy to fetch email content via Gmail API.

**Steps:**

1. **Create Google Cloud Project**
   - Go to Google Cloud Console
   - Create new project
   - Enable Gmail API
   - Enable Cloud Pub/Sub API

2. **Create Service Account**
   - Create service account for Gmail API
   - Download JSON key file
   - Grant service account access to Gmail inbox (domain-wide delegation)

3. **Set Up Pub/Sub Topic & Subscription**
   - Create Pub/Sub topic (e.g., `gmail-emails`)
   - Create subscription to deliver to webhook
   - Configure push endpoint: `https://your-domain.com/hooks/gmail`

4. **Configure Gmail Webhook**
   - In Gmail settings, set up filter to route emails to Pub/Sub topic
   - Test webhook with sample email

5. **Add credentials to .env**
   ```bash
   GOOGLE_SERVICE_ACCOUNT_JSON="path/to/service-account.json"
   OPENCLAW_HOOKS_TOKEN="secret-token-for-webhook-auth"
   ```

6. **Configure openclaw.json**
   ```json5
   {
     "channels": {
       "gmail": {
         "enabled": true,
         "serviceAccountKey": "${GOOGLE_SERVICE_ACCOUNT_JSON}",
         "webhookToken": "${OPENCLAW_HOOKS_TOKEN}",
         "gmailAddress": "your-email@gmail.com"
       }
     }
   }
   ```

7. **Test**
   - Send test email to your Gmail inbox
   - Verify webhook is received
   - Check logs for any errors

For full details, see [[stack/L3-channel/gmail/_overview]]

---

## Email Pipeline Guide


The `email.lobster` pipeline handles incoming emails: extracting metadata, classifying urgency, and routing to handlers.

**Pipeline structure:**
```yaml
name: email
triggers: [gmail_webhook]
timeout: 30s

steps:
  - id: parse
    command: # Parse email from webhook payload

  - id: classify
    command: # Classify urgency (urgent/normal/low)

  - id: draft_reply
    command: # Draft response (optional)

  - id: route
    command: # Route to alert or triage pipeline
```

**Features:**
- Extract: from, to, subject, body, attachments
- Classify: urgency level based on keywords/sender
- Draft: AI-generated reply (for common emails)
- Route: urgent → immediate alert, normal → batch processing

**Example flow:**
```
Email arrives (AWS billing alert)
     ↓
Parse: from=aws@amazon.com, subject="Billing alert"
     ↓
Classify: urgent=true (billing keywords)
     ↓
Draft: "Acknowledged, investigating..."
     ↓
Route: Send urgent alert to Telegram + draft reply button
```

---

## Notification Rules Guide


Configure urgency detection and notification routing for different types of emails.

**Urgency levels:**
- 🔴 Urgent: Immediate notification + sound (Telegram DM)
- 🟡 Medium: Notification, no sound
- 🟢 Low: Batched every 10 minutes

**Routing rules:**
```json5
{
  "gmail": {
    "urgency_rules": [
      {
        "from": ["aws@amazon.com"],
        "keywords": ["billing", "alert"],
        "level": "urgent"
      },
      {
        "from": ["github.com"],
        "keywords": ["security", "vulnerability"],
        "level": "urgent"
      },
      {
        "from": ["newsletters@"],
        "level": "low"
      },
      {
        "default": "medium"
      }
    ]
  }
}
```

**Gmail labels:**
- `crispy/inbox` — All incoming emails
- `crispy/urgent` — Flagged as urgent
- `crispy/processed` — Already handled
- `crispy/flagged` — Manual review needed

---

## Gmail Debugging Guide


Troubleshooting Gmail webhook integration, authentication, quota limits, and testing.

**Common issues:**

**Webhook not receiving emails:**
- [ ] Check Pub/Sub topic subscription is push to correct URL
- [ ] Verify `OPENCLAW_HOOKS_TOKEN` matches webhook header
- [ ] Test webhook with `curl -X POST https://your-domain.com/hooks/gmail -H "Authorization: Bearer $TOKEN"`

**Gmail API authentication failing:**
- [ ] Verify service account key is valid JSON
- [ ] Check service account has Gmail API permissions
- [ ] Verify domain-wide delegation is enabled

**Quota limits exceeded:**
- Gmail API has limits (per day/per minute)
- Implement caching to avoid re-fetching same emails
- Batch process instead of real-time if needed

**Email parsing errors:**
- [ ] Check MIME format is standard RFC 5322
- [ ] Test with `gmail_parse_email.py` script
- [ ] Enable debug logging for raw payload

**Testing checklist:**
```bash
# 1. Test webhook endpoint
curl -X POST https://your-domain.com/hooks/gmail \
  -H "Authorization: Bearer $OPENCLAW_HOOKS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"test":"true"}'

# 2. Test service account auth
python -c "from google.oauth2 import service_account; \
  creds = service_account.Credentials.from_service_account_file('key.json'); \
  print('Auth OK')"

# 3. Test Gmail API call
gmail_test_api.py --service-account key.json --test-email your@gmail.com

# 4. Send test email and monitor logs
```

---

## Webhook Payload Format

**Gmail sends:**
```json
{
  "message": {
    "attributes": {
      "messageId": "...",
      "publishTime": "..."
    },
    "data": "..."  // base64-encoded email metadata
  }
}
```

**Decoded payload:**
```json
{
  "email": "your@gmail.com",
  "historyId": 12345,
  "messages": [{
    "id": "msg_123",
    "threadId": "thread_456"
  }]
}
```

**Crispy fetches full email:**
```
GET https://www.googleapis.com/gmail/v1/users/me/messages/msg_123
Authorization: Bearer {service_account_token}
```

---

## Email Triage Logic

**Classification:**
1. Parse sender address (from @ domain)
2. Check against urgency_rules
3. Scan subject + body for keywords
4. Apply rule with highest match
5. Return urgency level

**Routing:**
```
if urgency == urgent:
  → notify.lobster (Telegram alert)
  → draft.lobster (draft reply)
  → approval gate (user approves before sending)
else if urgency == medium:
  → queue for batch processing (email.lobster)
else:
  → archive + skip processing
```

---

## Privacy & Security

**Data handling:**
- Email bodies are processed only for classification/drafting
- Store minimal metadata (from, subject, urgency level)
- Don't retain email content long-term
- Encryption at rest for stored metadata

**Attachment handling:**
- Maximum 10MB attachment size
- Scan for malware before processing
- Don't auto-execute attachments
- User approval required before accessing

**Approval workflows:**
- All auto-replies require user approval
- Forward suspicious emails manually
- Audit trail of all sent replies
- Ability to unsend within 30 seconds

---

## References

**Core Documentation:**
- [[stack/L3-channel/gmail/_overview]] — Architecture, webhook flow
- [[stack/L3-channel/gmail/email-triage]] — Classification, routing, webhook architecture, privacy & security

---

**Status:** ⏳ Planned — Not yet implemented. Setup steps are for future integration.

**Up →** [[stack/L3-channel/gmail/_overview]]
**Core →** [[stack/L3-channel/gmail/email-triage]]
