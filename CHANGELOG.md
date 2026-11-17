# Changelog

All notable changes are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.2.0] - 2026-11-17

### Added

- `--identify` mode: ranks a target against labelled reference endpoints using a weighted fingerprint score and explicit confidence.
- Tokenizer signature probe using `prompt_tokens` deltas, robust to hidden gateway system prompts.
- `--check-catalog` flag: GET `/v1/models` and flag model IDs absent from the advertised list.
- Self-ID, cutoff, and deterministic response fields in the identify fingerprint.
- Offline `--self-test` mode: 12 checks of scoring and parsing logic with no key, network, or credits.
- Tagged, SHA-256-verified installer, security policy, agent-facing install instructions, and repository documentation.

### Changed

- Verdicts are split into label authenticity, actual identity, backend quality, and certainty.
- The description now states both capabilities; the skill is versioned 0.2.0.
- Manual fallback prompts are preserved inside the authenticity procedure.

## [0.1.0]

- Initial private authenticity-only version.
