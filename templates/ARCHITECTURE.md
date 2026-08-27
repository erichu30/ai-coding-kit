# Architecture

<!-- Answers "why is it built this way". Read when changing structure, not routinely.

     Do not put a directory listing here unless the layout is genuinely surprising — an
     agent lists files faster than it reads about them, and a stale listing is worse
     than none. Annotate roles only where the filename does not already say it. -->

## Data Flow

<!-- One diagram of the main path, including the decision points and where things can
     stop early. Ordering that carries meaning — validation order, cleanup order —
     belongs here, because it is invisible in any single file. -->

```
{{ENTRY_POINT}}
  └── {{STEP}}
```

## Key Design Decisions

<!-- One section per decision that a reasonable person would make differently.
     State the decision, then why the obvious alternative was not taken. A decision with
     no rejected alternative is just a description — leave it out. -->

### {{DECISION}}

{{WHAT_IT_DOES}}

**Why not {{OBVIOUS_ALTERNATIVE}}:** {{REASON}}
