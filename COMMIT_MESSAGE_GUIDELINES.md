# Commit Message Guidelines

A good commit message should be descriptive and provide context about the changes made. This helps improve code review, debugging, and long-term maintainability. Verity uses [Conventional Commits](https://www.conventionalcommits.org) with the conventions below.

Table of Contents:

- [Commit Message Guidelines](#commit-message-guidelines)
  - [Commit Message Format](#commit-message-format)
    - [`<type>`](#type)
    - [`<scope>`](#scope)
    - [`<short message>`](#short-message)
    - [`<optional issue references>`](#optional-issue-references)
    - [`<optional PR reference>`](#optional-pr-reference)
    - [`<optional longer description>`](#optional-longer-description)
  - [Issue and PR References](#issue-and-pr-references)
    - [Best Practices](#best-practices)
    - [Examples for Issue and PR References](#examples-for-issue-and-pr-references)
    - [Summary Table for Issue and PR Linking (with Scope)](#summary-table-for-issue-and-pr-linking-with-scope)
  - [Squash Merges](#squash-merges)
  - [✅ Summary Examples with All Fields](#-summary-examples-with-all-fields)

## Commit Message Format

Use the following format for commit messages:

```md
<type>(<scope>): <short message> (<optional issue references>) (<optional PR reference>)

<optional longer description>
```

### `<type>`

The `<type>` field indicates the nature of the changes made in the commit. Use one of the following values:

| Type     | Description                                                                          |
|----------|--------------------------------------------------------------------------------------|
| feat     | A new feature or pipeline behavior (ingestion, retrieval, generation, API, web UI).  |
| fix      | A bug fix or correction of an issue.                                                 |
| eval     | Eval runner, metrics, judge prompts, thresholds, ablation configs or eval reports.   |
| docs     | Documentation updates (e.g., README, ADRs, design docs, code comments).              |
| style    | Code style changes (e.g., formatting, indentation, no logic).                        |
| refactor | Code refactoring without changing external behavior.                                 |
| perf     | Performance improvements (latency, cost, memory).                                    |
| test     | Adding or modifying tests.                                                           |
| ci       | GitHub Actions workflows, CI eval gate, deploy pipelines.                            |
| chore    | Routine tasks, maintenance, dependencies, tooling or release commits.                |

> [!Note]
> Golden-set labels (`evals/datasets/`) and judge-calibration labels (`evals/judges/calibration/`) are written by hand by the maintainer. Commit them as `eval(datasets): ...` and never mix them with code changes.

### `<scope>`

The `<scope>` is optional, but recommended. It names the part of Verity the commit affects. Scopes follow the repository layout:

| Scope         | Description                                                          |
|---------------|----------------------------------------------------------------------|
| repo          | Project-wide configuration or setup                                  |
| config        | `configs/` (provider, models, limits, experiments), environment      |
| deps          | Dependency updates (`pyproject.toml`, `uv.lock`, `web/package.json`) |
| corpus        | `corpus/sources.yaml` and source documents                           |
| ingest        | Fetching, parsing, chunking, contextual headers, embedding, indexing |
| retrieval     | Dense and keyword search, fusion, reranking, context assembly        |
| generation    | Prompts, generator, citation markers                                 |
| verification  | Support checks and abstention gates                                  |
| llm           | Model-agnostic LLM interface and provider adapters                   |
| api           | FastAPI service, SSE, rate limits, daily limits                      |
| web           | Next.js web app                                                      |
| db            | Data model and migrations                                            |
| evals         | Eval runner, metrics, judge, thresholds, reports                     |
| datasets      | Golden sets and injection test sets (human-labeled only)             |
| observability | Tracing, metrics, PII redaction                                      |
| infra         | Docker, Cloud Run, Supabase, Vercel, Secret Manager                  |
| security      | Threat model, scans, security controls                               |
| adr           | Architecture decision records in `docs/adr/`                         |
| release       | Version bumps and release commits                                    |

### `<short message>`

A concise summary of what the commit does.

Writing Tips:

- Use the imperative mood (e.g., “Add” not “Added”)
- Capitalize the first letter
- Don’t end with a period
- Keep under 50 characters if possible
- Be specific (e.g., “Add RRF fusion” > “Update retrieval”)
- Avoid "I", "this commit", or "fix" as vague verbs

### `<optional issue references>`

Optionally link the commit to relevant issues using GitHub keywords such as `fixes`, `closes`, `resolves`, or `refs`. Multiple issues can be referenced by separating them with commas. Every task in Verity has a GitHub issue, so most commits should carry at least a `refs #<issue>`.

### `<optional PR reference>`

Optionally link the commit to a pull request using the format `(#<number>)`. This should be placed at the end of the commit message.

### `<optional longer description>`

An optional detailed description of the changes made in the commit. This can include the reasoning behind the changes, implementation details, or any other relevant information. Separate this section from the header with a blank line.

For changes that affect quality, mention the measured effect (e.g., "Recall@10 on dev: 0.71 → 0.82"), and point to the eval report.

## Issue and PR References

Use GitHub keywords to link commits to issues, and standard notation for PRs.

### Best Practices

- **Pull Requests**: Use `(#<number>)` at the very end of the header. This is automatically recognized by GitHub.
  - ✅ `(#5)`
  - 🚫 `(pr #5)` or `refs #5` for the PR itself.
- **Issues**: Use standard GitHub keywords (`fixes`, `refs`, `closes`, `resolves`) in parentheses before the PR number.
  - 🚫 Don't write a bare `(#18)` for an issue: that is the PR reference slot.

### Examples for Issue and PR References

**Straightforward PR reference:**

```md
chore(deps): Bump docling to 2.x (#41)
```

**Issue + PR:**

```md
feat(retrieval): Add Reciprocal Rank Fusion (fixes #18) (#52)
```

**Multiple Issues + PR:**

```md
eval(evals): Add E1 and E2 ablation rows (refs #17, #23) (#60)
```

### Summary Table for Issue and PR Linking (with Scope)

| Purpose                | Example Commit Message                                                  | Result                              |
| ---------------------- | ----------------------------------------------------------------------- | ----------------------------------- |
| Close single issue     | `feat(retrieval): Add Reciprocal Rank Fusion (fixes #18) (#52)`         | Closes #18, links PR #52            |
| Reference single issue | `docs(adr): Record pgvector decision (refs #11) (#44)`                  | Links issue #11, PR #44             |
| Reference PR Only      | `chore(deps): Bump docling to 2.x (#41)`                                | Links PR #41                        |
| Close multiple issues  | `eval(evals): Add E0 report and runner (fixes #12, #13) (#40)`          | Closes #12, #13, links PR #40       |
| Mixed References       | `fix(verification): Handle empty citations (fixes #70, refs #21) (#71)` | Closes #70, refs #21, links PR #71  |
| Multiple PRs (rare)    | `chore(repo): Sync templates (#5, #6)`                                  | Links PR #5 and #6                  |

## Squash Merges

Pull requests are squash-merged into `main`. GitHub uses the PR title as the commit header and appends `(#<PR number>)` automatically, so write the PR title as `<type>(<scope>): <short message> (<issue references>)` and the final commit matches this guide. See [PULL_REQUEST_GUIDELINES.md](PULL_REQUEST_GUIDELINES.md).

## ✅ Summary Examples with All Fields

```md
feat(retrieval): Add Reciprocal Rank Fusion (fixes #18) (#52)

Fuses dense and keyword results with RRF (k = 60). E3 on dev:
Recall@10 0.78 → 0.86, MRR@10 0.55 → 0.63. Report in evals/reports/.
```

```md
fix(verification): Handle answers with no citation markers (fixes #70) (#71)
```

```md
eval(datasets): Add golden set v0 with datasheet (fixes #12) (#38)
```

```md
chore(release): Release v0.1.0 (refs #8) (#45)
```
