# Verity RAG: Evaluation-Driven Question Answering with Page-Level Citations

> **Ask questions about long, messy official documents and get answers you can check. Every claim cites a page. When the documents don't answer the question, Verity RAG says "I don't have that information."**

| | |
| --- | --- |
| **Repository** | `verity-rag` |
| **GitHub description** | Evaluation-driven RAG over messy real-world PDFs: hybrid search (keyword + vectors), reranking, page-level citations, calibrated abstention, LLM-as-judge evals gated in CI, OpenTelemetry tracing. Python · FastAPI · PostgreSQL/pgvector · Next.js |
| **GitHub topics** | `rag` `retrieval-augmented-generation` `llm` `llm-evaluation` `evals` `hybrid-search` `pgvector` `reranking` `fastapi` `nextjs` `opentelemetry` `langfuse` `docling` `generative-ai` `ai-engineering` `python` `typescript` |

---

## Contents

Each section lives in its own file under [design/](design/). Section numbers (§) never change, so references like [`docs/design.md §12.1`](design/05-evaluation.md#121-golden-dataset) in issues and docs always point to the same section.

| § | Section | File |
| --- | --- | --- |
| 0 | [TL;DR](#0-tldr) | [design.md](design.md) |
| 1 | [Scope at a glance](#1-scope-at-a-glance) | [design.md](design.md) |
| 2 | [Problem statement](design/01-problem-and-requirements.md#2-problem-statement) | [01-problem-and-requirements.md](design/01-problem-and-requirements.md) |
| 3 | [Goals, non-goals, success metrics](design/01-problem-and-requirements.md#3-goals-non-goals-success-metrics) | [01-problem-and-requirements.md](design/01-problem-and-requirements.md) |
| 4 | [Users and use cases](design/01-problem-and-requirements.md#4-users-and-use-cases) | [01-problem-and-requirements.md](design/01-problem-and-requirements.md) |
| 5 | [Requirements](design/01-problem-and-requirements.md#5-requirements) | [01-problem-and-requirements.md](design/01-problem-and-requirements.md) |
| 6 | [Solution overview](design/02-architecture.md#6-solution-overview) | [02-architecture.md](design/02-architecture.md) |
| 7 | [Architecture](design/02-architecture.md#7-architecture) | [02-architecture.md](design/02-architecture.md) |
| 8 | [Component design](design/03-components.md#8-component-design) | [03-components.md](design/03-components.md) |
| 9 | [Data model](design/04-data-api-stack.md#9-data-model) | [04-data-api-stack.md](design/04-data-api-stack.md) |
| 10 | [API design](design/04-data-api-stack.md#10-api-design) | [04-data-api-stack.md](design/04-data-api-stack.md) |
| 11 | [Tech stack](design/04-data-api-stack.md#11-tech-stack) | [04-data-api-stack.md](design/04-data-api-stack.md) |
| 12 | [Evaluation plan](design/05-evaluation.md#12-evaluation-plan) | [05-evaluation.md](design/05-evaluation.md) |
| 13 | [Observability and operations](design/06-operations-and-cost.md#13-observability-and-operations) | [06-operations-and-cost.md](design/06-operations-and-cost.md) |
| 14 | [Security](design/07-security-and-privacy.md#14-security) | [07-security-and-privacy.md](design/07-security-and-privacy.md) |
| 15 | [Privacy, legal and compliance](design/07-security-and-privacy.md#15-privacy-legal-and-compliance) | [07-security-and-privacy.md](design/07-security-and-privacy.md) |
| 16 | [Scaling and performance](design/06-operations-and-cost.md#16-scaling-and-performance) | [06-operations-and-cost.md](design/06-operations-and-cost.md) |
| 17 | [Cost model](design/06-operations-and-cost.md#17-cost-model) | [06-operations-and-cost.md](design/06-operations-and-cost.md) |
| 18 | [Reliability and failure modes](design/06-operations-and-cost.md#18-reliability-and-failure-modes) | [06-operations-and-cost.md](design/06-operations-and-cost.md) |
| 19 | [Testing strategy](design/08-testing-repo-ci.md#19-testing-strategy) | [08-testing-repo-ci.md](design/08-testing-repo-ci.md) |
| 20 | [Repository structure](design/08-testing-repo-ci.md#20-repository-structure) | [08-testing-repo-ci.md](design/08-testing-repo-ci.md) |
| 21 | [CI/CD](design/08-testing-repo-ci.md#21-cicd) | [08-testing-repo-ci.md](design/08-testing-repo-ci.md) |
| 22 | [Implementation plan (phases and milestones)](design/09-plan-and-risks.md#22-implementation-plan-phases-and-milestones) | [09-plan-and-risks.md](design/09-plan-and-risks.md) |
| 23 | [Stretch goals](design/09-plan-and-risks.md#23-stretch-goals) | [09-plan-and-risks.md](design/09-plan-and-risks.md) |
| 24 | [Risks and mitigations](design/09-plan-and-risks.md#24-risks-and-mitigations) | [09-plan-and-risks.md](design/09-plan-and-risks.md) |
| 25 | [Architecture decision records](design/10-decisions-and-deliverables.md#25-architecture-decision-records) | [10-decisions-and-deliverables.md](design/10-decisions-and-deliverables.md) |
| 26 | [Deliverables: README, demo video, write-up](design/10-decisions-and-deliverables.md#26-deliverables-readme-demo-video-write-up) | [10-decisions-and-deliverables.md](design/10-decisions-and-deliverables.md) |
| 27 | [Working with coding agents on this project](design/10-decisions-and-deliverables.md#27-working-with-coding-agents-on-this-project) | [10-decisions-and-deliverables.md](design/10-decisions-and-deliverables.md) |
| 28 | [Appendices](design/appendices.md#28-appendices) | [appendices.md](design/appendices.md) |

---

## 0. TL;DR

**What you build:** a question-answering system over 500–2,000 pages of real public documents. The default is your country's employment and labour regulations. Answers cite exact pages. The system refuses when the documents don't support an answer. A golden evaluation set and a CI gate prove the quality, and the whole thing runs as a deployed, monitored service.

---

## 1. Scope at a glance

| Area | What Verity RAG covers |
| --- | --- |
| RAG pipeline | Parsing, structure-aware chunking, hybrid retrieval, reranking, grounded generation |
| Evaluation | A golden set, a calibrated LLM judge, [ablations](design/05-evaluation.md#124-ablation-plan) (one-change-at-a-time experiments, E0–E9), a CI gate and an error analysis |
| Trust | Page-level citations for every claim, and "I don't have that information" when the documents don't answer |
| Context engineering | Contextual chunk headers, token budgets, passage ordering, version filtering |
| Agentic retrieval | An experiment (E9 in the [ablation plan](design/05-evaluation.md#124-ablation-plan)) that compares the normal fixed pipeline with a mode where the model searches step by step, on the same golden set, with cost and latency ([§8.12](design/03-components.md#812-agentic-retrieval-mode-should-have)) |
| Production | A containerized API, cloud deployment, OpenTelemetry traces, SLOs, dashboards |
| Security and privacy | An OWASP Top 10 for LLM Applications mapping, abuse controls and privacy design |
| Languages | Python backend and a TypeScript/Next.js frontend |

**Kept small on purpose:** one LLM provider (Groq) behind one OpenAI-compatible client, local open models for embeddings and reranking, one database (PostgreSQL with pgvector and full-text search), one deployed API and one web app. Ingestion runs from the command line. Anything beyond that is a stretch goal ([§23](design/09-plan-and-risks.md#23-stretch-goals)).

**Cost:** $0. Every service runs on its free plan; the services, models and limits are in [§17](design/06-operations-and-cost.md#17-cost-model).
