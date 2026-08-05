# CLAUDE.md

Claude Code plugin of Agent Skills that bracket GitHub Spec Kit's
spec-driven pipeline. Markdown only: no build, no tests, no dependencies.
Every change is a prose change to instructions a model will execute.

[CONTRIBUTING.md](CONTRIBUTING.md) is the authoritative guide. The notes
below are the parts easiest to get wrong.

## Editing skills

- `SKILL.md` files are addressed to the agent running the skill, not to a
  human reader: second person, imperative ("Ask one question at a time").
  Match that voice.
- Read the whole `SKILL.md` before editing one. A sentence added in
  isolation can contradict one three sections down.
- Skills must stay grounded in Spec Kit, reading
  `.specify/memory/constitution.md` and `specs/<NNN>-<name>/` as their
  source of truth. Making a skill generic again undoes the point of the
  port. Don't reimplement what `/speckit-*` commands already do.

## Keep in sync

A behavior change touches three places beyond the skill file:

1. the frontmatter `description` (the only text Claude matches on when
   deciding whether to invoke),
2. the skill catalog table in [README.md](README.md), in pipeline order,
3. `version` in `.claude-plugin/plugin.json` (patch for wording, minor for
   new skills or changed behavior).

## Style

Wrap prose at ~76 columns; leave frontmatter `description` values, table
rows, and URLs unwrapped. No em-dashes unless nothing else will do.

## Verifying

Nothing to run. Install from the working copy and drive the skill against a
real Spec Kit project:

```
/plugin marketplace add /path/to/your/speckit-support-skills
/plugin install sks@speckit-support-skills
```

The plugin is named `sks` (so skills invoke as `/sks:code-review`) while the
marketplace and the repo are still `speckit-support-skills`. That asymmetry
is deliberate; don't "fix" it.

Confirm it reads the constitution and spec tree it claims to, behaves as
its `description` promises, and degrades sensibly when those files are
missing.

## Attribution

Four of the five skills are ports of Matt Pocock's
[skills](https://github.com/mattpocock/skills). Keep the README Credit
section accurate and both copyright notices in [LICENSE](LICENSE) intact.
