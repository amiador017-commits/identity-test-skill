#!/usr/bin/env bash
# Install the identity-test skill into a Hermes Agent home.
# Works from a clone (./SKILL.md + ./scripts/identity_probe.py) or via curl | bash.
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/amiador017-commits/identity-test-skill/v0.2.0"
EXPECTED_SKILL_SHA256="12985cf0595636540ecd36ad1125f5cb94f572280faace8f7a9bc1c10d3587f0"
EXPECTED_SCRIPT_SHA256="947a1dd3e0e77843360712ae068da5fcc9081dcf2c2b6652c73ab5969c753b18"
HERMES_HOME_DIR="${HERMES_HOME:-$HOME/.hermes}"
DEST_DIR="$HERMES_HOME_DIR/skills/identity-test"
TMP_SKILL="$(mktemp)"
TMP_SCRIPT="$(mktemp)"
trap 'rm -f "$TMP_SKILL" "$TMP_SCRIPT"' EXIT

mkdir -p "$DEST_DIR/scripts"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"

if [ -f "$HERE/SKILL.md" ] && [ -f "$HERE/scripts/identity_probe.py" ]; then
  cp "$HERE/SKILL.md" "$TMP_SKILL"
  cp "$HERE/scripts/identity_probe.py" "$TMP_SCRIPT"
else
  curl -fsSL "$REPO_RAW/SKILL.md" -o "$TMP_SKILL"
  curl -fsSL "$REPO_RAW/scripts/identity_probe.py" -o "$TMP_SCRIPT"
fi

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo "ERROR: no sha256sum or shasum available; cannot verify download." >&2
    exit 1
  fi
}

ACTUAL_SKILL="$(hash_file "$TMP_SKILL")"
ACTUAL_SCRIPT="$(hash_file "$TMP_SCRIPT")"

if [ "$ACTUAL_SKILL" != "$EXPECTED_SKILL_SHA256" ]; then
  echo "ERROR: SKILL.md checksum mismatch. Expected $EXPECTED_SKILL_SHA256, got $ACTUAL_SKILL" >&2
  echo "Refusing to install an unverified file. Report this at the issue tracker." >&2
  exit 1
fi
if [ "$ACTUAL_SCRIPT" != "$EXPECTED_SCRIPT_SHA256" ]; then
  echo "ERROR: identity_probe.py checksum mismatch. Expected $EXPECTED_SCRIPT_SHA256, got $ACTUAL_SCRIPT" >&2
  echo "Refusing to install an unverified file. Report this at the issue tracker." >&2
  exit 1
fi

grep -q '^name: identity-test' "$TMP_SKILL" || { echo "ERROR: invalid skill frontmatter." >&2; exit 1; }
python3 -m py_compile "$TMP_SCRIPT" || { echo "ERROR: helper script failed syntax check." >&2; exit 1; }

mv "$TMP_SKILL" "$DEST_DIR/SKILL.md"
mv "$TMP_SCRIPT" "$DEST_DIR/scripts/identity_probe.py"

echo "Installed identity-test skill v0.2.0 -> $DEST_DIR"
echo "Verified SKILL.md:  SHA-256 $ACTUAL_SKILL"
echo "Verified helper:    SHA-256 $ACTUAL_SCRIPT"
echo "Next: start a NEW Hermes chat session so the skill loads."
