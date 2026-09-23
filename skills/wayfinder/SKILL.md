---
name: wayfinder
description: Plan an initiative too big for one agent session or one Spec Kit feature as a version-controlled map of decisions in the repo's wayfinder/ directory, resolved one per session until every remaining piece is feature-sized and ready for /grill-me and /speckit-specify, handing off in what/why terms with settled technology choices routed to /speckit-plan. Use when the user brings a loose, oversized idea to chart, or points at an existing map to work through.
disable-model-invocation: true
argument-hint: "A loose idea to chart, or an existing map to work through"
---

# Wayfinder

A loose idea has arrived, too big for one agent session or one Spec Kit
feature, and wrapped in fog: the way from here to the **destination** is
not visible yet. Wayfinding is about finding that way, not charging at the
destination. This skill charts the way as a **shared map**, a
version-controlled directory in the repo, then works its **decisions**
(questions whose resolution is a choice, not slices of a build to execute)
one at a time until the route is clear.

The destination varies per effort, and naming it is the first act of
charting; it shapes every decision. In a Spec Kit project the common
destination is a carved-up initiative: the way is clear when every
remaining piece of work is the size of one feature, ready to hand to
`/grill-me` and `/speckit-specify`. It might instead be a single decision
to lock before planning starts, or a change made in place, like a
data-structure migration. The map is domain-agnostic; engineering work,
course content, whatever fits the shape.

## Plan, don't do

Wayfinder is **planning** by default: each decision resolves a choice, and
the map is done when the way is clear, nothing left to decide before
someone goes and does the thing. The pull to just do the work is usually
the signal you have reached the edge of the map and it is time to hand
off. An effort can override this in its **Notes**, carrying execution into
the map itself, but absent that, produce decisions, not deliverables.

## Where this sits in Spec Kit

Walk up from the current directory looking for a `.specify/` directory to
find the Spec Kit repo root, if any. If
`.specify/memory/constitution.md` exists, read it before charting and
before resolving any decision. Every recommendation you make should
respect its principles; flag any candidate answer that would conflict with
one, naming the principle. If there is no `.specify/` directory, proceed
anyway; the map works outside Spec Kit projects too, it just loses the
constitution and the handoff below.

The map sits **above** the feature level, and stays there:

- A question that only matters inside a single feature's spec is not a
  map decision. Leave it for `/speckit-clarify`, or `/grill-me` in gap
  mode, once that feature is being specified.
- Technical planning inside a feature belongs to `/speckit-plan`, and
  task slicing to `/speckit-tasks`. The map never does either.
- When resolved decisions have shrunk a piece of work to feature size,
  that piece exits the map: the user runs `/grill-me` on it, then
  `/speckit-specify`. Frame that handoff in what/why terms only: specs
  are technology-agnostic, so technology choices the map has resolved
  (languages, frameworks, services, data stores) must not travel into
  it. They keep living in their decision files; note in the handoff
  that they exist and belong to `/speckit-plan`, which should read
  those resolutions when the feature reaches planning. Record the
  resulting `specs/<NNN>-<name>/` directory in the relevant
  resolution, so the map stays traceable to the features it spawned.

## Refer by name

Every map and decision is a file, so it has a **name**: its title. In
everything the human reads (narration, the map's Decisions so far), refer
to it by that name, never by a bare slug or path. A wall of
`auth-model.md, tenant-shape.md` is illegible; names read at a glance. The
path does not vanish; a name wraps its relative link. But the path rides
inside the name, never stands in for it.

## The map

The map is a directory at the top level of the repo:

```
wayfinder/<map-slug>/
  map.md           # the whole effort at low resolution
  decisions/
    <slug>.md      # one file per decision
```

`wayfinder/` is a sibling of `specs/`. It is deliberately not inside
`.specify/`, which Spec Kit owns and rewrites on upgrade, and not inside
`specs/`, whose entries Spec Kit's scripts expect to be `NNN-name`
feature directories. One directory per map keeps parallel efforts from
tangling. Everything is ordinary version-controlled Markdown: charting
sessions and resolutions are commits, reviewable like any other change.

The map is an **index**, not a store. It lists the decisions made and
points at the files that hold their detail; a decision lives in exactly
one place, its file, so the map never restates it, only gists it and
links.

### The map body

`map.md` is loaded once per session. Open decisions are **not** listed
here; they are the files in `decisions/` whose `status` is `open`, found
by reading frontmatter.

```markdown
# <map title>

## Destination

<what reaching the end of this map looks like: the carved-up initiative,
decision, or change this effort is finding its way to. One or two lines;
every session orients to it before choosing a decision.>

## Notes

<domain; skills every session should consult; standing preferences for
this effort>

## Decisions so far

<!-- the index: one line per resolved decision; zoom the link for the
detail the decision file holds -->

- [<decision title>](decisions/<slug>.md): <one-line gist of the answer>

## Not yet specified

<!-- see "Fog of war": in-scope fog you can't pin to a decision yet;
graduates as the frontier advances -->

## Out of scope

<!-- see "Out of scope": work ruled beyond the destination; never
graduates -->
```

### Decisions

Each decision is one file in `decisions/`, named by a kebab-case slug of
its title, its question sized to one agent session. Frontmatter carries
the state:

```markdown
---
title: <the decision's name>
status: open        # or: resolved, out-of-scope
type: grilling      # or: research, prototype, task
blocked-by: []      # slugs of decisions this one waits on
---

## Question

<the decision or investigation this file resolves>
```

The body above the resolution is **immutable once charted**: the question
never changes, so its history stays legible. Resolving a decision means
appending a `## Resolution` section and flipping `status` to `resolved`;
nothing else in the file moves. Assets created while resolving are linked
from the resolution, not pasted in: put throwaway code on a branch and
durable notes in a file next to the decision.

A decision is **unblocked** when no slug in its `blocked-by` list is
still `open`; the **frontier** is the open, unblocked decisions, the edge
of the known. Compute it from frontmatter, and report it when the user
asks where the map stands.

There is no claiming step: in a version-controlled map, the working copy
is the claim. The user may run unblocked decisions in parallel, each
session on its own branch; expect merges, and note that concurrent
appends to Decisions so far merge cleanly as separate list items.

## Decision types

Every decision is either **HITL**, human in the loop, worked with a human
who speaks for themselves, or **AFK**, driven by the agent alone. A HITL
decision only resolves through that live exchange; never stand in for the
human's side of it. A grilling session that answers its own questions has
broken this.

- **Grilling** (HITL): conversation. The default case. Call the Skill tool
  with "sks:grilling", scoped to this one decision.
- **Research** (AFK): reading documentation, third-party APIs, or local
  resources to surface a fact a decision waits on. Resolve it with a
  sub-agent (a codebase-exploration sub-agent for facts inside the repo,
  a general-purpose sub-agent with web access for those outside it) and
  record the findings as the resolution. Use when knowledge outside the
  conversation is required.
- **Prototype** (HITL): raise the fidelity of the discussion by making a
  cheap, rough, concrete artifact to react to: an outline, a rough take,
  a stub of UI or logic. Link the prototype from the resolution. Use
  when "how should it look" or "how should it behave" is the key
  question.
- **Task** (HITL or AFK): manual work that must happen before a decision
  can be made; nothing to decide, prototype, or research, but the
  discussion is blocked until it is done. Signing up for a service so
  its API can be judged, provisioning access, moving data so its shape
  can be seen. This is the one type that does rather than decides, and
  it earns its place by unblocking a decision, not by delivering the
  destination. Drive it alone where you can (AFK); otherwise hand the
  human a precise checklist (HITL). The resolution records what was done
  and any resulting facts (credential locations, new URLs, row counts)
  later decisions depend on.

## Fog of war

The map is *deliberately* incomplete: don't chart what you can't yet see.
Beyond the live decisions lies the **fog of war**, the dim view of
decisions and investigations you can tell are coming but can't yet pin
down, because they hang on questions still open. Resolving a decision
clears the fog ahead of it, graduating whatever is now specifiable into
fresh decision files, one at a time, until the way to the destination is
clear and no open decisions remain.

The map's **Not yet specified** section is where that dim view is written
down: the suspected question, the area to revisit later. It is the
undiscovered frontier *toward* the destination; everything here is in
scope, just not sharp enough to file. Write as loosely or as fully as the
view allows; it doubles as a signpost for collaborators reading where the
effort is headed.

**Fog or decision?** The test is whether you can state the question
precisely now, *not* whether you can answer it now.

- **Decision when** the question is already sharp, even if it is blocked
  and you can't act on it yet.
- **Not yet specified when** you can't yet phrase it that sharply. Don't
  pre-slice the fog into decision-sized pieces: it is coarser than a
  decision, and one patch may graduate into several decisions, or none,
  once the frontier reaches it.

**Not yet specified** excludes what is already decided (Decisions so
far), what is already a live decision file, and what is out of scope (the
next section).

## Out of scope

Fog only ever gathers *toward* the destination. The destination fixes the
scope, so work beyond it is **out of scope**: it isn't fog, and it
doesn't belong in **Not yet specified**. It gets its own **Out of scope**
section on the map, for work consciously ruled out of *this* effort.
Scope, not sharpness, lands it here.

Out-of-scope work never graduates; the frontier stops at the destination.
It returns only if the destination is redrawn, and then as a fresh
effort, not a resumption.

Ruling something out of scope is a scoping act, not a step on the route.
When a decision that already exists turns out to sit past the
destination, mis-scoped in while charting or exposed by a resolution,
flip its `status` to `out-of-scope` (unambiguously off the frontier) and
leave one line in the **Out of scope** section: the gist plus why it is
out, linking the file. It stays out of **Decisions so far**, which
records the route actually walked; a scope boundary isn't a step on it.

## Invocation

Two modes. Either way, **never resolve more than one decision per
session**, with the exception of research decisions.

### Chart the map

The user invokes with a loose idea.

1. **Name the destination.** Call the Skill tool with "sks:grilling" to
   pin down what this map is finding its way to: a carved-up initiative,
   a locked decision, or an in-place change. The destination fixes the
   scope, so it is settled first.
2. **Map the frontier.** Grill again, **breadth-first** this time: fan
   out across the whole space rather than deep on any one thread,
   surfacing the open decisions and the first steps takeable now. **If
   this surfaces no fog**, the way to the destination already clear and
   the whole journey feature-sized, you don't need a map. Stop and point
   the user at `/grill-me` directly.
3. **Create the map**: `wayfinder/<map-slug>/map.md` with Destination
   and Notes filled in, Decisions so far empty, the fog sketched into
   **Not yet specified**.
4. **Create the decisions you can specify now** as files in
   `decisions/`, wiring `blocked-by` as you write them (slugs are known
   up front, so no second pass is needed). Wiring sorts them into the
   frontier and the blocked; everything you can't yet specify stays in
   the fog.
5. **Fire the research sub-agents.** Research decisions are AFK: spin up
   a sub-agent for each one created, and as each reports, append its
   findings as that decision's resolution.
6. Stop; charting is one session's work. Beyond those research
   sub-agents, it hand-resolves nothing.

### Work through the map

The user invokes with a map (name or path); a specific decision is
optional. Without one, you pick the next decision, not the user. If the
named map directory doesn't exist, say so and offer to chart it instead.

1. Load `map.md`: the low-resolution view, not every decision body.
2. Choose the decision. If the user named one, use it. Otherwise take
   the frontier decision whose resolution unblocks the most. **Confirm
   the choice by name** before starting.
3. Resolve it, zooming as needed: read the full body of any related or
   resolved decision on demand; call the Skill tool for whichever skills
   the map's **Notes** section names. If in doubt, call it with
   "sks:grilling".
4. Record the resolution: append the `## Resolution` section, flip
   `status` to `resolved`, and add one gist line to the map's Decisions
   so far.
5. Tend the map. Add newly surfaced decisions; graduate any fog the
   answer has made specifiable, clearing each graduated patch from **Not
   yet specified** so it lives only as its new decision file. If the
   answer reveals a decision, this one or another, sits beyond the
   destination, rule it out of scope rather than resolving it on the
   route. If it invalidates other parts of the map, update or delete
   those files. If it has shrunk a piece of work to feature size, hand
   off per [Where this sits in Spec Kit](#where-this-sits-in-spec-kit).

---

Adapted from Matt Pocock's
[`wayfinder`](https://github.com/mattpocock/skills) skill, reworked from
issue-tracker tickets to a version-controlled `wayfinder/` directory and
grounded in Spec Kit's constitution and feature pipeline.
