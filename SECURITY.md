# Security Policy

The [Verity RAG](https://github.com/dileepadev/verity-rag) project team takes security issues very seriously. We appreciate your efforts to responsibly disclose any security vulnerabilities you find.

## Supported Versions

Verity RAG is in early development. Security fixes are made on `main` and included in the next release. Only the latest release and the live demo receive fixes.

## Reporting a Vulnerability

If you discover a security vulnerability, please send an email to **<contact@dileepa.dev>**. Please do not create a public issue for the vulnerability.

Your email should include the following information:

- A description of the vulnerability
- Steps to reproduce the vulnerability (for prompt-injection issues, the exact input and, if available, the trace ID)
- Possible impact of the vulnerability
- Any suggested mitigation or remediation steps

We will respond to your email as soon as possible and work with you to address any security issues.

## Scope

Verity RAG is a public, read-only question-answering service over public documents. The threat model and the mapping to the OWASP Top 10 for LLM Applications (2025) are in `docs/security.md` (planned in [#29](https://github.com/dileepadev/verity-rag/issues/29)) and [docs/design.md §14](docs/design/07-security-and-privacy.md#14-security).

**In scope:**

- Prompt injection, from a question or from a document, that leaks API keys or other users' data, bypasses the abstention or citation rules in a way that misleads users, or changes how other users are answered
- Poisoned or tampered documents getting into the index (bypassing the `corpus/sources.yaml` allowlist or hash checks)
- Bypassing rate limits, the daily request limit or the kill switch (unbounded consumption)
- Personal data appearing in logs, traces or stored feedback despite redaction
- Unsafe rendering of model output in the web UI (e.g., XSS)
- Exposed secrets, CI/CD or supply-chain weaknesses (dependencies, container images, GitHub Actions)

**Out of scope (please use a public issue instead):**

- Wrong, incomplete or badly cited answers with no security impact: use the **Answer Quality** issue template
- Jailbreaks that only make the model produce off-topic text: Verity RAG has no tools or actions, so report these as answer quality issues
- Findings that need denial-of-service or load testing against the live demo

Please don't run automated scanners or load tests against the live demo, and don't include real personal data in your reports.

## Bug Bounty Program

At this time, we do not offer a bug bounty program. If we decide to introduce one in the future, details will be shared here.

## Maintainer Responsibilities

Maintainers are responsible for the security of the project. This includes:

- Responding to security reports in a timely manner
- Investigating reported vulnerabilities
- Developing and releasing patches for confirmed vulnerabilities
- Adding a regression case to the injection test set when a report involves prompt injection
- Communicating with the reporting party as the issue is addressed
- Regularly reviewing and auditing the security of the project

## Disclosures

- We will acknowledge receipt of your report within one business day as soon as possible.
- We will confirm the vulnerability and determine its impact.
- We will release a fix as soon as possible, depending on the complexity of the issue.
- We will communicate the vulnerability and any patches or workarounds to our users.

Thank you for your help in making the [Verity RAG](https://github.com/dileepadev/verity-rag) project a more secure place.
