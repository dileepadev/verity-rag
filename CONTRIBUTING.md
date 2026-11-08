# Contributing to Verity RAG

Thank you for your interest in contributing to [Verity RAG](https://github.com/dileepadev/verity-rag)! We welcome contributions, including bug fixes, retrieval and evaluation improvements, documentation improvements, and reports of wrong or badly cited answers.

Verity RAG is evaluation-driven: every change to the pipeline has to show its effect on the golden set. Read [docs/design.md](docs/design.md) and [docs/engineering-standards.md](docs/engineering-standards.md) before starting a larger change.

> [!Note]
> Verity RAG is in early development. The Python tooling (`uv`, `make` targets, CI) is being set up in [#4](https://github.com/dileepadev/verity-rag/issues/4); until it lands, some commands below won't work yet.

## Getting Started

1. **Find or open an issue**  
   Every task starts from a GitHub issue with acceptance criteria. Check the [development plan (#1)](https://github.com/dileepadev/verity-rag/issues/1) for open tasks, or open a new issue using one of the [issue templates](.github/ISSUE_TEMPLATE). Comment on the issue before starting larger work.

2. **Fork the repository**  
   Fork this repository to your GitHub account. This creates a copy of the repository in your account, allowing you to make changes without affecting the original repository.  
   To fork the repository, click the **Fork** button in the top right corner of this page or click [here to fork the repository](https://github.com/dileepadev/verity-rag/fork).

3. **Clone your fork and set up**  
   Clone your forked repository and install the development environment (Python 3.12, [uv](https://docs.astral.sh/uv/), Docker):

   ```bash
   git clone https://github.com/<your-username>/verity-rag.git
   cd verity-rag
   cp .env.example .env   # add your own API keys; never commit .env
   make setup             # install dependencies and pre-commit hooks
   make up                # start Postgres + pgvector
   ```

4. **Create a new branch**  
   Create a new branch for your changes. Follow the [branch naming guidelines](BRANCH_NAMING_GUIDELINES.md).

   ```bash
   git checkout -b feat/18-hybrid-search
   ```

5. **Make changes, test and commit**  
   Run the checks before every commit, then commit with a descriptive message. Follow the [commit message guidelines](COMMIT_MESSAGE_GUIDELINES.md).

   ```bash
   make lint test
   git commit -m "feat(retrieval): Add Reciprocal Rank Fusion (refs #18)"
   ```

6. **Measure the effect**  
   If you changed retrieval, generation, prompts, configs or eval code, run the eval on the dev split and compare it with `main`:

   ```bash
   make eval SPLIT=dev
   make report
   ```

7. **Push your changes**  
   Push your changes to your forked repository.

   ```bash
   git push origin feat/18-hybrid-search
   ```

8. **Submit a pull request**  
   To submit a pull request:
   - Go to your forked repository.
   - Click the **Compare & pull request** button next to your branch.
   - Add a title and description for your pull request. Follow the [pull request guidelines](PULL_REQUEST_GUIDELINES.md).
   - Fill in the [pull request template](.github/PULL_REQUEST_TEMPLATE.md), including the **Eval impact** section, then click **Create pull request**.

## Guidelines

- **Code style:** typed Python 3.12 (mypy strict on core packages), ruff, small functions, no global mutable state, structured logging instead of `print()`.
- **Configuration:** the provider URL, model IDs and rate limits come from `configs/`. Never hardcode them, and never commit secrets.
- **New pipeline behavior** needs a unit test, a config flag and an ablation entry.
- **Tests:** unit tests run without network access. Keep coverage at 80% or more on core logic.
- **Evaluation:** tune on the dev split only; never tune on test. Don't weaken `evals/thresholds.yaml` without an ADR.
- **Human-labeled data:** files in `evals/datasets/` and `evals/judges/calibration/` are labeled by hand by the maintainer. Don't edit them in a PR. To suggest a new golden-set question, open an issue with the question and its evidence as `(document, page, quote)`.
- **Corpus:** new documents must be public and legally reusable. Add them to `corpus/sources.yaml` with their license, and commit metadata only unless the license allows redistribution.
- **Decisions:** record significant design decisions as an ADR in `docs/adr/` (MADR format).
- **Privacy:** don't put personal data in issues, test fixtures, prompts or eval examples.
- **Coding agents:** you may use them, but you must be able to explain every line you submit. Agents follow [AGENTS.md](AGENTS.md).
- Update documentation and [CHANGELOG.md](CHANGELOG.md) where necessary, and keep your pull request focused on one issue.
- Refer to the following templates and guidelines before submitting your changes:
  - [verity-rag/](./) - Root directory of the repository
    - [.github/](./.github) - GitHub-specific files (workflows, templates, etc.)
      - [ISSUE_TEMPLATE/](./.github/ISSUE_TEMPLATE) - Contains all issue templates
        - [answer_quality.md](./.github/ISSUE_TEMPLATE/answer_quality.md) - Template for reporting wrong, unsupported or badly cited answers
        - [bug_report.md](./.github/ISSUE_TEMPLATE/bug_report.md) - Template for reporting bugs
        - [documentation_update.md](./.github/ISSUE_TEMPLATE/documentation_update.md) - Template for documentation updates
        - [feature_request.md](./.github/ISSUE_TEMPLATE/feature_request.md) - Template for suggesting new features
        - [feedback.md](./.github/ISSUE_TEMPLATE/feedback.md) - Template for general feedback
        - [other.md](./.github/ISSUE_TEMPLATE/other.md) - Template for other types of issues
      - [PULL_REQUEST_TEMPLATE.md](./.github/PULL_REQUEST_TEMPLATE.md) - Template for pull request submissions
    - [AGENTS.md](./AGENTS.md) - Rules and workflow for coding agents
    - [BRANCH_NAMING_GUIDELINES.md](./BRANCH_NAMING_GUIDELINES.md) - Branch naming rules
    - [CHANGELOG.md](./CHANGELOG.md) - Record of project changes
    - [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) - Contributor behavior guidelines
    - [COMMIT_MESSAGE_GUIDELINES.md](./COMMIT_MESSAGE_GUIDELINES.md) - Rules for writing commit messages
    - [CONTRIBUTING.md](./CONTRIBUTING.md) - How to contribute to the project
    - [LICENSE](./LICENSE) - Project license
    - [PULL_REQUEST_GUIDELINES.md](./PULL_REQUEST_GUIDELINES.md) - Pull request submission guidelines
    - [README.md](./README.md) - Project overview
    - [SECURITY.md](./SECURITY.md) - Security policy and reporting
    - [TODO.md](./TODO.md) - Where planned work is tracked
    - [VERSIONING.md](./VERSIONING.md) - Versioning strategy for the project
    - [docs/](./docs) - Design, engineering standards, ADRs and other project docs

## Code of Conduct

This project adheres to the **Contributor Covenant Code of Conduct**. By participating, you agree to abide by its terms.  
Read the full Contributor Covenant Code of Conduct in the [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) file.

## Contact

If you have any questions or suggestions regarding Verity RAG, feel free to open an issue or submit a pull request in this repository.

You can also reach me via email at: **<contact@dileepa.dev>**
