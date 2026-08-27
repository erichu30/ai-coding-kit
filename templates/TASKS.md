# TODO

Design analysis for work that is planned but not built. Each entry states the problem,
lays out the options considered, and marks a recommendation.

**Before implementing anything here, read the entry first.** The analysis is the
expensive part; re-deriving it wastes more time than reading it. If you disagree with a
recommendation, say so and why — do not silently pick a different option.

**When an entry ships,** move it to *Shipped* below with the commit that did it, and
delete the analysis only if nothing in it is still true.

<!-- Mark an entry "needs revision" when later work invalidates its assumptions. An
     out-of-date plan that still reads as current is worse than no plan — someone will
     implement it. -->

| Task | Status |
|---|---|
| [{{TASK}}](#{{anchor}}) | Not implemented |

---

## Shipped

Kept short. The reasoning lives in [ERRORS.md](ERRORS.md) and
[ARCHITECTURE.md](ARCHITECTURE.md); this list exists so nobody re-solves a solved problem.

| What | Where | Commit |
|---|---|---|
| {{WHAT}} | {{FILE_OR_FUNCTION}} | `{{SHA}}` |

---

## {{TASK}}

**Status:** Not implemented

### Problem

{{WHAT_IS_WRONG_TODAY_AND_WHAT_IT_COSTS}}

### Option A — {{NAME}}

{{APPROACH}}

**Cost:** {{WHAT_IT_TAKES}}

**Why not:** {{WHY_IT_LOSES}}

### Option B — {{NAME}} (recommended)

{{APPROACH}}

**Cost:** {{WHAT_IT_TAKES}}

### Recommendation

{{WHICH_AND_WHY}}

<!-- If a measurement would settle the choice, say what to measure. A recommendation
     resting on a guess should say so. -->
