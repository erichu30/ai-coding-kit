#!/usr/bin/env bash
set -euo pipefail

KIT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT

pass=0
fail=0

ok() {
  printf 'ok - %s\n' "$1"
  pass=$((pass + 1))
}

not_ok() {
  printf 'not ok - %s\n' "$1" >&2
  fail=$((fail + 1))
}

test_init_rejects_unknown_options() {
  local repo="$TEST_ROOT/unknown-option"
  git init -q "$repo"

  if "$KIT/bin/aikit-init" "$repo" --unknown >/dev/null 2>&1; then
    not_ok "aikit-init rejects unknown options"
  else
    ok "aikit-init rejects unknown options"
  fi
}

test_context_does_not_require_timeout_binary() {
  local repo="$TEST_ROOT/context" fake_bin="$TEST_ROOT/bin" output
  mkdir -p "$fake_bin"
  git init -q "$repo"
  printf '# CLAUDE.md\n' > "$repo/CLAUDE.md"
  printf '#!/usr/bin/env bash\nprintf '\''{"num_turns":1,"result":"NONE"}'\''\n' > "$fake_bin/claude"
  chmod +x "$fake_bin/claude"

  output=$(PATH="$fake_bin:/usr/bin:/bin" "$KIT/bin/aikit-context" "$repo")
  if printf '%s' "$output" | grep -q '<no response>'; then
    not_ok "aikit-context works without a timeout executable"
  else
    ok "aikit-context works without a timeout executable"
  fi
}

test_init_scaffolds_without_overwriting_existing_files() {
  local repo="$TEST_ROOT/scaffold"
  git init -q "$repo"
  printf 'keep me\n' > "$repo/AGENTS.md"

  "$KIT/bin/aikit-init" "$repo" >/dev/null

  if [ "$(cat "$repo/AGENTS.md")" != "keep me" ]; then
    not_ok "aikit-init preserves existing files"
    return
  fi
  if [ ! -x "$repo/.claude/hooks/post-edit.sh" ] ||
     ! grep -qxF 'CLAUDE.local.md' "$repo/.gitignore" ||
     ! grep -qxF '.claude/settings.local.json' "$repo/.gitignore"; then
    not_ok "aikit-init creates an executable, safely ignored scaffold"
    return
  fi
  ok "aikit-init preserves existing files"
  ok "aikit-init creates an executable, safely ignored scaffold"
}

test_fresh_scaffold_passes_aikit_check() {
  local repo="$TEST_ROOT/check"
  git init -q "$repo"
  "$KIT/bin/aikit-init" "$repo" >/dev/null
  git -C "$repo" add AGENTS.md CLAUDE.md ARCHITECTURE.md ERRORS.md TASKS.md .claude/settings.json

  if "$KIT/bin/aikit-check" "$repo" >/dev/null; then
    ok "a fresh scaffold passes aikit-check"
  else
    not_ok "a fresh scaffold passes aikit-check"
  fi
}

test_init_rejects_unknown_options
test_context_does_not_require_timeout_binary
test_init_scaffolds_without_overwriting_existing_files
test_fresh_scaffold_passes_aikit_check

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
