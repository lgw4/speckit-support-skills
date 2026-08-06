---
name: grilling
description: Interview the user relentlessly about a plan, decision, or idea until every branch of the decision tree is resolved. Use when the user wants to stress-test their thinking, when another skill needs a shared interrogation loop, or when any "grill" trigger phrase is used.
---

Interview the user relentlessly about every aspect of the thing under
discussion, until you and they reach a shared understanding. Map the
discussion as a **decision tree**: every decision branches into the
decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose
prerequisites are already settled: the questions you can ask *now* without
guessing at answers you haven't heard yet. Ask the whole frontier in one
round: number each question and give your recommended answer, then wait for
the user's answers before the next round.

Format each question like so:

```
❓ **Q1** - **<question title>**: <question body, possibly several paragraphs, including any multiple choices>

➡️ <your recommended answer>
```

Each round of answers reshapes the tree: settled decisions push the
frontier outward and unblock the questions that depended on them. Recompute
the frontier and ask the next round. A question whose answer depends on
another question still open in this round belongs to a *later* round, not
this one.

Finding *facts* is your job, never the user's. When a frontier question
needs a fact from the environment (the filesystem, git history, existing
code, project documents), dispatch a sub-agent in the background to look it
up rather than asking. Don't block the round on it: a running lookup is an
unsettled prerequisite, so only the questions downstream of it wait for the
sub-agent to report; ask the rest of the frontier now. The *decisions* are
the user's alone; put each one to them and wait for their answer.

When a project constitution is available (for example
`.specify/memory/constitution.md` in a Spec Kit project), read it before
the first round. If a candidate answer would conflict with a principle in
it, say so and name the principle, rather than silently steering around it
or silently accepting it.

The session is done when the frontier is empty: every branch of the
decision tree visited, nothing left silently assumed. Do not act on any of
it until the user confirms you have reached a shared understanding.

---

Adapted from Matt Pocock's [`grilling`](https://github.com/mattpocock/skills)
skill.
