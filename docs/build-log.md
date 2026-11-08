# Build log

Notable coding-agent sessions: what was asked, what the agent got wrong, and how it was caught. The rules are in [AGENTS.md](../AGENTS.md).

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

## 2026-11-08: Project plan, docs and GitHub issues

- Asked: write the design, the GitHub issues and the community standards, then review the whole plan and keep it simple, with free plans only.
- Agent got wrong:
  - The first plan was too big: paid services (a paid LLM API and hosted embeddings), extra environments and too many issues.
  - Relative links in `.github/PULL_REQUEST_TEMPLATE.md` broke, because they resolve against `.github/`.
  - The command-line markdownlint showed line-length warnings that the editor didn't, because there was no shared config.
- Caught by: the maintainer's review; markdownlint; a link-check script.
- Verified: markdownlint reports 0 issues; all relative links and anchors resolve.
- Lesson: settle the budget and scope before designing; use one lint config for the editor, the CLI and CI; check links after moving files.
