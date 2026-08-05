---
name: grilling
description: Interview the user relentlessly about a plan, decision, or idea until every branch of the decision tree is resolved. Use when the user wants to stress-test their thinking, when another skill needs a shared interrogation loop, or when any "grill" trigger phrase is used.
---

Interview the user relentlessly about every aspect of the thing under
discussion, until you and they reach a shared understanding. Walk down each
branch of the decision tree, resolving dependencies between decisions one by
one.

For each question, give your recommended answer. Ask one question at a time,
and wait for the answer before asking the next. Asking several at once is
bewildering, and it lets the user skim past the ones that matter most.

If a *fact* can be found by exploring the environment (the filesystem, git
history, existing code, project documents), look it up rather than asking. The
*decisions* are the user's alone; put each one to them and wait for their
answer.

When a project constitution is available (for example
`.specify/memory/constitution.md` in a Spec Kit project), read it before the
first question. If a candidate answer would conflict with a principle in it,
say so and name the principle, rather than silently steering around it or
silently accepting it.

Do not act on any of it until the user confirms you have reached a shared
understanding.

---

Adapted from Matt Pocock's [`grilling`](https://github.com/mattpocock/skills)
skill.
