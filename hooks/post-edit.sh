#!/usr/bin/env bash
# PostToolUse hook for Edit|Write.
# Formats, vets, and tests the edited file's project — whatever the language turns out
# to be. Detection is by the edited file's extension plus the manifest next to it.
#
# Never fails the tool call: a hook that blocks on a pre-existing lint error makes the
# agent unable to work. Findings go to stderr for the agent to read and decide about.
set -uo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | python3 -c "
import sys, json
try: print(json.load(sys.stdin).get('tool_input', {}).get('file_path', ''))
except Exception: print('')
" 2>/dev/null || echo "")

[ -z "$file_path" ] && exit 0
[ -f "$file_path" ] || exit 0

root=$(git rev-parse --show-toplevel 2>/dev/null || dirname "$file_path")
run() { echo "--- $*" >&2; ( cd "$root" && "$@" ) >&2 2>&1 || true; }

case "$file_path" in
  *.go)
    command -v gofmt >/dev/null && gofmt -w "$file_path"
    run go vet ./...
    run go test ./...
    ;;
  *.py)
    if command -v ruff >/dev/null; then
      ruff format "$file_path" >/dev/null 2>&1
      run ruff check "$file_path"
    fi
    [ -f "$root/pyproject.toml" ] && command -v pytest >/dev/null && run pytest -q
    ;;
  *.ts|*.tsx|*.js|*.jsx)
    [ -f "$root/package.json" ] || exit 0
    command -v npx >/dev/null || exit 0
    npx --no-install prettier --write "$file_path" >/dev/null 2>&1
    run npx --no-install eslint "$file_path"
    ;;
  *.rs)
    command -v cargo >/dev/null || exit 0
    cargo fmt -- "$file_path" >/dev/null 2>&1
    run cargo clippy --quiet
    run cargo test --quiet
    ;;
  *) exit 0 ;;
esac
exit 0
