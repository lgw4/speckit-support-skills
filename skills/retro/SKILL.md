---
name: retro
description: "Conduct a retrospective on a coding session in a Spec Kit project."
disable-model-invocation: true
---

The user has asked for a **retrospective**. You are suggesting
improvements to the coding agent's **environment** to improve future runs.

## Steps

1. Call the Skill tool with "sks:writing-for-agents" for the writing style
   guide.

2. Read the primary sources for the session the user specifies. This may
   mean searching through session logs on this machine. If the user doesn't
   specify a session, default to the current one. If the session worked a
   Spec Kit feature, also read that feature's `specs/<NNN>-<name>/`
   artifacts and `.specify/memory/constitution.md`, so you can tell an
   environment gap from a gap in the spec.

3. Look for candidates for improvement in these categories.

- **Navigation**: how easy was it for the agent to find the right files?
  Are there hidden dependencies between files? Would a **navigation
  pointer** make it easier? _Use when_ the session took a long time to find
  a piece of information.
- **Automated checks**: are there automated checks that could catch errors
  the agent made? Linting, typing, tests, filesystem linters? Read the
  repo's own check command first (its `package.json`/build-tool
  `lint`/`check` scripts, its CI workflow), so a check that already exists
  but sits unwired or silently broken is the finding, not a reinvention. A
  repo with no **guardrail** (no pre-commit hook and no CI job running its
  lint/typecheck/test command) is itself a finding: an un-linted repo is a
  standing missed opportunity, not a neutral default. _Use when_ the agent
  made a mistake an automated check could have caught, or the repo has no
  guardrail at all.
- **Coding standards**: should the **reviewer agent** be given a new rule
  to enforce? Should an existing rule be removed or clarified? Classify the
  violation first, and route it by weight:
  - A **mechanical** one (a fixed syntactic pattern, a banned API, an
    import shape, a file-location rule) gets a deterministic check, full
    stop: a custom rule in the repo's own linter, a new pre-commit hook, or
    a new CI job, whichever the repo's language and existing guardrail make
    cheapest. Default to building the check over writing the rule.
  - A **judgment call** (cross-file consistency, "matches the surrounding
    style," anything no guardrail could ever substitute for) goes in
    `CODING_STANDARDS.md`.
  - A **principle**: a project-wide, MUST-level rule that should also bind
    planning, not just review. Propose a constitution amendment for the
    user to make with `/speckit-constitution`. Reserve this for rules that
    earn their place in every pipeline run.

  _Use when_ the reviewer agent failed to catch a mistake.
- **Spec artifacts**: did the implementing agent stall, guess, or
  backtrack because `spec.md`, `plan.md`, or `tasks.md` left something
  open? Name the pipeline step that should have caught it:
  `/speckit-clarify` for an ambiguous requirement, `/speckit-analyze` for
  artifacts that disagree with each other, `/speckit-checklist` for a
  quality gate the feature lacked. _Use when_ the session's struggle traces
  back to the spec rather than the code or the tooling.
- **Global AGENTS.md**: are there any steering instructions that should be
  moved to coding standards (or automated checks) instead? Leave the
  Spec Kit-managed block between `<!-- SPECKIT START -->` and
  `<!-- SPECKIT END -->` to Spec Kit, which regenerates it. _Use when_ the
  AGENTS.md file is particularly large, in the repo OR the user's global
  scope.
- **Tool economy**: did the agent make expensive tool calls that could be
  streamlined? Is there any custom tooling (CLIs, MCPs) that is
  particularly token-inefficient? _Use when_ the agent made an expensive
  tool call.
- **No-ops**: look for instructions in steering files that don't modify the
  agent's behavior. _Use when_ the steering files are large and unwieldy.
- **Information access**: look for opportunities to increase the agent's
  access to information. Teeing dev server logs, read-only access to
  third-party services. _Use when_ a crucial piece of information was not
  available to the agent.

4. Present these candidates to the user, in order of severity. Tie each one
   to the moment in the session that produced it.

## Reference

### Implementation vs Review

Remember that all work goes through two stages: implementation
(`/speckit-implement`) and review (`/sks:code-review`). The implementation
agent has the most **context pressure**. They are responsible for
exploration, writing code, and debugging failures.

The review agent has the least context pressure: it receives a diff, so no
exploration needed. It often does not need to write code or debug.

This means that the review agent should be responsible for imposing coding
standards, not the implementation agent.

### Files

You have access to several files in the repo:

- `CLAUDE.md`/`AGENTS.md`: these files are pushed to the context window of
  any agent working in this repo. They should be used incredibly sparingly,
  usually only for **navigation pointers** to other files.
- `.specify/memory/constitution.md`: read by every `/speckit-*` command and
  by the Standards axis of `/sks:code-review`, where its principles
  override every other standard. Change it only through
  `/speckit-constitution`.
- `CODING_STANDARDS.md`: this file is read during review, not
  implementation; `/sks:code-review`'s Standards axis picks it up. Add
  **navigation pointers** to docs folders if the standards file gets more
  than 1,000 lines long.
- Docs: use docs as reference files, pointed to by other files. Look for
  existing docs before writing new ones.
- Skills: use skills for docs (since their description goes into the
  agent's context window), or for user-invoked commands. Follow the advice
  in the `writing-for-agents` skill.

---

Adapted from Matt Pocock's [`retro`](https://github.com/mattpocock/skills)
skill.
