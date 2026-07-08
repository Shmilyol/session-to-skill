---
name: session-to-skill
description: Use when a session is ending (closing/wrap-up intent, or all tasks complete with no new requests), when the user asks to recap what conventions/preferences were established in this session — even a plain summary request, since the skill itself decides whether to just answer or also offer to persist — when the user explicitly asks to save/persist conventions into a skill file, when a mid-session preference signal is detected, or right before suggesting /compact. Writes project conventions and workflow preferences to ~/.claude/skills/<project-name>-skill/SKILL.md.
---

# Session to Skill

Capture project conventions and workflow preferences from the current conversation and write them
directly to `~/.claude/skills/<project-name>-skill/SKILL.md`. **Never write to the memory system.**

## Trigger Conditions

### 1. End-of-session

User's message conveys a **session-closing intent** — they are wrapping up, expressing gratitude
for the session, or signaling they're done for now. Detect by semantic meaning, not exact words
(e.g. "done", "thanks", "谢谢", "收工" are illustrative, not exhaustive). Also triggers when all
tasks are complete with no new requests.

### 2. Explicit request

User explicitly asks to **persist** conventions/preferences into a skill file. Detect this by a
**persistence signal**, not by matching specific phrases: does the request name something that
outlives this turn — a file, "skill", "记住", "保存", "以后/下次自动加载" — or does it only ask
about
*this conversation's content* ("总结/回顾/讲讲/复盘/我们聊了什么") with no reference to storage or
reuse? Only the former counts as this trigger. Any phrasing lacking a persistence signal is a plain
recap, regardless of surface wording — including phrasings not listed here.

**Plain recap ≠ silent skip.** When a request lacks a persistence signal, still answer with the
plain-text recap first. Then check the recap's own content: if what you just summarized *is itself*
conventions/preferences (the material this skill extracts), ask once, after answering: "要不要我也
把这些存成项目 skill,下次自动加载?" If declined, don't ask again this session. Never write a file
just because the request was shaped like a summary — persistence requires either the persistence
signal above or this explicit follow-up confirmation.

### 3. Mid-session preference signal

Triggered by the global rule in `CLAUDE.md` (active regardless of whether this skill is invoked).
When the user confirms, invoke this skill and apply the extraction and write rules below,
recording only that preference item.

The three intent types that trigger the rule:

- **Rejection / exclusion intent** — user signals what they don't want or what to stop doing
  (e.g. "don't", "never", "不要", "别", or any semantically equivalent phrasing)
- **Constraint / narrowing intent** — user limits scope to a specific approach, tool, or behavior
  (e.g. "only", "just X is enough", "就可以", "X 就行", or similar narrowing language)
- **Directive / recommendation intent** — user says what I should always or must do
  (e.g. "you should", "always", "你应该", "你需要", "必须", or similar directive phrasing)

### 4. /compact suggestion

When suggesting `/compact`, append the reminder
from [reference/compact-reminder.md](reference/compact-reminder.md) (translate to the user's
language).

**Do NOT trigger on:** brief acknowledgments, mid-session confirmations, or messages whose intent
is to continue or ask something new — not to close the session or express a preference.

## What to Extract

Extract **only** when explicitly signaled — never infer:

**Project Conventions:** user corrected approach / confirmed non-obvious choice / made explicit tech
or naming decision

**Workflow Preferences:** user required a specific step / rejected a behavior / same pattern
appeared ≥ 2 times

**Hard filter:** Ambiguous signal → skip. One-off request → never a convention. Nothing passes →
silently skip.

## Write Rules

**Path:** `~/.claude/skills/<project-name>-skill/SKILL.md` — never `~/.claude/projects/.../memory/`

**Project name** (priority order): `git rev-parse --show-toplevel | xargs basename` → working
directory name → ask user

**Decision:**

- File doesn't exist → create full file
- File exists, stays ≤ 180 lines → Read, merge new items (skip duplicates), Write
- File would exceed 180 lines → split: SKILL.md becomes a slim index; move bullets to
  `reference/conventions.md` and `reference/workflow.md`

**After writing the skill file**, register it in the project's `CLAUDE.md` so Claude auto-invokes
it on every future session:

1. Get project root: `git rev-parse --show-toplevel`
2. Check `<project-root>/CLAUDE.md` for an existing `<project-name>-skill` invocation line
3. Already present → skip (idempotent)
4. Not present → append to `<project-root>/CLAUDE.md`:

   ```markdown

   ## Project Skill
   Invoke the `<project-name>-skill` skill at the start of every session using the Skill tool.
   ```

## Confirm Before Writing

Show a preview (in the user's language) and wait for confirmation:

```
Extracted the following, ready to [create | append to | split] `~/.claude/skills/<project-name>-skill/SKILL.md`:

**Project Conventions (new)**
- <item>

**Workflow Preferences (new)**
- <item>

Also: append skill invocation to `<project-root>/CLAUDE.md` (skipped if already present).

Shall I write the files now?
```

- Confirmed → use Write tool directly; never output raw skill content in chat
- Declined → silently skip
- Nothing extracted → skip confirmation entirely

After writing, confirm path to user (in their language).

## Generated File Format

```markdown
---
name: <project-name>-skill
description: Use when working on <project-name>. Loads project-specific conventions from past sessions.
---

## Project Conventions

- <item>

## Workflow Preferences

- <item>
```

Naming: lowercase, hyphen-separated, gerund form preferred. Never generic names (`utils`, `misc`,
`general`).
