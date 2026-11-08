# Verity design: Evaluation plan

Part of the [Verity design](../design.md). Section numbers (§) match the index and the GitHub issues.

---

## 12. Evaluation plan

**This section is the heart of the project.** Many RAG systems skip it; here it decides every change.

### 12.1 Golden dataset

| Version | Size | When | Contents |
| --- | --- | --- | --- |
| v0 | 50 | **Before** any optimization | 40 answerable + 10 unanswerable |
| v1 | 150 | While tuning retrieval and generation | All categories in [§4.3](01-problem-and-requirements.md#43-question-categories-these-drive-the-eval-set) except temporal; at least 25% unanswerable/false-premise |
| v2 | 200–300 | After deployment | Adds production feedback cases (and multilingual questions, if relevant) |

**Where questions come from:**

1. **Real questions** people ask on forums, Reddit, government FAQ pages and Q&A sites. Paraphrase them; don't copy verbatim.
2. **Your own questions**, written after reading a section.
3. **Synthetic questions:** an LLM generates them from random chunks and you review every one. Cap them at 30% and tag them `source: synthetic`.
4. **Unanswerable:** plausible topics the corpus doesn't cover, or details it doesn't specify.
5. **Production:** thumbs-down cases from [§8.10](03-components.md#810-feedback-and-data-flywheel).

**Label gold evidence as `(document, page, quote)`, never as chunk IDs.** Chunk IDs change every time you change chunking. Page-plus-quote labels survive re-chunking, so you can compare chunking strategies fairly. A retrieved passage counts as a hit if it covers the gold page and contains the gold quote (normalized fuzzy match ≥ 0.9).

**Splits:** dev (70%) for tuning and test (30%) for reporting. **Never tune on test.** A question never changes split: v0 test questions stay in test in v1 and v2. Report test numbers in the README. In CI, retrieval metrics run on all of dev, because they need no LLM calls. Generated-answer metrics run on the **smoke set**: a stratified sample of 20 dev questions, which keeps each PR run inside the free daily limits.

**Datasheet:** write `evals/datasets/README.md` covering sources, labeling rules, category counts, known biases and version history. This mirrors "Datasheets for Datasets", the industry practice.

**Labeling guide:** write `docs/labeling-guide.md` defining exactly what counts as correct, partial and wrong. Consistency matters more than volume.

### 12.2 Metrics

| Group | Metric | How |
| --- | --- | --- |
| Retrieval | Recall@k (k = 5, 10), MRR@10, nDCG@10 | Against gold (doc, page, quote); **no LLM needed, so it's free to run** |
| Generation | Faithfulness (claims supported by cited passages) | LLM judge |
| Generation | Answer correctness vs gold | LLM judge (correct / partial / wrong) |
| Citations | Citation precision and recall | Judge checks each (sentence, citation) pair; recall = gold evidence pages cited |
| Abstention | Precision, recall, F1 on unanswerables; false-refusal rate | Exact (label vs `abstained`) |
| Operations | TTFT and full latency p50/p95, tokens per query | From traces and `usage` |

Report **95% bootstrap confidence intervals** for headline metrics. With about 45 test questions, an interval of roughly ±10 points is normal for a metric near 0.85, so show it next to every headline number.

### 12.3 LLM-as-judge (and proving it's trustworthy)

1. **Rubric, not vibes.** Use binary or ternary decisions per criterion, not 1–10 scores, which are unreliable. Prompt in Appendix B.
2. **Inputs:** question, gold answer, system answer, cited passages. **Output:** JSON with `correct`, `faithful`, `unsupported_sentences`, `notes`.
3. **Judge model:** a strong model from a different family than the generator (`llama-3.3-70b-versatile` judging `openai/gpt-oss-120b` answers). A judge from the same family can favor its own style, which is one more reason the calibration below is required. A separate model also has its own free daily limit. Record the judge model ID in every result.
4. **Calibrate:**
   1. Hand-label 100 answers (mixed quality) yourself, blind to the judge.
   2. Compute Cohen's κ and the confusion matrix.
   3. Iterate the judge prompt until κ ≥ 0.70 ("substantial" agreement).
   4. Commit the calibration set and the report (`evals/judges/calibration/`).
5. **Re-calibrate** whenever you change the judge model or prompt.
6. **Variance:** run borderline cases 3 times and take the majority. Report how often the judge flips.

### 12.4 Ablation plan

| Exp | Change | Hypothesis |
| --- | --- | --- |
| E0 | Baseline: fixed 512-token chunks, dense only, no rerank | Reference point |
| E1 | Structure-aware chunking | Better recall on section questions |
| E2 | + contextual headers | Fewer retrieval misses on ambiguous chunks |
| E3 | + keyword search + RRF (hybrid) | Better on exact terms and section numbers |
| E4 | + reranker | Better MRR; lets you send fewer passages to the LLM |
| E5 | + query rewrite | Better on paraphrase questions; costs latency |
| E6 | Generator swap (`gpt-oss-120b` / `gpt-oss-20b` / `llama-3.1-8b-instant`) | Quality vs speed and tokens |
| E7 | Context budget (top 5 / 8 / 12) | More context isn't always better |
| E8 | Abstention thresholds sweep | PR curve; choose the operating point |
| E9 | Fixed pipeline vs agentic retrieval mode ([§8.12](03-components.md#812-agentic-retrieval-mode-should-have)) | Where agentic search wins (multi-hop), and what it costs in tokens, latency and variance |

Every run records git SHA, config hash, dataset version and model IDs. `make report` renders a Markdown table and two charts: a quality-vs-tokens scatter and the abstention PR curve.

### 12.5 CI gating

- `evals/thresholds.yaml` (Appendix C) holds absolute floors and a max regression (e.g. −0.03) against `evals/baseline.json`, the smoke-set metrics committed on `main`. A PR that changes the metrics updates `evals/baseline.json` in the same PR.
- **PR workflow:** when retrieval, generation, prompt, config or eval files change, CI runs the smoke set against the hosted index (Supabase, read-only role). It posts a sticky PR comment with a metrics table and deltas, and fails if a threshold is breached.
- **Index changes:** PRs that change ingestion or chunking are measured locally after re-indexing, with the dev report attached to the PR. Re-ingest the hosted index after merging.
- **Start small:** begin with retrieval and abstention floors; add judge-based floors once the judge is calibrated ([§12.3](#123-llm-as-judge-and-proving-its-trustworthy)).
- **Releases:** the full test split runs once per release (`make eval SPLIT=test`). There are no nightly runs.
- **Free limits:** every LLM call is cached on disk by `hash(prompt + model + params)`, so a re-run only calls the API for changed prompts. Runs respect `retry-after`, resume where they stopped and can span more than one day ([§17.5](06-operations-and-cost.md#175-evaluation-runs)).
- **CI model cache:** CI caches the downloaded embedding and rerank models between runs.

### 12.6 Error analysis

After every major run, sample the failures and tag each with one category:

| Code | Category | Typical fix |
| --- | --- | --- |
| R1 | Retrieval miss (gold page not in top 50) | Chunking, headers, hybrid, query rewrite |
| R2 | Ranking miss (in top 50, not top 10) | Reranker, rerank depth |
| P1 | Parsing error (table/OCR garbage) | Parser settings, table handling |
| G1 | Hallucinated detail | Prompt, verifier, model |
| G2 | Wrong number/condition | Table formatting, prompt |
| C1 | Citation mismatch | Marker parsing, verifier |
| A1 | False refusal | Thresholds |
| A2 | Answered an unanswerable | Thresholds, prompt |
| V1 | Version confusion | Version filter |

Keep the table of counts in `docs/error-analysis.md` and show how it changed across runs. The goal is findings like "40% of failures were R1; after fixing chunking, R1 dropped to 12%."
