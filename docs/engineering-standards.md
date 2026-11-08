# Engineering standards

These standards apply to everything in this repository. The project-specific design is in [design.md](design.md).

## 1. Repository hygiene

- [ ] README follows the blueprint in [design §26](design/10-decisions-and-deliverables.md#26-deliverables-readme-demo-video-write-up). **Results come before setup instructions.**
- [ ] `LICENSE` (MIT), `.env.example`, `Makefile` with standard targets (`setup`, `up`, `lint`, `test`, `ingest`, `ask`, `eval`, `report`, `run`).
- [ ] `docker compose up` works on a fresh machine (test it in a clean clone).
- [ ] `pre-commit` with ruff, mypy, gitleaks and markdownlint.
- [ ] **Conventional Commits** ([COMMIT_MESSAGE_GUIDELINES.md](../COMMIT_MESSAGE_GUIDELINES.md)); small, squash-merged PRs ([PULL_REQUEST_GUIDELINES.md](../PULL_REQUEST_GUIDELINES.md)).
- [ ] **Semantic versioning tags** + GitHub Releases whose notes include eval numbers (`v0.1.0` baseline → `v1.0.0` launch; [VERSIONING.md](../VERSIONING.md)).
- [ ] `CHANGELOG.md`; PR template with an **"Eval impact"** section; issue templates.
- [ ] Branch protection on `main` (CI must pass). Dependabot and CodeQL enabled.
- [ ] Work is tracked in GitHub issues: each phase is a sub-issue of [#1](https://github.com/dileepadev/verity/issues/1), with its tasks as sub-issues.

## 2. Code quality

- Typed Python (mypy strict on core packages), ruff, pytest. Coverage ≥ 80% on core logic.
- 12-factor configuration (env vars and config files, no hardcoded secrets or model IDs).
- Structured logging with request/trace IDs; no `print`.
- No global mutable state; small functions; explicit error handling.

## 3. LLM engineering

- **One OpenAI-compatible LLM client**; provider URL, model IDs and reasoning effort in config; tokens counted from each response's `usage`.
- Retries with exponential backoff and jitter (SDK built-ins), honoring `retry-after` on `429`; timeouts; a search-only mode when the model is unavailable; checks on `finish_reason` (`length`).
- Prompts are versioned files (prompts as code), reviewed in PRs like code.
- Every LLM call cached on disk by `hash(prompt + model + params)`; `max_tokens` per request; a daily request limit; a kill switch (`GENERATION_ENABLED=false`).
- Outputs vary even at temperature 0, so measure variance with repeated runs.

## 4. Evaluation

- Golden datasets are **versioned**, each with a **datasheet** (sources, labeling rules, counts, known biases).
- Dev/test split. **Never tune on test.** Headline numbers come from test.
- `evals/thresholds.yaml`, a PR smoke suite with a sticky PR comment, and a full test-split run for every release.
- LLM judges **calibrated against your own labels** (report Cohen's κ).
- Report confidence intervals or repeated-trial variance.
- `docs/error-analysis.md` with a failure taxonomy and counts over time.

## 5. Observability

OpenTelemetry with the GenAI semantic conventions → Langfuse; one trace per request; tokens per request; dashboards; health endpoints.

## 6. Security and privacy

- Map the system to the OWASP Top 10 for LLM Applications (2025).
- Secrets in a secret manager. CI deploys via OIDC (no long-lived cloud keys). Least-privilege roles.
- Dependency scanning (Dependabot, `pip-audit`), CodeQL, and gitleaks for secrets.
- `docs/security.md` (threat model) and `docs/privacy.md` (data inventory, retention, provider terms).

## 7. Documentation as code

- The design is the architecture document: [design.md](design.md), with Mermaid diagrams in [§7](design/02-architecture.md#7-architecture).
- `docs/adr/` in MADR format: one short file per new or changed decision. The initial decisions are in [design §25](design/10-decisions-and-deliverables.md#25-architecture-decision-records).
- `docs/runbook.md` for operations; known limitations go in the README.
- `docs/build-log.md` (see `AGENTS.md`).

## 8. Cost controls

- Free plans only; the services and their limits are listed in [design §17](design/06-operations-and-cost.md#17-cost-model). Don't turn on a paid plan.
- A Google Cloud budget alert at $1; Cloud Run with 0 minimum and 1 maximum instance; an Artifact Registry cleanup policy.
- Retrieval metrics need no LLM calls, so tune retrieval first. Cache every LLM call.
- Re-check free-plan limits before you publish any numbers.

## 9. Definition of done

- [ ] Live demo URL (or a recorded demo + IaC to recreate it) and a 2-minute video.
- [ ] README with **real** results on the test split.
- [ ] CI green; eval gate active; release tagged.
- [ ] Security and privacy docs; runbook.
- [ ] Write-up published ([design §26](design/10-decisions-and-deliverables.md#26-deliverables-readme-demo-video-write-up)).
