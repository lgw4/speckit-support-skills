---
name: improve-codebase-architecture
description: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.
disable-model-invocation: true
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities**: refactors that turn shallow modules into deep ones. The aim is testability and
AI-navigability.

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

## Process

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

### 2. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in
the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or
`%TEMP%` on Windows), and write to
`<tmpdir>/architecture-review-<timestamp>.html` so each run gets a fresh file.
Open it for the user: `open <path>` on macOS, `xdg-open <path>` on Linux,
`start <path>` on Windows. Tell them the absolute path.

The report uses **Tailwind via CDN** for layout and styling, and **Mermaid via
CDN** for diagrams where a graph/flow/sequence reliably communicates the
structure. Mix Mermaid with hand-crafted CSS/SVG visuals; use Mermaid when
relationships are graph-shaped (call graphs, dependencies, sequences), and
hand-built divs/SVG when you want something more editorial (mass diagrams,
cross-sections, collapse animations). Each candidate gets a **before/after
visualization**. Be visual.

For each candidate, render a card with:

- **Files:** which files/modules are involved
- **Problem:** why the current architecture is causing friction
- **Solution:** plain English description of what would change
- **Benefits:** explained in terms of locality and leverage, and how tests
  would improve
- **Before / After diagram:** side-by-side, custom-drawn, illustrating the
  shallowness and the deepening
- **Recommendation strength:** one of `Strong`, `Worth exploring`,
  `Speculative`, rendered as a badge

End the report with a **Top recommendation** section: which candidate you'd
tackle first and why.

See [HTML-REPORT.md](HTML-REPORT.md) for the full HTML scaffold, diagram
patterns, and styling guidance.

**Constitution conflicts**: if a candidate contradicts a principle in
`.specify/memory/constitution.md`, only surface it when the friction is real
enough to warrant revisiting the principle. Mark it clearly in the card (a
warning callout: *"contradicts Constitution Principle III, but worth
reopening because..."*). Don't list every theoretical refactor the
constitution forbids.

Do NOT propose interfaces yet. After the file is written, ask the user: "Which
of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, run the `/grilling` skill to walk the
decision tree with them: constraints, dependencies, the shape of the deepened
module, what sits behind the seam, what tests survive.

### 4. Exit, read-only

This skill never edits code and never touches the `.specify/` or `specs/`
tree. Once the grilling loop reaches a shared understanding, offer next steps
rather than acting on them:

- Feed the chosen refactor into `/speckit-specify` as a new feature, using the
  grilling session's decisions as the feature description.
- If the conversation surfaced a principle worth recording, for instance
  because a candidate was rejected specifically for contradicting one, or
  because a gap in the constitution caused real ambiguity, suggest
  `/speckit-constitution` to record it, rather than doing it yourself.

---

Adapted from Matt Pocock's
[`improve-codebase-architecture`](https://github.com/mattpocock/skills) and
[`codebase-design`](https://github.com/mattpocock/skills) skills.
