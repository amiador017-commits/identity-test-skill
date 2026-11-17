# Agent-facing install instructions

If an agent is given this repository and asked to "install this skill", do exactly this:

1. Check the runtime prerequisite:

   ```bash
   python3 --version
   ```

   Python 3 with the standard library is required at use time. If it is missing, tell the user and stop. This repo does not install Python.

2. Run the pinned, checksum-verified installer:

   ```bash
   bash install.sh
   ```

   Or directly from GitHub without cloning:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/amiador017-commits/identity-test-skill/v0.2.0/install.sh | bash
   ```

   The installer downloads `SKILL.md` and `scripts/identity_probe.py` from the `v0.2.0` tag and verifies the SHA-256 of each before writing. Either mismatch aborts. It writes exactly two persistent files.

3. Verify installation:

   ```bash
   hermes skills list | grep identity-test
   ```

   Expected: a row containing `identity-test`.

4. Confirm the helper works offline before any API call:

   ```bash
   python3 ~/.hermes/skills/identity-test/scripts/identity_probe.py --self-test
   ```

   Expected: `SELF-TEST PASS: 12 checks, no network and no API key used.`

5. Tell the user to start a **new** Hermes chat session. Skills loaded in an existing session are cached.

## Prerequisites at use time

An OpenAI-compatible endpoint and an API key in an environment variable are required when the skill runs. This repo installs neither. See the README's Prerequisites section.

## Paths and scope

- Target: `$HERMES_HOME/skills/identity-test/`, or `~/.hermes/skills/identity-test/` when `HERMES_HOME` is unset.
- The skill is Markdown instructions plus one Python script. Do not execute the code blocks in `SKILL.md`; they are documentation for the agent that loads it.
- Do not run any file from this repo other than `install.sh`.
- The helper makes network calls only when invoked with an endpoint supplied by the user. `--self-test` makes none.

## Manual alternative

Copy `SKILL.md` to `~/.hermes/skills/identity-test/SKILL.md` and `identity_probe.py` to `~/.hermes/skills/identity-test/scripts/identity_probe.py`, then start a new session. Expected digests are in `install.sh`.

## Availability

Hermes Agent only for now. Other agents are planned for a later release.
