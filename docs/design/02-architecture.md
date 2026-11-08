# Verity RAG design: Architecture

Part of the [Verity RAG design](../design.md). Section numbers (§) match the index and the GitHub issues.

---

## 6. Solution overview

Verity RAG has four parts.

1. **Ingestion pipeline (offline).** Fetches documents, parses them (including OCR and tables), splits them into chunks that follow the document's structure, and adds a short context header to each chunk ("Employment Act 2019 > Part III > Section 12: Overtime"). It then builds two indexes, vector and keyword.
2. **Query pipeline (online).** Rewrites the question for search, runs both searches, merges the results, reranks them, and builds a compact context. It asks the LLM to answer only from that context with citations, checks each sentence against its cited source, and then either answers or abstains.
3. **Evaluation loop.** A hand-written golden question set, automated metrics, an LLM judge validated against your own labels, and a CI gate that blocks regressions.
4. **Operations layer.** Tracing, metrics, token tracking, rate limiting, a daily request limit and dashboards.

The core idea: **you prove every design choice with a measurement.** Each technique (hybrid search, reranking, contextual headers) earns its place in an ablation table.

---

## 7. Architecture

### 7.1 System context

```mermaid
flowchart LR
    user["User<br/>browser or phone"]
    web["Web app<br/>Next.js on Vercel"]
    api["Verity RAG API<br/>FastAPI on Cloud Run<br/>local embedding and rerank models"]
    db[("PostgreSQL<br/>pgvector + full-text")]
    store[("Object storage<br/>PDFs and page images")]
    llm["LLM API<br/>OpenAI-compatible"]
    obs["Langfuse<br/>OpenTelemetry traces"]
    ingest["Ingestion CLI<br/>make ingest, Docling,<br/>local embedding model"]
    ci["GitHub Actions<br/>tests and eval gate"]

    user --> web --> api
    api --> db
    api --> store
    api --> llm
    api --> obs
    ingest --> store
    ingest --> db
    ci -->|deploys| api
    ci -->|runs evals with| llm
```

### 7.2 Ingestion pipeline

```mermaid
flowchart TD
    A["sources.yaml<br/>URL, title, version, effective date, license"] --> B["Fetch and hash<br/>skip unchanged files"]
    B --> C["Parse with Docling<br/>layout, tables, OCR"]
    C --> D["Normalize<br/>pages, sections, bounding boxes"]
    D --> E["Structure-aware chunking<br/>sections kept, tables whole"]
    E --> F["Contextual header<br/>title, version, section path"]
    F --> G["Embed chunks locally<br/>open embedding model"]
    F --> H["Full-text index<br/>tsvector"]
    G --> I[("PostgreSQL")]
    H --> I
    I --> J["Ingestion report<br/>pages, OCR rate, tables, chunk stats"]
```

### 7.3 Query pipeline

```mermaid
sequenceDiagram
    autonumber
    participant U as User
    participant API as Verity RAG API
    participant R as Retriever
    participant RR as Reranker
    participant L as LLM
    participant V as Verifier
    U->>API: Ask a question
    API->>API: Guards - rate limit, length, daily request limit
    API->>L: Rewrite query with a small model
    par Hybrid retrieval
        API->>R: Dense search, top 50
    and
        API->>R: Keyword search, top 50
    end
    R-->>API: Candidates
    API->>API: Reciprocal Rank Fusion
    API->>RR: Rerank fused top 50
    RR-->>API: Scored passages
    alt Top score below threshold
        API-->>U: No answer, plus the closest sections
    else Enough evidence
        API->>L: Grounded prompt with sources S1 to S8
        L-->>API: Streamed answer with S-number citations
        API-->>U: Stream tokens
        API->>V: Check each sentence against its cited source
        V-->>API: Supported or unsupported per sentence
        API-->>U: Final answer with verified citations
    end
```

### 7.4 Evaluation loop

```mermaid
flowchart LR
    G["Golden set<br/>dev and test splits"] --> RUN["Eval runner"]
    CFG["Pipeline config<br/>git SHA and config hash"] --> RUN
    RUN --> M["Metrics<br/>retrieval, faithfulness,<br/>abstention, tokens, latency"]
    M --> T{"Meets thresholds?"}
    T -->|yes| PASS["CI passes<br/>PR comment with deltas"]
    T -->|no| FAIL["CI fails<br/>merge blocked"]
    PROD["Production feedback<br/>thumbs down and traces"] --> TRIAGE["Weekly triage"]
    TRIAGE --> G
```

### 7.5 Deployment

```mermaid
flowchart LR
    subgraph Vercel
        WEB["Next.js web app"]
    end
    subgraph GCP["Google Cloud"]
        RUNAPI["Cloud Run service<br/>verity-rag-api"]
        SM["Secret Manager"]
    end
    subgraph Supabase
        PG[("Postgres + pgvector")]
        ST[("Storage<br/>PDFs and page images")]
    end
    LF["Langfuse Cloud"]
    LLM["LLM API<br/>OpenAI-compatible"]
    WEB --> RUNAPI
    RUNAPI --> PG
    RUNAPI --> ST
    RUNAPI --> LLM
    INGEST["make ingest<br/>run by the maintainer"] --> PG
    INGEST --> ST
    SM -.-> RUNAPI
    RUNAPI --> LF
```

**LLM provider:** the diagrams show a generic OpenAI-compatible LLM API. The current provider and models are set in `configs/` and listed in [§17.1](06-operations-and-cost.md#171-models), so changing provider doesn't change the architecture.

**Why this deployment:** every service runs on its free plan ([§17](06-operations-and-cost.md#17-cost-model)), it scales to zero and it uses managed Postgres with pgvector. Ingestion is rare and offline, so it runs from the command line instead of as a cloud job; that keeps Docling and its OCR models out of the API image.
