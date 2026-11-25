# Build log

Notable coding-agent sessions: what was asked, what the agent got wrong, and how it was caught. The rules are in [AGENTS.md](../AGENTS.md). Entries are newest first: add each new entry above the existing ones, right after the horizontal rule below the template.

Entry template:

```markdown
## YYYY-MM-DD: [task]

- Asked: ...
- Agent got wrong: ...
- Caught by: ... (a test? an eval drop? review?)
- Verified: ...
- Lesson: ...
```

---

## 2026-11-25: Review of the architecture diagrams before merge (#48)

- Asked: review the branch, including the diagrams, and fix every issue before it merges, so no wrong content reaches `main`.
- Agent got wrong:
  - The PR #52 description, written without reading the diff, said the Mermaid blocks were kept; the branch replaces them with GIFs.
  - Four diagrams contradicted the design. Query showed one of the three abstention gates (§8.7) and implied unsupported sentences are dropped. Evaluation said every golden question runs in CI (CI runs the dev split and the smoke set, §12.5). Ingestion said everything is stored in PostgreSQL (page images go to object storage). Deployment left the verifier out of the LLM calls.
  - The first fix only added a note under the query diagram, which left the wrong images in place.
- Caught by: comparing the PR description with the diff, and each diagram's labels and captions with the design sections they illustrate; the maintainer rejected the note-only fix.
- Verified: the original generator scripts were gone, so a new generator parses the SVGs and rebuilds the frames; with no edits applied it re-renders all five original SVGs pixel-identical. The four corrected diagrams were rendered and every hold frame inspected; each GIF decodes frame by frame to its source render, loops forever and is 205 to 307 KB; all 193 MP4 frames decode at their planned times, with seven chapters, and the file is 446 KB (2 min 31 sec); the system context files are unchanged; the Mermaid sources and alt text match the new diagrams; no other file refers to the old wording; `make lint test` passes. The Mermaid sources were not rendered, because running mermaid-cli was not permitted in the session.
- Lesson: write a PR description from the diff, not from memory; check a diagram against the design text it illustrates, not only against its own source; fix wrong content at the source instead of annotating around it; keep the tools that generate binary assets. The generator now lives outside the repository in `verity-rag-diagram-tools/`, next to the repository, with a README.

## 2026-11-17: Architecture walkthrough video (#48)

- Asked: make an MP4 from the maintainer's updated diagrams, with dark chapter titles and on-screen explanations; keep generation scripts outside the repository.
- Agent got wrong: the first export repeated static frames and exceeded the repository's 500 KB file limit; player controls also covered the bottom captions while paused.
- Caught by: checking the encoded file size and pausing the video in a browser before delivery.
- Verified: the final H.264 MP4 is 2 min 26 sec and below 500 KB; original 1360 × 760 diagram content is preserved with an 80-pixel margin below for player controls; all five chapters retain the GIF captions and timing; chapter metadata, full-file decoding, browser playback and seeking checked; source diagram hashes unchanged; repository lint and tests pass.
- Lesson: use variable frame timing for diagram videos, leave room for playback controls, and inspect frames decoded from the compressed MP4 rather than only the source images.

## 2026-11-17: Animated architecture diagrams (#48)

- Asked: add clearer dark-mode animated images of the five Mermaid diagrams; first beneath links to each original, then (the maintainer's later decision) replace the Mermaid blocks in the document with the animated GIFs and keep the Mermaid source as `.mmd` files in the diagrams directory.
- Agent got wrong: the first delivery put playback behind an HTML viewer's Play button, so the user could not see animation directly; an early deployment arrow also pointed to the provider instead of the API. In the rebuild, the GIF palette dropped small accent colors (a purple dot and a red badge came out the wrong color), step labels and a loop-back line overlapped other text, and the first GIF encoding was up to 1.3 MB against the 500 KB `check-added-large-files` limit.
- Caught by: the user's review of animation visibility; diagram source review and browser screenshots for arrow destinations; decoding frames from the finished GIFs instead of trusting the pre-palette renders; checking file sizes against the hook limit.
- Verified: each `.mmd` file is byte-identical to the Mermaid block in the last commit; no Mermaid block is left in the document; all relative links and image paths resolve; SVGs parse as XML; each GIF decodes to 33 to 45 frames, loops forever and is under 340 KB; markdownlint passes on the changed Markdown files.
- Lesson: deliver animation in the image itself when the expected artifact is an animated diagram; check arrow destinations as carefully as labels; reduce GIF palettes with the exact drawing colors included, and look at the decoded GIF.

## 2026-11-08: Scaffold the repository and tooling (#4)

- Asked: set up the `uv` project, ruff, mypy, pytest, pre-commit, the `Makefile`, Postgres in Docker and CI.
- Agent got wrong:
  - The `trailing-whitespace` hook removed two-space Markdown line breaks from `CONTRIBUTING.md` and `VERSIONING.md`.
  - The first `make lint` skipped ruff and mypy, because the new files weren't staged and pre-commit only sees tracked files.
- Caught by: reading the hook's diff before committing; the "(no files to check)" lines in the pre-commit output.
- Verified: both files restored; the hook now uses `--markdown-linebreak-ext=md`; `make lint` (10 checks on all files) and `make test` pass.
- Lesson: review every file a formatter changes; stage new files before running pre-commit on them.

## 2026-11-08: Project plan, docs and GitHub issues

- Asked: write the design, the GitHub issues and the community standards, then review the whole plan and keep it simple, with free plans only.
- Agent got wrong:
  - The first plan was too big: paid services (a paid LLM API and hosted embeddings), extra environments and too many issues.
  - Relative links in `.github/PULL_REQUEST_TEMPLATE.md` broke, because they resolve against `.github/`.
  - The command-line markdownlint showed line-length warnings that the editor didn't, because there was no shared config.
- Caught by: the maintainer's review; markdownlint; a link-check script.
- Verified: markdownlint reports 0 issues; all relative links and anchors resolve.
- Lesson: settle the budget and scope before designing; use one lint config for the editor, the CLI and CI; check links after moving files.
