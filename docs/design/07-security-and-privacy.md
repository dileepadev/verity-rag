# Verity design: Security and privacy

Part of the [Verity design](../design.md). Section numbers (§) match the index and the GitHub issues.

---

## 14. Security

### 14.1 Threat model (summary)

- **Assets:** API keys and the free LLM quota; index integrity; users' questions; service availability.
- **Actors:** anonymous internet users, bots, anyone who can get text into the corpus.
- **Trust boundaries:** browser → API (untrusted input); corpus → index (semi-trusted, allowlisted sources); API → LLM provider (third party).

### 14.2 OWASP Top 10 for LLM Applications (2025) mapping

| Risk | How it applies | Controls in Verity |
| --- | --- | --- |
| LLM01 Prompt Injection | Users try to override rules; a document contains "ignore previous instructions…" | Instruction hierarchy in the system prompt; sources wrapped as clearly delimited data; **no tools or actions, so the blast radius is small**; injection test set (20 cases, including a planted "poisoned" document in the test fixture corpus) |
| LLM02 Sensitive Information Disclosure | Users may type personal data; system prompt or keys could leak | No secrets in prompts; PII redaction before storage; public corpus only |
| LLM03 Supply Chain | Compromised packages or models | `uv.lock`; model IDs pinned in config; Dependabot; `pip-audit`; CodeQL |
| LLM04 Data and Model Poisoning | A malicious document enters the index | Source allowlist in `sources.yaml`; hash verification; ingestion diff report reviewed before publishing |
| LLM05 Improper Output Handling | Model output rendered as HTML | Render sanitized Markdown only; strict Content Security Policy; never execute output |
| LLM06 Excessive Agency | — | Read-only design; no tools (documented as a deliberate decision) |
| LLM07 System Prompt Leakage | Users extract the prompt | Assume the prompt is public; nothing sensitive in it |
| LLM08 Vector and Embedding Weaknesses | Cross-tenant retrieval in a multi-tenant future | Tenant filters enforced in SQL and Postgres row-level security, never in the prompt |
| LLM09 Misinformation | Confident wrong answers | Citations, verifier, abstention, effective dates, disclaimer, CI eval gate |
| LLM10 Unbounded Consumption | Bots using up the free LLM quota | Per-IP and global rate limits; max question length (1,000 chars); `max_tokens` caps; daily request limit with search-only fallback; timeouts; Cloudflare Turnstile if bots appear |

### 14.3 Application security checklist

- HTTPS only; CORS allowlist (your web domain only); security headers (CSP, X-Content-Type-Options, Referrer-Policy).
- Pydantic validation on every input; reject oversized bodies.
- No admin endpoints: ingestion runs from the command line with its own database role.
- Secrets live in Secret Manager or env vars, never in git. `gitleaks` runs in pre-commit and CI.
- GitHub Actions authenticate to Google Cloud with **Workload Identity Federation (OIDC)**, not JSON keys.
- Least-privilege database roles ([§9](04-data-api-stack.md#9-data-model)) and a least-privilege service account for Cloud Run.
- CodeQL and `pip-audit` run in CI. Dependabot is on.

---

## 15. Privacy, legal and compliance

### 15.1 Data inventory

| Data | Personal? | Stored where | Retention |
| --- | --- | --- | --- |
| Corpus documents | No (public) | Object storage + DB | Until removed from `sources.yaml` |
| User questions | Possibly (people describe their situation) | DB (redacted), traces (redacted) | 30 days raw traces; metrics aggregated |
| Feedback | Possibly | DB | 30 days, then anonymized aggregate |
| IP addresses | Yes | Rate limiter memory only | Not persisted |

### 15.2 Controls

- **Data minimization:** no accounts and no cookies beyond what's necessary. Show a "don't enter personal details" hint.
- **PII redaction** before storage and before sending traces, with regex recognizers for emails, phone numbers and local ID formats. Test them on your language; add Microsoft Presidio only if the regexes miss too much.
- **Retention:** a scheduled SQL job (Supabase Cron) deletes `queries` and `feedback` older than 30 days. Check the trace retention of your Langfuse plan.
- **LLM provider terms:** questions and passages are sent to Groq. Read Groq's data-use and retention terms for the free plan and state them on the privacy page. This is one more reason for the "don't enter personal information" notice.
- **Privacy notice page:** what's collected, why, retention, that thumbs-down cases may be reviewed and added, anonymized, to the eval set, and how to request deletion (by trace ID).
- **Transparency:** tell users they're talking to an AI system. The EU AI Act's transparency rules require it, and it's good practice everywhere.

### 15.3 Legal

- Check the corpus license or terms of use. Government works are often freely reusable, but verify.
- Attribute sources and link to the originals.
- Show effective dates; disclaim "not legal advice".
- Data protection laws to know about: GDPR/UK GDPR principles (minimization, purpose limitation, retention) and your local law (e.g. India's DPDP Act 2023, Sri Lanka's PDPA 2022). Mention which one you designed for.
