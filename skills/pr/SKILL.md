---
name: pr
description: "Shape a pull request body for a Spec Kit feature: a Summary visual, Evidence tied to the spec's acceptance scenarios and success criteria, and a Merge Danger call. Use when writing or rewriting a PR body."
---

# PR

## Ground it in the feature

Before writing, find the spec the branch implements. Walk up from the
current directory for a `.specify/` directory. If found, resolve the
feature directory from `$SPECIFY_FEATURE_DIRECTORY`, or
`.specify/feature.json`, or by matching the branch name against
`specs/<NNN>-<short-name>/`, then read its `spec.md` and `plan.md`, plus
`data-model.md` and `contracts/` if present. Read
`.specify/memory/constitution.md` too.

If no feature resolves, write the body from the diff alone and leave the
**Spec** line out.

## Template

Use this template for the PR body:

```markdown
## Summary

**Spec:** `specs/<NNN>-<short-name>/`

<diagram, diff-sketch, or tree>

## Evidence

- **Before:** <screenshot/output/failing test run>
  **After:** <screenshot/output/passing test run>

## Merge Danger

**Door:** <one-way or two-way>

<optional: description>

**Blast Radius:** <one-word description>

<optional: potential ramifications of merge>
```

## Sections

Skip all preambles and keep prose brief. Use the domain language of the
feature's `spec.md`: the names in its Key Entities and requirements, not
the class names in the diff.

### Summary

Pick the smallest view that makes the key point clear.

- Show logic or an algorithm as pseudocode:

```text
on(save)
  if content is unchanged
    return cached result
  write new content
  return fresh result
```

- Show runtime control flow as a call tree:

```text
submitForm
  createSession
    persistPrompt
    launchAgent
  navigateToSession
```

- Show UI structure as a component tree, including state and module
  boundaries that matter:

```text
<SessionPage> (apps/example/src/routes/session.tsx)
  useSessionEvents()
  <SessionToolbar>
    <RunSkillButton> (packages/ui)
```

- Show file responsibility or a broad refactor as a shallow file tree:

```text
src/
├── commands/       # parses user actions
├── sessions/       # owns session state
└── transport/      # sends API requests
```

- Show component interaction, control flow, or data flow with Mermaid:

```mermaid
sequenceDiagram
    participant User
    participant UI
    participant Daemon
    User->>UI: choose command
    UI->>Daemon: send expanded prompt
    Daemon-->>UI: stream result
```

- Use `diff` when the point is what changes and the surrounding shape
  already exists. Match the diff shape to the topic.

For a component change:

```diff
 <SessionPage>
   useSessionEvents()
   <SessionToolbar>
+    <RunSkillButton />
   <SessionTimeline>
+    <SkillResultCard />
```

For a file-layout change:

```diff
 src/
 ├── commands/
+│   └── show-me.ts       # expands the slash command
 ├── sessions/
-└── transport.ts
+└── transport/
+    ├── client.ts
+    └── stream.ts
```

For a call-tree or call-stack change:

```diff
 submitForm
   createSession
     persistPrompt
+    expandSkillMention
     launchAgent
-  navigateToSession
+  navigateToSession
+    subscribeToEvents
```

For a state or control-flow change:

```diff
 on(save)
-  write content
+  if content is unchanged
+    return cached result
+  write new content
+  invalidate cache
```

- Show the whole block when most of it is new, when omitted context would
  hide ownership or order, or when the user needs a copyable target shape:

```ts
function expandSkill(command: string): string {
  const skillName = command.slice(1);
  return `use the ${skillName} skill`;
}
```

#### Guidance

Place each visual next to the short text it supports. Keep only the calls,
files, props, states, and boundaries needed to answer the user's current
question or the options to resolve the current discussion point.

You may use one of these, you may use several, it is unlikely you will use
all of them. Use your judgment and don't overwhelm the user.

### Evidence

Concrete evidence that the change works. Show a before and after.

Screenshots are S-tier, when the environment is set up for it and the
change is visual.

Execution-based evidence is A-tier. Test results, console output. Show the
exact test that now fails and passes, using pseudocode.

Anchor each before/after to what `spec.md` promised: name the acceptance
scenario (US1/AC2) or success criterion (SC-002) it demonstrates. A
success criterion with no evidence in the body is worth saying so.

### Merge Danger

Describe whether it's a one-way or two-way door. You can walk back through
two-way doors, but not one-way doors. A PR that is cheap to roll back is
lower risk. Changes that involve destructive actions or hard-to-reverse
decisions are one-way doors.

The blast radius is the potential impact or scope of the changes introduced
by this PR. Consider all possibilities. Examples are layout shift,
breakages for consumers, mobile responsiveness, etc.

Read the feature's artifacts for the doors the diff hides: a change to
`data-model.md` that migrates stored data is usually one-way, and a change
under `contracts/` widens the blast radius to every consumer of that
interface. If the constitution names changes it treats as one-way, use its
call.

---

Adapted from Matt Pocock's [`pr`](https://github.com/mattpocock/skills)
skill; the Summary visuals come from Dex Horthy's `show-me`, see
[CREDITS.md](CREDITS.md).
