# Spec Kit Support Skills

A collection of [Claude Code](https://code.claude.com/docs/en/skills) **Agent
Skills** that bracket [GitHub Spec Kit](https://github.com/github/spec-kit)'s
spec-driven pipeline. Spec Kit is strong once a spec exists
(`/speckit-specify` → `/speckit-clarify` → `/speckit-plan` → `/speckit-tasks`
→ `/speckit-implement`), but it doesn't interrogate a fuzzy idea before
turning it into a confident spec, doesn't review code against that spec once
written, doesn't surface architectural decay, and doesn't teach.

These five skills are ports of [Matt Pocock](https://github.com/mattpocock)'s
[skills](https://github.com/mattpocock/skills), adapted to read a Spec Kit
project's `.specify/memory/constitution.md` and `specs/<NNN>-<name>/` tree as
their source of truth instead of the generic conventions Matt's originals
look for. All credit for the underlying design goes to him; see
[Credit](#credit).

## Where these fit

```
idea → /grill-me → /speckit-specify → /speckit-clarify → /speckit-plan
     → /speckit-tasks → /speckit-implement → /code-review → /speckit-converge
                                           ↘ /improve-codebase-architecture
```

`/grill-me` turns a fuzzy idea into a decisions brief before Spec Kit's
pipeline starts. `/code-review` and `/improve-codebase-architecture` run
after code exists, reading it against the spec, constitution, and each
other's architecture, something `/speckit-analyze` doesn't do since it only
compares Spec Kit's own artifacts against each other. `/teach` is
orthogonal, a standalone stateful learning workspace, useful for onboarding
onto a Spec Kit project's own domain or for anything else.

## Installation

```
/plugin marketplace add lgw4/speckit-support-skills
/plugin install speckit-support-skills@speckit-support-skills
```

Pull future updates with:

```
/plugin marketplace update speckit-support-skills
```

## Invoking the skills

Installing as a plugin namespaces every skill under the plugin's name:
`/speckit-support-skills:grill-me`, `/speckit-support-skills:code-review`,
and so on. The bare form (`/grill-me`, `/code-review`, ...) also works as
long as nothing else installed claims the same name; if it collides with
another plugin's skill or a built-in, Claude Code falls back to needing the
namespaced form. The table below lists the bare form for brevity, prefix it
with `speckit-support-skills:` if it doesn't resolve on its own.

## Skill catalog

| Skill | Invocation | What it does |
|-------|------------|---------------|
| [grill-me](skills/grill-me/SKILL.md) | `/grill-me` | Relentless one-question-at-a-time interview that turns a raw idea, or the gaps in an existing `spec.md`, into a decisions brief ready for `/speckit-specify` |
| [grilling](skills/grilling/SKILL.md) | model-invoked | The shared interview loop `grill-me` and `improve-codebase-architecture` both run on |
| [code-review](skills/code-review/SKILL.md) | `/code-review` | Two-axis review of a diff: Standards (constitution + coding standards + Fowler smell baseline) and Spec (`spec.md`/`plan.md`/`tasks.md`), each run by a parallel sub-agent |
| [improve-codebase-architecture](skills/improve-codebase-architecture/SKILL.md) | `/improve-codebase-architecture` | Scans for shallow modules and deepening opportunities, renders a visual HTML report, then grills through whichever candidate you pick |
| [teach](skills/teach/SKILL.md) | `/teach` | Stateful, multi-session learning workspace: mission, resources, lessons, glossary, learning records |

## Credit

These skills are close ports of Matt Pocock's
[mattpocock/skills](https://github.com/mattpocock/skills) (`grill-me`,
`grilling`, `code-review`, `improve-codebase-architecture`, `codebase-design`,
and `teach`), reworked to ground themselves in Spec Kit's constitution and
spec tree instead of the generic conventions the originals look for. The
interview technique, the two-axis review, the deep-module vocabulary, and the
teaching workspace model are all his; go star the original repo.

The `grill-me` framing was also informed by Luis Mori's
["The Grill-Me Skill" article](https://luismori.dev/article/grill-me-skill-agentic-development-workflow/),
which describes the same idea explicitly in the context of a spec-driven
workflow.

## License

MIT, see [LICENSE](LICENSE). Matt Pocock's original work is also MIT
licensed; his copyright notice is preserved alongside this repo's.
