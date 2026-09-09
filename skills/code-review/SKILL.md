---
name: code-review
description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes: Standards (does the code follow this repo's constitution and documented coding standards?) and Spec (does the code match the feature's spec.md, plan.md, and tasks.md?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, or work-in-progress changes against a Spec Kit feature."
---

# Code Review

Two-axis review of the diff between `HEAD` and a fixed point the user
supplies:

- **Standards:** does the code conform to this repo's constitution and
  documented coding standards?
- **Spec:** does the code faithfully implement the feature's `spec.md`,
  honor its `plan.md`, and complete its `tasks.md`?

Both axes run as **parallel sub-agents** so they don't pollute each other's
context; this skill aggregates their findings afterward.

This is distinct from `/speckit-analyze`, which compares Spec Kit's own
artifacts (spec, plan, tasks) against each other and never reads the source.
This skill reads the code.

## Process

### 1. Pin the fixed point

Delegate all git operations in this step to the `git-ops` agent. Whatever the
user said is the fixed point: a commit SHA, branch name, tag, `main`,
`HEAD~5`, etc. If they didn't specify one and the repo has a default branch,
default to the merge-base with it and say so; otherwise ask.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so
the comparison is against the merge-base). Also note the commit list via
`git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse
<fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail
here, not inside two parallel sub-agents.

### 2. Identify the spec source

Walk up from the current directory for a `.specify/` directory. If found:

1. Resolve the current feature directory from `$SPECIFY_FEATURE_DIRECTORY`, or
   `.specify/feature.json`, or by matching the branch name against
   `specs/<NNN>-<short-name>/`.
2. Read that feature's `spec.md`, `plan.md`, `tasks.md`, and anything in its
   `checklists/`.

If no `.specify/` directory exists, or no feature resolves, ask the user where
the spec is: a path, an issue, a PRD. If they say there isn't one, the Spec
sub-agent is skipped and the report says so.

### 3. Identify the standards sources

In priority order:

1. `.specify/memory/constitution.md`, if present. Its principles are
   MUST-level and override everything below.
2. Anything else in the repo that documents how code should be written:
   `CLAUDE.md`, `CONTRIBUTING.md`, `CODING_STANDARDS.md`.

On top of whatever the repo documents, the Standards axis always carries the
**smell baseline** below: a fixed set of Fowler code smells (*Refactoring*,
ch. 3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented standard, or a constitution principle,
  always wins; where it endorses something the baseline would flag, suppress
  the smell.
- **Always a judgment call.** Each smell is a labeled heuristic ("possible
  Feature Envy"), never a hard violation. Constitution and documented-standard
  breaches can be hard violations; baseline smells never are. Skip anything
  tooling already enforces (linters, formatters, type checkers).

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name:** a function, variable, or type whose name doesn't
  reveal what it does or holds. → rename it; if no honest name comes, the
  design's murky.
- **Duplicated Code:** the same logic shape appears in more than one hunk or
  file in the change. → extract the shared shape, call it from both.
- **Feature Envy:** a method that reaches into another object's data more
  than its own. → move the method onto the data it envies.
- **Data Clumps:** the same few fields or params keep traveling together (a
  type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession:** a primitive or string standing in for a domain
  concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches:** the same `switch`/`if`-cascade on the same type
  recurs across the change. → replace with polymorphism, or one map both sites
  share.
- **Shotgun Surgery:** one logical change forces scattered edits across many
  files in the diff. → gather what changes together into one module.
- **Divergent Change:** one file or module is edited for several unrelated
  reasons. → split so each module changes for one reason.
- **Speculative Generality:** abstraction, parameters, or hooks added for
  needs the spec doesn't have. → delete it; inline back until a real need
  shows.
- **Message Chains:** long `a.b().c().d()` navigation the caller shouldn't
  depend on. → hide the walk behind one method on the first object.
- **Middle Man:** a class or function that mostly just delegates onward. →
  cut it, call the real target direct.
- **Refused Bequest:** a subclass or implementer that ignores or overrides
  most of what it inherits. → drop the inheritance, use composition.

### 4. Spawn both sub-agents in parallel

Send a single message with two `Agent` tool calls, both `general-purpose`.

**Standards sub-agent prompt** should include:

- The full diff command and commit list.
- The constitution text (if any), plus the other standards-source files found
  in step 3, plus the smell baseline from step 3 pasted in full; the
  sub-agent has no other access to it.
- The brief: "Report per file/hunk where relevant: (a) every place the diff
  violates the constitution or a documented standard, citing the source (file
  + rule, or constitution principle); and (b) any baseline smell you spot,
  named and quoting the hunk. Distinguish hard violations from judgment
  calls: constitution and documented-standard breaches can be hard; baseline
  smells are always judgment calls; and the repo's own rules override the
  baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** should include:

- The diff command and commit list.
- The contents of `spec.md`, `plan.md`, `tasks.md`, and any `checklists/`
  found in step 2, or a note that none exist.
- The brief: "Report: (a) requirements from spec.md or tasks the diff doesn't
  satisfy, missing or partial; (b) behavior in the diff that wasn't asked for
  (scope creep); (c) requirements that look implemented but where the
  implementation looks wrong. Quote or cite the source for each finding using
  its identifier: FR-003, SC-002, US1/AC2, a plan.md decision, a task ID, or
  a constitution principle. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final
report.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim
or lightly cleaned. Do **not** merge or rerank findings across axes; see Why
two axes below.

End with a one-line summary: total findings per axis, and the worst issue
*within each axis* (if any). Don't pick a single winner across axes; that's
the reranking the separation exists to prevent.

### 6. Next steps

Suggest, but do not run:

- `/speckit-converge` if the Spec axis found requirements the diff doesn't yet
  satisfy: it appends the gap as new tasks.
- `/speckit-analyze` if the findings suggest the artifacts themselves
  (spec/plan/tasks) are inconsistent with each other, not just with the code.

This skill never edits any file and never marks a task complete.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards
  pass, Spec fail.**
- Code that does exactly what the spec asked but breaks the project's
  constitution or conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.

---

Adapted from Matt Pocock's [`code-review`](https://github.com/mattpocock/skills)
skill.
