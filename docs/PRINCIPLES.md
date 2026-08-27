# Principles

Why the layout is shaped this way. Each of these came from a specific failure, not from
taste.

## One fact, one place

A rule written in five files is a rule maintained in zero. Nobody updates all five.

In the project this kit was extracted from, the platform build-tag convention appeared in
five documents, and `sync.Map`-for-the-directory-cache in four. The architecture document
attributed two functions to the wrong file for three months and nobody noticed, because
the correct version existed in three other places and everyone read one of those.

When you catch yourself writing something you have already written, replace the second
copy with a link. If the link feels too weak, the two places should be one place.

## Contracts, not descriptions

The valuable content in an agent-facing document is the part that fails silently.

An agent can read `process.go` and see what `processFile` does. It cannot see that every
transfer path must go through `resolveTarget` first, because the consequence of skipping
it is not a compile error or a failing test — it is files silently overwriting each other
in production six months later.

So write down the things that break quietly:

| Weak | Strong |
|---|---|
| "`resolveTarget` picks the destination path" | "**Every transfer path goes through `resolveTarget` before it writes.** Skipping it reintroduces silent overwrite data loss." |
| "Logging is set up in `run()`" | "**Nothing calls `logrus.Fatal` after `setupLogging`.** logrus is redirected to a file there; a fatal past it exits 1 with a blank terminal." |

The pattern: state the invariant, then state what breaking it costs. The cost is what
makes an agent take it seriously, and what tells a human whether the rule still applies
after a refactor.

## Nothing personal in a shared file

Your machine's paths, your NAS address, the tool only you have installed — none of it
survives contact with a second developer, and all of it makes the shared document
slightly wrong for everyone else.

The failure is not cosmetic. A shared file telling agents to run `graphify query` against
a `graphify-out/` directory that is not in version control sends every teammate's agent
after a tool it does not have and a directory that does not exist.

`CLAUDE.local.md` and `.claude/settings.local.json` are both auto-loaded and both
gitignored. Use them. The split costs nothing at runtime.

## Don't document what the code already says

A directory listing, a table of every function, a restatement of the public API — an
agent derives all of this faster than it reads about it, and every line costs context on
every turn.

Write down what is *not* derivable:

- why a design was chosen over the alternative that looks better on paper
- which trap has already been hit and what it cost
- what was already analysed, so it does not get re-analysed
- the invariants that fail silently

That is the whole of it. If a paragraph would still be true after a total rewrite of the
code, it is probably not worth its space; if it would be *forgotten* after a total
rewrite, it certainly is.

## Verify docs mechanically

Prose is not self-checking. Every doc claim that can be tested by a script should be:

- do referenced files and functions exist?
- do documented flags match the parser?
- does the pasted `--help` output match the real one?
- do the commands the doc tells you to run actually pass?

`aikit-check` does this. It is the reason the wrong-file attribution above was found at
all — reading had not caught it in three months.

Pasted CLI output goes stale the fastest. Regenerate it from the binary rather than
editing it by hand.

## Automate the rules that are mechanical

A convention a human has to remember is a convention that erodes. Formatting, vetting,
testing after an edit, and not committing straight to the default branch are all
mechanical, so they belong in hooks rather than in prose.

That leaves the written rules for the things judgment actually applies to.

## Keep the always-loaded set small

See [FINDINGS.md](FINDINGS.md) for what "always-loaded" means concretely. The short
version: `AGENTS.md` is a per-turn tax, so it holds what is needed *before* touching code
— contracts, conventions, commands, and a routing table. Everything else waits behind a
link with a stated trigger.
