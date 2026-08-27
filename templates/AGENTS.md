# AGENTS.md

Working agreement for AI coding agents in this repository. Claude Code reads this via
`CLAUDE.md`; Codex and other tools read it directly.

Personal setup — your machine's paths, your remotes, tooling only you have installed —
belongs in `CLAUDE.local.md`, which is gitignored. Do not add it here.

<!-- Keep this file to what an agent needs BEFORE it touches code. It is loaded on every
     turn. Rationale, post-mortems, and feature analysis go in the reference docs at the
     bottom, behind a stated trigger. -->

## Project

<!-- Two or three sentences. What it is, what it does, what it talks to.
     Do not restate the directory layout — an agent can list files faster than it can
     read about them. -->

{{ONE_PARAGRAPH_DESCRIPTION}}

Runtime dependencies:

- {{DEPENDENCY}} — {{WHY_IT_IS_NEEDED}}

## Commands

<!-- The ones that are not guessable from the manifest. Build, test, run, and the
     narrowing incantations for a single test. -->

```bash
{{BUILD_COMMAND}}
{{TEST_COMMAND}}
{{SINGLE_TEST_COMMAND}}
{{RUN_COMMAND}}
```

## Behaviour Contracts

<!-- The highest-value section. Invariants whose violation does NOT fail a test.
     Anything a test would catch does not belong here — the test is the documentation.

     Format: state the invariant in bold, then what breaking it costs. The cost is what
     makes it stick, and what tells a future reader whether the rule still applies. -->

Invariants this codebase depends on. Breaking one does not fail a test — it produces
software that quietly does the wrong thing.

| Contract | Consequence of breaking it |
|---|---|
| **{{INVARIANT}}** | {{WHAT_GOES_WRONG_AND_WHEN_YOU_NOTICE}} |

<!-- Real examples from the project this template came from:

| **Every transfer path goes through `resolveTarget` before it writes** | Duplicate-filename data loss returns. `os.Rename`, `os.Create`, and `rclone moveto` all replace the destination silently |
| **No `logrus.Fatal` after `setupLogging`** | logrus is redirected to the log file there; a fatal past it exits 1 with a blank terminal |
| **`-dry-run` writes nothing** — files and directories both | It is the command users reach for when unsure |
-->

## Code Conventions

<!-- Only what an agent would get wrong by defaulting to the language's common style.
     Skip anything the linter or formatter already enforces. -->

{{CONVENTIONS}}

## Adding a {{EXTENSION_POINT}}

<!-- The checklist for the change type this project sees most often — a new flag, a new
     endpoint, a new migration. Include the steps that are easy to forget, especially
     the ones that live outside the code. -->

1. {{STEP}}

## Verifying a Change

```bash
{{FORMAT_CHECK}}
{{LINT_COMMAND}}
{{TEST_COMMAND}}
```

<!-- If CI runs in an environment that differs from a developer machine — no optional
     binaries, a different OS — say how to reproduce it. That gap is where bugs slip
     through green local runs. -->

## Reference Docs

Read on demand, not by default.

| File | Read when |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Changing structure, or asking why something is built the way it is |
| [ERRORS.md](ERRORS.md) | Editing {{TRAP_PRONE_FILES}} |
| [TASKS.md](TASKS.md) | Starting a new feature — the analysis may already exist |

<!-- Add the project's README or other user-facing docs here when they exist. Every
     local link in this table must resolve so `aikit-check` can detect stale routes. -->
