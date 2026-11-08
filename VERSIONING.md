# Versioning

This project follows a versioning pattern similar to [Semantic Versioning](https://semver.org/) (SemVer) for managing releases.

## Table of Contents

- [Versioning](#versioning)
  - [Table of Contents](#table-of-contents)
  - [Format](#format)
    - [Examples](#examples)
  - [Planned Releases](#planned-releases)
  - [What Else Is Versioned](#what-else-is-versioned)
  - [Release Process](#release-process)
    - [Typical Steps](#typical-steps)
  - [Pre-release Versions](#pre-release-versions)
  - [Viewing Tags \& Differences](#viewing-tags--differences)
  - [Questions or Issues?](#questions-or-issues)

## Format

Version numbers follow the structure:

`MAJOR.MINOR.PATCH`

- **MAJOR** – Incompatible changes to the public API (`/v1/...`), the config schema or the CLI
- **MINOR** – Backward-compatible functionality, pipeline improvements and new features
- **PATCH** – Backward-compatible bug fixes and small improvements

While Verity RAG is below `1.0.0`, any release may contain breaking changes.

### Examples

| Version | Meaning                          |
| ------- | -------------------------------- |
| `0.1.0` | First public release / early dev |
| `0.1.1` | Bug fix                          |
| `0.2.0` | New non‑breaking feature         |
| `1.0.0` | Official stable release          |
| `1.0.1` | Bug fix after release            |
| `1.1.0` | New feature added                |
| `2.0.0` | Major breaking change            |

## Planned Releases

Each phase of the [development plan](https://github.com/dileepadev/verity-rag/issues/1) ends with a tagged release:

| Version  | Milestone           | Phase                                                                        |
| -------- | ------------------- | ---------------------------------------------------------------------------- |
| `v0.1.0` | M1: baseline report | [Phase 1 · Measure first](https://github.com/dileepadev/verity-rag/issues/8) |
| `v0.5.0` | M2: quality targets | [Phase 2 · Make it good](https://github.com/dileepadev/verity-rag/issues/15) |
| `v1.0.0` | M3: deployed v1.0   | [Phase 3 · Make it real](https://github.com/dileepadev/verity-rag/issues/24) |

## What Else Is Versioned

The software version is separate from the other versioned parts of Verity RAG. A release note names the version of each one it was measured with.

| Item              | Scheme                                       | Where                                   |
| ----------------- | -------------------------------------------- | --------------------------------------- |
| Golden set        | `golden_v0`, `golden_v1`, `golden_v2`, ...   | `evals/datasets/` and its datasheet     |
| Prompts           | Versioned files, reviewed like code          | `src/verity_rag/generation/prompts/`    |
| Index             | `chunker_version` and `embedding_model`      | Stored on every chunk row               |
| Experiments       | `E0` ... `E9`                                | `configs/experiments/`                  |
| Eval runs         | Date + git SHA + config hash                 | `evals/reports/`                        |

## Release Process

All notable changes are documented in the [CHANGELOG.md](CHANGELOG.md) file. **Every release note includes eval numbers.**

### Typical Steps

1. Meet the exit criteria of the phase issue (all `priority: must` sub-issues closed)
2. Run the full eval on the **test split** with the chosen default model, and keep the report in `evals/reports/`
3. Update the `CHANGELOG.md` with categorized entries:  
   - **Added**, **Changed**, **Fixed**, **Removed**
   - plus an **Eval results** table: metric, value, 95% confidence interval, v1 target
4. Bump the `version` in `pyproject.toml`
5. Open a release PR and squash-merge it (e.g. `chore(release): Release v0.1.0 (refs #8)`)
6. Tag the merge commit on `main`:

   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```

7. Create a GitHub release and paste the changelog section, including the eval table, the golden-set version, the model IDs and the git SHA of the eval run:

   ```bash
   gh release create v0.1.0 --title "v0.1.0" --notes-file <release-notes.md>
   ```

## Pre-release Versions

For beta or release candidates, we use suffixes:

- `1.0.0-beta.1` – Beta release
- `1.0.0-rc.1` – Release candidate

These versions are intended for testing and may not be fully stable.

## Viewing Tags & Differences

List all version tags:

```bash
git tag
```

View differences between versions:

```bash
git log v0.1.0..v0.5.0
```

## Questions or Issues?

If you have questions about the versioning strategy or encounter version-related problems, feel free to open an issue on the [GitHub repository](https://github.com/dileepadev/verity-rag/issues).
