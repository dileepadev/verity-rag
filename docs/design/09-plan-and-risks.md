# Verity design: Implementation plan and risks

Part of the [Verity design](../design.md). Section numbers (§) match the index and the GitHub issues.

---

## 22. Implementation plan (phases and milestones)

The plan lives in GitHub issues: [#1](https://github.com/dileepadev/verity/issues/1) lists the phases, and each phase issue lists its tasks as sub-issues. Work through the phases in order; inside a phase, do `priority: must` issues first, then `should`, then `could`.

| Phase | Goal | Milestone and release |
| --- | --- | --- |
| [0 · Project setup](https://github.com/dileepadev/verity/issues/2) | Repo, tooling, corpus and 20 seed questions | — |
| [1 · Measure first](https://github.com/dileepadev/verity/issues/8) | A naive baseline (E0) and an eval harness that measures it, before any optimization | M1: baseline report · `v0.1.0` |
| [2 · Make it good](https://github.com/dileepadev/verity/issues/15) | Ablations E1–E8, a calibrated judge, tuned abstention and a CI eval gate | M2: quality targets · `v0.5.0` |
| [3 · Make it real](https://github.com/dileepadev/verity/issues/24) | API, web UI, tracing, deployment, security docs and a results-first README | M3: deployed v1.0 · `v1.0.0` |
| [4 · Polish and publish](https://github.com/dileepadev/verity/issues/32) | Agentic retrieval (E9), real users and the public write-up | — |
| [Backlog](https://github.com/dileepadev/verity/issues/39) | Stretch goals ([§23](#23-stretch-goals)), only after v1.0 | — |

A milestone is reached when its phase's `must` issues are closed and the real numbers are reported, even if some targets are missed. Build the UI only after the quality targets are measured, and ship it plain first.

---

## 23. Stretch goals

In priority order:

1. **An MCP server for Verity:** expose `search_regulations` and `get_passage` as tools so Claude Desktop, IDEs or other agents can query your corpus. This adds MCP to this repo.
2. **Retrieval router:** after E9, route multi-hop questions to agentic mode and simple ones to the fixed pipeline. Measure the cost saved at equal quality.
3. **Multilingual and code-mixed questions** in your local language, with a separate metric breakdown.
4. **"As-of date" answers** across amendment history.
5. **Fine-tune the embedding model** on domain pairs (synthetic question–passage pairs, `sentence-transformers`) and measure the recall gain.
6. **Graph-based retrieval for cross-references** ("subject to section 12"), only if error analysis shows multi-hop failures dominate.

---

## 24. Risks and mitigations

| Risk | Likelihood | Mitigation |
| --- | --- | --- |
| Corpus license unclear | Medium | Choose government or openly licensed documents; commit metadata only |
| OCR poor for local script | Medium | Check OCR on 10 scanned pages before building the pipeline; fall back to digital-only documents |
| Free LLM limits slow down evals | High | Retrieval-only evals; cache every LLM call; resumable runs; a separate model per role, each with its own limit |
| A free plan changes or ends | Medium | Provider and model IDs in config; Gemini API free tier or local Ollama as a fallback |
| Scope creep (UI polish) | High | MoSCoW; build the UI only after quality targets are met; ship ugly-but-working first |
| Judge unreliable | Medium | Calibration with κ; binary rubrics; spot-check |
| Slow first request (cold start) | High | Expected for a demo that scales to zero; say so in the README and the demo video |
| Scope too large | Medium | Keep v1 small (one provider, one database, one API); Phase 1–2 alone (eval-driven retrieval + report) are already a complete project |
