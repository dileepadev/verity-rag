# Verity design: Operations, scaling and cost

Part of the [Verity design](../design.md). Section numbers (§) match the index and the GitHub issues.

---

## 13. Observability and operations

| Signal | What | Where |
| --- | --- | --- |
| Traces | One per request; spans per stage; GenAI attributes (model, tokens) | OpenTelemetry → Langfuse |
| Metrics | Latency per stage (histograms), tokens per day per model, abstention rate, gate distribution, feedback rate, error rate | Langfuse dashboards |
| Logs | Structured JSON with request/trace IDs; PII-redacted | Cloud Logging |
| Health | `/healthz` and `/readyz` endpoints | Cloud Run |

**SLOs (demo, warm instance):** full answer under 8 s for 95% of requests; error rate under 1%. The demo scales to zero when idle, so the first request after a break is slow ([§17.3](#173-the-demo-sleeps-when-idle)).

**Alerts:** a Google Cloud budget alert at $1 (email). Hitting the daily request limit is logged and shown on the dashboard.

**Runbook (`docs/runbook.md`):**

- **Provider outage:** flip `GENERATION_ENABLED=false` (search-only mode) and confirm traces.
- **Daily limit reached:** search-only mode turns on by itself; check traces for the cause, and lower the rate limit if it's abuse.
- **Bad ingestion:** quarantine the document, re-run with the fixed parser settings, compare the reports.
- **Quality regression in production:** roll back to the previous image (Cloud Run revisions), then add failing cases to the golden set.
- **Supabase project paused:** restore it from the Supabase dashboard.

---

## 16. Scaling and performance

### 16.1 Today's assumptions

1–3k pages → about 10–30k chunks; a few hundred queries a month; one region.

### 16.2 Latency budget (target, warm instance)

| Stage | Budget | Notes |
| --- | --- | --- |
| Guards | 5 ms | In-memory |
| Query rewrite | 200–500 ms | Small model; skip for short queries |
| Query embedding | 50–200 ms | Local model on CPU |
| Dense + keyword search | 30–80 ms | In parallel; HNSW + GIN |
| Rerank (local, on CPU) | 0.5–2 s | Measure it; lower the depth if it's too slow |
| Generation TTFT | 0.5–1.5 s | Streaming; the reasoning effort set in config adds time before the first token |
| Generation complete | 1–4 s | Depends on model and answer length |
| Verification | 0.3–0.8 s | Small model; batched sentences; runs after streaming |

### 16.3 Scale tiers

**T1, demo** (30k chunks, a few users): as designed.

**T2, organization** (5M chunks, 50 QPS):

- Tune HNSW (`m`, `ef_construction`, `ef_search`); use `halfvec` to halve vector memory; partition by corpus.
- Connection pooling (PgBouncer/Supavisor) and read replicas.
- Queue-based ingestion workers and batch embedding on GPUs.
- Exact-match answer cache (normalized question + index version) and prompt caching.
- Paid LLM plans with higher limits; autoscale API instances; CDN for page images.

**T3, multi-tenant SaaS** (100M+ chunks, 500+ QPS, many tenants):

- Dedicated vector engine (Qdrant / Weaviate / OpenSearch / Vespa) with sharding, replicas, and quantization with rescoring.
- Tenant isolation (namespaces + row-level security).
- Event-driven ingestion (object-store events → queue → workers).
- **Model routing:** a small model first, escalating on low confidence.
- Per-tenant limits; regional deployments for data residency.

### 16.4 Token levers

In order: smaller context via better reranking → lower reasoning effort → a smaller model for easy questions (routing) → caching frequent answers.

---

## 17. Cost model

Verity runs on free plans only. **Expected total: $0.**

| Service | Used for | Plan | Free limits | Cost |
| --- | --- | --- | --- | --- |
| [Groq](https://console.groq.com/docs/rate-limits) | LLM: answers, judge, query rewrite, verifier | Free | Requests and tokens per minute and per day, set per model (see the console's limits page) | $0 |
| Hugging Face Hub | Download the open embedding and rerank models | Free | — | $0 |
| [Supabase](https://supabase.com/pricing) | Postgres + pgvector; Storage for PDFs and page images | Free | 500 MB database, 1 GB file storage; pauses after a week without activity | $0 |
| [Google Cloud Run](https://cloud.google.com/run/pricing) | The API | Free tier | 2M requests, 180,000 vCPU-seconds and 360,000 GiB-seconds a month | $0 |
| Artifact Registry | API container image | Free tier | 0.5 GB storage | $0 |
| Secret Manager | API keys | Free tier | 6 active secret versions, 10,000 access operations a month | $0 |
| [Vercel](https://vercel.com/pricing) | Web app | Hobby | Personal, non-commercial use | $0 |
| [Langfuse Cloud](https://langfuse.com/pricing) | Traces and dashboards | Hobby | Monthly usage cap; short trace retention | $0 |
| GitHub | Code, issues, Actions CI | Free | Free Actions minutes for public repositories | $0 |
| **Total** | | | | **$0** |

Free limits change. Check each pricing page before you rely on a number, and keep the numbers in `configs/`, not in code.

### 17.1 Models

| Role | Model (Groq) | Runs |
| --- | --- | --- |
| Generator | `openai/gpt-oss-120b` | Every answer |
| Judge | `llama-3.3-70b-versatile` | Evals only; a different model family from the generator |
| Small tasks: query rewrite, verifier | `llama-3.1-8b-instant` | Every answer |
| Embeddings | `BAAI/bge-m3` (1,024 dimensions, multilingual), local | Ingestion and every query |
| Reranker | `BAAI/bge-reranker-v2-m3`, local | Every query |

Groq sets its free limits **per model**, so giving each role its own model also gives each role its own daily limit. These are starting choices: E6 compares generators, and the IDs live in `configs/`.

### 17.2 Tokens per query

About 5,000 input tokens (sources + prompt) and 700 output tokens (including reasoning) on the generator, plus about 2,500 tokens on the small model for rewrite and verification. **Measure the real numbers from `usage`.**

To see how many answers a day the free plan allows, divide the generator's daily token limit by about 6,000. For example, a 200,000-token daily limit gives about 30 answers a day.

### 17.3 The demo sleeps when idle

- Cloud Run runs with **0 minimum and 1 maximum instance**, so it costs nothing while idle and can't scale up.
- The instance needs about **2 vCPU and 8 GiB of memory**, because it holds both local models. Measure it and lower it if you can.
- The first request after a break takes a minute or two: the instance starts and loads the models. That's expected, and nothing keeps it awake.
- Supabase pauses a free project after a week without activity. Restore it from the dashboard.

### 17.4 Ingestion (one-time, on your laptop)

| Item | Cost |
| --- | --- |
| Parsing (Docling) | $0, local CPU |
| Contextual headers | $0, built from the document structure, no LLM ([§8.3](03-components.md#83-chunking-structure-aware)) |
| Embeddings (≈ 20k chunks) | $0, local CPU (roughly an hour; measure it) |
| Page images | $0; render them small (WebP or JPEG) so all pages fit in Supabase's 1 GB of storage |

### 17.5 Evaluation runs

- **Retrieval metrics:** no LLM calls, so they're free and unlimited. Do most of your tuning here, because most RAG gains come from retrieval.
- **Generation metrics:** about 6,000 tokens on the generator and 6,000 on the judge per question. A full run can take more than one day on the free limits, so the runner caches every call and resumes where it stopped ([§12.5](05-evaluation.md#125-ci-gating)).
- **CI smoke run (20 questions):** about 120,000 tokens on the generator and 120,000 on the judge, which fits inside one day's free limits.
- **Token limit per answer:** chosen by the maintainer after the E0 baseline, from real numbers.

### 17.6 Guardrails that keep it at $0

- Every service stays on its free plan. Don't turn on a paid plan.
- Groq's free plan returns `429` when a limit is reached; it never bills.
- Google Cloud:
  - a budget alert at $1;
  - Cloud Run min 0 and max 1 instance;
  - an Artifact Registry cleanup policy that keeps only the latest image;
  - a small image (CPU-only PyTorch; models are downloaded at startup, not baked in).
- In the app: a daily request limit (`DAILY_REQUEST_LIMIT`). When it's reached, generation switches off and search-only mode serves results.
- Tokens per request in every trace, and a daily tokens panel.

---

## 18. Reliability and failure modes

| Failure | Detection | Mitigation |
| --- | --- | --- |
| LLM provider 5xx/timeouts | Error rate, latency spikes | Retries with backoff + jitter (max 2); search-only degraded mode |
| Rate limited (429) | 429 count | Honor `retry-after`; reduce concurrency; evals resume later |
| Free daily limit used up / abuse | Daily request counter; 429s | Search-only mode until the next day; tighter rate limit; Turnstile if bots appear |
| Reranker too slow or out of memory | Span latency; errors | Skip the rerank (use RRF order), lower confidence, and flag it in `meta` |
| Database unavailable or paused | `/readyz` fails | Return 503 quickly with a friendly message; restore the Supabase project |
| Parsing garbage (bad OCR) | Ingestion report thresholds | Quarantine the document; fix settings; re-ingest |
| Quality regression | CI gate; feedback spike | Roll back the revision; add failing cases to the golden set |
| Model removed or limits changed | Provider notices; eval drift | Config-driven model IDs; re-run the eval suite before switching; record model IDs in results |
