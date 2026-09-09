---
name: improve-codebase-architecture
description: Scan a codebase for deepening opportunities, persist them as Markdown under a top-level architecture-reviews/ directory alongside a rendered HTML report, then grill through one candidate per session. Use when the user wants an architectural review, wants to find shallow modules or refactoring opportunities, or wants to resume a review already on disk.
disable-model-invocation: true
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities**:
refactors that turn shallow modules into deep ones. The aim is testability
and AI-navigability.

## Vocabulary

Use these terms exactly in every suggestion; don't drift into "component,"
"service," "API," or "boundary." Consistent language is the whole point.

**Module:** anything with an interface and an implementation. Deliberately
scale-agnostic: a function, class, package, or tier-spanning slice.

**Interface:** everything a caller must know to use the module correctly: the
type signature, but also invariants, ordering constraints, error modes,
required configuration, and performance characteristics.

**Implementation:** what's inside a module, its body of code. Distinct from
**Adapter**: a thing can be a small adapter with a large implementation
(a Postgres repo) or a large adapter with a small implementation (an in-memory
fake).

**Depth:** leverage at the interface: the amount of behavior a caller (or
test) can exercise per unit of interface they have to learn. A module is
**deep** when a large amount of behavior sits behind a small interface,
**shallow** when the interface is nearly as complex as the implementation.

**Seam** (Michael Feathers): a place where you can alter behavior without
editing in that place; the *location* at which a module's interface lives.
Where to put the seam is its own design decision, distinct from what goes
behind it.

**Adapter:** a concrete thing that satisfies an interface at a seam.
Describes *role* (what slot it fills), not substance (what's inside).

**Leverage:** what callers get from depth: more capability per unit of
interface they learn.

**Locality:** what maintainers get from depth: change, bugs, knowledge, and
verification concentrate in one place rather than spreading across callers.

### Principles

- **The deletion test.** Imagine deleting the module. If complexity vanishes,
  it was a pass-through. If complexity reappears across N callers, it was
  earning its keep.
- **The interface is the test surface.** Callers and tests cross the same
  seam. If you want to test *past* the interface, the module is probably the
  wrong shape.
- **One adapter means a hypothetical seam. Two adapters means a real one.**
  Don't introduce a seam unless something actually varies across it.
- **Depth is a property of the interface, not the implementation.** A deep
  module can be internally composed of small, mockable, swappable parts;
  they just aren't part of the interface.

## Where the review lives

A review is a directory at the top level of the repo, one per run:

```
architecture-reviews/<YYYY-MM-DD>-<slug>/
  review.md              # the index: scope, commit, candidate list, top pick
  candidates/
    <slug>.md            # one file per candidate; the durable record
  review.html            # the rendering; generated, gitignored
```

`architecture-reviews/` is a sibling of `specs/` and `wayfinder/`. It is
deliberately not inside `.specify/`, which Spec Kit owns and rewrites on
upgrade, and not inside `specs/`, whose entries Spec Kit's scripts expect to
be `NNN-name` feature directories. `<slug>` names the scope that was scanned
(`2026-04-11-order-intake`), and one directory per run means a rerun never
clobbers a review the user is still working through.

**The Markdown is the source of truth.** It is version-controlled, cheap to
re-read, and greppable; the HTML is a rendering of it and is regenerated, not
edited. Splitting candidates one-per-file is what lets a later session load
only the candidate it is grilling instead of the whole review.

`review.md` is an **index, not a store**: it gists each candidate and links to
its file, never restating the detail that lives there.

```markdown
---
date: <YYYY-MM-DD>
commit: <HEAD sha at scan time>
scope: <what was scanned, and why those paths>
feature: specs/<NNN>-<name>/   # omit if no feature directory resolved
---

# Architecture review: <scope>

## Candidates

- [<title>](candidates/<slug>.md) - `Strong` - <one-line gist>

## Top recommendation

<which candidate to tackle first, one sentence why, linked by name>
```

Each candidate file carries everything both the renderer and a later grilling
session need:

```markdown
---
title: <names the deepening, e.g. "Collapse the Order intake pipeline">
strength: Strong        # or: Worth exploring, Speculative
status: open            # or: grilled, specified, rejected
files: [<path>, <path>]
---

## Problem

<one sentence: what hurts>

## Solution

<one sentence: what changes>

## Wins

<bullets, six words or fewer, in glossary terms>

## Diagram

<which pattern from HTML-REPORT.md fits, and what the before and after shapes
are, in words. This is what the renderer draws from.>

## Constitution

<only when the candidate contradicts a principle: name the principle and why
it is worth reopening anyway>
```

## Process

### 0. Resume or scan

Walk up from the current directory to find the repo root; that is where
`architecture-reviews/` lives. If there is no repo root, use the current
directory and tell the user that is where the review went.

If `architecture-reviews/` already exists, read the frontmatter of the most
recent review's candidates. If any are still `open`, offer to resume that
review rather than rescanning: read `review.md`, list the open candidates by
name, and go to step 3. Refer to candidates by their titles, never by bare
slugs or paths.

Compare `review.md`'s `commit` against current HEAD. If the tree has moved on
enough that the findings may no longer hold, say so and let the user choose
between resuming anyway and a fresh scan.

Otherwise continue to step 1.

### 1. Explore

**Scope before you scan (YAGNI).** Deepening a module pays off by making
future changes to it easier, so put extra weight on the parts of the codebase
that have recently changed. Decide *where* to look before you look:

- If the user named a direction (a module, a subsystem, a pain point), take
  it, and skip the inference below.
- Otherwise, walk back a good stretch of the commit history (`git log
  --oneline`) to find the codebase's hot spots: the files and areas that keep
  coming up. Let those paths pull your attention first. If the changes
  are scattered with no clear hot spot, widen the net.

Record the current HEAD SHA (`git rev-parse HEAD`) while you are here; step 2
stamps it into `review.md` so a later session can tell how far the tree has
moved.

For domain vocabulary, read the current feature's `data-model.md` and the
`Key Entities` section of its `spec.md` if a `.specify/` tree exists. Use the
project's own terms for the domain: if the spec calls something an "Order,"
talk about "the Order intake module," not "the FooBarHandler" and not "the
Order service." Also read `.specify/memory/constitution.md` if present.

Then use the Agent tool with `subagent_type=Explore` to walk the codebase.
Don't follow rigid heuristics; explore organically and note where you
experience friction:

- Where does understanding one concept require bouncing between many small
  modules?
- Where are modules **shallow**: interface nearly as complex as the
  implementation?
- Where have pure functions been extracted just for testability, but the real
  bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their
  current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting
it concentrate complexity, or just move it? A "yes, concentrates" is the
signal you want.

### 2. Write the review, then have it rendered

Write the Markdown yourself; delegate the HTML. In order:

**Create the directory.** Make
`architecture-reviews/<YYYY-MM-DD>-<slug>/candidates/` at the repo root,
using the layout above.

**Write one file per candidate**, then `review.md` as the index. Fill every
section of the candidate template: the `## Diagram` section is prose, not
markup, describing which pattern from [HTML-REPORT.md](HTML-REPORT.md) fits
and what the before and after shapes are. The renderer draws from it, so a
vague `## Diagram` section produces a vague diagram.

**Offer to ignore the HTML.** Check whether the rendering is already ignored
(`git check-ignore -q architecture-reviews/<dir>/review.html`). If it isn't,
tell the user the line to add, `architecture-reviews/**/review.html`, and
offer to add it. Never edit `.gitignore` without being asked.

**Delegate the rendering.** Use the Agent tool to write `review.html`. Give
the subagent the absolute path to the review directory and the absolute path
to `HTML-REPORT.md` in this skill's directory, and have it read the candidate
files and write the HTML. Ask it to return only the path it wrote. Do not
author the markup in this session: keeping several thousand tokens of Tailwind
and Mermaid out of the main context is the point, and it is what leaves room
for the grilling loop.

**Open it and report both paths.** `open <path>` on macOS, `xdg-open <path>`
on Linux, `start <path>` on Windows. Tell the user where `review.md` is first
and `review.html` second; the Markdown is what survives.

**Constitution conflicts**: if a candidate contradicts a principle in
`.specify/memory/constitution.md`, only surface it when the friction is real
enough to warrant revisiting the principle. Put it in that candidate's
`## Constitution` section, naming the principle (*"contradicts Constitution
Principle III, but worth reopening because..."*); the renderer turns it into a
callout. Don't list every theoretical refactor the constitution forbids.

Do NOT propose interfaces yet. Once the files are written, ask the user:
"Which of these would you like to explore?"

### 3. Grilling loop, one candidate per session

Once the user picks a candidate, read that candidate's file and call the Skill
tool with "sks:grilling" to walk the decision tree with them: constraints,
dependencies, the shape of the deepened module, what sits behind the seam,
what tests survive.

**One candidate per session.** Grill the candidate the user picked, hand it
off in step 4, and stop. Do not move on to the next candidate, and do not run
the Spec Kit pipeline across several of them in one session; that is what
fills the context window and loses the review. The user re-invokes this skill
for the next one, and step 0 picks the review back up, reading `review.md`
plus the one candidate file that session needs.

### 4. Exit

This skill never edits source code and never touches the `.specify/` or
`specs/` tree. The only thing it writes is its own `architecture-reviews/`
directory, plus one `.gitignore` line when the user asks for it.

Append what the grilling settled to the candidate's file and update its
`status`. Then offer next steps rather than acting on them:

- Feed the chosen refactor into `/speckit-specify` as a new feature, using the
  grilling session's decisions as the feature description. When a feature
  directory results, set the candidate's `status` to `specified` and record
  the `specs/<NNN>-<name>/` path in its file, so the review stays traceable
  to the features it spawned. A candidate the user rules out is `rejected`,
  with the reason; one talked through but not specified is `grilled`.
- If the conversation surfaced a principle worth recording, for instance
  because a candidate was rejected specifically for contradicting one, or
  because a gap in the constitution caused real ambiguity, suggest
  `/speckit-constitution` to record it, rather than doing it yourself.

---

Adapted from Matt Pocock's
[`improve-codebase-architecture`](https://github.com/mattpocock/skills) and
[`codebase-design`](https://github.com/mattpocock/skills) skills.
