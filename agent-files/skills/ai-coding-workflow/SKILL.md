---
name: ai-coding-workflow
description: Use when implementing a feature, bugfix, refactor, or other repository change that should be planned, tested, verified, committed for review, and pushed only after approval.
---

# AI Coding Workflow

Produce a reviewable change without bypassing approval, testing, or repository safety.

1. Read the applicable `AGENTS.md` instructions and inspect repository status. Preserve
   unrelated user changes.
2. Confirm scope and success criteria. For behavior or design changes, present the
   proposed approach and wait for approval before editing.
3. Create a focused branch before modifying files. Do not work directly on the default
   branch.
4. For production behavior changes, write a failing test and observe the expected
   failure before implementation. Documentation-only and configuration-only changes use
   the closest deterministic validation available.
5. Implement only the approved scope. Share concise progress updates during longer work.
6. Run fresh targeted tests, relevant regression tests, formatting or lint checks, and
   inspect the complete diff.
7. Create a focused local commit only after verification succeeds. Report skipped or
   unavailable checks explicitly.
8. Stop for human review. Do not push, open a pull request, deploy, or otherwise publish
   until the user explicitly approves that action.

If a required choice would materially change scope, stop and request direction. Urgency
does not authorize skipped verification, default-branch edits, or publication.
