# ERRORS — Pitfalls & Gotchas

<!-- Traps already hit, so they are not hit twice. The single highest-value document
     here, because none of it is derivable from the code: the code shows what is done,
     not what was tried and hurt.

     Add an entry when a bug takes more than an hour, when the fix is non-obvious enough
     that someone would undo it, or when a review catches something subtle.

     Each entry: what looks reasonable, why it is wrong, what to do instead. -->

## 1. {{TITLE — state the trap, not the topic}}

{{WHAT_LOOKS_REASONABLE}}

{{WHY_IT_IS_WRONG_AND_HOW_IT_SHOWED_UP}}

{{WHAT_TO_DO_INSTEAD}}

<!-- Real example:

## Cancelled work must not be counted as failure

The worker loop reads `ctx.Err()` at the top of every iteration. Without it, the files
already sitting in the jobs channel when Ctrl-C arrives are still attempted: each fails
instantly against the cancelled context, and each failure then pays for a remote cleanup
on a fresh 30-second context. A 300-file run took 14 extra seconds to exit and blamed
108 files that had never been touched.
-->
