# Security policy

## Supported versions

| Version | Supported |
|---|---|
| 0.2.x | Yes |
| < 0.2 | No |

## Reporting a vulnerability

Open a private security advisory on this repository, or email `amiador017@gmail.com` with the affected version, reproduction steps, and potential impact. Please do not open a public issue for an unpatched vulnerability. No response time is guaranteed.

## Scope

This repo contains one Markdown skill, one Python helper script, one Bash installer, an SVG logo, and documentation. It has no compiled binaries, no pip dependencies, no build step, and no telemetry. Python 3 with the standard library is a runtime prerequisite supplied by the user.

At use time, the helper sends chat-completion requests to the base URLs the user supplies, authenticated with the user's own environment variable. Keys are never printed or written into result files. Result files are plain JSONL in the user's current directory. The installer verifies pinned SHA-256 digests before writing into the skills directory. The `--self-test` flag runs 12 offline logic checks with no key and no network.

Out of scope: vulnerabilities in the endpoints being tested or in Hermes Agent itself. Report those to their respective maintainers.
