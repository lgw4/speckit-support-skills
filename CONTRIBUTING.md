# Contributing

Thanks for your interest in improving these skills. This repo is a Claude
Code plugin containing only Markdown: there is no build, no test suite, and
no dependencies. Contributions are prose changes to skill instructions, plus
the occasional new skill.

## Ground rules

- **Stay grounded in Spec Kit.** These skills exist because they read a Spec
  Kit project's `.specify/memory/constitution.md` and `specs/<NNN>-<name>/`
  tree as their source of truth. A change that makes a skill generic again
  moves it back toward its upstream original and away from the point of this
  repo.
- **Don't duplicate Spec Kit.** If `/speckit-specify`, `/speckit-clarify`,
  `/speckit-plan`, `/speckit-tasks`, `/speckit-implement`, or
  `/speckit-analyze` already does something, a skill here should not do it
  again. These skills bracket that pipeline; they don't replace parts of it.
- **Preserve attribution.** Five of the six skills are ports of
  [Matt Pocock's skills](https://github.com/mattpocock/skills). Keep the
  Credit section of the README accurate, and keep both copyright notices in
  [LICENSE](LICENSE) intact.

## Repository layout

```
.claude-plugin/
  plugin.json        # plugin manifest: name, version, description, keywords
  marketplace.json   # marketplace entry pointing at this repo
skills/
  <skill-name>/
    SKILL.md         # required; the skill itself
    *.md             # optional supporting docs the skill links to
```

Everything a skill needs lives in its own directory. Supporting files (for
example `skills/teach/MISSION-FORMAT.md`) are referenced from `SKILL.md` by
relative link.

## Changing an existing skill

1. Read the whole `SKILL.md` before editing. These are instructions to a
   model, so a sentence added in isolation can quietly contradict one three
   sections down.
2. Keep the voice: second person, imperative, addressed to the agent
   executing the skill ("Ask the whole frontier in one round"), not to the
   human reader.
3. If you change what a skill *does*, update its frontmatter `description`
   and the skill catalog table in [README.md](README.md) to match. The
   description is what Claude Code matches against to decide whether to
   invoke the skill, so it carries real weight.
4. Test it (see below) before opening a pull request.

## Adding a new skill

Create `skills/<skill-name>/SKILL.md` with YAML frontmatter:

```yaml
---
name: skill-name
description: One or two sentences covering what the skill does and when to use it. Written for Claude, on a single line, not wrapped.
disable-model-invocation: true   # optional; user-invoked skills only
argument-hint: "What do you want to be grilled on?"   # optional
---
```

- `name` must match the directory name and be kebab-case.
- `description` is required. Include the triggering conditions ("Use when
  ..."), since this is the only text Claude sees when deciding to invoke.
- `disable-model-invocation: true` marks a skill that only a human should
  start with a slash command. `grill-me`, `improve-codebase-architecture`,
  and `teach` all use it. Omit it for skills other skills can call, like
  `grilling`.
- `argument-hint` sets the placeholder shown after the slash command.

Then add a row to the skill catalog table in the README, in pipeline order.

New skills should earn their place: if the behavior fits inside an existing
skill without bloating it, put it there instead.

## Style

- Wrap prose at roughly 76 columns. Leave frontmatter `description` values,
  Markdown table rows, and URLs unwrapped.
- No em-dashes unless nothing else will do. Hyphens, en-dashes, and slashes
  are tight: `well-known`, `2020–2025`, `and/or`.
- Use fenced code blocks for command sequences and diagrams.
- Prefer specific instructions over general encouragement. "Number each
  question and give your recommended answer" beats "be thorough."

## Testing a change

There is nothing to run, so test by installing the plugin from your working
copy and driving the skill against a real Spec Kit project:

```
/plugin marketplace add /path/to/your/speckit-support-skills
/plugin install sks@speckit-support-skills
```

Then invoke the skill you changed (`/sks:code-review`, and so on) and
confirm it:

- finds and reads the constitution and spec tree it claims to read,
- behaves the way the frontmatter `description` promises,
- degrades sensibly when those files are missing.

Note in your pull request what you exercised it against.

## Pull requests

- One logical change per pull request. A skill rewrite and a README
  reorganization are two pull requests.
- Bump `version` in `.claude-plugin/plugin.json` when skill behavior
  changes. Patch for wording and fixes, minor for new skills or changed
  behavior.
- Describe what changed in the skill's *behavior*, not just which lines
  moved, and say how you tested it.

## Issues

When reporting a problem with a skill, include the skill name, what you
asked for, what it did, and what you expected. If the skill misread a
project's constitution or spec tree, the shape of that project's
`.specify/` and `specs/` directories is the most useful thing you can
share.

## License

By contributing, you agree that your contributions are licensed under the
MIT License, as found in [LICENSE](LICENSE).
