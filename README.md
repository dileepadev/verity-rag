# Verity

> Ask questions about long, messy official documents and get answers you can check. Every claim cites a page. When the documents don't answer the question, Verity says "I don't have that information."

**Status:** in development.

**Stack:** Python · FastAPI · PostgreSQL/pgvector · Docling · Groq · bge-m3 · Next.js · OpenTelemetry · Google Cloud Run · Supabase · Vercel. Runs on free plans only.

## Docs

| File | What it's for |
| --- | --- |
| [docs/design.md](docs/design.md) | Index of the full design, with each section in its own file under [docs/design/](docs/design/): problem, architecture, components, data model, evaluation, security, privacy, costs, implementation phases ([§22](docs/design/09-plan-and-risks.md#22-implementation-plan-phases-and-milestones)), stretch goals ([§23](docs/design/09-plan-and-risks.md#23-stretch-goals)) |
| [docs/engineering-standards.md](docs/engineering-standards.md) | Repository, code, LLM, eval, observability and security standards, plus the definition of done |
| [AGENTS.md](AGENTS.md) | Rules and workflow for coding agents (also loaded by `CLAUDE.md`) |

## Contributing

Contributions are welcome. Start with [CONTRIBUTING.md](CONTRIBUTING.md), and follow the [branch](BRANCH_NAMING_GUIDELINES.md), [commit](COMMIT_MESSAGE_GUIDELINES.md) and [pull request](PULL_REQUEST_GUIDELINES.md) guidelines. Report wrong or badly cited answers with the **Answer Quality** issue template, and security issues privately as described in [SECURITY.md](SECURITY.md). Releases follow [VERSIONING.md](VERSIONING.md) and are recorded in [CHANGELOG.md](CHANGELOG.md). This project follows the [Code of Conduct](CODE_OF_CONDUCT.md) and is released under the [MIT License](LICENSE).

## First steps

The plan lives in GitHub issues: start with [#1](https://github.com/dileepadev/verity/issues/1) and work through [Phase 0](https://github.com/dileepadev/verity/issues/2) in order.

1. Pick the corpus: public, legally reusable, 500–2,000 pages, ideally with tables and scanned pages ([#6](https://github.com/dileepadev/verity/issues/6)).
2. Collect 20 real questions people ask about it ([#7](https://github.com/dileepadev/verity/issues/7)).
3. Write golden set v0 **before** tuning anything ([design §12.1](docs/design/05-evaluation.md#121-golden-dataset)).

> When the project ships, replace this README with the blueprint in [design §26](docs/design/10-decisions-and-deliverables.md#26-deliverables-readme-demo-video-write-up): results first, then how it works, then setup.
