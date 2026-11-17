<div align="center">

<img src="docs/assets/logo.svg" alt="identity-test skill" width="640">

**Is that model really what the label says? And which model is it actually?**

<a href="https://github.com/amiador017-commits/identity-test-skill/releases"><img src="https://img.shields.io/github/v/release/amiador017-commits/identity-test-skill?style=flat-square&color=1f6feb" alt="Release"></a>
<img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License: MIT">
<img src="https://img.shields.io/badge/platform-linux%20%7C%20macOS%20%7C%20Windows-lightgrey?style=flat-square" alt="Platforms">
<img src="https://img.shields.io/badge/agent-Hermes-orange?style=flat-square" alt="Hermes Agent">
<img src="https://img.shields.io/badge/SHA--256-verified%20install-brightgreen?style=flat-square" alt="Checksum-verified installer">

**[Install](#install) · [Prerequisites](#prerequisites) · [Prompt](#prompt) · [How it works](#how-it-works) · [Usage](#usage) · [Security](#security-and-privacy) · [FAQ](#faq)**

</div>

---

> **Availability:** Currently available for **Hermes Agent only**. Other agents are planned for a later release.

## The problem

A provider sells `GPT-6-Astra`, `Fable-5.2`, or a similar new flagship at a suspicious price. The label is a string in a JSON response. Nothing in the API proves what is actually answering. A relabeled 8B model can be sold as a frontier one, and several "different" model IDs can be the same backend.

## The fix

This skill runs black-box probes through an OpenAI-compatible endpoint and reports **evidence with confidence**, not a guess. It answers two questions separately: is the label honest, and which known model is it most likely to be.

| | Without this skill | With this skill |
|---|---|---|
| Label check | Trust the model ID | Family traps, self-ID, catalog miss, duplicate groups |
| Actual identity | "Seems like GPT" | Fingerprint ranked against labelled references |
| Confidence | None | Explicit high / medium / low / none with matching evidence |
| Proof limits | Claimed as fact | Stated plainly: black-box is evidence, not proof |

## Prompt

Copy this whole block into any agent chat (Hermes, Claude Code, Codex, or another agent). It installs and verifies the skill from this repository without you running commands yourself.

````text
Install the identity-test skill from https://github.com/amiador017-commits/identity-test-skill into this machine's Hermes Agent skills directory.

Do exactly this:
1. Fetch and read https://raw.githubusercontent.com/amiador017-commits/identity-test-skill/v0.2.0/install.sh. Confirm it only writes SKILL.md and scripts/identity_probe.py under the identity-test skill directory, verifies a SHA-256 digest for each, and aborts on mismatch. If it does anything else, stop and report it.
2. Check the runtime prerequisite with: python3 --version. Python 3 with the standard library is required. If it is missing, tell me and stop. Do not install anything for me.
3. Run: curl -fsSL https://raw.githubusercontent.com/amiador017-commits/identity-test-skill/v0.2.0/install.sh | bash
4. Verify with: hermes skills list | grep identity-test
5. Run the offline check: python3 ~/.hermes/skills/identity-test/scripts/identity_probe.py --self-test
6. Report the installed path, both checksums printed, the self-test result, and tell me to start a NEW Hermes chat session so the skill loads.

Do not modify any other file. This skill is supported by Hermes Agent only for now. If Hermes is not installed here, stop and say so instead of installing anything.
````

## How it works

1. **Positive control.** A known-good model is called first so a bad key is not mistaken for a fake model.
2. **Authenticity battery.** Eleven deterministic probes at `temperature: 0`: liveness, known answer, reverse and hex traps, origin, native-language self-ID, SDK default, architecture, cutoff, system-prompt leak, and prompt-inflation accounting.
3. **Duplicate grouping.** One fixed prompt goes to every model ID; exact replies are hashed. Identical hashes mean one backend.
4. **Tokenizer signature.** Four fixed strings are sent; the *deltas* of reported `prompt_tokens` are compared. Deltas cancel hidden system-prompt overhead, which makes this hard for a relabeler to fake.
5. **Identification.** The target fingerprint is scored against trusted reference endpoints: deterministic response +3, tokenizer +3, self-ID +2, known answer +1, cutoff +1. A `high` verdict needs score >=7 and a margin >=3 over the runner-up.

The skill never claims proof. Only a signed attestation or self-hosted weights can provide that.

## Install

```bash
bash install.sh
```

Or without cloning:

```bash
curl -fsSL https://raw.githubusercontent.com/amiador017-commits/identity-test-skill/v0.2.0/install.sh | bash
```

The installer verifies SHA-256 for both the skill file and the helper script before writing anything. A mismatch aborts. It writes exactly two files: SKILL.md and the helper script. See [INSTALL.md](INSTALL.md) for the agent-facing steps.

**Start a new Hermes chat session after installing.** An open session keeps the old skill list.

## Prerequisites

- Python 3 with the standard library. No pip packages.
- An OpenAI-compatible endpoint (`/v1/chat/completions`, optionally `/v1/models`).
- An API key exported under an environment variable. The skill never asks you to paste a key into chat.
- For identification only: two or more labelled reference endpoints you already trust. Without them, authenticity checks still work and identity is reported as `undetermined`.

This repository does not install Python or contact any provider on its own. Network calls happen only when the helper is invoked with an endpoint you supply.

## Usage

Ask your agent:

> /identity-test on `suspicious-model-id` at `https://api.example.com/v1`, key env `EXAMPLE_KEY`, advertised as Qwen. Also tell me which real model it is; here are two official references.

The agent loads the skill, reads the helper script, and runs:

```bash
python3 <script_path> \
  --base-url https://api.example.com/v1 \
  --key-env EXAMPLE_KEY \
  --models suspicious-model-id \
  --family Qwen \
  --check-catalog \
  --out identity_results.jsonl
```

For identification:

```bash
python3 <script_path> \
  --base-url https://api.example.com/v1 \
  --key-env EXAMPLE_KEY \
  --model suspicious-model-id \
  --family Qwen \
  --identify \
  --candidates candidates.json \
  --out identify_results.jsonl
```

`candidates.json` holds base URLs, model IDs, and **environment variable names**, never literal keys.

To verify the tool before spending any credits, run `python3 <script_path> --self-test`. It checks the scoring logic offline: no key, no network, no API calls.

## Security and privacy

| Item | Behaviour |
|---|---|
| Secrets | API keys are read from env vars by name; never printed, logged, or written to result files |
| Files read | `SKILL.md`, the helper script, your `candidates.json`, and env vars you name |
| Network calls | Only to the base URLs you pass, using your own key, from the helper script |
| Files written | JSONL result files in your current directory, plus two skill files by the installer |
| Dependencies | Python 3 standard library only; no pip install, no build step |
| binaries / telemetry | No compiled binaries and no telemetry in this repository |
| Verify the download | `sha256sum SKILL.md` and compare with the digest in `install.sh`; the installer checks this automatically |
| Offline verification | `python3 <script_path> --self-test` runs 12 logic checks with no key, no network, and no credits |

Read [SECURITY.md](SECURITY.md) for the reporting channel.

## FAQ

**Does this prove a model is fake?**
No. It produces black-box evidence with a confidence level. A proxy can imitate answers and tokenizers. Signed attestation or your own weights are the only proof.

**Can it identify an entirely new, unreleased model?**
No. It ranks against references you provide. If nothing matches, it says `unknown backend, no reference matched`.

**Why compare `prompt_tokens` deltas instead of raw counts?**
Gateways inject different hidden system prompts. Deltas between fixed-length inputs cancel that constant overhead and leave tokenizer behaviour.

**Do reverse/hex traps prove identity?**
No. They only show that no output string-replacer is active. The skill treats them as weak signals.

**Will this burn my credits?**
Probe mode costs 12 calls per model (11 probes + 1 duplicate fingerprint). In identify mode, each endpoint (target and every reference) costs 8 calls: 4 response probes + 4 tokenizer samples. Start with one model and a small budget. A 402 or 429 response stops the run; it is not identity evidence.

**Can I use it outside Hermes Agent?**
The helper script is plain Python and can be called directly. The SKILL.md instructions are written for Hermes Agent and are not a generic prompt.

## Contributions

Contributions are **closed for now**. Bug reports are welcome through the issue tracker; please do not open pull requests yet.

## License

MIT. See [LICENSE](LICENSE). The skill text is MIT licensed; the endpoints it tests have their own terms.
