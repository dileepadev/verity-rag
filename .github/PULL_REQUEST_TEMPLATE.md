# Pull Request

<!--
about: Template for Pull Requests
title: "<type>(<scope>): <message> (<issue references>)"
# Example: "feat(retrieval): Add Reciprocal Rank Fusion (fixes #18)"
-->

## 📜 Description

<!-- [REQUIRED] Briefly describe the changes in this PR and the reasoning behind them. -->

## ❗ Related Issues

<!-- [REQUIRED] List related issue(s) or PR(s), e.g., "Closes #18" or "Related to #23". One issue per PR where possible. -->

Closes #

## ⚙️ Type of Change

<!-- [REQUIRED] Check the type of change your PR introduces -->

- [ ] 🌱 New Feature / Pipeline Behavior (`feat`)
- [ ] 🐞 Bug Fix (`fix`)
- [ ] 📊 Evaluation: runner, metrics, judge, thresholds, ablation or report (`eval`)
- [ ] 📝 Documentation / ADR (`docs`)
- [ ] ♻️ Refactor / Style / Performance (`refactor`, `style`, `perf`)
- [ ] 🧪 Tests (`test`)
- [ ] ⚙️ CI / Infrastructure (`ci`)
- [ ] 🧹 Chore / Dependencies / Release (`chore`)
- [ ] 💡 Other (please explain in Description)

## 📊 Eval Impact

<!-- [REQUIRED] Pick one. -->

- [ ] **No eval impact.** Reason: <!-- e.g., docs only; tooling; web styling -->
- [ ] **Measured.** Results below, or see the CI smoke-eval comment.

<!--
Fill in for changes to retrieval, generation, prompts, configs or eval code.
Use the dev split only. Never tune on test.

Experiment: E? · Golden set: golden_v? (dev, N questions) · Generator: <model ID> · Judge: <model ID>

| Metric             | main | this PR | Δ |
| ------------------ | ---- | ------- | - |
| Recall@10          |      |         |   |
| MRR@10             |      |         |   |
| Faithfulness       |      |         |   |
| Answer correctness |      |         |   |
| Citation precision |      |         |   |
| Abstention recall  |      |         |   |
| False-refusal rate |      |         |   |
| Latency p95        |      |         |   |
| Tokens per query   |      |         |   |

Eval run tokens (generator / judge):
-->

## 📸 Screenshots

<!-- [OPTIONAL] For web UI changes, include before/after screenshots. For report changes, include the chart. Remove if not applicable. -->

## ✅ Checklist

<!-- [REQUIRED] Tick all that apply -->

<!-- Use "x" to check. -->
<!-- example: - [x] I've followed the [CONTRIBUTING.md](https://github.com/dileepadev/verity-rag/blob/main/CONTRIBUTING.md). -->

- [ ] I've followed the [CONTRIBUTING.md](https://github.com/dileepadev/verity-rag/blob/main/CONTRIBUTING.md).
- [ ] I've followed the [Commit Message Guidelines](https://github.com/dileepadev/verity-rag/blob/main/COMMIT_MESSAGE_GUIDELINES.md).
- [ ] I've followed the [Branch Naming Guidelines](https://github.com/dileepadev/verity-rag/blob/main/BRANCH_NAMING_GUIDELINES.md).
- [ ] I agree to follow the [Pull Request Guidelines](https://github.com/dileepadev/verity-rag/blob/main/PULL_REQUEST_GUIDELINES.md).
- [ ] I agree to follow the [Code of Conduct](https://github.com/dileepadev/verity-rag/blob/main/CODE_OF_CONDUCT.md).
- [ ] `make lint test` passes locally.
- [ ] New pipeline behavior has a unit test, a config flag and an ablation entry.
- [ ] No provider URLs, model IDs or secrets are hardcoded outside `configs/` and `.env`.
- [ ] No human-labeled data (`evals/datasets/`, `evals/judges/calibration/`) is changed, or this PR only contains labels written by hand by the maintainer.
- [ ] `evals/thresholds.yaml` is not weakened, or an ADR explains why.
- [ ] Significant design decisions are recorded as an ADR in `docs/adr/`.
- [ ] Documentation and [CHANGELOG.md](https://github.com/dileepadev/verity-rag/blob/main/CHANGELOG.md) have been updated where necessary.
- [ ] No personal data in code, fixtures, prompts or eval examples.
- [ ] If a coding agent helped, I can explain every line, and notable sessions are logged in `docs/build-log.md`.

<!-- example:
- [ ] I've tested the web UI changes where applicable:
  - [ ] Screen sizes (mobile/tablet/desktop)
  - [ ] Browsers (Chrome/Firefox/Safari/etc.)
  - [ ] Keyboard navigation and screen-reader labels
  - [ ] Theme modes (Dark mode / Light mode)
-->

## 💬 Additional Comments

<!-- [OPTIONAL] Any additional context, edge cases, considerations, or explanations for reviewers. Remove if not needed.  -->
