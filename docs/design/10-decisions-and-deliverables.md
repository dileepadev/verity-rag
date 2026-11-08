# Verity RAG design: Decisions, deliverables and agents

Part of the [Verity RAG design](../design.md). Section numbers (§) match the index and the GitHub issues.

---

## 25. Architecture decision records

These are the initial decisions, and this table is their record. When a decision changes, or a new one is made (for example, a threshold change), add a short MADR-format file to `docs/adr/`.

| ADR | Decision | Main alternatives | Rationale |
| --- | --- | --- | --- |
| 001 | PostgreSQL + pgvector as the only datastore | Qdrant, Pinecone, Weaviate | Fewer moving parts; SQL filters and joins; HNSW is enough to millions of vectors; documented migration path ([§16](06-operations-and-cost.md#16-scaling-and-performance)) |
| 002 | Docling for parsing | Unstructured, LlamaParse, cloud document AI | Open source; table structure; provenance (page + bbox) needed for highlights |
| 003 | Hybrid retrieval with RRF | Dense only; weighted score fusion | Exact terms (section numbers) plus paraphrase; RRF needs no score normalization |
| 004 | Local open models for embeddings and reranking (`bge-m3`, `bge-reranker-v2-m3`) | Hosted embedding and rerank APIs; no rerank | Free with no limits; multilingual; the same models in ingestion, the API and CI |
| 005 | Explicit pipeline code instead of a RAG framework in production | LangChain / LlamaIndex | Control, testability, transparent tracing |
| 006 | One OpenAI-compatible LLM client; Groq free plan | Provider SDK calls everywhere; a multi-provider router; paid APIs | Free; models chosen by evals; changing provider is a config change; the fallback is search-only mode |
| 007 | Inline `[S#]` markers + own verifier | Provider-native citations | Portable and streamable; works with any model |
| 008 | SSE for streaming | WebSockets | One-way streaming is enough; simpler infra; works through proxies |
| 009 | Cloud Run + Supabase + Vercel; ingestion from the command line | AWS ECS + RDS; a cloud ingestion job | Free plans; little ops for a demo; scales to zero; the API image stays small |

---

## 26. Deliverables: README, demo video, write-up

### 26.1 README blueprint (in this order)

1. **Title, one-liner, badges** (CI, eval gate status, license) and a 10-second GIF.
2. **Live demo link** and a 2-minute video link.
3. **Results:** a headline metrics table on the **test** split with confidence intervals, plus the quality-vs-cost chart.
4. **How it works:** the architecture diagram ([§7](02-architecture.md#7-architecture)) and a 5-sentence explanation.
5. **Evaluation:** dataset summary, judge calibration (κ), the ablation table, the abstention PR curve.
6. **Error analysis highlights:** the top 3 failure categories and what you did about them.
7. **Engineering decisions:** a link to the decision table ([§25](#25-architecture-decision-records)) and any ADR files.
8. **Quickstart:** `make setup && make up && make ingest && make ask Q="…"`.
9. **Configuration and deployment.**
10. **Security and privacy:** a short summary with links to `docs/security.md` and `docs/privacy.md`.
11. **Limitations and next steps:** honest.
12. **How I built this with coding agents:** links to `docs/build-log.md`.
13. **License and acknowledgements.**

### 26.2 Demo video script (2 minutes)

| Time | Show |
| --- | --- |
| 0:00 | The problem in one sentence; the corpus (pages, documents) |
| 0:15 | Ask an answerable question → streamed answer → click a citation → the page with the passage highlighted |
| 0:45 | Ask an unanswerable question → abstains, shows the closest sections |
| 1:00 | The eval report: ablation table + a PR comment that blocked a regression |
| 1:25 | A Langfuse trace: per-stage latency and cost |
| 1:45 | Architecture in one slide; link to the repo |

### 26.3 Write-up (blog + LinkedIn)

- **Title ideas:** "I wrote 200 questions before tuning my RAG system. Here's what moved the numbers." and, from E9, "Fixed pipeline vs agentic search: what 200 questions say".
- **Structure:** problem → why evals first → baseline → the 3 changes that mattered (with the ablation chart) → abstention trade-off → what failed → tokens per query on free plans → what I'd do next.
- **LinkedIn post:** 5–8 lines, one chart, a link to the repo and the post. Close with a question to invite comments.

---

## 27. Working with coding agents on this project

Use Claude Code, Codex, Cursor or similar. The rules and workflow live in [AGENTS.md](../../AGENTS.md), which `CLAUDE.md` loads; they aren't repeated here, so there is one source of truth. In short: every task starts from an issue, the agent proposes a plan first, and a human reviews every diff, runs the tests and evals, and owns the labels, thresholds, metric interpretation, security review and README claims.

**Build log (`docs/build-log.md`):** record notable sessions: what you asked, what the agent got wrong, how you caught it (a test? an eval drop?), and what you changed. **Rule:** never commit code you can't explain line by line.
