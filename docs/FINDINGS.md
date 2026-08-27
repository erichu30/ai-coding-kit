# What agents actually load

Measured against Claude Code 2.1.247, 2026-08-27. These are implementation details, not
promises — re-measure with `aikit-context --isolated` after a CLI upgrade.

## The results

Each row: a scratch directory containing only the listed files, one of them holding a
canary token, then `claude -p "What is the token?"` **with every read tool disabled** so
the agent can only answer from what was already in its context.

| Directory contains | Canary reached the model? | Turns |
|---|---|---|
| `AGENTS.md` only | **No** | 2 |
| `CLAUDE.md` only | Yes | 1 |
| `CLAUDE.md` + `AGENTS.md`, no import | **No** (the `AGENTS.md` canary) | 2 |
| `CLAUDE.md` containing `@AGENTS.md` | Yes | 1 |
| `CLAUDE.local.md` only | Yes | 1 |

**Claude Code does not load `AGENTS.md`. Ever.** Not when it is the only file, not when
it sits beside `CLAUDE.md`. The only route is an explicit `@AGENTS.md` import.

That makes this file the load-bearing part of the whole layout:

```markdown
# CLAUDE.md

@AGENTS.md
```

Delete that one line and your entire working agreement drops out of context while still
sitting in the repo looking authoritative. Nothing errors. Nothing warns. The agent
simply stops knowing the rules.

Other tools — Codex, Cursor — do read `AGENTS.md` directly, which is why the content
lives there rather than in `CLAUDE.md`. The import is the bridge for the one tool that
needs it.

## Summary

| File | Auto-loaded by Claude Code |
|---|---|
| `~/.claude/CLAUDE.md` | Yes (global, every project) |
| `<repo>/CLAUDE.md` | Yes |
| `<repo>/CLAUDE.local.md` | Yes — gitignore it; this is where personal setup goes |
| `@path` imports inside either | Yes |
| `<repo>/AGENTS.md` | **No** — reachable only via `@AGENTS.md` |
| `<repo>/skills/` | **No** — only `.claude/skills/` is discovered |
| `.claude/settings.json`, `.claude/settings.local.json` | As config, not context |

That `skills/` row costs people hundreds of lines of documentation nothing ever reads.
A `skills/` directory at the repo root is inert markdown.

## How to measure this yourself

Two traps make the naive version of this test lie in both directions.

**False positive — the agent reads the file.** Ask "what is the token?" with tools
available and it will open the file and answer correctly whether or not the content was
ever in context. Every read path has to be closed:

```bash
claude -p "What is the token? Reply with only the token, or NONE." \
  --disallowedTools Read Glob Grep Bash Task WebFetch WebSearch \
  --output-format json < /dev/null
```

**False negative — the prompt talks the model out of it.** Phrasing the question as
"Without reading any files: …" produces `UNKNOWN` even when the content *is* loaded —
the model reads its own context as file-derived and declines. Restrict the tools instead
of asking the model to pretend.

`num_turns` in the JSON output is the cleanest signal: **1 means it answered straight
from context**; 2 or more means it went looking and came back empty.

`< /dev/null` matters too, or the CLI waits several seconds for stdin that never comes.

`aikit-context` does all of this for you.

## What this implies for structure

**The always-loaded set is a per-turn tax.** `CLAUDE.md`, its imports, and
`CLAUDE.local.md` are paid for on every single request whether relevant or not. That is
the budget `AGENTS.md` lives within, and why rationale, post-mortems, and feature
analysis belong in separate files opened deliberately.

**Anything outside that set needs a route.** An agent will not stumble onto `ERRORS.md`.
It reads it because `AGENTS.md` carries a table saying *when* to. A reference doc with no
inbound route is as inert as the `skills/` directory.
