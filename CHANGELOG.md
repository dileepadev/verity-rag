# Changelog

All notable changes to this project are documented in this file.

Changes are organized into the following categories:

- **Added:** New features or functionality introduced to the project.
- **Changed:** Modifications to existing functionality that do not add new features.
- **Fixed:** Bug fixes that resolve issues or correct unintended behavior.
- **Removed:** Features or components that have been removed from the project.

Every release also includes an **Eval results** table measured on the test split. See [VERSIONING.md](VERSIONING.md) for the release process.

## [Unreleased]

Unreleased changes go here.

## [v0.1.0] - Work in progress

### Added - v0.1.0

- Design docs: [docs/design.md](docs/design.md) (index) with sections in [docs/design/](docs/design/), and [docs/engineering-standards.md](docs/engineering-standards.md) (refs #3)
- Agent instructions: [AGENTS.md](AGENTS.md) and [CLAUDE.md](CLAUDE.md) (refs #3)
- Initial [README.md](README.md) (refs #3)
- Build log and ADR template: [docs/build-log.md](docs/build-log.md), [docs/adr/](docs/adr/) (refs #3)
- Community standards (refs #5):
  - [.github/ISSUE_TEMPLATE/](./.github/ISSUE_TEMPLATE) - Issue templates, including answer quality reports
  - [.github/PULL_REQUEST_TEMPLATE.md](./.github/PULL_REQUEST_TEMPLATE.md) - Pull request template with an **Eval impact** section
  - [BRANCH_NAMING_GUIDELINES.md](./BRANCH_NAMING_GUIDELINES.md), [COMMIT_MESSAGE_GUIDELINES.md](./COMMIT_MESSAGE_GUIDELINES.md), [PULL_REQUEST_GUIDELINES.md](./PULL_REQUEST_GUIDELINES.md)
  - [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md), [CONTRIBUTING.md](./CONTRIBUTING.md), [SECURITY.md](./SECURITY.md)
  - [CHANGELOG.md](./CHANGELOG.md), [VERSIONING.md](./VERSIONING.md), [TODO.md](./TODO.md), [LICENSE](./LICENSE)
- Markdown lint configuration: [.markdownlint.jsonc](./.markdownlint.jsonc) (refs #3)
- Project scaffold: `uv` project with the `verity_rag` package, ruff, mypy, pytest, pre-commit, `Makefile`, `docker-compose.yml` (Postgres + pgvector), `.env.example`, the CI workflow and Dependabot (refs #4)

<!-- Release entry template:

## [v0.1.0] - YYYY-MM-DD

### Added - v0.1.0

- ...

### Eval results - v0.1.0

Golden set: golden_vN (test split, N questions) · Generator: <model ID> · Judge: <model ID> · Eval run: <date>-<git SHA>

| Metric             | Value | 95% CI      | v1 target |
| ------------------ | ----- | ----------- | --------- |
| Recall@10          |       |             | ≥ 0.90    |
| MRR@10             |       |             | ≥ 0.70    |
| Faithfulness       |       |             | ≥ 0.90    |
| Answer correctness |       |             | ≥ 0.85    |
| Citation precision |       |             | ≥ 0.90    |
| Abstention recall  |       |             | ≥ 0.85    |
| False-refusal rate |       |             | ≤ 0.10    |
| Latency p95 (TTFT / full) |  |          | ≤ 2 s / ≤ 8 s |
| Tokens per query   |       |             | report    |
-->

<!-- e.g., -->
<!-- Unreleased -->
<!-- v1.0.0 -->
<!-- v0.5.0 -->
<!-- v0.1.0 -->

[Unreleased]: https://github.com/dileepadev/verity-rag/commits/main
[v0.1.0]: https://github.com/dileepadev/verity-rag/commits/v0.1.0
