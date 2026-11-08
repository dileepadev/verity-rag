# Pull Request Guidelines

Pull requests are squash-merged into `main`, so the PR title becomes the commit header. Write it using the [Commit Message Guidelines](COMMIT_MESSAGE_GUIDELINES.md) convention. GitHub appends the PR number when it squash-merges.

## PR Title Format

The pull request title should follow the format:

```md
<type>(<scope>): <message> (<issue references>)
```

- `<type>`: Type of the change. Use one of the following:

  - `feat`: A new feature or pipeline behavior.
  - `fix`: A bug fix or correction of an issue.
  - `eval`: Eval runner, metrics, judge, thresholds, ablations or reports.
  - `docs`: Documentation updates (e.g., README, ADRs, comments).
  - `style`: Code style changes (e.g., formatting, indentation).
  - `refactor`: Code refactoring or restructuring without changing functionality.
  - `perf`: Latency, cost or memory improvements.
  - `test`: Adding or modifying tests.
  - `ci`: GitHub Actions workflows, the eval gate, deploy pipelines.
  - `chore`: Routine tasks, maintenance, or tooling changes.

- `<scope>`: The part of Verity RAG the change affects (e.g., `ingest`, `retrieval`, `generation`, `api`, `web`, `evals`). The full list is in the [Commit Message Guidelines](COMMIT_MESSAGE_GUIDELINES.md#scope).

- `<message>`: A short, clear, and concise description of the changes, in the imperative mood with a capital first letter.

- `<issue references>`: The issue the PR works on, using a GitHub keyword (`fixes #18`, `refs #18`).

## Examples

- `feat(retrieval): Add Reciprocal Rank Fusion (fixes #18)`
- `eval(evals): Add E0 baseline report (fixes #13)`
- `fix(verification): Handle answers with no citation markers (fixes #70)`
- `docs(adr): Record pgvector decision (refs #11)`

## Rules

- **One issue per PR** where possible. Put `Closes #<issue>` in the PR body.
- **Small PRs.** Split large changes into reviewable steps. Open a draft PR early if you want feedback.
- **Fill in the Eval impact section** of the [pull request template](.github/PULL_REQUEST_TEMPLATE.md). Any change to retrieval, generation, prompts, configs or eval code needs before/after numbers on the dev split, or the CI smoke-eval comment. Never tune on the test split.
- **CI must pass**, including the eval gate. Don't weaken `evals/thresholds.yaml` to get a PR through. A threshold change needs an ADR.
- **New pipeline behavior** needs a unit test, a config flag and an ablation entry.
- **Don't edit human-labeled data** (`evals/datasets/`, `evals/judges/calibration/`) in a PR that also changes code.
- **Coding agents are welcome**, but you must be able to explain every line you submit.

Please adhere to this naming convention to maintain consistency and clarity.
