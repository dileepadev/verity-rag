# Verity RAG: agent instructions

Before starting a task, read [`docs/engineering-standards.md`](docs/engineering-standards.md) and the design index [`docs/design.md`](docs/design.md), then the section files in [`docs/design/`](docs/design/) that the issue references (issues cite sections as `docs/design.md §N`; the index maps each § to its file). The work order is in the GitHub issues: phases under #1, `priority: must` first ([design §22](docs/design/09-plan-and-risks.md#22-implementation-plan-phases-and-milestones)).

## Rules

- Python 3.12, uv. Run `make lint test` before every commit.
- Never edit files in `evals/datasets/` or `evals/judges/calibration/`: human-labeled data.
- Never weaken thresholds in `evals/thresholds.yaml` without an ADR.
- The provider URL, model IDs and rate limits come from `configs/`; never hardcode them.
- Free plans only ([design §17](docs/design/06-operations-and-cost.md#17-cost-model)). Don't add a service or setting that can bill.
- New pipeline behavior needs: a unit test, a config flag, and an ablation entry.
- Keep functions small and typed; no global state; no `print()`, use the logger.
- Keep it simple: one LLM provider (Groq, through one OpenAI-compatible client), one database, one deployed API. Don't add services, frameworks or dependencies that the issue doesn't ask for.
- Every Markdown file must pass [markdownlint](https://github.com/DavidAnson/markdownlint) with no warnings, using the repo config `.markdownlint.jsonc` (default rules, with MD013 line length off, as in the editor). Fix the content instead of disabling rules. Write placeholders as `[placeholder]` or in backticks, never as bare `<placeholder>` (MD033).
- The only exception is a one-line file that can't be fixed, such as `CLAUDE.md` (just `@AGENTS.md`): it may use `<!-- markdownlint-disable-next-line <rule> -->` for that one rule. Never disable a rule for a whole file or folder, and don't turn off more rules in `.markdownlint.jsonc`.

## Workflow for every task

1. A GitHub issue with acceptance criteria.
2. Propose a plan first; wait for approval.
3. Implement on a branch.
4. The human reviews the diff, runs tests and evals, then fixes or rejects.
5. Small PRs only, using Conventional Commits. Follow `BRANCH_NAMING_GUIDELINES.md`, `COMMIT_MESSAGE_GUIDELINES.md` and `PULL_REQUEST_GUIDELINES.md`, and fill in the **Eval impact** section of the PR template.

## Commits and pushes

Never commit or push without the maintainer's explicit approval. Before every commit, stage the files, then show:

1. the full commit message;
2. the files being committed (`git diff --staged --stat`);
3. the lines being committed (`git diff --staged`). If the diff is too long to read in chat, show the per-file line counts and say how to view the full diff;
4. whether it will be pushed, and to which remote and branch.

Then wait. Approval covers only that commit and push; ask again for the next one.

## Never delegated to an agent

- golden-set labels and judge-calibration labels;
- choosing thresholds;
- interpreting metrics;
- security review;
- the final README claims.

## Build log

Notable sessions go in `docs/build-log.md`:

```markdown
## YYYY-MM-DD: <task>
- Asked: ...
- Agent got wrong: ...
- Caught by: ... (a test? an eval drop?)
- Verified: ...
- Lesson: ...
```

Never commit code that can't be explained line by line.
