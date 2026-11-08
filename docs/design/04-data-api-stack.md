# Verity RAG design: Data model, API and tech stack

Part of the [Verity RAG design](../design.md). Section numbers (§) match the index and the GitHub issues.

---

## 9. Data model

```sql
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE documents (
  id              UUID PRIMARY KEY,
  source_id       TEXT NOT NULL,              -- from sources.yaml
  title           TEXT NOT NULL,
  publisher       TEXT,
  language        TEXT NOT NULL DEFAULT 'en',
  version_label   TEXT,
  effective_date  DATE,
  superseded_by   UUID REFERENCES documents(id),
  url             TEXT,
  sha256          CHAR(64) NOT NULL UNIQUE,
  page_count      INT,
  license         TEXT,
  ingested_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE chunks (
  id               UUID PRIMARY KEY,
  document_id      UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  section_path     TEXT,
  page_start       INT NOT NULL,
  page_end         INT NOT NULL,
  bboxes           JSONB,                     -- [{page, x0, y0, x1, y1}]
  content_type     TEXT NOT NULL CHECK (content_type IN ('text', 'table')),
  content          TEXT NOT NULL,
  context_header   TEXT,
  token_count      INT NOT NULL,
  embedding        vector(1024),              -- set dims to your embedding model
  tsv              tsvector GENERATED ALWAYS AS
                   (to_tsvector('simple', coalesce(context_header, '') || ' ' || content)) STORED,  -- 'english' for English-only corpora
  content_sha256   CHAR(64) NOT NULL,
  embedding_model  TEXT NOT NULL,
  chunker_version  TEXT NOT NULL
);
CREATE INDEX chunks_embedding_hnsw ON chunks USING hnsw (embedding vector_cosine_ops);
CREATE INDEX chunks_tsv_gin        ON chunks USING gin (tsv);
CREATE INDEX chunks_document       ON chunks (document_id);

CREATE TABLE queries (
  id                 UUID PRIMARY KEY,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  question_redacted  TEXT NOT NULL,           -- PII-redacted
  rewritten_query    TEXT,
  answer             TEXT,
  abstained          BOOLEAN NOT NULL,
  abstain_gate       SMALLINT,                -- 1, 2 or 3
  model              TEXT NOT NULL,
  input_tokens       INT, output_tokens INT,
  cost_usd           NUMERIC(10, 6),
  latency_ms         INT, ttft_ms INT,
  config_hash        TEXT NOT NULL,
  trace_id           TEXT NOT NULL
);

CREATE TABLE feedback (
  id          UUID PRIMARY KEY,
  query_id    UUID NOT NULL REFERENCES queries(id) ON DELETE CASCADE,
  rating      SMALLINT NOT NULL CHECK (rating IN (-1, 1)),
  reason      TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Database roles (least privilege):** `verity_rag_app` (the API) can `SELECT` on `documents`/`chunks` and `INSERT` on `queries`/`feedback`. `verity_rag_ingest` (the `make ingest` CLI) can write `documents`/`chunks`. `verity_rag_eval` (CI) can only `SELECT` on `documents`/`chunks`. Migrations run as the owner role only. Use Alembic for migrations. Eval results are files in `evals/reports/`, not database rows.

---

## 10. API design

| Method and path | Purpose | Auth |
| --- | --- | --- |
| `POST /v1/ask` | Ask a question; SSE stream | Public, rate-limited, optional Turnstile token |
| `POST /v1/search` | Passages only, no generation | Public, rate-limited |
| `GET /v1/documents/{id}/pages/{n}` | Signed URL for a page image | Public (signed, short TTL) |
| `POST /v1/feedback` | Rate an answer | Public, rate-limited |
| `GET /healthz`, `GET /readyz` | Liveness, readiness (DB reachable) | Public |

There are no admin endpoints: ingestion runs from the command line (`make ingest`).

**`POST /v1/ask` request:**

```json
{ "question": "How many days of annual leave do I get after one year?" }
```

**SSE events:** `meta` (trace_id, sources list), `token` (text delta), `verification` (per-sentence status), `done` (final payload), `error`.

**Final payload (`done`):**

```json
{
  "trace_id": "4bf92f3577b34da6",
  "abstained": false,
  "answer": "You are entitled to ... [S1]. If you work part-time ... [S2].",
  "sentences": [
    {"text": "You are entitled to ...", "citations": ["S1"], "verified": "supported"},
    {"text": "If you work part-time ...", "citations": ["S2"], "verified": "supported"}
  ],
  "sources": [
    {"id": "S1", "chunk_id": "…", "document": "Employment Act 2019", "section": "Part III > Section 12",
     "page_start": 14, "page_end": 14, "effective_date": "2024-07-01"}
  ],
  "usage": {"input_tokens": 5120, "output_tokens": 410, "cost_usd": 0.0142},
  "latency_ms": 4310, "ttft_ms": 1180
}
```

FastAPI publishes OpenAPI docs automatically at `/docs`. Link them from the README.

---

## 11. Tech stack

| Layer | Choice | Why | Alternatives |
| --- | --- | --- | --- |
| Languages | Python 3.12+ (backend), TypeScript (web) | Python for the ML and retrieval ecosystem; TypeScript for the web UI | — |
| Tooling | `uv`, `ruff`, `mypy`, `pytest`, `pre-commit` | The current Python standard: fast and reproducible | poetry, black, flake8 |
| API | FastAPI, Pydantic v2, SSE | Async, typed, auto OpenAPI | Litestar, Flask |
| Parsing | Docling (+ OCR engine); page images rendered by Docling | Open source, strong on tables, keeps provenance | Unstructured, LlamaParse, Azure Document Intelligence |
| Database | PostgreSQL 15+ with pgvector ≥ 0.7, full-text search, `pg_trgm` | One store for vectors, text and metadata; plain SQL | Qdrant, Weaviate, Pinecone, OpenSearch |
| Embeddings | `BAAI/bge-m3` run locally on CPU (open model, 1,024 dimensions) | Free, no API key or limits; strong multilingual quality | Hosted embedding APIs (Voyage AI, Cohere) |
| Reranker | `BAAI/bge-reranker-v2-m3` run locally on CPU (cross-encoder) | Free; big quality gain | Hosted rerank APIs |
| LLMs | Groq free plan through one OpenAI-compatible client; generator `openai/gpt-oss-120b`, judge `llama-3.3-70b-versatile`, small tasks `llama-3.1-8b-instant` ([§17.1](06-operations-and-cost.md#171-models)) | Free and fast; open models; changing provider is a config change | Gemini API free tier; Ollama locally for offline work |
| Evals | Custom harness: metrics, judge, gate and report | You understand every number | Ragas, DeepEval, promptfoo, Inspect |
| Observability | OpenTelemetry (GenAI semantic conventions) → Langfuse | Vendor-neutral standard | Arize Phoenix, LangSmith, Datadog |
| Frontend | Next.js (App Router), Tailwind, shadcn/ui | The industry default | Streamlit (early prototype only) |
| Infra | Docker; Cloud Run (API); Vercel (web); Supabase (Postgres + Storage); Secret Manager | All on free plans ([§17](06-operations-and-cost.md#17-cost-model)); scales to zero | AWS App Runner/ECS + RDS |
| CI/CD | GitHub Actions; Artifact Registry; Dependabot; CodeQL; `pip-audit`; gitleaks | Standard supply-chain hygiene | GitLab CI |
