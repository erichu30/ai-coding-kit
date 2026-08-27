#!/usr/bin/env bash
# PreToolUse hook for Edit|Write|NotebookEdit.
# Refuses edits made while sitting on the repository's default branch.
#
# Exit 2 blocks the tool call and shows stderr to the agent.
set -euo pipefail

branch=$(git branch --show-current 2>/dev/null || echo "")
[ -z "$branch" ] && exit 0   # not a git repo, or detached HEAD — not our business

# Honour whatever this repo actually calls its default branch.
# `|| true` is load-bearing: without a configured origin/HEAD this pipeline fails, and
# under `set -e -o pipefail` that would kill the hook. A hook that dies exits non-zero
# without the exit code 2 that actually blocks, so the guard would silently do nothing.
default=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || true)
if [ -z "$default" ]; then
  for candidate in main master trunk; do
    if git show-ref --verify --quiet "refs/heads/$candidate"; then default=$candidate; break; fi
  done
fi
[ -z "$default" ] && exit 0

if [ "$branch" = "$default" ]; then
  echo "Blocked: direct edits on '$default' are not allowed." >&2
  echo "Create a branch first: git checkout -b <type>/<name>" >&2
  exit 2
fi
exit 0
