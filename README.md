# Spec Kit Support Skills

A collection of [Claude Code](https://code.claude.com/docs/en/skills) **Agent
Skills** that bracket [GitHub Spec Kit](https://github.com/github/spec-kit)'s
spec-driven pipeline. Spec Kit is strong once a spec exists
(`/speckit-specify` → `/speckit-clarify` → `/speckit-plan` → `/speckit-tasks`
→ `/speckit-implement`), but it doesn't plan an initiative too big for a
single spec, doesn't interrogate a fuzzy idea before turning it into a
confident spec, doesn't review code against that spec once written, doesn't
surface architectural decay, and doesn't teach.

These six skills are ports of [Matt Pocock](https://github.com/mattpocock)'s
[skills](https://github.com/mattpocock/skills), adapted to read a Spec Kit
project's `.specify/memory/constitution.md` and `specs/<NNN>-<name>/` tree as
their source of truth instead of the generic conventions Matt's originals
look for. All credit for the underlying design goes to him; see
[Credit](#credit).

## Where these fit

```
oversized idea → /wayfinder ↘ (one feature-sized piece at a time)
          idea → /grill-me → /speckit-specify → /speckit-clarify → /speckit-plan
     → /speckit-tasks → /speckit-implement → /code-review → /speckit-converge
                                           ↘ /improve-codebase-architecture
```

`/wayfinder` charts an initiative too big for one spec as a
version-controlled map of decisions under a top-level `wayfinder/`
directory, resolved one session at a time until each remaining piece is
feature-sized and ready to enter the pipeline. `/grill-me` turns a fuzzy
idea into a decisions brief before Spec Kit's pipeline starts.
`/code-review` and `/improve-codebase-architecture` run after code exists,
reading it against the spec, constitution, and each other's architecture,
something `/speckit-analyze` doesn't do since it only compares Spec Kit's
own artifacts against each other. `/improve-codebase-architecture` persists
its findings as version-controlled Markdown under a top-level
`architecture-reviews/` directory, then works through one candidate per
session. `/teach` is orthogonal, a standalone
stateful learning workspace, useful for onboarding onto a Spec Kit
project's own domain or for anything else.

## Installation

```
/plugin marketplace add lgw4/speckit-support-skills
/plugin install sks@speckit-support-skills
```

Pull future updates with:

```
/plugin marketplace update speckit-support-skills
```

### OpenCode

The same six `SKILL.md` files load in [OpenCode](https://opencode.ai),
which tolerates the plugin's Claude Code frontmatter as-is. There is no
plugin package to install: OpenCode reads skills straight from this repo's
`skills/` directory. Add it to `skills.paths` in an `opencode.json` at any
scope (`.opencode/opencode.json` for one project, or
`~/.config/opencode/opencode.json` to follow you everywhere):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": ["/path/to/speckit-support-skills/skills"]
  }
}
```

User-invoked skills (`/grill-me`, `/wayfinder`, `/teach`,
`/improve-codebase-architecture`, `/code-review`) are slash commands via the
wrapper files in this repo's `.opencode/command/`. To get them across
projects, copy that directory into `~/.config/opencode/command/`:

```
cp -R .opencode/command ~/.config/opencode/command/
```

`grilling` is model-invoked only, as in Claude Code. OpenCode's newer
unified marketplace may eventually consume this repo's
`.claude-plugin/marketplace.json` catalog directly; until then, the
`skills.paths` route above is the supported path.

Restart OpenCode after making these changes. Note that in OpenCode the
skills remain model-discoverable even where Claude Code restricts them to
slash invocation: the wrapper commands are the intended hand, not a fence.

## Invoking the skills

Installing as a plugin namespaces every skill under the plugin's name,
`sks`: `/sks:grill-me`, `/sks:code-review`, and so on. The bare form
(`/grill-me`, `/code-review`, ...) also works as long as nothing else
installed claims the same name; if it collides with another plugin's skill
or a built-in, Claude Code falls back to needing the namespaced form. The
table below lists the bare form for brevity, prefix it with `sks:` if it
doesn't resolve on its own.

The plugin is `sks` but the marketplace it comes from is
`speckit-support-skills`, which is why the install command above reads
`sks@speckit-support-skills`.

## Skill catalog

| Skill | Invocation | What it does |
|-------|------------|---------------|
| [wayfinder](skills/wayfinder/SKILL.md) | `/wayfinder` | Charts an initiative too big for one spec as a version-controlled map of decisions (`wayfinder/<map-slug>/`), then resolves one decision per session until every remaining piece is feature-sized and ready for `/grill-me`, handing off what/why only and routing settled technology choices to `/speckit-plan` |
| [grill-me](skills/grill-me/SKILL.md) | `/grill-me` | Relentless round-by-round interview that turns a raw idea, or the gaps in an existing `spec.md`, into a technology-agnostic decisions brief ready for `/speckit-specify`, with settled technology choices split out for `/speckit-plan` |
| [grilling](skills/grilling/SKILL.md) | model-invoked | The shared round-by-round interview loop `wayfinder`, `grill-me`, and `improve-codebase-architecture` all run on |
| [code-review](skills/code-review/SKILL.md) | `/code-review` | Two-axis review of a diff: Standards (constitution + coding standards + Fowler smell baseline) and Spec (`spec.md`/`plan.md`/`tasks.md`), each run by a parallel sub-agent |
| [improve-codebase-architecture](skills/improve-codebase-architecture/SKILL.md) | `/improve-codebase-architecture` | Scans for shallow modules and deepening opportunities, persists them as version-controlled Markdown (`architecture-reviews/<date>-<slug>/`, one file per candidate) alongside a sub-agent-rendered HTML report, then grills through one candidate per session and hands it to `/speckit-specify` |
| [teach](skills/teach/SKILL.md) | `/teach` | Stateful, multi-session learning workspace: mission, resources, lessons, glossary, learning records |

The interviews run round by round: each round asks every question whose
prerequisites are already settled, so a session lands in a few rounds
instead of one long drip. If you prefer one question at a time, say so, or
add "When grilling, ask one question at a time." to your global
`CLAUDE.md` (or `AGENTS.md` in OpenCode).

## Credit

These skills are close ports of Matt Pocock's
[mattpocock/skills](https://github.com/mattpocock/skills), specifically his
`wayfinder`, `grill-me`, `grilling`, `code-review`,
`improve-codebase-architecture`, `codebase-design`, and `teach`
(`codebase-design` has no standalone skill here; it is folded into this
repo's `improve-codebase-architecture`). They are reworked to ground
themselves in Spec Kit's constitution and spec tree instead of the generic
conventions the originals look for. The decision-map model, the interview
technique, the two-axis review, the deep-module vocabulary, and the
teaching workspace model are all his; go star the original repo.

The `grill-me` framing was also informed by Luis Mori's
["The Grill-Me Skill" article](https://luismori.dev/article/grill-me-skill-agentic-development-workflow/),
which describes the same idea explicitly in the context of a spec-driven
workflow.

## License

MIT, see [LICENSE](LICENSE). Matt Pocock's original work is also MIT
licensed; his copyright notice is preserved alongside this repo's.
